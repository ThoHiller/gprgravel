function [domain,params] = prepareDomain(domain,grains,params,varargin)
%prepareDomain generates the domain data based on the user entries
%
% Syntax:
%       [domain,params] = prepareDomain(domain,grains,params)
%
% Inputs:
%       domain
%       grains
%       params
%
% Outputs:
%       domain
%       params
%
% Example:
%       [domain,params] = prepareDomain(domain,grains,params)
%
% Other m-files required:
%       getSubBodyCoords
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also GPRGRAVEL
% Author(s): see AUTHORS.md
% License: GNU GPLv3 (at end)

%------------- BEGIN CODE --------------

% check if called from GUI
isgui = false;
if nargin > 3
    src = varargin{1};
    % get GUI handle
    fig = ancestor(src,'figure','toplevel');
    isgui = true;
    % get GUI data
    gui = getappdata(fig,'gui');
end

str = 'INIT - prepareDomain: init voxel volume';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

% original volume of the main container [m^3]
domain.Vbox = domain.xm*domain.ym*domain.zm;
% matrix volume [m^3]
domain.Vmatrix = (1 - domain.porosity)*domain.Vbox;

% number of inner voxels in each direction
domain.nx0 = round(domain.xm/domain.dx) + 1;
domain.ny0 = round(domain.ym/domain.dx) + 1;
domain.nz0 = round(domain.zm/domain.dx) + 1;

% if there is an inner margin mask increase the number of inner voxels
if params.applyMarginMask
    domain.nx0 = domain.nx0 + 2;
    domain.ny0 = domain.ny0 + 2;
    domain.nz0 = domain.nz0 + 1;
end
% the voxel volume without the margin
domain.VOL0 = domain.nx0*domain.ny0*domain.nz0;

% margin extends the domain on all sides depending on the largest grain
% radius
domain.marg = 2*ceil((grains.rmax+domain.dx)/domain.dx);
marg = domain.marg;

% how many elements in each spatial direction (incl. margin on all sides)
domain.nx = domain.nx0 + 2*domain.marg;
domain.ny = domain.ny0 + 2*domain.marg;
domain.nz = domain.nz0 + 2*domain.marg;

% complete voxel volume
VOL2 = domain.nx*domain.ny*domain.nz;

Vol0b = (domain.nx0+marg/2)*(domain.ny0+marg/2)*(domain.nz0+marg/2);
% margin volume (NOTE: why is it not VOL2-VOL0?)
VOLmarg = VOL2-Vol0b;

% set up matrices for storing the final positions of the grains
% logical matrix to mark occupied voxels
M = false(domain.nx,domain.ny,domain.nz);

% logical matrix to mark valid grain center positions
M_valCtr = true(domain.nx,domain.ny,domain.nz);

% Label matrix for each radius bin
L2 = zeros(domain.nx,domain.ny,domain.nz);

% create indices for margin to check voxel positions
tmpInd = reshape(1:numel(L2),size(L2));
kInner = tmpInd(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
kInner = kInner(:);
kMargin = setdiff(tmpInd,kInner);
% at these voxel no grain centers can be set
M_valCtr(kMargin) = false;

clear tmpInd kMarginA kMarginB

%% TARGETS
str = 'INIT - prepareDomain: apply target(s)';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

% take care of target
if params.useTarget
    % prepare calculation of voxels inside target
    tmpdata.domain = domain;
    tmpdata.params = params;
    [tmpdata] = setTargetPosition(tmpdata,'calc');
    params = tmpdata.params;

    % get target voxel volume
    target = params.target;
    target_vol = sum(target(:)>1);
    params.VOLtarget = target_vol;

    % get occupied target voxel indices
    index = sub2ind(size(M), params.targetIDX(:,1)+marg,...
        params.targetIDX(:,2)+marg, params.targetIDX(:,3)+marg);
    % mark target voxels as occupied in M
    M(index) = true;
    % mark target voxel as invalid for new grain centers
    M_valCtr(index) = false;
    
    % mark target voxels in Lr
    L2(index) = params.ID_MASKED.Target.Lr;
else
    params.VOLtarget = 0;

    xstart = round(size(M,1)/2);
    ystart = round(size(M,2)/2);
    zstart = round(size(M,3)/2);
    tdims = zeros(1,3);
end

%% MASKS
str = 'INIT - prepareDomain: apply mask';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

% mask regions if defined
if params.use_mask
    % check for any dip value
    if sum(params.maskdipx+params.maskdipy) > 0
        % create a standard mask
        mask = struct('arrTiltDegXY',[params.maskdipx params.maskdipy],...
            'arrBaseXYZ',[0 0 0],...
            'zBaseMinTop',domain.marg*domain.dx);
        % several masks may be applied subsequently
        % here we only add the one for a tilted surface
    else
        % create a dummy mask
        mask = struct('arrTiltDegXY',[0 0],...
            'arrBaseXYZ',[0 0 0],...
            'zBaseMinTop',domain.marg*domain.dx);
    end
    params.masks = {mask};
end

if params.use_mask
    cellMasks = params.masks;
    nMask = numel(cellMasks);

    for iMask = 1:nMask
        curMask = params.masks{iMask};
        
        if isfield(curMask,'arrMinMaxXYZ')
            arrMinMaxXYZ = curMask.arrMinMaxXYZ;

            kMinMax = round(arrMinMaxXYZ/domain.dx);

            kX = domain.marg+1+(kMinMax(1,1):kMinMax(1,2));
            kY = domain.marg+1+(kMinMax(2,1):kMinMax(2,2));
            kZ = domain.marg+1+(kMinMax(3,1):kMinMax(3,2));

            if params.applyMarginMask
                kX = kX+1;
                kY = kY+1;
            end

            M_valCtr(kX,kY,kZ) = false;
        end

        if isfield(curMask,'arrTiltDegXY')
            
           [index] = getMaskVoxel(curMask,[domain.nx domain.ny domain.nz],domain,params,'prep');

            % mark masked region as invalid for new grain centers
            M_valCtr(index) = false;

            % mark masked region as air in Lr
            L2(index) = params.ID_MASKED.Air.Lr;
            clear index;
        end
    end
end

%% MARGIN MASK
str = 'INIT - prepareDomain: apply margin mask';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

if params.applyMarginMask
    % build x- MarginMask
    kInnerX = domain.marg+(1:domain.nx0);
    kInnerY = domain.marg+(1:domain.ny0);
    kInnerZ = domain.marg+(1:domain.nz0);

    % 26.10.22: mask is part of margin
    M([domain.marg,domain.nx-domain.marg+1],kInnerY,kInnerZ) = true;
    M(kInnerX,[domain.marg,domain.ny-domain.marg+1],kInnerZ) = true;
    M(kInnerX,kInnerY,domain.nz-domain.marg+1) = true;
end

% until 26.10.22
% now the volume in terms of voxel and accounting for the margin
% domain.VOL = sum(~M(:));
% sync kInner with valid grain center positions
% (take care of masked regions
% kInner = kInner(M_valCtr(kInner));
% innerM = M(kInner);
% domain.VOL0 = sum(~innerM(:));
% domain.VOLmask = sum(innerM(:));

% 26.10.22: interpret only voxels as box volume at
% valid grain center positions at start
domain.VOL0 = sum(M_valCtr(:));
domain.kEvalPoro = find(M_valCtr(:));

% VOL0matrix is later needed to find the total number of grains to create
% this particular matrix volume
% domain.VOLmatrix  = round((1-domain.porosity)*domain.VOL);
domain.VOL0matrix = round((1-domain.porosity)*domain.VOL0);

% all matrices with margin
domain.final{1}.M = M;
domain.final{1}.M_valCtr = M_valCtr;
domain.final{1}.Lr = L2;

domain.porosity_final = 1-sum(domain.final{1}.M(domain.kEvalPoro))/domain.VOL0;

% allocation for grain center coordinates and radius
% radius is always in real units [m]
% coordinates in real dimensions [m]

% maximum numbers of grains to place inside the container
nmax = 50000;
nPreOcc = sum(M(:));

% xyzr = -1*ones(max([nmax nPreOcc]),4);
% coordinates in lattice units
xyzr0 = -1*ones(max([nmax nPreOcc]),4);

str = 'INIT - prepareDomain: coord list of pre-allocated voxels:';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

n = 1;
if nPreOcc > 0
    % detect margin
    szM = size(M);
    Mmarg = zeros(size(M));

    dCalc = diff(M,1,1);
    dAppl = cat(1,zeros([1,szM(2),szM(3)]),dCalc);
    Mmarg(dAppl > 0) = 1;
    dAppl = cat(1,dCalc,zeros([1,szM(2),szM(3)]));
    Mmarg(dAppl < 0) = 1;


    dCalc = diff(M,1,2);
    dAppl = cat(2,zeros([szM(1),1,szM(3)]),dCalc);
    Mmarg(dAppl > 0) = 1;
    dAppl = cat(2,dCalc,zeros([szM(1),1,szM(3)]));
    Mmarg(dAppl < 0) = 1;

    dCalc = diff(M,1,3);
    dAppl = cat(3,zeros([szM(1),szM(2),1]),dCalc);
    Mmarg(dAppl > 0) = 1;
    dAppl = cat(3,dCalc,zeros([szM(1),szM(2),1]));
    Mmarg(dAppl < 0) = 1;

    clear dCalc dAppl

    [xOcc,yOcc,zOcc] = ind2sub(size(M),find(Mmarg));
    clear Mmarg

    xyzOcc = cat(2,xOcc,yOcc,zOcc,zeros(size(xOcc)));
    sphere = getSubBodyCoords(grains.shape,grains.axes,domain.dx,domain.dx);
    nUpdate = round(size(xyzOcc,1)/1000);
    for nn = 1:size(xyzOcc,1)

        spnew = [xyzOcc(nn,1)*ones(length(sphere),1) ...
            xyzOcc(nn,2)*ones(length(sphere),1) ....
            xyzOcc(nn,3)*ones(length(sphere),1)];
        [ix1,~] = find(spnew(:,1)<marg | spnew(:,1)>size(M,1)-marg);
        [ix2,~] = find(spnew(:,2)<marg | spnew(:,2)>size(M,2)-marg);

        % in z-dimension, accept positions in upper margin
        % to create a surface pattern
        [ix3,~] = find(spnew(:,3)>size(M,3)-marg);
        ix = unique([ix1;ix2;ix3]);
        spnew(ix,:) = [];

        % get indices of the current sphere into M
        %         index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));

        center = xyzOcc(nn,1:3);
        % xyzr(n,1:4) = [(center-1-marg)*domain.dx, domain.dx/2];
        xyzr0(n,1:4) = [center, domain.dx/2];
        n = n + 1;

        if mod(nn,nUpdate) == 0
            str = ['INIT - prepareDomain: coord list of pre-allocated voxels: ',sprintf('%d',round(100*nn/size(xyzOcc,1))),'%'];
            if isgui
                set(gui.text_handles.Status,'String', str);
            else
                disp(str);
            end
            pause(0.001);
        end

    end
    xyzr0 = unique(xyzr0,'rows');
end

domain.xyzr0 = xyzr0;
return

%------------- END OF CODE --------------

%% License:
% GNU GPLv3
%
% GPRGRAVEL
% Copyright (C) 2023 Thomas Hiller
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

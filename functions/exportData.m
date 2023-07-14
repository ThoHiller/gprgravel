function [domain,grains,params] = exportData(domain,grains,params,varargin)
%exportData export the results
%
% Syntax:
%       [domain,grains,params] = exportData(domain,grains,params,varargin)
%
% Inputs:
%       domain
%       grains
%       params
%       varargin
%
% Outputs:
%       domain
%       grains
%       params
%
% Example:
%       [domain,grains,params] = exportData(domain,grains,params,varargin)
%
% Other m-files required:
%       none
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
else
    gui = 0;
end

%% INITIALIZE
% get the standard output path if it is not already there
if ~isfield(params,'EXPORTpath')
    params.EXPORTpath = fullfile(params.GPRGRAVELpath,'output',datestr(now,'yyyymmdd_HHMM'));
end
if ~exist(params.EXPORTpath,'dir')
    mkdir(params.EXPORTpath);
end

%% Calculate summary of the results and export the model

% get the model cubes
% Lr = domain.final{1}.Lr; -> voxels coded with grain size
% M = domain.final{1}.M; -> voxels boolean coded ean (0 = vacant, 1 = occupied)

% refresh volumetric fractions
nVox_H2O = sum(domain.final{1}.Lr(domain.kEvalPoro) == params.ID_MASKED.Water.Lr);
nVox_air = sum(domain.final{1}.Lr(domain.kEvalPoro) == params.ID_MASKED.Air.Lr);
nVox_mtx = sum(domain.final{1}.M(domain.kEvalPoro))-nVox_H2O;

final_vol.air = nVox_air/domain.VOL0;
final_vol.H2O = nVox_H2O/domain.VOL0;
final_vol.mtx = nVox_mtx/domain.VOL0;
domain.final_vol = final_vol;

%%
if params.exportMAT
    data.domain = domain;
    data.grains = grains;
    data.params = params;
    fname = 'GPRGRAVEL.mat';

    str1 = 'EXPORT - saving data to MAT file ... ';
    str2 = 'EXPORT - saving data to MAT file ... done.';
    if isgui
        set(gui.text_handles.Status,'String', str1);
    else
        disp(str1);
    end
    pause(0.01);
    save(fullfile(params.EXPORTpath,fname),'data','-v7.3');
    if isgui
        set(gui.text_handles.Status,'String', str2);
    else
        disp(str2);
    end
    pause(0.01);
end

if params.exportH5

    params.save_h5 = 'GPRGRAVEL_full.h5';

    % check if a PML should be used
    if params.exportPML
        % boundary
        marg = domain.marg;
        % extra region to be cut out
        if isfield(params,'cut')
            marg1 = params.cut;
        else
            marg1 = [0 0 0];
        end
        % container without boundaries except z+
        % uses Label matrix "Lr" for each radius bin
        % M = domain.final{1}.Lr(marg+1:end-marg,marg+1:end-marg,marg+1:end);
        kInnerX = marg+1+marg1(1):size(domain.final{1}.Lr,1)-marg-marg1(1);
        kInnerY = marg+1+marg1(2):size(domain.final{1}.Lr,2)-marg-marg1(2);
        kInnerZ = 1:size(domain.final{1}.Lr,3)-marg-marg1(2);

        if params.applyMarginMask
            kInnerX = kInnerX(2:end-1);
            kInnerY = kInnerY(2:end-1);
            kInnerZ = kInnerZ(1:end-1);
        end

        M = domain.final{1}.Lr(kInnerX,kInnerY,kInnerZ);
        [nx,ny,nz] = size(M);

        % PML boundaries
        if isfield(params,'pml_w')
            pml_w = params.pml_w;
        else
            pml_w = 10;
        end

        if length(pml_w) == 1
            pml_w = pml_w * ones(1,3);
        end
        % create container with PML boundaries (PML = 999)
        %M_pml = 999*ones(nx+2*pml_w,ny+2*pml_w,nz+pml_w);
        M_pml = 999*ones(nx+2*pml_w(1),ny+2*pml_w(2),nz+pml_w(3));

        % fill z+ margin with air
        M_pml(:,:,1:domain.marg) = 0;

        % account for masked regions in PML
        cellMasks = params.masks;
        nMask = numel(cellMasks);

        for iMask=1:nMask
            curMask = params.masks{iMask};

            if isfield(curMask,'arrTiltDegXY')
                szPML = size(M_pml);
                maxX = domain.dx*szPML(1);
                maxY = domain.dx*szPML(2);
                xPML = domain.dx*((1:szPML(2))-domain.marg+pml_w(2));
                yPML = domain.dx*((1:szPML(1))-domain.marg+pml_w(1));
                zPML = domain.dx*((1:szPML(3))-domain.marg+pml_w(3));
                [tmpY,tmpX,tmpZ] = meshgrid(xPML,yPML,zPML);
                clear xPML yPML zPML

                arrSlope = curMask.arrTiltDegXY;

                if isfield(curMask,'zBaseMinTop')
                    zBase = curMask.zBaseMinTop+abs((maxX-curMask.arrBaseXYZ(1))*tan(arrSlope(1)*pi/180) + abs(maxY-curMask.arrBaseXYZ(2))*tan(arrSlope(2)*pi/180));
                    curMask.arrBaseXYZ(3) = zBase;
                end
                arrBase = curMask.arrBaseXYZ;


                tmpSel = tmpZ <= (arrBase(3)+(arrBase(1)-tmpX)*tan(arrSlope(1)*pi/180) + (arrBase(2)-tmpY)*tan(arrSlope(2)*pi/180));
                clear tmpZ tmpX tmpZ

                % mark masked region as air
                M_pml(tmpSel) = 0;

                clear tmpSel;
            end
        end

        % copy the original container into the container with PMLs
        M_pml(pml_w(1)+1:pml_w(1)+nx,pml_w(2)+1:pml_w(2)+ny,1:nz) = M;
%         figure;imagesc(squeeze(M_pml(:,100,:)).');axis equal;

        if isfield(params,'PMLduplicate')
            if params.PMLduplicate
                % M_pml(1:pml_w,:,:) = repmat(M_pml(pml_w+1,:,:),[pml_w,1,1]);
                % M_pml(pml_w+nx+1:end,:,:) = repmat(M_pml(pml_w+nx,:,:),[pml_w,1,1]);
                % M_pml(:,1:pml_w,:) = repmat(M_pml(:,pml_w+1,:,:),[1,pml_w,1]);
                % M_pml(:,pml_w+ny+1:end,:,:) = repmat(M_pml(:,pml_w+ny,:),[1,pml_w,1]);
                % M_pml(:,:,nz+1:end)= repmat(M_pml(:,:,nz),[1,1,pml_w]);
                kSelX = pml_w(1)+(1:nx);
                kSelY = pml_w(2)+(1:ny);
                M_pml(kSelX,kSelY,nz+1:end) = repmat(M_pml(kSelX,kSelY,nz),[1,1,pml_w(3)]);
            end
        end

        % create the HDF5 output container
        % M5 = zeros(size(M_pml),'int16'); % all air
        % M5(M_pml~=0) = 1;   % mark matrix
        % M5(M_pml==99) = 2;  % mark water
        % M5(M_pml==999) = 3; % mark PML

        M5 = zeros(size(M_pml),'int16'); % all air
        M5(M_pml~=0) = 1; % mark matrix
        M5(M_pml==params.ID_MASKED.Water.Lr) = params.ID_MASKED.Water.M5; % mark water
        M5(M_pml==params.ID_MASKED.PML.Lr) = params.ID_MASKED.PML.M5; % mark PML
        M5(M_pml==params.ID_MASKED.Target.Lr) = params.ID_MASKED.Target.M5; % mark Target

        if true
            xScale = ((0:size(M5,1))-pml_w(1))*domain.dx;
            yScale = ((0:size(M5,2))-pml_w(2))*domain.dx;
            zScale = ((0:size(M5,3))-domain.marg)*domain.dx;

            hFigVerbose = figure('Name','hd5_preview');
            subplot(1,2,1);
            imagesc(xScale,zScale,squeeze(M5(:,round(size(M5,2)/2),:)).');
            set(gca,'DataAspectRatio',[1 1 1],'YDir','normal');
            xlabel('x (m)');
            ylabel('z (m)');
            grid on;

            subplot(1,2,2);
            imagesc(yScale,zScale,squeeze(M5(round(size(M5,1)/2),:,:)).');
            set(gca,'DataAspectRatio',[1 1 1],'YDir','normal');
            xlabel('y (m)');
            ylabel('z (m)');
            grid on;
            savefig(hFigVerbose,fullfile(params.EXPORTpath,'hd5_exportPreview.fig'));
            print(hFigVerbose,fullfile(params.EXPORTpath,'hd5_exportPreview.png'),'-dpng');
        end

        if isfield(params,'PMLtruncate')
            if params.PMLtruncate
                M5(:,:,nz+1:end) = [];
            end
        end

        [nx,ny,nz] = size(M5);
        infostr1{1,1} = ['0 = Air (dk = ',sprintf('%6.4f',domain.dkSpeciesAIR),')'];
        infostr1{2,1} = ['1 = Matrix (dk = ',sprintf('%6.4f',domain.dkSpeciesMTX),')'];
        infostr1{3,1} = ['2 = H2O (dk = ',sprintf('%6.4f',domain.dkSpeciesH2O),')'];

        % calculate bulk dk for PML with CRIM
        if isfield(domain,'final_vol')
            dk_pml = getDK([domain.dkSpeciesAIR domain.dkSpeciesMTX domain.dkSpeciesH2O],...
                [domain.final_vol.air domain.final_vol.mtx domain.final_vol.H2O]);
        else
            dk_pml = getDK([domain.dkSpeciesAIR domain.dkSpeciesMTX domain.dkSpeciesH2O],...
                [domain.VolSpeciesAIR domain.VolSpeciesMTX domain.VolSpeciesH2O]);
        end
        params.dk_pml = dk_pml;

        infostr1{4,1} = ['3 = PML (dk = ',sprintf('%6.4f',dk_pml),')'];
        if params.useTarget
            infostr1{5,1} = ['4 = Target (dk = ',sprintf('%6.4f',dk_pml),')'];
        end

        infostr2 = 'DIM inkl. PML';

        % 19.04.22: replaced "nx-1" etc. with "nx"
        % infostr3{1,1} = ['x ',sprintf('%3d',nx),' -> ',sprintf('%3d',nx-1),'*',...
        % sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(nx-1)),'m'];
        infostr3{1,1} = ['x ',sprintf('%3d',nx),' -> ',sprintf('%3d',nx),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(nx)),'m'];
        infostr3{2,1} = ['y ',sprintf('%3d',ny),' -> ',sprintf('%3d',ny),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(ny)),'m'];
        infostr3{3,1} = ['z ',sprintf('%3d',nz),' -> ',sprintf('%3d',nz),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(nz)),'m'];
    else
        % boundary
        marg = domain.marg;
        % container without boundaries except z+
        % uses Label matrix "Lr" for each radius bin
        M = domain.final{1}.Lr(marg+1:end-marg,marg+1:end-marg,marg+1:end);

        % create the HDF5 output container
        M5 = zeros(size(M),'int16'); % all air
        M5(M~=0) = 1; % mark matrix
        M5(M==99) = 2;  % mark water

        if params.use_target
            tdims = size(params.target);

            target = params.target;
            target(target~=0) = 3;  % mark target
            % start point of target inside M (target ids always centered)
            xstart = round(domain.marg + (domain.nx0-1-tdims(1))/2);
            ystart = round(domain.marg + (domain.ny0-1-tdims(2))/2);
            zstart = round(domain.marg + (domain.nz0-1-tdims(3))/2);
            % place target into temp. M
            M5(xstart:xstart+tdims(1)-1,ystart:ystart+tdims(2)-1,...
                zstart:zstart+tdims(3)-1) = target;
        end

        [nx,ny,nz] = size(M5);
        infostr1{1,1} = ['0 = Air (dk = ',sprintf('%4.2f',domain.dkSpeciesAIR),')'];
        infostr1{2,1} = ['1 = Matrix (dk = ',sprintf('%4.2f',domain.dkSpeciesMTX),')'];
        infostr1{3,1} = ['2 = H2O (dk = ',sprintf('%4.2f',domain.dkSpeciesH2O),')'];
        if params.use_target
            infostr1{4,1} = ['3 = Target (dk = ',sprintf('%4.2f',domain.dkSpeciesAIR),')'];
        end

        infostr2 = 'DIM';

        infostr3{1,1} = ['x ',sprintf('%3d',nx),' -> ',sprintf('%3d',nx),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(nx)),'m'];
        infostr3{2,1} = ['y ',sprintf('%3d',ny),' -> ',sprintf('%3d',ny),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(ny)),'m'];
        infostr3{3,1} = ['z ',sprintf('%3d',nz),' -> ',sprintf('%3d',nz),'*',...
            sprintf('%5.3f',domain.dx),' = ',sprintf('%4.2f',domain.dx*(nz)),'m'];
    end

    params.arrDomainOut = domain.dx*size(M5);

    if length(domain.final) == 1
        % matrices without margin
        Mp = domain.final{1}.Lr(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    else
        Mp = domain.final{2}.Lr;
    end

    % calculate porosity (only of the interior box without any margin)

    ind0 = sum(Mp(:)==0); % air
    ind99 = sum(Mp(:)==99); % water
    % porosity = (ind0+ind99)/(numel(Mp)-domain.VOLmask);
    porosity = (ind0+ind99)/(numel(domain.kEvalPoro));

    if ~isfield(params,'boolPrelimExport') || ~params.boolPrelimExport
        infostr4 = sprintf('Porosity = %4.3f%% (Aim: %4.3f%%)\n',porosity*100,domain.porosity*100);
        infostr4 = [infostr4 sprintf('H2O = %4.3f%% (Aim: %4.3f%%)\n',100*[domain.final_vol.H2O,domain.VolSpeciesH2O])];
        infostr4 = [infostr4 sprintf('Matrix = %4.3f%% (Aim: %4.3f%%)\n',100*[domain.final_vol.mtx,domain.VolSpeciesMTX])];
        infostr4 = [infostr4 sprintf('Air = %4.3f%% (Aim: %4.3f%%)\n',100*[domain.final_vol.air,domain.VolSpeciesAIR])];

        dk_AIM = getDK([domain.dkSpeciesAIR domain.dkSpeciesMTX domain.dkSpeciesH2O],...
            [domain.VolSpeciesAIR domain.VolSpeciesMTX domain.VolSpeciesH2O]);
        infostr4 = [infostr4 sprintf('\nDK = %6.4f (Aim: %6.4f)\n',params.dk_pml,dk_AIM)];
    else
        infostr4 = 'prelim Export';
    end

    % export the HDF5 file
    % flip z-direction
    M5 = flip(M5,3);
    % swap dimensions because gprMax is "weird"
    M5 = permute(M5,[3 2 1]);
    h5name = fullfile(params.EXPORTpath,params.save_h5);
    dx = domain.dx*ones(1,3);
    h5Title = 'GPRGRAVEL'; % should be changed
    h5create(h5name,'/data',size(M5),'Datatype','int16');
    h5write(h5name,'/data',int16(M5));
    h5writeatt(h5name,'/','gprMax','3.1.5');
    h5writeatt(h5name,'/','Title',h5Title);
    h5writeatt(h5name,'/','dx_dy_dz',dx);
    fprintf('Created %s\n',h5name);

    % write corresponding info file
    fileID = fopen(fullfile(params.EXPORTpath,[params.save_h5,'_INFO.txt']),'w');
    for i = 1:numel(infostr1)
        fprintf(fileID,'%s\n',infostr1{i});
    end
    fprintf(fileID,'\n');
    fprintf(fileID,'%s\n',infostr2);
    fprintf(fileID,'\n');
    for i = 1:numel(infostr3)
        fprintf(fileID,'%s\n',infostr3{i});
    end
    fprintf(fileID,'\n');
    fprintf(fileID,'%s\n',infostr4);
    fclose(fileID);

end

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

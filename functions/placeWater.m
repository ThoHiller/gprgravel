function [domain,grains,params] = placeWater(domain,grains,params,varargin)
%placeWater places all water voxels within the domain
%
% Syntax:
%       [domain,grains,params] = placeGrainsFull(domain,grains,params)
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
%       [domain,grains,params] = placeWater(domain,grains,params,src)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       getSatProfile
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

n = find(domain.xyzr0(:,end)>0,1,'last');
if isempty(n)
    n = 0;
end
n = n+1;
n_start = n;

log = domain.monitor.log;
log = [log sprintf(' \n')];
log = [log sprintf('%s: Start placing water voxels.\n',datestr(now,'dd.mm.yy HH:MM'))];
showLogInfo(log,isgui,gui);
pause(0.01);

if ~params.useSatProfile % random
    % porosity goal
    % now we only add water voxels until the final air volume is
    % reached
%     poro_final = domain.VolSpeciesAIR;

    % global grain counter
    % n_start = max(max(domain.final{1}.Ln(:)));

    % index of r bin class to set (usually the two smallest ones:
    % single voxel and 7 voxel crosses)
    idr = 1;
    rbins = grains.rbins(idr);
%     nbins = grains.nbins(idr);
    binVol = grains.binVol(idr);

    % get the matrices with the margin
    M = domain.final{1}.M;
    if ~params.boolOmitLn
        L1 = domain.final{1}.Ln;
    end
    L2 = domain.final{1}.Lr;
    M_valCtr = domain.final{1}.M_valCtr;

    % get the coordinate lists
    xyzr0 = domain.xyzr0;
    % margin width
    marg = domain.marg;

    % estimate how many voxel to set globally to reach desired porosity
    % v_to_add = numel(domain.final{2}.M(:)) - sum(domain.final{2}.M(:)) - round(numel(domain.final{2}.M(:))*poro_final);
    % v_to_add = domain.VOL0  - (sum(domain.final{2}.M(:)) - domain.VOLmask) - round(domain.VOL0*poro_final);
    % v_to_add = domain.VOL0  - (sum(domain.final{2}.M(:)) - domain.VOLmask) - round(domain.VOL0*poro_final);
    % v_to_add = domain.VOL0  - (sum(domain.final{1}.M(domain.kEvalPoro)) - round(domain.VOL0*poro_final));

%     nVoxMatrix = sum(domain.final{1}.M(domain.kEvalPoro));
    nVoxExisting = sum(domain.final{1}.Lr(domain.kEvalPoro) == params.ID_MASKED.Water.Lr);
    nVoxWaterTarget = round(domain.VOL0*domain.VolSpeciesH2O);
    nVoxWaterToAdd = nVoxWaterTarget-nVoxExisting;
    v_to_add = nVoxWaterToAdd;

    % estimate grains to add to reach desired porosity + some extra
    g_to_add = round(round(v_to_add/sum(binVol))*1.1);

    nbins = round(g_to_add/10);

    % extend point coordinate matrices accordingly
    xyzr0 = [xyzr0; zeros(g_to_add,4)];

    % make an initial index list
    log = [log sprintf('%s: Create initial index list.\n',datestr(now,'dd.mm.yy HH:MM'))];
    showLogInfo(log,isgui,gui);
    pause(0.01);
    [Mindex,~] = updateIndexList('std',M,marg/2,rbins(1),xyzr0,domain,grains);

    % sync with valid grain center positions
    Mindex = Mindex(M_valCtr(Mindex) == true);
    clear M_valCtr;
    MvN = numel(Mindex);

    % list(1).Mindex = Mindex;
    % list(1).MvN = MvN;


    % start porosity
    % poro = domain.porosity_final;

    % continuous grain counter
    n = n_start + 1;
    % statistics
    stat = [0 0 0 0];
    nVoxWaterAdded = 0;

%     PackVel = zeros(2,2);
%     PackVel(2,:) = [toc nVoxWaterAdded];
%     velPackMax = 0;

    % nDumpUpdateCurBin = max([1 round(nVoxWaterToAdd/params.dumpsPerBin)]);
    params.dump = 10000;
    % while poro > poro_final
    while nVoxWaterAdded < nVoxWaterToAdd

        % the larger grains first
        for i = numel(rbins):-1:1
            % global counter
            % current radius of grain in [m]
            r = rbins(i);
            % radius in lattice units
%             r2 = ceil(r/domain.dx);
            % current grain
            sphere = getSubBodyCoords(grains.shape,grains.axes,r,domain.dx);
            % a grain that is one lattice unit larger
            sphereB = getSubBodyCoords(grains.shape,grains.axes,2*r,domain.dx);

            tmpOnesA = ones(size(sphere,1),1);
            tmpOnesB = ones(size(sphereB,1),1);

            nb = 1;
            while nb <= nbins(i)
                % global counter
                stat(1) = stat(1) + 1;
                stat(4) = stat(4) + 1;

                % update indexList every xxx tries
                if mod(stat(1),5e5) == 0
                    log = [log sprintf('%s: Updating index list.\n',datestr(now,'dd.mm.yy HH:MM'))]; %#ok<AGROW> 
                    showLogInfo(log,isgui,gui);
                    pause(0.01);
                    [Mindex,MvN] = updateIndexList('std',M,marg/2,rbins(1),xyzr0,domain,grains);
                    %  list(1).Mindex = Mindex;
                    %  list(1).MvN = MvN;
                    if MvN<=1
                        % if this happens you should stop the calculation
                        disp('placWater: updateIndexList: no free voxels');
                    end
                end

                % draw a center point out of the list
                ind1 = randi([1 MvN]);
                [i1,i2,i3] = ind2sub(size(M),Mindex(ind1));
                center = [i1 i2 i3];

                % move the grain to the current center point
                spnew = sphere + [center(1)*tmpOnesA ...
                    center(2)*tmpOnesA ....
                    center(3)*tmpOnesA];

                % also move the larger grain to the current center point
                spnewB = sphereB + [center(1)*tmpOnesB ...
                    center(2)*tmpOnesB ....
                    center(3)*tmpOnesB];

                % get indices of the current grain into M
                index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));
                % indices of the larger grain
                indexB = sub2ind(size(M), spnewB(:,1), spnewB(:,2), spnewB(:,3));

                % sub matrices for testing
                A = M(index);
                B = M(indexB);

                % if the current water voxel touches nothing (sum(A)==0) and
                % the larger "grain" touches an already existing grain
                % (sum(B)>0) then place it
                if sum(A(:)) == 0 && sum(B(:)) > 0
                    % mark the new grain
                    M(index) = true;
                    % and label it
                    if ~params.boolOmitLn
                        L1(index) = n; % with unique counter
                    end
                    L2(index) = 99; % water marker
                    % coordinate lists
                    %  xyzr(n,1:4) = [(center-1-marg)*domain.dx, 99];
                    xyzr0(n,1:4) = [center, 99];
                    % increase counters
                    % current bin
                    nb = nb + 1;
                    % global counter
                    n = n + 1;

                    % total voxel counter
                    nVoxWaterAdded = nVoxWaterAdded + numel(index);
                    % reset the current tries per grain counter
                    stat(4) = 0;
                else
                    % count tries where grain intersected already
                    % existing grain
                    stat(3) = stat(3) + 1;
                end

                % poro = 1-sum(M(domain.kEvalPoro))/domain.VOL0;
                % pAir = 1-(nVoxMatrix + nVoxWaterAdded)/domain.VOL0;

                % output some statistics from time to time
                if mod(stat(1),params.dump) == 0
                    % how mcuh water voxels are already set
                    CurWater = nVoxWaterAdded/nVoxWaterToAdd;
                    str = ['RUN - placeWater: water voxels: ',sprintf('%d',round(100*CurWater)),'%'];
                    if isgui
                        set(gui.text_handles.Status,'String', str);
                    else
                        disp(str);
                    end
                    pause(0.001);
                    % update Monitor
                    if mod(stat(1),params.dump*10) == 0 && isgui
                        data = getappdata(fig,'data');
                        monitor.Lr = L2;
                        data.monitor = monitor;
                        setappdata(fig,'data',data);
                        plotMatrixdata(fig,'monitor');
                    end
                end

                % the current grain could not be set after 1e5 tries
                % break -> should actually never happen
                if stat(4) > 1e6
                    disp(' ');
                    disp(['current tries    : ',num2str(stat(4))]);
                    disp('stopping here because the current grain could not be placed');
                    disp('try a new random seed or adjust the corr_fac in prepareDomain.m.');
                    break;
                end
                if nVoxWaterAdded >= nVoxWaterToAdd
                    break;
                end
            end
            if stat(4) > 1e6 || nVoxWaterAdded >= nVoxWaterToAdd
                break;
            end
        end
        if stat(4) > 1e6 || nVoxWaterAdded >= nVoxWaterToAdd
            break;
        end
    end

    % finalize the output data
    % and remove possible empty fields
    Nxyz = find(xyzr0(:,4)==0,1,'first')-1;
    if ~isempty(Nxyz)
        xyzr0 = xyzr0(1:Nxyz,:);
    end

    % save the number of water voxels
    grains.n_water = sum(L2(:)==99);

    domain.xyzr0 = xyzr0;
    % all matrices with margin
    domain.final{1}.M = M;
    if ~params.boolOmitLn
        domain.final{1}.Ln = L1;
    end
    domain.final{1}.Lr = L2;
    % matrices without margin
    domain.final{2}.M = M(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    if ~params.boolOmitLn
        domain.final{2}.Ln = L1(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    end
    domain.final{2}.Lr = L2(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    % update final porosity
    domain.porosity_final = 1-sum(M(domain.kEvalPoro))/domain.VOL0;
    domain.porosity_final_water = sum(M(L2==99))/domain.VOL0;

    
    log = [log sprintf(' \n')];
    log = [log sprintf('%s: Final porosity (air): %3.2f\n',datestr(now,'dd.mm.yy HH:MM'),domain.porosity_final)];
    log = [log sprintf('%s: Water Voxels: %d\n',datestr(now,'dd.mm.yy HH:MM'),grains.n_water)];
    log = [log sprintf('%s: Final porosity (h2o): %3.2f\n',datestr(now,'dd.mm.yy HH:MM'),domain.porosity_final_water)];
    showLogInfo(log,isgui,gui);
    pause(0.01);

else % profile

    % get saturation profile
    Sat = getSatProfile(domain,params);
    params.sat_profile = Sat;

    % margin width
    marg = domain.marg;

    % get the matrices with the margin
    M = domain.final{1}.M;
    if ~params.boolOmitLn
        L1 = domain.final{1}.Ln;
    end
    L2 = domain.final{1}.Lr;
%     MvC = domain.final{1}.M_valCtr;
    % get the coordinate lists
    % xyzr = domain.xyzr;
    xyzr0 = domain.xyzr0;

    poro = domain.porosity_final;
    sliceV = round(numel(domain.final{1}.M(:,:,1))*poro);
    % estimate how many water voxel to set globally to create the
    % desired profile
    v_to_add = round(sum(sliceV*Sat));

    % estimate water "grains" to add + some extra
    g_to_add = round(v_to_add*1.1);

    % extend point coordinate matrices
    % xyzr = [xyzr; zeros(g_to_add,4)];
    xyzr0 = [xyzr0; zeros(g_to_add,4)];

    % global grain counter
    % n_start = max(max(domain.final{1}.Ln(:)));

    %  n = n_start;
    % loop over all interior slices starting at the bottom (highest saturation)
    % so we need to flip "Sat" as it is defined from top to bottom
%     Sat = fliplr(Sat);
    for zi = marg+1:size(M,3)-marg

        % get current depth slice (without margin)
        M1 = squeeze(M(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi));
        if ~params.boolOmitLn
            L1s = squeeze(L1(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi));
        end
        L2s = squeeze(L2(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi));
%         MvCs = squeeze(MvC(marg+1:size(MvC,1)-marg,marg+1:size(MvC,2)-marg,zi));

        % count the empty voxels in the current layer
        c0 = sum(M1(:)==0);

        % how many voxel to mark as water in this layer
        cw = round(c0*Sat(zi-marg));

        % if we have to place water voxels in this layer proceed
        % the second check test if there are at least some grains in the
        % slice, otherwise it won't work for a dipping surface (this needs
        % to be corrected in a future version anyway)
        if cw > 0 && sum(M1(:))>0
            stat = [0 0];

            % make a list with all empty voxels
            M2 = M1(:);
            ic = (1:numel(M2))';
            ic(M2) = [];

            % water voxels set counter
            sw = 0;
            % neighbor voxels
            neigh = zeros(8,2);
            while sw < cw
                stat(1) = stat(1) + 1;

                if mod(stat(1),c0) == 0
                    % disp('making new list')
                    % make a list with all empty voxels
                    M2 = M1(:);
                    ic = (1:numel(M2))';
                    ic(M2) = [];
                end

                % draw a random empty location
                index = randi([1 numel(ic)],1);

                % get the neighbors:
                % current center coord
                [i1,i2] = ind2sub(size(M1),ic(index));
                % neighbor coords in 2D
                neigh(1,1:2) = [i1-1 i2-1];
                neigh(2,1:2) = [i1   i2-1];
                neigh(3,1:2) = [i1+1 i2-1];
                neigh(4,1:2) = [i1-1 i2];
                neigh(5,1:2) = [i1+1 i2];
                neigh(6,1:2) = [i1-1 i2+1];
                neigh(7,1:2) = [i1   i2+1];
                neigh(8,1:2) = [i1+1 i2+1];

                % remove any neighbor point that is outside of the container
                [ix1,~] = find(neigh(:,1)<1 | neigh(:,1)>size(M1,1));
                [ix2,~] = find(neigh(:,2)<1 | neigh(:,2)>size(M1,2));
                ix = unique([ix1;ix2]);
                neigh(ix,:) = [];

                % global coordinates of the neighbors
                n_ind = sub2ind(size(M1), neigh(:,1), neigh(:,2));

                % only place it if the current position is not occupied and at
                % least one neighbor is not air (empty)
                if ~M1(ic(index)) && sum(M1(n_ind))>0
                    sw = sw + 1;

                    % mark the new grain
                    M1(ic(index)) = true;
                    % global counter
                    n = n + 1;
                    % and label it
                    if ~params.boolOmitLn
                        L1s(ic(index)) = n;
                    end
                    L2s(ic(index)) = 99;

                    % update coordinate lists
                    coord = [i1 i2 zi];
                    %  xyzr(n,1:4) = [(coord-1-marg)*domain.dx, 99];
                    xyzr0(n,1:4) = [coord, 99];
                else
                    stat(2) = stat(2) + 1;
                end
            end
        end

        str = ['RUN - placeWater: slice: ',sprintf('%d / %d',zi-marg,size(M,3)-2*marg)];
        if isgui
            set(gui.text_handles.Status,'String', str);
        else
            disp(str);
        end
        pause(0.001);
        if mod(zi,round(size(M,3)/20)) == 0 && isgui
            data = getappdata(fig,'data');
            monitor.Lr = L2;
            data.monitor = monitor;
            setappdata(fig,'data',data);
            plotMatrixdata(fig,'monitor');
        end

        % insert the current slice back into the larger block
        M(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi) = M1;
        if ~params.boolOmitLn
            L1(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi) = L1s;
        end
        L2(marg+1:size(M,1)-marg,marg+1:size(M,2)-marg,zi) = L2s;
    end

    % finalize the output data
    % and remove possible empty fields
    Nxyz = find(xyzr0(:,4)==0,1,'first')-1;
    if ~isempty(Nxyz)
        % xyzr = xyzr(1:Nxyz,:);
        xyzr0 = xyzr0(1:Nxyz,:);
    end

    % save the number of water voxels
    grains.n_water = sum(L2(:)==99);

    % finalize the output data
    % remove possible empty fields
    Nxyz = find(xyzr0(:,4)==0,1,'first')-1;
    if ~isempty(Nxyz)
        %             xyzr = xyzr(1:Nxyz,:);
        xyzr0 = xyzr0(1:Nxyz,:);
    end

    %  domain.xyzr = xyzr;
    domain.xyzr0 = xyzr0;
    % all matrices with margin
    domain.final{1}.M = M;
    if ~params.boolOmitLn
        domain.final{1}.Ln = L1;
    end
    domain.final{1}.Lr = L2;
    % matrices without margin
    domain.final{2}.M = M(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    if ~params.boolOmitLn
        domain.final{2}.Ln = L1(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    end
    domain.final{2}.Lr = L2(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg);
    % update final porosity
    domain.porosity_final = 1-sum(M(domain.kEvalPoro))/domain.VOL0;
    domain.porosity_final_water = sum(M(L2==99))/domain.VOL0;

    log = domain.monitor.log;
    log = [log sprintf(' \n')];
    log = [log sprintf('%s: Final porosity (air): %3.2f\n',datestr(now,'dd.mm.yy HH:MM'),domain.porosity_final)];
    log = [log sprintf('%s: Water Voxels: %d\n',datestr(now,'dd.mm.yy HH:MM'),grains.n_water)];
    log = [log sprintf('%s: Final porosity (h2o): %3.2f\n',datestr(now,'dd.mm.yy HH:MM'),domain.porosity_final_water)];
    showLogInfo(log,isgui,gui);
    pause(0.01);
end

log = [log sprintf('%s: Finished placing Water.\n',datestr(now,'dd.mm.yy HH:MM'))];
showLogInfo(log,isgui,gui);
str = 'RUN - FINISHED.';
if isgui
    set(gui.text_handles.Status,'String', str);
else
    disp(str);
end
pause(0.001);

% update the monitor plot one last time
if isgui
    data = getappdata(fig,'data');
    monitor.Lr = L2;
    data.monitor = monitor;
    setappdata(fig,'data',data);
    plotMatrixdata(fig,'result');
end

end

function Sat = getSatProfile(domain,params)

switch params.satProfileType

    case 'linear'
        % linear 0 -> 1
        slope = (params.satBounds(2)-params.satBounds(1))/(domain.nz0-1);
        z = 0:1:domain.nz0-1;
        Sat = slope*z+params.satBounds(1);

    case 'exponential'
        B = 20; % degree of curvature

        z = linspace(0,1,domain.nz0);
        y1 = params.satBounds(1);
        y2 = params.satBounds(2);
        % normalizes z
        r = (z - z(1)) / (z(end) - z(1));
        C = B^(z(end) - z(1));
        Sat = ((y2-y1)*C.^r + y1*C-y2)/(C-1);
end

end

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

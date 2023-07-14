function [domain,grains,params] = placeGrains(domain,grains,params,monitor,varargin)
%placeGrains places all grains within the domain
%
% Syntax:
%       [domain,grains] = placeGrains(domain,grains,params,monitor)
%
% Inputs:
%       domain
%       grains
%       params
%       monitor
%       varargin
%
% Outputs:
%       domain
%       grains
%       params
%
% Example:
%       [domain,grains] = placeGrains(domain,grains,params,monitor,src)
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
if nargin > 4
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
tic;

% init the RNG
if params.use_customRNG
    rng(params.customRNGSEED)
else
    s = rng();
    params.customRNGstate = s;
end

% reset/empty log field before caluclation
monitor.log = '';

% global statistics counters
monitor.stat = [0 0 0 0];
monitor.threshMaxTry = 2e6; % until 31.01.22
monitor.nVoxAim = flip(cumsum(flip(grains.nvoxBins)));
monitor.poro_final = domain.VolSpeciesAIR+domain.VolSpeciesH2O;
monitor.domainVOL0 = domain.VOL0;
monitor.domainVOL0matrix = domain.VOL0matrix;

% get the matrices with the margin
M = domain.final{1}.M;
M_valCtr = domain.final{1}.M_valCtr;
if ~params.boolOmitLn
    L1 = domain.final{1}.Ln;
end
L2 = domain.final{1}.Lr;
szM = size(M);

% margin width
marg = domain.marg;

% get the coordinate lists
if isfield(domain,'xyzr0')
    xyzr0 = domain.xyzr0;
    monitor.nxyzr0 = size(xyzr0,1);
end

monitor.n = find(domain.xyzr0(:,end)>0,1,'last');
if isempty(monitor.n)
    monitor.n = 0;
end
monitor.n = monitor.n+1;
n_start = monitor.n;
if size(xyzr0,1) >= monitor.n
    if xyzr0(monitor.n,4) < 0
        monitor.n = n_start+1;
        n_start = monitor.n;
    end
end

% open surface switch and threshold radius
closeSurface = params.closeSurface;
closeSurfaceR = params.closeSurfaceR;

por_RequireTouch = 0.6;
r_RequireTouch = 0;
if isfield(params,'requireTouch')
    if isfield(params.requireTouch,'r')
        r_RequireTouch = params.requireTouch.r;
        por_RequireTouch = 1e-6;
    elseif isfield(params.requireTouch,'por')
        r_RequireTouch = 0;
        por_RequireTouch = params.requireTouch.por;
    end

    if isfield(params.requireTouch,'nVox')
        monitor.nMinTouch = min([0 params.requireTouch.nVox-1]);
    else
        monitor.nMinTouch = 0;
    end
end

monitor.nSwapListBoxMax = 1e2;
monitor.threshSwapListBox = 1e3;    % swap after these number of successive failures
if isfield(params,'nSwapListBoxMax')
    monitor.nSwapListBoxMax = params.nSwapListBoxMax;
end
if isfield(params,'threshSwapListBox')
    monitor.threshSwapListBox = params.threshSwapListBox;
end


if params.useTarget
%     domain.target_MargBox = params.target_MargBox;
end
monitor.binStat = zeros(4,length(grains.rbins));
monitor.voxHist = zeros(3,length(grains.rbins));
monitor.voxHist(1,:) = grains.rbins;
monitor.voxHist(3,:) = monitor.nVoxAim;

% plotting during calculation
% plotting = init_plotting(domain,grains,monitor);
% plotting.threshMaxTry = monitor.threshMaxTry;
% plotting.HullHist = cat(1,linspace(0,1,51),zeros(1,51));
% plotting.HullLims = [0 0];

monitor.boolMustTouch = false;

% run backwards to start with the largest grains
nBin = numel(grains.rbins);
monitor.threshMaxTry = 2e6; % until 31.01.22

% update list of vacant voxels as soon as
% failed attempt counter reaches 10%
nMod_UpdateIndexList = 10*round(monitor.threshMaxTry/(100*10));

if isfield(grains,'nVox')
    monitor.nVox = grains.nVox;
else
    monitor.nVox = [0 0];
end

if isfield(grains,'iBin')
    iBinStart = grains.iBin;
else
    iBinStart = nBin;
end

monitor.arrPackVel = zeros(2,2);
monitor.arrPackVel(2,:) = [toc monitor.nVox(1)];
monitor.velPackMax = 0;

monitor.por_cur = 1-monitor.nVox(1)/domain.VOL0;

if isfield(domain,'plotting')
    plotting = domain.plotting;
end

monitor.log = [monitor.log sprintf('%s: Switching to tight placement of grains.\n',datestr(now,'dd.mm.yy HH:MM'))];
grains.nLastFreely = monitor.n-1;

% count swapping between
%    - list-based drawing(to ensure touch)
%    - box-based (to ensure free positions)
%
iSwapListBox = 0;
% define max. number of swaps

boolUpdateBoxList = false;
boolDrawFromGrainList = false;


monitor.nLstVox = 0;
monitor.iRandPos = 1;
monitor.nRandPos = 1;

cc = 0;
%% GRAIN PLACEMENT STARTS
for i = iBinStart:-1:1
    cc = cc + 1;
    % reset failure statistics
    monitor.arrFailStat = zeros(1,3);
    % current radius of sphere in [m]
    r = grains.rbins(i);
    monitor.rbin = r;

    % info output
    str1 = ['RUN - placeGrains: bin class: ',sprintf('%d / %d',cc,numel(grains.rbins))];
    monitor.log = [monitor.log newline sprintf('%s: Init radius bin #%d (r=%6.4f m)\n',datestr(now,'dd.mm.yy HH:MM'),i,r)];

    if isgui
        set(gui.text_handles.Status,'String', str1);
    else
        disp(str1);
    end
    showLogInfo(monitor.log,isgui,gui);
    pause(0.01);

    if monitor.nVoxAim(i) == 0
        % skip bin if empty
        monitor.log = [monitor.log sprintf('%s: bin is empty. Skipping.\n',datestr(now,'dd.mm.yy HH:MM'))];
        showLogInfo(monitor.log,isgui,gui);
        pause(0.01);
        break;
    end

    monitor.binStat(4,i) = max([monitor.binStat(4,i) monitor.stat(4)]);
    monitor.voxHist(2,1:i) = monitor.nVox(1);
%     plotting = update_PackingMonitor(M,L2,plotting,monitor);

    switch grains.shape
        case 'sphere'
            % the actual grain
            sphere = getSubBodyCoords(grains.shape,[1 1 1],r,domain.dx);
            % a grain that is one lattice unit larger
            sphereB = getSubBodyCoords(grains.shape,[1 1 1],r+domain.dx,domain.dx);
        case 'ellipse'
            % here one can randomize the size of the ellipses
            grains.axes = grains.axes./max(grains.axes);
            a = grains.axes(1);%0.4 + (1-0.4).*rand(1);
            b = grains.axes(2);%0.4 + (1-0.4).*rand(1);
            c = grains.axes(3);%0.4 + (1-0.4).*rand(1);
            % here one can ranomize the orientation (per radius bin)
            orient = grains.orient; % grains.orient(1) = randi([20 60]);
            sphere = getSubBodyCoords(grains.shape,[a b c],r,domain.dx,orient);
            % a grain that is one lattice unit larger
            sphereB = getSubBodyCoords(grains.shape,[a b c],r+domain.dx,domain.dx,orient);
    end
    tmpOnesA = ones(size(sphere,1),1);
    tmpOnesB = ones(size(sphereB,1),1);

    if ~boolDrawFromGrainList
        % fprintf('\n%s\ncreating index list after previous r_bin is finished\n',repmat('#',[1,70]));
%         monitor.log = [monitor.log sprintf('%s: Creating index list after previous r_bin is finished\n',datestr(now,'dd.mm.yy HH:MM'))];
%         showLogInfo(monitor.log,isgui,gui);
%         pause(0.01);

        monitor.binStat(4,i) = max([monitor.binStat(4,i) monitor.stat(4)]);
        monitor.voxHist(2,1:i) = monitor.nVox(1);
        % plotting = update_PackingMonitor(M,L2,plotting,monitor);

        boolUpdateBoxList = true;
    else
        monitor.n = find(domain.xyzr0(:,end)>0,1,'last');
    end

    % current bin counter
    nb = 1;

    % run as long as a sufficient amount of voxels are placed inside the domain (without margin)
    nDumpUpdateCurBin = max([1 round(grains.Nbins(i)/params.dumpsPerBin)]);
    while monitor.nVox(1) <= monitor.nVoxAim(i)
        % global counter
        monitor.stat(1) = monitor.stat(1) + 1;
        % current grain counter
        monitor.stat(4) = monitor.stat(4) + 1;

        if closeSurface &&  r <= closeSurfaceR
            % mark all invalid grain center positions as occupied
            % (otherwise M_valCtr won't be taken into account for packing)
            M = M | ~M_valCtr;

            monitor.log = [monitor.log sprintf('%s: Fixing soil surface, new grains must be placed below\n',datestr(now,'dd.mm.yy HH:MM'))];
            showLogInfo(monitor.log,isgui,gui);
            pause(0.01);
            if isgui
                data = getappdata(fig,'data');
                monitor.Lr = L2;
                data.monitor = monitor;
                setappdata(fig,'data',data);
                plotGSDdata(fig,'monitor');
                plotMatrixdata(fig,'monitor');
            end

            boolUpdateBoxList = true;
            closeSurface = false;
        end

        if monitor.por_cur <= por_RequireTouch || r <= r_RequireTouch
            monitor.boolMustTouch = true;
        end

        % reset current voxel increment,
        % necessary to prevent from overestimating if
        % placing fails
        incVoxel = 0;
        incMargin = 0;

        if (mod(monitor.stat(4),nMod_UpdateIndexList) == nMod_UpdateIndexList-1 )
            monitor.binStat(4,i) = max([monitor.binStat(4,i) monitor.stat(4)]);
            monitor.voxHist(2,1:i) = monitor.nVox(1);
%             plotting = update_PackingMonitor(M,L2,plotting,monitor);
        end

        % draw a new center position based on the center of an already placed grain
        if boolDrawFromGrainList
            % draw an already placed grain center point
            ind1 = randi([1 monitor.n-1]);
            cBase = xyzr0(ind1,1:3);

            % define shift distance
            vRad = round((xyzr0(ind1,4) + r) / domain.dx);

            % draw shift direction
            vDir = 2*rand(1,3) - 1;
            vDir = vDir / sqrt(sum(vDir.^2));

            %apply shift
            center = round(cBase + vDir*vRad);
            if any(center < (r/domain.dx)+1) || any([center(1)>szM(1)-marg center(2)>szM(2)-marg center(3)>szM(3)-marg]) % org:(center < 1)
                continue;
            end
        else
            % draw grain center from list of vacant/free voxels
            if (monitor.iRandPos > monitor.nRandPos) || boolUpdateBoxList
                % fprintf('end of list reached at position %d - refreshing index\n',monitor.nRandPos);
                monitor.log = [monitor.log sprintf('%s: End of list reached at position %d -> Updating index list\n',datestr(now,'dd.mm.yy HH:MM'),monitor.nRandPos)];
                showLogInfo(monitor.log,isgui,gui);
                pause(0.01);
                if isgui
                    data = getappdata(fig,'data');
                    monitor.Lr = L2;
                    data.monitor = monitor;
                    setappdata(fig,'data',data);
                    plotMatrixdata(fig,'monitor');
                end

                [Mindex,~] = updateIndexList('std',M,marg/2,r,xyzr0,domain,grains);
                clear MtmpVal;

                % sync with valid grain center positions
                Mindex = Mindex(M_valCtr(Mindex) == true);
                MvN = numel(Mindex);

                if MvN<=1
                    % if this happens you should stop the calculation
                    disp(' ');
                    disp('updateIndexList: no free voxels');
                end
                monitor.log = [monitor.log sprintf('%s: Current porosity: %3.2f\n',datestr(now,'dd.mm.yy HH:MM'),monitor.por_cur)];
                monitor.log = [monitor.log sprintf('%s: Updated index list: %d free voxels left\n',datestr(now,'dd.mm.yy HH:MM'),MvN)];
                showLogInfo(monitor.log,isgui,gui);
                pause(0.01);
                if isgui
                    data = getappdata(fig,'data');
                    monitor.Lr = L2;
                    data.monitor = monitor;
                    setappdata(fig,'data',data);
                    plotMatrixdata(fig,'monitor');
                end

                listRandPos = unique(randi([1,MvN],[1 1e6]));
                monitor.iRandPos = 1;
                monitor.nRandPos = length(listRandPos);
                listRandPos = listRandPos(randperm(monitor.nRandPos));
                boolUpdateBoxList = false;
                Mindex = Mindex(listRandPos);
            end

            [i1,i2,i3] = ind2sub(size(M),Mindex(monitor.iRandPos));
            center = [i1 i2 i3];
            monitor.iRandPos = monitor.iRandPos+1;

        end

        % move the grain to the current center point
        spnew = sphere + [center(1)*tmpOnesA ...
            center(2)*tmpOnesA ....
            center(3)*tmpOnesA];

        % also move the larger grain to the current center point
        spnewB = sphereB + [center(1)*tmpOnesB ...
            center(2)*tmpOnesB ....
            center(3)*tmpOnesB];

        try
        % get indices of the current grain into M
        index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));
        % indices of the larger grain
        indexB = sub2ind(size(M), spnewB(:,1), spnewB(:,2), spnewB(:,3));
        catch
           disp('Something went utterly wrong.');
        end
        % sub matrices for testing
        boolFree = ~any(M(index(:)));
%         boolTouch = ~monitor.boolMustTouch || (sum(M(indexB(:)))>monitor.nMinTouch);
        if monitor.boolMustTouch
            if sum(M(indexB(:)))>monitor.nMinTouch
                boolTouch = true;
            else
               boolTouch = false;
            end
        else
            boolTouch = true;
        end

        monitor.arrFailStat(1) = monitor.arrFailStat(1)+1;
        if boolFree && boolTouch

            incMargin = ~M_valCtr(index);
            incMargin = sum(incMargin(:));
            incVoxel  = grains.binVol(i)-incMargin;

            % mark the new grain
            M(index) = true;

            % label it with radius
            L2(index) = r;

            % append to coordinate list
            xyzr0(monitor.n,1:4) = [center, r];

            % increase current bin counter
            nb = nb + 1;

            % increase global counter
            monitor.n = monitor.n + 1;

            monitor.binStat(4,i) = max([monitor.binStat(4,i) monitor.stat(4)]);

            % reset the current tries per grain counter
            monitor.stat(4) = 0;
        else
            % count tries where grain intersected already
            % existing grain
            monitor.stat(3) = monitor.stat(3) + 1;
            monitor.arrFailStat(2:3)  = monitor.arrFailStat(2:3) + [~boolFree ~boolTouch];
        end

        if size(xyzr0,1)-monitor.n < 10
            tmpAdd = round(0.1*size(xyzr0,1));
            xyzr0 = cat(1,xyzr0,-1*ones(tmpAdd,4));
            monitor.nxyzr0 = size(xyzr0,1);
        end

        % update number of used voxels in box / in margin
        monitor.nVox = monitor.nVox + [incVoxel incMargin];

        monitor.por_cur = 1-monitor.nVox(1)/domain.VOL0;
        % timing
        monitor.t1 = toc;

        if (mod(monitor.stat(1),nDumpUpdateCurBin) == 0) || (mod(round(monitor.t1),params.dumpSec) == 0) || (monitor.stat(1) == 1)
            monitor.i = i;  % update coutner for current grain size bin
%             monitor = printProgress(monitor);
        end

        if (mod(round(monitor.t1),params.updateVisualSec) == 0)
%             plotting = update_PackingMonitor(M,L2,plotting,monitor);
        end

        % the current grain could not be set after 1e5 tries

        if mod(monitor.stat(4),monitor.threshSwapListBox) == monitor.threshSwapListBox-1 &&...
                (iSwapListBox < monitor.nSwapListBoxMax) && monitor.boolMustTouch
            boolDrawFromGrainList = ~boolDrawFromGrainList;

            if ~boolDrawFromGrainList
                strDrawStyle = 'box-based';
                boolUpdateBoxList = true;
            else
                strDrawStyle = 'grain-based';
            end
            monitor.log = [monitor.log sprintf('%s: Switch to %s drawing.\n',datestr(now,'dd.mm.yy HH:MM'),strDrawStyle)];
            showLogInfo(monitor.log,isgui,gui);
            pause(0.01);
        end

        if monitor.stat(4) > monitor.threshMaxTry
            monitor.log = [monitor.log sprintf('%s: Aborting bin: max. threshold %d/%d is reached.\n',...
                datestr(now,'dd.mm.yy HH:MM'),monitor.stat(4),monitor.threshMaxTry)];
            showLogInfo(monitor.log,isgui,gui);
            pause(0.01);
            break;
        end

        if monitor.por_cur <= monitor.poro_final
            monitor.log = [monitor.log sprintf('%s: Aborting bin: porosity of %4.2f%% is reached.\n',...
                datestr(now,'dd.mm.yy HH:MM'),monitor.por_cur)];
            showLogInfo(monitor.log,isgui,gui);
            pause(0.01);
            break;
        end
    end
    
    % the current bin is done (all grains of this size have been placed)
    monitor.nLstVox = monitor.nVox(1);

    monitor.log = [monitor.log sprintf('%s: Finished bin: placed %d of %d voxels.\n',...
        datestr(now,'dd.mm.yy HH:MM'),monitor.nVox(1),monitor.nVoxAim(i))];
    showLogInfo(monitor.log,isgui,gui);
    pause(0.01);
    if isgui
        data = getappdata(fig,'data');
        monitor.Lr = L2;
        data.monitor = monitor;
        setappdata(fig,'data',data);
        plotGSDdata(fig,'monitor');
        plotMatrixdata(fig,'monitor');
    end
    if monitor.stat(4) > monitor.threshMaxTry || monitor.por_cur <= monitor.poro_final
        break;
    end
end

monitor.log = [monitor.log sprintf('%s: Finished last bin.\n',datestr(now,'dd.mm.yy HH:MM'))];
showLogInfo(monitor.log,isgui,gui);
pause(0.01);

str1 = 'RUN - placeGrains: finished setting grains. ';
if isgui
    set(gui.text_handles.Status,'String', str1);
else
    disp(str1);
end

% total run time
t = toc;

% finalize the output data
domain.xyzr0 = xyzr0;

% all matrices with margin
domain.final{1}.M = M;
if ~params.boolOmitLn
    % reset remaining empty voxels in margin
    L1(L1 == -1) = 0;
    domain.final{1}.Ln = L1;
end
domain.final{1}.Lr = L2;
domain.porosity_final = 1-sum(M(domain.kEvalPoro))/domain.VOL0;

% printStat(domain,monitor.stat,t);

statStruct.porosity_final = domain.porosity_final;
statStruct.runtimeMin = t/60;
statStruct.stat = monitor.stat;
domain.statB = statStruct;
domain.monitor = monitor;

% domain.plotting = plotting;

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

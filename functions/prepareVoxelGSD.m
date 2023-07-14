function grains = prepareVoxelGSD(domain,grains,varargin)
%prepareVoxelGSD generates the voxelised GSD input data
%
% Syntax:
%       grains = prepareVoxelGSD(domain,grains,varargin)
%
% Inputs:
%       domain
%       grains
%       varargin
%
% Outputs:
%       grains
%
% Example:
%       grains = prepareVoxelGSD(domain,grains,varargin)
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
if nargin > 2
    src = varargin{1};
    % get GUI handle
    fig = ancestor(src,'figure','toplevel');
    isgui = true;
    % get GUI data
    gui = getappdata(fig,'gui');
end

if grains.ishistogram
    % create a diameter binning vector considering the minimum grid
    % discretization
    dbins = domain.dx:domain.dx:grains.rmax*2;
    % radius binning vector
    rbins = dbins/2;
    nbins = zeros(size(rbins));
    nvoxBins = zeros(size(rbins));

    % get the voxel volume per individual grain radius
    grains.binVol = zeros(1,numel(rbins));

    % interpolate the input histogram on the radius binning vector
    tmpCumVol = interp1(grains.hist_raw(:,1),grains.hist_raw(:,2),rbins);
    fracBin = [tmpCumVol(1) diff(tmpCumVol)];

    remainVox = 0;
    cc = 0;
    str2 = cell(1,1);
    for i = fliplr(1:numel(rbins))
        cc = cc + 1;
        sphere = getSubBodyCoords(grains.shape,grains.axes,rbins(i),domain.dx);
        grains.binVol(i) = size(sphere,1);
        nbins(i) = floor((remainVox + domain.VOL0matrix*fracBin(i))/grains.binVol(i));
        nvoxBins(i) = nbins(i)*grains.binVol(i);
        remainVox = domain.VOL0matrix*sum(fracBin(i:end))-sum(nvoxBins(i:end));

        str1 = ['INIT - prepareVoxelGSD: bin classes done: ',sprintf('%d',round(100*cc/numel(rbins))),'%'];
        if cc == 1
            str2{1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' r bin class ',num2str(i),...
                ' (',sprintf('%5.4f',rbins(i)),'m) ',sprintf('%d',nbins(i)),' grains'];
        else
            str2{end+1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' r bin class ',num2str(i),...
                ' (',sprintf('%5.4f',rbins(i)),'m) ',sprintf('%d',nbins(i)),' grains'];
        end
        str2{end+1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' voxel used: ',sprintf('%d / %d',...
                nvoxBins(i),round(domain.VOL0matrix*fracBin(i)))];
        str2{end+1,1} = ' ';
        
        if isgui
            set(gui.text_handles.Status,'String', str1);
        else
            disp(str1);
        end
        showLogInfo(str2,isgui,gui);
        pause(0.01);

    end

    % remove bins with no members
    boolOK = nbins~=0;
    rbins = rbins(boolOK);
    nvoxBins = nvoxBins(boolOK);
    grains.binVol = grains.binVol(boolOK);
    nbins = nbins(boolOK);

    % TODO: why is this switch-off here?
    % if ~any(rbins == domain.dx/2)
    %     rbins = [domain.dx/2 rbins];
    %     nbins = [0 nbins];
    % end

    % ensure smallest bin class
    if ~any(rbins == domain.dx)
        rbins = [domain.dx rbins];
        nbins = [0 nbins];
    end

    % the voxel volume of all grains from the distribution
    grains.VOLspheres = sum(grains.binVol.*nbins);

    % output data
    grains.rbins = rbins;
    grains.nbins = nbins;
    grains.Nbins = nbins;
    grains.nvoxBins = nvoxBins;

else
    % create a diameter binning vector considering the minimum grid
    % discretization
    dbins = domain.dx:domain.dx:grains.rmax*2;
    % radius binning vector
    rbins = dbins/2;
    % get the counts per bin
    %     nbins = hist(grains.dia_raw,dbins);
    % --- account for new Matlab behaviour of histogram vs hist
    d = diff(dbins)/2;
    edges = [dbins(1)-d(1), dbins(1:end-1)+d, dbins(end)+d(end)];
    edges(2:end) = edges(2:end)+eps(edges(2:end));
    %     nbins = histcounts(grains.dia_raw,edges);
    N = histcounts(grains.dia_raw,edges,'Normalization','cdf');

    tmp_hist = [[0 rbins]' [0 N]'];

    do_old = false;
    %% OLD WAY
    if do_old
        % remove bins with no members
        rbins = rbins(nbins~=0);
        nbins = nbins(nbins~=0);

        if ~any(rbins == domain.dx/2)
            rbins = [domain.dx/2 rbins];
            nbins = [0 nbins];
        end

        if ~any(rbins == domain.dx)
            rbins = [domain.dx rbins];
            nbins = [0 nbins];
        end

        % get the voxel volume per grain radius
        grains.binVol = zeros(1,numel(rbins));
        for i = 1:numel(rbins)
            sphere = getSubBodyCoords(grains.shape,grains.axes,rbins(i),domain.dx);
            grains.binVol(i) = size(sphere,1);
        end
        % the voxel volume of all grains from the distribution
        grains.VOLspheres = sum(grains.binVol.*nbins);

        % how many copies of the distribution we need to fill the matrix
        grains.ncopies = domain.VOL0matrix/grains.VOLspheres;

        grains.rbins = rbins;
        grains.nbins = nbins;
        grains.Nbins = round(nbins*grains.ncopies);
        grains.nvoxBins = grains.Nbins.*grains.binVol;
        grains.nbins = grains.Nbins;

        %% NEW WAY - use cumulative histogram
    else
        nbins = zeros(size(rbins));
        nvoxBins = zeros(size(rbins));

        % get the voxel volume per individual grain radius
        grains.binVol = zeros(1,numel(rbins));

        % interpolate the input histogram on the radius binning vector
        tmpCumVol = interp1(tmp_hist(:,1),tmp_hist(:,2),rbins);
        fracBin = [tmpCumVol(1) diff(tmpCumVol)];

        remainVox = 0;
        cc = 0;
        for i = fliplr(1:numel(rbins))
            cc = cc + 1;
            sphere = getSubBodyCoords(grains.shape,grains.axes,rbins(i),domain.dx);
            grains.binVol(i) = size(sphere,1);
            nbins(i) = round((remainVox + domain.VOL0matrix*fracBin(i))/grains.binVol(i));
            nvoxBins(i) = nbins(i)*grains.binVol(i);
            remainVox = domain.VOL0matrix*sum(fracBin(i:end))-sum(nvoxBins(i:end));

            str1 = ['INIT - prepareVoxelGSD: bin classes done: ',sprintf('%d',round(100*cc/numel(rbins))),'%'];
            if cc == 1
                str2{1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' r bin class ',num2str(i),...
                    ' (',sprintf('%5.4f',rbins(i)),'m) ',sprintf('%d',nbins(i)),' grains'];
            else
                str2{end+1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' r bin class ',num2str(i),...
                    ' (',sprintf('%5.4f',rbins(i)),'m) ',sprintf('%d',nbins(i)),' grains'];
            end
            str2{end+1,1} = [sprintf('%s',datestr(now,'dd.mm.yy HH:MM')),' voxel used: ',sprintf('%d / %d',...
                nvoxBins(i),round(domain.VOL0matrix*fracBin(i)))];
            str2{end+1,1} = ' ';

            if isgui
                set(gui.text_handles.Status,'String', str1);
            else
                disp(str1);
            end
            showLogInfo(str2,isgui,gui);
            pause(0.01);

        end

        % remove bins with no members
        boolOK = nbins~=0;
        rbins = rbins(boolOK);
        nvoxBins = nvoxBins(boolOK);
        grains.binVol = grains.binVol(boolOK);
        nbins = nbins(boolOK);

        % TODO: why is this switch-off here?
        % if ~any(rbins == domain.dx/2)
        %     rbins = [domain.dx/2 rbins];
        %     nbins = [0 nbins];
        % end

        % ensure smallest bin class
        if ~any(rbins == domain.dx)
            rbins = [domain.dx rbins];
            nbins = [0 nbins];
        end

        % the voxel volume of all grains from the distribution
        grains.VOLspheres = sum(grains.binVol.*nbins);

        % output data
        grains.rbins = rbins;
        grains.nbins = nbins;
        grains.Nbins = nbins;
        grains.nvoxBins = nvoxBins;
        disp(sum(nvoxBins)/domain.VOL0);
    end
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

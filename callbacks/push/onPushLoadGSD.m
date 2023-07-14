function onPushLoadGSD(src,~)
%onPushLoadGSD starts the import of a user provided GSD file
%
% Syntax:
%       onPushLoadGSD(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushLoadGSD(src)
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

% get GUI handle
fig = ancestor(src,'figure','toplevel');

if ~isempty(fig) && strcmp(get(fig,'Tag'),'GPRGRAVEL')
    % get GUI data
    gui = getappdata(fig,'gui');
    data = getappdata(fig,'data');
    grains = data.grains;

    % get the standard input path for GSD data if it is not already there
    if ~isfield(grains,'GSDpath')
        grains.GSDpath = fullfile(data.params.GPRGRAVELpath,'input','GSD');
    end
    % get the file to open
    [file,path] = uigetfile('.txt','Select the GSD file',grains.GSDpath);
    grains.GSDpath = path;
    grains.GSDfile = file;
    % try to import the data
    tmp = importdata(fullfile(grains.GSDpath,grains.GSDfile));

    % if there is data, proceed
    if ~isempty(tmp)
        % IMPORTANT:
        % if there is no header, assume the data is given as diameters in mm!!!
        if isstruct(tmp)
            header = tmp.colheaders{1};
            % get unit of data
            ind = strfind(header,'#');
            unit = strtrim(header(ind+1:end));
            switch unit
                case 'mm'
                    fac = 1000;
                case 'cm'
                    fac = 100;
                case 'm'
                    fac = 1;
            end
            tmpd = tmp.data;
        else
            % conversion factor from mm to m
            fac = 1000;
            tmpd = tmp;
        end

        % assume it is a list of grain sizes
        grains.ishistogram = false;
        if size(tmpd,2) == 2
            % if not, it is a histogram CDF
            grains.ishistogram = true;
        end
        
        % save the data as radius in [m]
        if grains.ishistogram
            grains.hist_raw = tmpd;
            % transform to radius in [m]
            grains.hist_raw(:,1) = grains.hist_raw(:,1)/(2*fac);
            % get maximum radius
            grains.rmax = max(grains.hist_raw(:,1));
        else
            % grain diameter in [mm]
            dia = tmpd;
            % transform to [m]
            grains.dia_raw = dia/fac;
            % transform to radius in [m]
            grains.r_raw = dia/2/fac;
            % get maximum radius
            grains.rmax = max(grains.r_raw);
        end
        % update the GSD file name text fiedl
        set(gui.edit_handles.gsdfile,'String',grains.GSDfile);

        % delete old voxelised GSD data
        if isfield(grains,'binVol')
            grains = rmfield(grains,'binVol');
        end
        if isfield(grains,'VOLspheres')
            grains = rmfield(grains,'VOLspheres');
        end
        if isfield(grains,'rbins')
            grains = rmfield(grains,'rbins');
        end
        if isfield(grains,'nbins')
            grains = rmfield(grains,'nbins');
        end
        if isfield(grains,'Nbins')
            grains = rmfield(grains,'Nbins');
        end
        if isfield(grains,'nvoxBins')
            grains = rmfield(grains,'nvoxBins');
        end

        % update GUI data
        data.grains = grains;
        setappdata(fig,'data',data);
        % plot the GSD data
        plotGSDdata(fig,'input');
    else
        warndlg({'onPushLoadGSD:','Please provide grain size data.'},...
            'GPRGRAVEL error');
    end
else
    warndlg({'onPushLoadGSD:','There is no figure with the GPRGRAVEL Tag open.'},...
        'GPRGRAVEL error');
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

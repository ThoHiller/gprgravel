function onPushRun(src,~)
%onPushRun starts the calculation
%
% Syntax:
%       onPushRun(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushRun(src)
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

    % get data
    grains = data.grains;
    params = data.params;
    domain = data.domain;

    % get the tag of the button
    tag = get(src,'tag');

    % time the calculation
    t0 = tic;
    switch tag
        case 'INIT' % init domain         
            
            % check if there is GSD data, otherwise we cannot start
            if isfield(grains,'ishistogram')

                % init the domain box
                [domain,params] = prepareDomain(domain,grains,params,src);
                % init the voxelised grain size distribution
                grains = prepareVoxelGSD(domain,grains,src);

                % update data
                data.grains = grains;
                data.domain = domain;
                data.params = params;
                setappdata(fig,'data',data);

                % plot voxelisd GSD
                plotGSDdata(fig,'input');

                % activate the RUN button
                set(gui.push_handles.Run,'Enable','on');

                % activate menu
                set(gui.menu_handles.view_figures_voxelgrains,'Enable','on');

                % init/reset the grid panel
                % input GSD
                set(gui.panels.Plot.grains,'Selection',1);
                % 3D monitor view
                onPushAxView(gui.push_handles.DLv);
                set(gui.panels.Plot.result,'Selection',1);
                clearSingleAxis(gui.axes_handles.Volume);
                clearSingleAxis(gui.axes_handles.Slice);
                clearSingleAxis(gui.axes_handles.ProfileAir);
                clearSingleAxis(gui.axes_handles.ProfileH2O);
                clearSingleAxis(gui.axes_handles.histOut);

            else
                warndlg({'onPushRun:','LOAD GSD data first.'},...
                    'GPRGRAVEL error');
            end

        case 'RUN' % run calculation

            % switch view to output GSD plot
            set(gui.panels.Plot.grains,'Selection',2);
            set(gui.panels.Plot.result,'Selection',1);

            % start placing the grains
            [domain,grains,params] = placeGrains(domain,grains,params,data.monitor,src);
            % update data
            data.grains = grains;
            data.domain = domain;
            data.params = params;
            setappdata(fig,'data',data);

            % now add the water
            [domain,grains,params] = placeWater(domain,grains,params,src);
            % update data
            data.grains = grains;
            data.domain = domain;
            data.params = params;
            setappdata(fig,'data',data);

            % plot results
            onPushAxView(gui.push_handles.XZLs);
            data = getappdata(fig,'data');
            plotProfiledata(fig);
            
            % activate menu
            set(gui.menu_handles.view_figures_volume,'Enable','on');

            % export results
            [~,~,~] = exportData(domain,grains,params,src);

    end
    
    % time the calculation
    data.info.Timer = toc(t0);
    
    % update GUI data
    setappdata(fig,'data',data);
    % update status bar
    updateStatusInformation(fig);

else
    warndlg({'onPushRun:','There is no figure with the GPRGRAVEL Tag open.'},...
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

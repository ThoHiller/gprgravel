function minimizePanel(src,~)
%minimizePanel handles the minimization/maximization of all box-panels
%
% Syntax:
%       minimizePanel(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       minimizePanel(src)
%
% Other m-files required:
%       findParentOfType
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

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
gui = getappdata(fig,'gui');

% get the corresponding box-panel to be minimized / maximized
panel = findParentOfType(src,'uix.BoxPanel');
% panel title
paneltitle = get(panel,'Title');
% check if panel is minimized (true)
isminimized = get(panel,'Minimized');

% minimized height (default value for all box-panels)
pheightmin = 22;
% default heights
def_heights = gui.myui.heights;

if ~isempty(fig) && strcmp(get(fig,'Tag'),'GPRGRAVEL')
    
    panel_1 = 'Grains';
    panel_2 = 'Domain';
    panel_3 = 'Parameter';
    
    switch paneltitle
        case panel_1
            id = 1;
        case panel_2
            id = 2;
        case panel_3
            id = 3;
        otherwise
            helpdlg({'function: minimizePanel',...
                'Something is utterly wrong.'},'Info');
    end
    
    switch paneltitle
        case {panel_1,panel_2,panel_3}
            % all heights of the left panels
            heights = get(gui.panels.main,'Heights');
            % default height of this panel
            pheight = def_heights(2,id);
            if isminimized % maximize panel
                heights(id) = pheight;
                set(gui.panels.main,'Heights',heights);
                set(panel,'Minimized',false);
            else % minimize panel
                heights(id) = pheightmin;
                set(gui.panels.main,'Heights',heights);
                set(panel,'Minimized',true)
            end
            onFigureSizeChange(fig);
        otherwise
            helpdlg({'function: minimizePanel',...
                'Something is utterly wrong.'},'Info');
    end    
else
    warndlg({'minimizePanel:','There is no figure with the GPRGRAVEL Tag open.'},...
        'GPRGRAVEL error');
end
% update GUI data
setappdata(fig,'gui',gui);

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

function gui = GPRGRAVEL_createMenus(gui)
%GPRGRAVEL_createMenus creates all GUI menus
%
% Syntax:
%       gui = GPRGRAVEL_createMenus(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       gui = GPRGRAVEL_createMenus(gui)
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

%% 1. File
gui.menu_handles.file = uimenu(gui.figh,...
    'Label','File',...
    'Enable','off');

% 1.1 Import
gui.menu_handles.file_import = uimenu(gui.menu_handles.file,...
    'Label','Import Data','Enable','off',...
    'Callback',@onMenuImport);

% 1.2 Export
gui.menu_handles.file_export = uimenu(gui.menu_handles.file,...
    'Label','Export Data','Enable','off',...
    'Callback',@onMenuExport);

% 1.3 Restart
gui.menu_handles.file_restart = uimenu(gui.menu_handles.file,...
    'Label','Restart',...
    'Separator','on',...
    'Callback',@onMenuRestartQuit);

% 1.4 Quit
gui.menu_handles.file_quit = uimenu(gui.menu_handles.file,...
    'Label','Quit',...
    'Callback',@onMenuRestartQuit);

%% 2. Extras
gui.menu_handles.view = uimenu(gui.figh,...
    'Label','View',...
    'Enable','off');

% 2.1 Tooltips (on/off)
gui.menu_handles.view_tooltips = uimenu(gui.menu_handles.view,...
    'Label','Tooltips',...
    'Checked','on','Enable','off',...
    'Callback',@onMenuView);

% 2.2 Figure Toolbar
gui.menu_handles.view_toolbar = uimenu(gui.menu_handles.view,...
    'Label','Figure Toolbar',...
    'Callback',@onMenuView);
% 2.3.1 Figures
gui.menu_handles.view_figures = uimenu(gui.menu_handles.view,...
    'Label','Figures','Separator','on');
% 2.3.1.1 all grains as voxels
gui.menu_handles.view_figures_voxelgrains = uimenu(gui.menu_handles.view_figures,...
    'Label','Voxelised Grains','Enable','off',...
    'Callback',@onMenuViewFigure);
% 2.3.1.2 only magnetization
gui.menu_handles.view_figures_volume = uimenu(gui.menu_handles.view_figures,...
    'Label','Volume','Enable','off',...
    'Callback',@onMenuViewFigure);
% % 2.3.1.3 only ramp
% gui.menu_handles.view_figures_ramp = uimenu(gui.menu_handles.view_figures,...
%     'Label','Switch-off Ramp',...
%     'Enable','off',...
%     'Callback',@onMenuViewFigure);
% % 2.3.1.4 only pulse
% gui.menu_handles.view_figures_pulse = uimenu(gui.menu_handles.view_figures,...
%     'Label','Pulse',...
%     'Enable','off',...
%     'Callback',@onMenuViewFigure);

%% 3. Help
gui.menu_handles.help = uimenu(gui.figh,...
    'Label','Help',...
    'Enable','off');

% 3.1 About
gui.menu_handles.help_about = uimenu(gui.menu_handles.help,...
    'Label','About',...
    'Callback',@onMenuHelp);

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

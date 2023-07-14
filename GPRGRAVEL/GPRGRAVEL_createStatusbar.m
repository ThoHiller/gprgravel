function [gui,myui] = GPRGRAVEL_createStatusbar(gui,myui)
%GPRGRAVEL_createStatusbar creates the bottom status bar
%
% Syntax:
%       [gui,myui] = GPRGRAVEL_createStatusbar(gui,myui)
%
% Inputs:
%       gui - figure gui elements structure
%       myui - individual GUI settings structure
%
% Outputs:
%       gui
%       myui
%
% Example:
%       [gui,myui] = GPRGRAVEL_createStatusbar(gui,myui)
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

% create panels inside the bottom hbox to show persistent status
% information
gui.panels.status.main = uix.Panel('Parent',gui.bottom);
gui.panels.status.Timer = uix.Panel('Parent',gui.bottom);
gui.panels.status.Masks = uix.Panel('Parent',gui.bottom);
gui.panels.status.Targets = uix.Panel('Parent',gui.bottom);
gui.panels.status.SatProfile = uix.Panel('Parent',gui.bottom);
gui.panels.status.Version = uix.Panel('Parent',gui.bottom);

% adjust the panel widths
set(gui.bottom,'Widths',[300 -1 -1 -1 -1 -1]);

gui.text_handles.Status = uicontrol('Style','Text',...
    'Parent',gui.panels.status.main,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.text_handles.TimerStat = uicontrol('Style','Text',...
    'Parent',gui.panels.status.Timer,...
    'String','Calc. Time: 0 s',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.text_handles.Surface = uicontrol('Style','Text',...
    'Parent',gui.panels.status.Masks,...
    'String','SURFACE: OPEN',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.text_handles.Targets = uicontrol('Style','Text',...
    'Parent',gui.panels.status.Targets,...
    'String','TARGETS: OFF',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.text_handles.SatProf = uicontrol('Style','Text',...
    'Parent',gui.panels.status.SatProfile,...
    'String','SATURATION Profile: OFF',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.text_handles.VersionStat = uicontrol('Style','Text',...
    'Parent',gui.panels.status.Version,...
    'String','Version: ',...
    'HorizontalAlignment','left',...
    'FontSize',8);

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

function GPRGRAVEL_createGUI(h,wbon)
%GPRGRAVEL_createGUI controls the creation of all GUI elements
%
% Syntax:
%       GPRGRAVEL_createGUI(h)
%
% Inputs:
%       h - figure handle
%       wbon - show waitbar (yes=true, no=false)
%
% Outputs:
%       none
%
% Example:
%       GPRGRAVEL_createGUI(h,true)
%
% Other m-files required:
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

%% get GUI data
data = getappdata(h,'data');
gui = getappdata(h,'gui');
myui = gui.myui;

%% initialize wait bar
if wbon
    hwb = waitbar(0,'loading ...','Name','GPRGRAVEL initialization','Visible','off');
    steps = 6;
    if ~isempty(h)
        posf = get(h,'Position');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    end
    set(hwb,'Visible','on');
end

%% uimenus
if wbon
    waitbar(1/steps,hwb,'loading GUI elements - menus');
end
gui = GPRGRAVEL_createMenus(gui);

%% MAIN GUI "BOX"
gui.main = uix.VBox('Parent',gui.figh,'Visible','off');

% top part for settings and plots
gui.top = uix.HBox('Parent',gui.main);
% bottom part for the status bar
gui.bottom = uix.HBox('Parent',gui.main);
set(gui.main,'Heights',[-1 20]);

% top left contains the three main panels plus the control panel
gui.leftTop = uix.VBox('Parent',gui.top);
% all plots in a flexible grid on the right side
gui.right = uix.GridFlex('Parent',gui.top,'Spacing',7);
set(gui.top,'Widths',[300 -1]);
set(gui.top,'MinimumWidths',[300 200]);

% the three main panels are inside a vertically scrollable panel
gui.left = uix.ScrollingPanel('Parent',gui.leftTop);
% but the control panel is fixed to the bottom
gui.panels.Control.main = uix.BoxPanel('Parent',gui.leftTop,'Title','Control',...
    'TitleColor',[164 164 164]./255,'ForegroundColor','k');
set(gui.leftTop,'Heights',[-1 53]);

%% A. settings column
gui.panels.main = uix.VBox('Parent',gui.left);
gui.panels.Grains.main = uix.BoxPanel('Parent',gui.panels.main,'Title','Grains',...
    'TitleColor',myui.color.grains,'ForegroundColor','k','MinimizeFcn',@minimizePanel);
gui.panels.Domain.main = uix.BoxPanel('Parent',gui.panels.main,'Title','Domain',...
    'TitleColor',myui.color.domain,'ForegroundColor','k','MinimizeFcn',@minimizePanel);
gui.panels.Params.main = uix.BoxPanel('Parent',gui.panels.main,'Title','Parameter',...
    'TitleColor',myui.color.params,'ForegroundColor','k','MinimizeFcn',@minimizePanel);
uix.Empty('Parent',gui.panels.main);

% adjust the heights of all left-column-panels
% edit and popup elements are 24
edith = 22;
% panel header is always 22 high
headerh = 22;
% spacing is set to 3
spacing = 3;
% maximal height of each panel
grains_max = 6*edith+7*spacing+headerh;
% params_max = 8*edith+9*spacing+headerh-14;
params_max = 13*edith+14*spacing+headerh-5;
domain_max = 8*edith+9*spacing+headerh;
% save the heights information (needed for minimizing the panels)
myui.heights = [22 22 22 -1; grains_max domain_max params_max -1];
set(gui.panels.main,'Heights',myui.heights(2,:),...
    'MinimumHeights',[22 22 22 0]);
% the 'MinimumHeights' guarantees that the three panels fit into the
% ScrollingPanel when the GUI becomes smaller
set(gui.left,'Heights',-1,'MinimumHeights',grains_max+domain_max+params_max);

if wbon
    waitbar(2/steps,hwb,'loading GUI elements - Grains panel');
end
[gui,myui] = GPRGRAVEL_createPanelGrains(data,gui,myui);

if wbon
    waitbar(3/steps,hwb,'loading GUI elements - Parameter panel');
end
[gui,myui] = GPRGRAVEL_createPanelParameter(data,gui,myui);

if wbon
    waitbar(4/steps,hwb,'loading GUI elements - Domain panel');
end
[gui,myui] = GPRGRAVEL_createPanelDomain(data,gui,myui);

if wbon
    waitbar(5/steps,hwb,'loading GUI elements - Control panel');
end
[gui,myui] = GPRGRAVEL_createPanelControl(gui,myui);

if wbon
    waitbar(6/steps,hwb,'loading GUI elements - Plot panel');
end
[gui,myui] = GPRGRAVEL_createGridPlots(gui,myui);

% delete wait bar
if wbon
    delete(hwb);
end

[gui,myui] = GPRGRAVEL_createStatusbar(gui,myui);

% make the main GUI visible
set(gui.main,'Visible','on');

%% enable all menus
set(gui.menu_handles.file,'Enable','on');
set(gui.menu_handles.view,'Enable','on');
set(gui.menu_handles.help,'Enable','on');

%% update the GUI data
gui.myui = myui;
setappdata(gui.figh,'gui',gui);
setappdata(gui.figh,'data',data);
set(gui.text_handles.Status,'String','GPRGRAVEL successfully started');

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

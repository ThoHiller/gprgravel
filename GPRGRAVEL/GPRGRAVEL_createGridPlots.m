function [gui,myui] = GPRGRAVEL_createGridPlots(gui,myui)
%GPRGRAVEL_createGridPlots creates the "Plots" grid panel
%
% Syntax:
%       [gui,myui] = GPRGRAVEL_createGridPlots(gui,myui)
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
%       [gui,myui] = GPRGRAVEL_createGridPlots(gui,myui)
%
% Other m-files required:
%       findjobj.m
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

%% first create the individual tab panels
%(1,1) grains
gui.panels.Plot.grains = uix.TabPanel('Parent',gui.right,...
    'BackgroundColor',myui.color.grains);
%(2,1) results
gui.panels.Plot.result = uix.TabPanel('Parent',gui.right,...
    'BackgroundColor',myui.color.params);
%(1,2) domain
gui.panels.Plot.domain = uix.TabPanel('Parent',gui.right,...
    'BackgroundColor',myui.color.domain);
%(2,2) info
gui.panels.Plot.info = uix.TabPanel('Parent',gui.right,...
    'BackgroundColor',[164 164 164]./255); 

%% domain panel
plotDOMAIN = uix.VBox('Parent',gui.panels.Plot.domain,'Spacing',3,'Padding',3);
gui.panels.Plot.domain.TabTitles = {'Domain Setup'};
gui.panels.Plot.domain.TabWidth = 75;

% add view buttons and axes to the panel
plotDomain = uicontainer('Parent',plotDOMAIN);
DomainButtons = uix.HButtonBox('Parent',plotDOMAIN);
gui.push_handles.XZLd = uicontrol('Parent',DomainButtons,...
    'String','XZ',...
    'Tag','domain',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.YZLd = uicontrol('Parent',DomainButtons,...
    'String','YZ',...
    'Tag','domain',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.XYLd = uicontrol('Parent',DomainButtons,...
    'String','XY',...
    'Tag','domain',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.DLd = uicontrol('Parent',DomainButtons,...
    'String','3D',...
    'Tag','domain',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
set(plotDOMAIN,'Heights',[-1 30]);
gui.axes_handles.domain = axes('Parent',plotDomain,'Box','on');
view(gui.axes_handles.domain,3);
axis(gui.axes_handles.domain,'equal');
clearSingleAxis(gui.axes_handles.domain);

%% results panel
plotVOLUME = uix.VBox('Parent',gui.panels.Plot.result,'Spacing',3,'Padding',3);
plotSLICE = uix.VBox('Parent',gui.panels.Plot.result,'Spacing',3,'Padding',3);
plotPROFILE = uix.HBox('Parent',gui.panels.Plot.result,'Spacing',3,'Padding',3);

gui.panels.Plot.result.TabTitles = {'Monitor','Slice','Profiles'};
gui.panels.Plot.result.TabWidth = 85;

% Volume
% add view buttons and axes to the panel
plotVolume = uicontainer('Parent',plotVOLUME);
VolumeButtons = uix.HButtonBox('Parent',plotVOLUME);
gui.push_handles.XZLv = uicontrol('Parent',VolumeButtons,...
    'String','XZ',...
    'Tag','monitor',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.YZLv = uicontrol('Parent',VolumeButtons,...
    'String','YZ',...
    'Tag','monitor',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.XYLv = uicontrol('Parent',VolumeButtons,...
    'String','XY',...
    'Tag','monitor',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.DLv = uicontrol('Parent',VolumeButtons,...
    'String','3D',...
    'Tag','monitor',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
set(plotVOLUME,'Heights',[-1 30]);
gui.axes_handles.Volume = axes('Parent',plotVolume,'Box','on');
view(gui.axes_handles.Volume,3);
axis(gui.axes_handles.Volume,'equal');
clearSingleAxis(gui.axes_handles.Volume);

% Slice
plotSliceBox = uix.HBox('Parent',plotSLICE);
plotSlice = uicontainer('Parent',plotSliceBox);
gui.slider_handles.slider = uicontrol('Style','Slider',...
    'Parent',plotSliceBox,'Callback',@onSlider);

SliceButtons = uix.HButtonBox('Parent',plotSLICE);
gui.push_handles.XZLs = uicontrol('Parent',SliceButtons,...
    'String','XZ',...
    'Tag','slice',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.YZLs = uicontrol('Parent',SliceButtons,...
    'String','YZ',...
    'Tag','slice',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
gui.push_handles.XYLs = uicontrol('Parent',SliceButtons,...
    'String','XY',...
    'Tag','slice',...
    'FontSize',myui.fontsize,...
    'Callback',@onPushAxView);
set(plotSLICE,'Heights',[-1 30]);
set(plotSliceBox,'Widths',[-1 20]);
gui.axes_handles.Slice = axes('Parent',plotSlice,'Box','on');
axis(gui.axes_handles.Slice,'equal');
clearSingleAxis(gui.axes_handles.Slice);

% Profiles
plotProfile1 = uicontainer('Parent',plotPROFILE);
plotProfile2 = uicontainer('Parent',plotPROFILE);
gui.axes_handles.ProfileAir = axes('Parent',plotProfile1,'Box','on');
gui.axes_handles.ProfileH2O = axes('Parent',plotProfile2,'Box','on');
clearSingleAxis(gui.axes_handles.ProfileAir);
clearSingleAxis(gui.axes_handles.ProfileH2O);

%% grains / histogram panel
plotGrainsHistIn = uicontainer('Parent',gui.panels.Plot.grains);
plotGrainsHistOut = uicontainer('Parent',gui.panels.Plot.grains);
gui.panels.Plot.grains.TabTitles = {'GSD Input','GSD Output'};
gui.panels.Plot.grains.TabWidth = 75;

gui.axes_handles.histIn = axes('Parent',plotGrainsHistIn,'Box','on');
gui.axes_handles.histOut = axes('Parent',plotGrainsHistOut,'Box','on');
clearSingleAxis(gui.axes_handles.histIn);
clearSingleAxis(gui.axes_handles.histOut);

%% info panel
plotInfo = uix.VBox('Parent',gui.panels.Plot.info,'Spacing',3,'Padding',3);
gui.panels.Plot.info.TabTitles = {'Info'};
gui.panels.Plot.info.TabWidth = 75;

gui.listbox_handles.info = uicontrol('Parent',plotInfo,...
    'Style','listbox','Tag','Info',...
    'FontSize',10,'String','>>',...
    'HorizontalAlignment','left','Enable','on');

% arrange the panels in a 2x2 grid
set(gui.right,'Widths',[-1 -1],'Heights',[-1 -1]);

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
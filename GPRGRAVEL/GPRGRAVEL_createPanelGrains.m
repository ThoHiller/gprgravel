function [gui,myui] = GPRGRAVEL_createPanelGrains(data,gui,myui)
%GPRGRAVEL_createPanelGrains creates "Grains" settings panel
%
% Syntax:
%       [gui,myui] = GPRGRAVEL_createPanelGrains(gui,myui,data)
%
% Inputs:
%       data - figure data structure
%       gui - figure gui elements structure
%       myui - individual GUI settings structure
%
% Outputs:
%       gui
%       myui
%
% Example:
%       [gui,myui] = GPRGRAVEL_createPanelGrains(data,gui,myui)
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

%% create all boxes
gui.panels.Grains.VBox = uix.VBox('Parent', gui.panels.Grains.main,...
    'Spacing',3,'Padding',3);

getGSD = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);
setShape = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);
textEllipse = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);
setEllipse = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);
textOrient = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);
setOrient = uix.HBox('Parent',gui.panels.Grains.VBox,'Spacing',3);

%% load GSD
gui.text_handles.gsd = uicontrol('Style','Text',...
    'Parent',getGSD,...
    'String','GSD',...
    'FontSize',myui.fontsize);
tstr = 'grain size distribution file';
gui.edit_handles.gsdfile = uicontrol('Style','Edit',...
    'Parent',getGSD,...
    'String','...',...
    'Tag','grains_gsdfile',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','on');
tstr = 'Load GSD File.';
gui.push_handles.LoadGSD = uicontrol('Style','pushbutton',...
    'Parent',getGSD,...
    'String','Load',...
    'Tag','Load',...
    'ToolTipString',tstr,...
    'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),...
    'Callback',@onPushLoadGSD);
set(getGSD,'Widths',[75 -1 50]);

%% Grain Shape
gui.text_handles.shape = uicontrol('Style','Text',...
    'Parent',setShape,...
    'String','grain shape',...
    'FontSize',myui.fontsize);
% uix.Empty('Parent',setShape);
tstr = 'Choose grain shape.';
gui.popup_handles.Shape = uicontrol('Style', 'Popup',...
    'Parent',setShape,...
    'String',{'sphere','ellipsoid'},...
    'Tag','shape',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),...
    'Callback',@onPopupShape);
set(setShape,'Widths',[75 -1]);

%% ellipse settings - axes
gui.text_handles.ellipsex = uicontrol('Style','Text',...
    'Parent',textEllipse,...
    'String','x-axis [-]',...
    'FontSize',myui.fontsize);
gui.text_handles.ellipsey = uicontrol('Style','Text',...
    'Parent',textEllipse,...
    'String','y-axis [-]',...
    'FontSize',myui.fontsize);
gui.text_handles.ellipsez = uicontrol('Style','Text',...
    'Parent',textEllipse,...
    'String','z-axis [-]',...
    'FontSize',myui.fontsize);

tstr = 'Set ellipsoid axes ratios';
gui.edit_handles.axesx = uicontrol('Style','Edit',...
    'Parent',setEllipse,...
    'String',sprintf('%4.3f',data.grains.axes(1)),...
    'Tag','grains_axesx',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','off',...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.grains.axes(1) 0 1]),...    
    'Callback',@onEditValue);
gui.edit_handles.axesy = uicontrol('Style','Edit',...
    'Parent',setEllipse,...
    'String',sprintf('%4.3f',data.grains.axes(2)),...
    'Tag','grains_axesy',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','off',...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.grains.axes(2) 0 1]),...    
    'Callback',@onEditValue);
gui.edit_handles.axesz = uicontrol('Style','Edit',...
    'Parent',setEllipse,...
    'String',sprintf('%4.3f',data.grains.axes(3)),...
    'Tag','grains_axesz',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','off',...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.grains.axes(3) 0 1]),...    
    'Callback',@onEditValue);
set(setEllipse,'Widths',[-1 -1 -1]);

%% ellipse settings - orient
gui.text_handles.ellipse1 = uicontrol('Style','Text',...
    'Parent',textOrient,...
    'String','polar angle [deg]',...
    'FontSize',myui.fontsize);
gui.text_handles.ellipse2 = uicontrol('Style','Text',...
    'Parent',textOrient,...
    'String','azimuthal angle [deg]',...
    'FontSize',myui.fontsize);

tstr = 'Set polar angle';
gui.edit_handles.orientp = uicontrol('Style','Edit',...
    'Parent',setOrient,...
    'String',sprintf('%4.3f',data.grains.orient(1)),...
    'Tag','grains_orientp',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','off');
tstr = 'Set azimuthal angle';
gui.edit_handles.orienta = uicontrol('Style','Edit',...
    'Parent',setOrient,...
    'String',sprintf('%4.3f',data.grains.orient(2)),...
    'Tag','grains_orienta',...
    'TooltipString',tstr,...
    'FontSize',myui.fontsize,...
    'Enable','off');
set(setOrient,'Widths',[-1 -1]);


% Java Hack to adjust the text fields vertical alignment
jh = findjobj(gui.text_handles.gsd);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.shape);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.ellipsex);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.ellipsey);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.ellipsez);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.ellipse1);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
jh = findjobj(gui.text_handles.ellipse2);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
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
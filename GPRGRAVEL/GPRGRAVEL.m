function GPRGRAVEL
%GPRGRAVEL is a graphical user interface (GUI) to create "grain packings"
%(spheres or ellipsoids) for 3D GPR simulations based on grain size
% distributions (GSDs)
%
% Syntax:
%       GPRGRAVEL
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       GPRGRAVEL
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

%% GUI 'header' info and default GUI settings
myui.version = '0.1.1';
myui.date = '05.09.2023';
myui.author = 'Thomas Hiller';

myui.fontsize = 8;
myui.axfontsize = 10;
myui.linewidth = 2;
myui.color.domain = [141 211 199]./255;
myui.color.grains = [251 128 114]./255;
myui.color.params = [128 177 211]./255;
% 255 255 179
% 190 186 218

%% Default data settings
data = GPRGRAVEL_loadDefaults;
tmp = mfilename('fullpath');
idcs   = strfind(tmp,filesep);
newdir = tmp(1:idcs(end-1)-1);
data.params.GPRGRAVELpath = newdir;

%% GUI initialization
gui.figh = figure('Name','GPRGRAVEL',...
    'NumberTitle','off','Tag','GPRGRAVEL','ToolBar','none','MenuBar','none',...
    'SizeChangedFcn',@onFigureSizeChange);

% position on screen
pos = GPRGRAVEL_setPositionOnScreen;
set(gui.figh,'Position',pos);

%% GUI data
gui.myui = myui;

% save the data struct within the GUI
setappdata(gui.figh,'data',data);
setappdata(gui.figh,'gui',gui);

%% Create GUI elements
GPRGRAVEL_createGUI(gui.figh,true);
% update status bar
updateStatusInformation(gui.figh);
% plot domain
plotDomaindata(gui.figh);

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

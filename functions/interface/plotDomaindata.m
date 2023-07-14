function plotDomaindata(fig)
%plotDomaindata plots all relevant domain data
%
% Syntax:
%       plotDomaindata(fig)
%
% Inputs:
%       fig - figure handle
%
% Outputs:
%       none
%
% Example:
%       plotDomaindata(fig)
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

% get GUI data
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');
grains = data.grains;
domain = data.domain;
params = data.params;

% get axes
ax = gui.axes_handles.domain;
clearSingleAxis(ax);
hold(ax,'on');

xmin = 0;
ymin = 0;
zmin = 0;
xmax = domain.xm;
ymax = domain.ym;
zmax = domain.zm;

if params.useTarget
    axes(ax);
    ix = params.targetIDX.*domain.dx;
    plot3(ix(:,1),ix(:,2),ix(:,3),'k.','Parent',ax);
end

% if the surface dips, take care of it
zBase = zmin+[(xmax-xmin)*tand(params.maskdipx(1)) ...
    (ymax-ymin)*tand(params.maskdipy(1))];

% planes parallel to x
xplane1 = [xmin ymin zBase(1)+zBase(2); xmax ymin zBase(2); xmax ymin zmax; xmin ymin zmax];
xplane2 = [xmin ymax zBase(1); xmax ymax zmin; xmax ymax zmax; xmin ymax zmax];
% planes parallel to y
yplane1 = [xmin ymin zBase(1)+zBase(2); xmin ymax zBase(1); xmin ymax zmax; xmin ymin zmax];
yplane2 = [xmax ymin zBase(2); xmax ymax zmin; xmax ymax zmax; xmax ymin zmax];
% planes parallel to z
zplane1 = [xmin ymin zBase(1)+zBase(2); xmax ymin zBase(2); xmax ymax zmin; xmin ymax zBase(1)];
zplane2 = [xmin ymin zmax; xmax ymin zmax; xmax ymax zmax; xmin ymax zmax];

% plot the planes
V = [xplane1;xplane2;yplane1;yplane2;zplane1;zplane2];
F = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16; 17 18 19 20; 21 22 23 24];
ph = patch('Faces',F,'Vertices',V,'Parent',ax);
ph.FaceAlpha = 0.5;
ph.FaceColor = gui.myui.color.domain;

% plot the center axes
plot3([xmin xmax],[(ymax-ymin)/2 (ymax-ymin)/2],[(zmax-zmin)/2 (zmax-zmin)/2],...
    'Color','r','Parent',ax);
plot3([(xmax-xmin)/2 (xmax-xmin)/2],[ymin ymax],[(zmax-zmin)/2 (zmax-zmin)/2],...
    'Color','g','Parent',ax);
plot3([(xmax-xmin)/2 (xmax-xmin)/2],[(ymax-ymin)/2 (ymax-ymin)/2],[zmin zmax],...
    'Color','b','Parent',ax);

if isfield(grains,'rmax')
    dx = grains.rmax;
else
    dx = 0.05;
end
set(ax,'XLim',[xmin-dx xmax+dx],'XTick',linspace(xmin,xmax,3),...
    'YLim',[ymin-dx ymax+dx],'YTick',linspace(ymin,ymax,3),......
    'ZLim',[zmin-dx zmax+dx],'ZTick',linspace(zmin,zmax,3));
set(ax,'XTickLabelMode','auto','YTickLabelMode','auto','ZTickLabelMode','auto');
set(ax,'ZDir','reverse');
set(get(ax,'XLabel'),'String','x [m]');
set(get(ax,'YLabel'),'String','y [m]');
set(get(ax,'ZLabel'),'String','z [m]');
set(ax,'FontSize',gui.myui.axfontsize);

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

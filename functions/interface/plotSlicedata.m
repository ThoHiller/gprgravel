function plotSlicedata(fig,tag,val)
%plotSlicedata plots the resulting gravel "packing" in the slice panel
%
% Syntax:
%       plotSlicedata(fig)
%
% Inputs:
%       fig - figure handle
%       tag - slice view
%       val - slice step
%
% Outputs:
%       none
%
% Example:
%       plotSlicedata(fig)
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

% get axes
ax = gui.axes_handles.Slice;
clearSingleAxis(ax);
hold(ax,'on');

% get final data
Lr = domain.final{1}.Lr;
% remove air
Lr(Lr==0) = NaN;
% remove target
Lr(Lr==9999) = NaN;

marg = domain.marg;

% prepare slices
szL = size(Lr);

x = 0:domain.dx:domain.xm;
y = 0:domain.dx:domain.ym;
z = 0:domain.dx:domain.zm;

mx = szL(1)-numel(x);
my = szL(2)-numel(y);
mz = szL(3)-numel(z);

xx = -(mx/2*domain.dx):domain.dx:domain.xm+(mx/2*domain.dx);
yy = -(my/2*domain.dx):domain.dx:domain.ym+(my/2*domain.dx);
if mod(mz,2)==0
    zz = -(mz/2*domain.dx):domain.dx:domain.zm+(mz/2*domain.dx);
else
    zz = -(floor(mz/2)*domain.dx):domain.dx:domain.zm+(ceil(mz/2)*domain.dx);
end

rmax = grains.rmax;
switch tag
    case 'XZ'
        [XX,YY] = meshgrid(xx,zz);
        S = squeeze(Lr(:,marg+val,:));
        xlims = [x(1)-rmax x(end)+rmax];
        xticks = linspace(x(1),x(end),3);
        ylims = [z(1)-rmax z(end)+rmax];
        yticks = linspace(z(1),z(end),3);
        xlabel = 'x [m]';
        ylabel = 'z [m]';
        ydir = 'reverse';
    case 'YZ'
        [XX,YY] = meshgrid(yy,zz);
        S = squeeze(Lr(marg+val,:,:));
        xlims = [y(1)-rmax y(end)+rmax];
        xticks = linspace(y(1),y(end),3);
        ylims = [z(1)-rmax z(end)+rmax];
        yticks = linspace(z(1),z(end),3);
        xlabel = 'y [m]';
        ylabel = 'z [m]';
        ydir = 'reverse';
    case 'XY'
        [XX,YY] = meshgrid(xx,yy);
        S = squeeze(Lr(:,:,marg+val));
        xlims = [x(1)-rmax x(end)+rmax];
        xticks = linspace(x(1),x(end),3);
        ylims = [y(1)-rmax y(end)+rmax];
        yticks = linspace(y(1),y(end),3);
        xlabel = 'x [m]';
        ylabel = 'y [m]';
        ydir = 'normal';
end

pcolor(XX,YY,S','Parent',ax);

% colors
cmap = flipud(copper(numel(grains.rbins)));
cmap = [cmap;0 0 1];
set(ax,'Colormap',cmap);
set(ax,'CLim',[1e-4  max(grains.rbins)*1.1]);
axis(ax,'equal');
shading(ax,'flat');
% axes settings
set(ax,'XLim',xlims,'XTick',xticks,'YLim',ylims,'YTick',yticks,'YDir',ydir);
set(get(ax,'XLabel'),'String',xlabel,'FontSize',gui.myui.axfontsize);
set(get(ax,'YLabel'),'String',ylabel,'FontSize',gui.myui.axfontsize);
set(get(ax,'Title'),'String',['slice: ',sprintf('%4.3f',(val-1)*domain.dx),'m'],...
    'FontSize',gui.myui.axfontsize);
set(ax,'FontSize',gui.myui.axfontsize);
hold(ax,'off');

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

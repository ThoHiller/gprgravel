function plotProfiledata(fig)
%plotProfiledata plots the resulting porosity profile(s) in the profile
%panel
%
% Syntax:
%       plotProfiledata(fig,tag)
%
% Inputs:
%       fig - figure handle
%
% Outputs:
%       none
%
% Example:
%       plotProfiledata(fig)
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
domain = data.domain;

% get axes
ax1 = gui.axes_handles.ProfileAir;
clearSingleAxis(ax1);
hold(ax1,'on');
ax2 = gui.axes_handles.ProfileH2O;
clearSingleAxis(ax2);
hold(ax2,'on');

%% porosity (only air voxel -> M=0)
M = domain.final{2}.M;
% flip upside down because 0 is at surface
M = flip(M,3);

sz = size(M);
% sum the corresponding air voxel in each dimension
px = 1-squeeze(sum(sum(M,2),3)/sz(2)/sz(3));
py = 1-squeeze(sum(sum(M,1),3)/sz(1)/sz(3));
pz = 1-squeeze(sum(sum(M,1),2)/sz(1)/sz(2));
% the distance vectors
x = 1:1:sz(1);
y = 1:1:sz(2);
z = 1:1:sz(3);
% plot data
plot(px,x./sz(1),'r','DisplayName','yz-slice','Parent',ax1);
plot(py,y./sz(2),'g','DisplayName','xz-slice','Parent',ax1);
plot(pz,z./sz(3),'b','DisplayName','xy-slice','Parent',ax1);

% add a line for each mean value
plot([mean(px) mean(px)],[0 1],'r.','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax1);
plot([mean(py) mean(py)],[0 1],'g:','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax1);
plot([mean(pz) mean(pz)],[0 1],'b--','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax1);

% set axis properties
set(ax1,'XLim',[0 max([px(:);py(:);pz(:)])]*1.1,'XTickMode','auto',...
    'XTickLabelMode','auto');
set(ax1,'YLim',[0 1],'YTick',0:0.2:1,...
    'YTickLabel',{'0 (bot)','0.2','0.4','0.6','0.8','1 (top)'});
set(get(ax1,'XLabel'),'String','air volume [-]');
set(get(ax1,'YLabel'),'String','normalized domain dimension');
set(get(ax1,'Title'),'String',['mean \Phi=',sprintf('%6.4f',mean(px))]);
set(ax1,'FontSize',gui.myui.axfontsize);
hold(ax1,'off');
legend(ax1,'Location','best');

%% porosity (only water voxel -> Lr=99)
M = zeros(size(domain.final{2}.Lr));
% flip upside down because 0 is at surface
M(domain.final{2}.Lr==99) = 1;
M = flip(M,3);
sz = size(M);
% sum the corresponding water voxel in each dimension
px = squeeze(sum(sum(M,2),3)/sz(2)/sz(3));
py = squeeze(sum(sum(M,1),3)/sz(1)/sz(3));
pz = squeeze(sum(sum(M,1),2)/sz(1)/sz(2));
% the distance vectors
x = 1:1:sz(1);
y = 1:1:sz(2);
z = 1:1:sz(3);

% get maximum water content for axis limits
max_w = max([px(:);py(:);pz(:)]);
if max_w == 0
    xlims = [-1 1];
else
    xlims = [0 max_w*1.1];
end

% plot data
plot(px,x./sz(1),'r','DisplayName','yz-slice','Parent',ax2);
plot(py,y./sz(2),'g','DisplayName','xz-slice','Parent',ax2);
plot(pz,z./sz(3),'b','DisplayName','xy-slice','Parent',ax2);

% add a line for each mean value
plot([mean(px) mean(px)],[0 1],'r.','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax2);
plot([mean(py) mean(py)],[0 1],'g:','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax2);
plot([mean(pz) mean(pz)],[0 1],'b--','HandleVisibility','off',...
    'Tag','MarkerLines','Parent',ax2);

% set axis properties
set(ax2,'XLim',xlims,'XTickMode','auto','XTickLabelMode','auto');
set(ax2,'YLim',[0 1],'YTick',0:0.2:1,...
    'YTickLabel',{'0 (bot)','0.2','0.4','0.6','0.8','1 (top)'});
set(get(ax2,'XLabel'),'String','water volume [-]');
set(get(ax2,'Title'),'String',['mean \Theta=',sprintf('%6.4f',mean(px))]);
set(ax2,'FontSize',gui.myui.axfontsize);
hold(ax2,'off');

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

function plotMatrixdata(fig,type)
%plotMatrixdata plots the Matrix data
%
% Syntax:
%       plotMatrixdata(fig,type)
%
% Inputs:
%       fig - figure handle
%       type - string ('input' or 'output')
%
% Outputs:
%       none
%
% Example:
%       plotMatrixdata(fig,'input')
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

switch type
    case {'monitor','result'}
        % get axis
        ax = gui.axes_handles.Volume;
        clearSingleAxis(ax);
        hold(ax,'on');

        % get monitor data
        monitor = data.monitor;
        Lr = monitor.Lr;
        Lr(Lr==0) = NaN;
        Lr(Lr==9999) = NaN;

        % prepare slices
        szL = size(Lr);
        
        % real coordinates
        x = 0:domain.dx:domain.xm;
        y = 0:domain.dx:domain.ym;
        z = 0:domain.dx:domain.zm;

        % how many margin voxel
        mx = szL(1)-numel(x);
        my = szL(2)-numel(y);
        mz = szL(3)-numel(z);
        
        % coordinates without margin
        xx = -(mx/2*domain.dx):domain.dx:domain.xm+(mx/2*domain.dx);
        yy = -(my/2*domain.dx):domain.dx:domain.ym+(my/2*domain.dx);
        if mod(mz,2)==0
            zz = -(mz/2*domain.dx):domain.dx:domain.zm+(mz/2*domain.dx);
        else
            zz = -(floor(mz/2)*domain.dx):domain.dx:domain.zm+(ceil(mz/2)*domain.dx);
        end

        % get the 3D grid coordinates
        [XXX,YYY,ZZZ] = meshgrid(xx,yy,zz);
        
        % define the center slices
        xslice = xx(ceil(numel(xx)/2));
        yslice = yy(ceil(numel(yy)/2));
        zslice = zz(ceil(numel(zz)/2));
        
        % swap xy dimensions
        Lr = permute(Lr,[2 1 3]);
        % plot the slices
        try
            slice(XXX,YYY,ZZZ,Lr,xslice,yslice,zslice,'Parent',ax);
        catch
            disp('plotMatrixdata: No data yet to plot on slice(s).')
        end        

        % colors
        cmap = flipud(copper(numel(grains.rbins)));
        cmap = [cmap;0 0 1];
        set(ax,'Colormap',cmap);
        set(ax,'CLim',[1e-4  max(grains.rbins)*1.1],'ColorScale','lin');

        % axis properties
        rmax = grains.rmax;
        axis(ax,'equal');
        shading(ax,'flat');
        set(ax,'XLim',[x(1)-rmax x(end)+rmax],'XTick',linspace(x(1),x(end),3),...
            'YLim',[y(1)-rmax y(end)+rmax],'YTick',linspace(y(1),y(end),3),...
            'ZLim',[z(1)-rmax z(end)+rmax],'ZTick',linspace(z(1),z(end),3));
        set(get(ax,'XLabel'),'String','x [m]');
        set(get(ax,'YLabel'),'String','y [m]');
        set(get(ax,'ZLabel'),'String','z [m]');
        set(ax,'ZDir','reverse');
        set(ax,'FontSize',gui.myui.axfontsize);
        hold(ax,'off');

        % colorbar
        cbh = colorbar(ax,'Location','EastOutside');
        vec = [1e-4 0.005 0.01 0.015 0.02 0.025 0.03 0.035 0.04 0.045 0.5];
        vec = vec(vec<max(grains.rbins));
        vecstr = cell(1,1);
        for i1 = 1:numel(vec)
            vecstr{i1} = sprintf('%4.3f',vec(i1));
        end
        vecstr{1} = 'r [m]';
        vecstr{end+1} = 'water';
        set(cbh,'Ticks',[vec max(grains.rbins)*1.1],'TickLabels',vecstr); 

    otherwise
        % nothing to do        
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

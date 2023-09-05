function onMenuViewFigure(src,~)
%onMenuViewFigure shows predefined figure layouts
%
% Syntax:
%       onMenuViewFigure(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuViewFigure(src)
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

% get GUI handle
fig = ancestor(src,'figure','toplevel');

if ~isempty(fig) && strcmp(get(fig,'Tag'),'GPRGRAVEL')
    % get GUI data
    gui = getappdata(fig,'gui');
    data = getappdata(fig,'data');
    grains = data.grains;
    domain = data.domain;
    params = data.params;

    % get GUI position
    posf = get(fig,'Position');
    % opening the export figure
    %     expfig = figure;

    % create the axes layout on the export figure and get the axes
    % positions
    switch get(src,'Label')
        case 'Volume'
            expfig = findobj('Tag','GPRGRAVELvolume');
            if isempty(expfig)
                expfig = figure('Name','GPRGRAVEL: Volume',...
                    'NumberTitle','off','Tag','GPRGRAVELvolume');
                set(expfig,'Position',[600 300 800 700]);
            else
                clf(expfig);
            end
            ax = axes('Parent',expfig);
            
            % get final data
            Lr = data.domain.final{2}.Lr;
            % remove grains smaller
            threshR = 1e-3;
            Lr(Lr<threshR) = NaN;
            % remove water
            threshW = 99;
            Lr(Lr==threshW) = NaN;
            % remove target
            threshT = 9999;
            Lr(Lr==threshT) = NaN;

            % prepare slices
            szL = size(Lr);

            xticks = linspace(0,szL(1),5);
            xtickL = cell(size(xticks));
            for i = 1:numel(xticks)
                xtickL{i} = sprintf('%3.2f',(xticks(i))*domain.dx);
            end
            yticks = linspace(0,szL(2),5);
            ytickL = cell(size(yticks));
            for i = 1:numel(yticks)
                ytickL{i} = sprintf('%3.2f',(yticks(i))*domain.dx);
            end
            zticks = linspace(0,szL(3),5);
            ztickL = cell(size(zticks));
            for i = 1:numel(zticks)
                ztickL{i} = sprintf('%3.2f',(zticks(i))*domain.dx);
            end
            
            % plot the voxel volume
            % if there is a target only show half of the domain
            if params.useTarget
                cut = [1 size(Lr,1)...
                    1 params.targetCenter(2)/domain.dx ...
                    1 size(Lr,3)];
            else
                cut = [1 size(Lr,1) 1 size(Lr,2) 1 size(Lr,3)];
            end
            Lr = Lr(cut(1):cut(2),cut(3):cut(4),cut(5):cut(6));

            % swap xy dimension
            Lr = permute(Lr,[2 1 3]);
            box = [1 size(Lr,1) 1 size(Lr,2) 1 size(Lr,3)];
            axes(ax);
            voxelSurf(Lr,false,box,1);
            hold(ax,'on');

            % colors
            cmap = flipud(copper(numel(grains.rbins)));
            cmap = [cmap;0 0 1];
            set(expfig,'Colormap',cmap);
            set(ax,'CLim',[1e-4  max(grains.rbins)*1.1]);

            % colorbar
            cbh = colorbar(ax,'Location','EastOutside');
            vec = [1e-4 0.005 0.01 0.015 0.02 0.025 0.03 0.035 0.04 0.045 0.5];
            vec = vec(vec<max(grains.rbins));
            vecstr = cell(1,1);
            for i1 = 1:numel(vec)
                vecstr{i1} = sprintf('%d',round(1e3*vec(i1)));
            end
            vecstr{1} = 'r [mm]';
            vecstr{end+1} = 'water';
            set(cbh,'Ticks',[vec max(grains.rbins)*1.1],...
                'TickLabels',vecstr,'FontSize',gui.myui.axfontsize);
            
            % add the domain planes
            % in voxel units
            xmin = 0;
            ymin = 0;
            zmin = 0;
            xmax = xmin+domain.xm/domain.dx;
            ymax = ymin+domain.ym/domain.dx;
            zmax = zmin+domain.zm/domain.dx;

            % if the surface dips, take care of it
            zBase = zmin+[(xmax-xmin)*tand(params.maskdipx(1)) ...
                (ymax-ymin)*tand(params.maskdipy(1))];

            % planes parallel to x
            xplane1 = [xmin ymin (zBase(1)+zBase(2)); xmax ymin zBase(2); xmax ymin zmax; xmin ymin zmax];
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
            ph.FaceAlpha = 0;
            ph.EdgeColor = gui.myui.color.domain;
            ph.LineWidth = gui.myui.linewidth;

            if params.useTarget
                patch('Vertices',params.targetSurf.vertices./domain.dx,'Faces',params.targetSurf.faces,...
                    'FaceColor',[0.5 0.5 0.5],'FaceAlpha',1,'EdgeColor','none','Parent',ax);
            end

            set(get(ax,'Title'),'String',...
                sprintf('only grains larger than radius: %d mm are shown', 1e3*threshR));
            set(ax,'XTick',xticks,'XTickLabel',xtickL,'XLim',[-domain.marg domain.nx0+domain.marg],...
                'YTick',yticks,'YTickLabel',ytickL,'YLim',[-domain.marg domain.ny0+domain.marg],...
                'ZTick',zticks,'ZTickLabel',ztickL,'ZLim',[-domain.marg domain.nz0+domain.marg]);
            set(get(ax,'XLabel'),'String','x [m]');
            set(get(ax,'YLabel'),'String','y [m]');
            set(get(ax,'ZLabel'),'String','z [m]');
            set(ax,'ZDir','reverse');
            set(ax,'FontSize',gui.myui.axfontsize);
            hold(ax,'off');
            view(ax,[148 30]);

        case 'Voxelised Grains'
            expfig = findobj('Tag','GPRGRAVELvoxelgrains');
            if isempty(expfig)
                expfig = figure('Name','GPRGRAVEL: voxelised grains',...
                    'NumberTitle','off','Tag','GPRGRAVELvoxelgrains');
                set(expfig,'Position',[600 300 800 700]);
            else
                clf(expfig);
            end

            R = grains.rbins;
            R2 = ceil(R/domain.dx);
            D2 = 2*R2;

            axn = sqrt(numel(grains.rbins));
            if mod(numel(grains.rbins),axn)~=0
                axn = ceil(axn);
            end

            for i = 1:numel(grains.rbins)
                % global counter
                % current grain radius in [m]
                r = grains.rbins(i);

                a = grains.axes(1);
                b = grains.axes(2);
                c = grains.axes(3);

                M = zeros(D2(i)+2,D2(i)+2,D2(i)+2);

                sphere = getSubBodyCoords(grains.shape,[a b c],r,domain.dx);

                center(1) = floor(size(M,1)/2);
                center(2) = floor(size(M,2)/2);
                center(3) = floor(size(M,3)/2);

                spnew = sphere + [center(1)*ones(length(sphere),1) ...
                    center(2)*ones(length(sphere),1) ....
                    center(3)*ones(length(sphere),1)];

                % get indices of the current sphere into M
                index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));

                M(index) = r;

                figure(101);clf;
                [~,TT,X,Y,Z,CC,~] = voxelSurf(M,false,[1 size(M,1) 1 size(M,2) 1 size(M,3)],1);

                % code copied from voxelSurf.m:
                ax = subplot(axn,axn,i,'Parent',expfig);
                trisurf(TT,X,Y,Z,CC,'EdgeColor','none','FaceAlpha',1,'Parent',ax);

                aa = [1 size(M,1) 1 size(M,2) 1 size(M,3)];
                material(ax,[0.2 0.7 0.3])
                daspect(ax,[1 1 1]);
                pbaspect(ax,[1 1 1]);
                % camproj(ax,'perspective')
                % replot light sources
                % delete(findall(gcf,'Type','light'))
                light(ax,'Position',[(aa(2)-aa(1))/2     (aa(4)-aa(3))/2       aa(5)-(aa(6)-aa(5))],'Style','local')
                light(ax,'Position',[(aa(2)-aa(1))/2     (aa(4)-aa(3))/2       aa(6)+(aa(6)-aa(5))],'Style','local')
                light(ax,'Position',[(aa(2)-aa(1))/2      aa(3)-(aa(4)-aa(3)) (aa(6)-aa(5))/2   ],'Style','local')
                light(ax,'Position',[(aa(2)-aa(1))/2      aa(4)+(aa(4)-aa(3)) (aa(6)-aa(5))/2   ],'Style','local')
                light(ax,'Position',[aa(1)-(aa(2)-aa(1)) (aa(4)-aa(3))/2      (aa(6)-aa(5))/2   ],'Style','local')
                light(ax,'Position',[aa(2)+(aa(2)-aa(1)) (aa(4)-aa(3))/2      (aa(6)-aa(5))/2   ],'Style','local')

                axis(ax,[0.5 size(M,1)+0.5 0.5 size(M,2)+0.5 0.5 size(M,3)+0.5]);

                cmap = flipud(copper(numel(grains.rbins)));
                set(gcf,'Colormap',cmap);
                set(ax,'CLim',[min(grains.rbins) max(grains.rbins)]);
                set(get(ax,'Title'),'String',['r: ',sprintf('%d',round(1e3*r)),'mm']);
                %   set(get(ax,'Title'),'String',['d: ',sprintf('%d',round(2e3*r)),'mm']);
                set(ax,'XColor','none','YColor','none','ZColor','none');
                view(ax,[-60 10]);

            end
            set(expfig,'Colormap',cmap);
            delete(101);
    end

    % adjust the position of the export figure
    set(expfig,'Position',[posf(1)+300 posf(2) (posf(3)-300)*0.8 posf(4)*0.8]);

    % show legends
    switch get(src,'Label')

    end
else
    warndlg({'onMenuViewFigure:','There is no figure with the GPRGRAVEL Tag open.'},...
        'GPRGRAVEL error');
end

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

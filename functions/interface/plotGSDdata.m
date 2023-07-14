function plotGSDdata(fig,type)
%plotGSDdata plots the GSD data
%
% Syntax:
%       plotGSDdata(fig,type)
%
% Inputs:
%       fig - figure handle
%       type - string ('input' or 'output')
%
% Outputs:
%       none
%
% Example:
%       plotGSDdata(fig,'input')
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

    case 'input'

        ax = gui.axes_handles.histIn;
        clearSingleAxis(ax);
        hold(ax,'on');

        if grains.ishistogram
            plot(grains.hist_raw(:,1),grains.hist_raw(:,2),'Color',gui.myui.color.grains,'Parent',ax);
        else
            % create tmporary bins for plotting
            %             dbins = domain.dx:domain.dx:grains.rmax*2;
            dbins = logspace(-5,0,50);
            % radius binning vector
            rbins = dbins/2;
            % --- account for new Matlab behaviour of histogram vs hist
            d = diff(dbins)/2;
            edges = [dbins(1)-d(1), dbins(1:end-1)+d, dbins(end)+d(end)];
            edges(2:end) = edges(2:end)+eps(edges(2:end));
            N = histcounts(grains.dia_raw,edges,'Normalization','cdf');
            plot(rbins,N,'Color',gui.myui.color.grains,'Parent',ax);
        end

        if isfield(grains,'rbins')
            line(grains.rbins,cumsum(grains.nvoxBins)/sum(grains.nvoxBins),...
                'marker','+','Color','k','LineStyle','none','Parent',ax);
        end

        % plot a line at rmax
        plot([grains.rmax grains.rmax],[0 1],'k--','Parent',ax);
        text(grains.rmax*2,0.35,['r_{max}=',sprintf('%4.3f',grains.rmax),'m'],'Rotation',90,'FontSize',12,...
            'FontWeight','demi','Parent',ax);

        % axes settings
        set(ax,'XLim',[5e-6 1],'XTick',logspace(-5,0,6),'XScale','log');
        %         set(ax,'XLim',[0 grains.rmax],'XTick',linspace(0,grains.rmax,6),'XScale','lin');
        set(get(ax,'XLabel'),'String','Radius [m]');
        set(get(ax,'YLabel'),'String','CDF [-]');
        set(ax,'FontSize',gui.myui.axfontsize);
        hold(ax,'off');

    case 'monitor'
        % get axes
        ax = gui.axes_handles.histOut;
        clearSingleAxis(ax);
        hold(ax,'on');

        % get monitor data
        monitor = data.monitor;

        plot(monitor.voxHist(1,:),cumsum(grains.nvoxBins)./domain.VOL0matrix,...
            'Color',gui.myui.color.grains,'Parent',ax);
        plot(monitor.voxHist(1,:),(domain.VOL0matrix-monitor.voxHist(2,:))./domain.VOL0matrix,...
            'Marker','+','Color','k','LineStyle','none','Parent',ax);        

        % axes settings
        set(ax,'XLim',[5e-6 1],'XTick',logspace(-5,0,6),'XScale','log');
        %  set(ax,'XLim',[0 grains.rmax],'XTick',linspace(0,grains.rmax,6),'XScale','lin');
        set(get(ax,'XLabel'),'String','Radius [m]');
        set(get(ax,'YLabel'),'String','CDF [-]');
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

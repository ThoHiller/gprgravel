function clearSingleAxis(axh)
%clearSingleAxis clears an individual axis
%
% Syntax:
%       clearSingleAxis(axh)
%
% Inputs:
%       axh - axis handle
%
% Outputs:
%       none
%
% Example:
%       clearSingleAxis(gca)
%
% Other m-files required:
%       clearSingleAxis
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
fig = ancestor(axh,'figure','toplevel');

if ~isempty(fig) && strcmp(get(fig,'Tag'),'GPRGRAVEL')
    % get GUI data
    gui = getappdata(fig,'gui');
    
    % get the parent of the axis and find possible legends
    parent = get(axh,'Parent');
    lgh = findobj('Type','legend','Parent',parent);
    if ~isempty(lgh)
        delete(lgh);
    end
    
    % look for specific tags and clear corresponding objects
    ph = findall(axh,'Tag','MarkerLines');
    if ~isempty(ph); set(ph,'HandleVisibility','on'); end
    
    % clear the axis labels
    xlabel(axh,'');
    ylabel(axh,'');
    zlabel(axh,'');
    title(axh,' ');
    
    % reset axis limits and scale
    grid(axh,'off');
    set(axh,'XLim',[0 1],'YLim',[0 1],'ZLim',[0 1]);
    set(axh,'XTickMode','auto','XTickLabelMode','auto');
    set(axh,'YTickMode','auto','YTickLabelMode','auto');
    set(axh,'ZTickMode','auto','ZTickLabelMode','auto');
    set(axh,'XScale','lin','YScale','lin','ZScale','lin');
    set(axh,'FontSize',gui.myui.axfontsize);
    
    % clear the axis itself
    cla(axh);
    
else
    warndlg({'clearSingleAxis:','There is no figure with the GPRGRAVEL Tag open.'},...
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

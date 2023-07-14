function onFigureSizeChange(fig,~)
%onFigureSizeChange fixes an ugly Matlab bug when resizing a box-panel
%which holds an axis and a legend. This problem occurs even though the
%axis is inside a uicontainer to group all axes elements. And it only
%occurs for box-panels. If the uicontainer, which holds axis and legend, 
%is inside a tab-panel this problem does not occur. They had one job ... m(
%
% Syntax:
%       onFigureSizeChange(fig,~)
%
% Inputs:
%       fig - handle of the calling figure
%
% Outputs:
%       none
%
% Example:
%       onFigureSizeChange(h)
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

%% get GUI data
gui = getappdata(fig,'gui');

% proceed if there is data
if ~isempty(gui)
    if isfield(gui,'panels')
        heights = get(gui.panels.main,'Heights');
        set(gui.left,'Heights',-1,'MinimumHeights',sum(heights)+1);
    end
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

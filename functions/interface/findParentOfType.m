function ph = findParentOfType(h,type)
%findParentOfType is a "hack" because Matlab changed the parent-child
%hierarchy for some graphical objects
%2018: the minimize checkbox is a child of the uix.BoxPanel
%2014: the minimize checkbox is a child of a uicontainer -> child of a HBox ->
%child of a the BoxPanel
%
% Syntax:
%       ph = findParentOfType(h,type)
%
% Inputs:
%       h - handle
%       type - type to look for
%
% Outputs:
%       ph - handle of parent object
%
% Example:
%       ph = findParentOfType(h,type)
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

lookingfor = true;
child = h;
while lookingfor
    parent = get(child,'Parent');
    if isa(parent,type) % the parent uix.BoxPanel was found
        lookingfor = false;
        ph = parent;
    elseif isempty(parent) % nothing was found
        ph = [];
        disp('findParentOfType: No parent of specified type found.');
        break;
    else % set the current parent to child and continue
        child = parent;
    end
end

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

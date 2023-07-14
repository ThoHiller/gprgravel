function onRadioSurface(src,~)
%onRadioSurface activates/deactivates open surface
%
% Syntax:
%       onRadioSurface
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioSurface(src,~)
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

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% on/off
val = get(src,'Value');

switch val
    case 0 % off
        data.params.closeSurface = false;
        data.params.closeSurfaceR = 1;
        set(gui.edit_handles.closeSurfaceR,'Enable','off');
        set(gui.edit_handles.closeSurfaceR,'String',sprintf('%4.3f',data.params.closeSurfaceR));

    case 1 % on
        data.params.closeSurface = true;
        set(gui.edit_handles.closeSurfaceR,'Enable','on');
        if isfield(data.grains,'rmax')
            data.params.closeSurfaceR = data.grains.rmax;
        end
        set(gui.edit_handles.closeSurfaceR,'Enable','on');
        set(gui.edit_handles.closeSurfaceR,'String',sprintf('%4.3f',data.params.closeSurfaceR));
end

% update GUI data
setappdata(fig,'data',data);
% update status
updateStatusInformation(fig);

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
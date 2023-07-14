function  showLogInfo(str,isgui,gui)
%showLogInfo plots the info either to the GUI or to the commandline
%
% Syntax:
%       showLogInfo(str,isgui,gui)
%
% Inputs:
%       str - info str
%       isgui - bool (true | false)
%       gui - gui handle
%
% Outputs:
%       none
%
% Example:
%       showLogInfo(str,isgui,gui)
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

if isgui
    set(gui.listbox_handles.info,'String', str);
    set(gui.listbox_handles.info,'Value',size(get(gui.listbox_handles.info,'String'),1))
else
    disp(str);
end
pause(0.001);

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
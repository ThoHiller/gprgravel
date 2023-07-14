function onRadioSatProfile(src,~)
%onRadioSatProfile activates/deactivates saturation profile option
%
% Syntax:
%       onRadioSatProfile
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioSatProfile(src,~)
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
        data.params.useSatProfile = false;
        set(gui.popup_handles.SatProfileType,'Enable','off');

        data.params.satBounds = [0 1];
        set(gui.edit_handles.SatProfileTop,'Enable','off',...
            'String',sprintf('%d',data.params.satBounds(1)));
        set(gui.edit_handles.SatProfileBottom,'Enable','off',...
            'String',sprintf('%d',data.params.satBounds(2)));

    case 1 % on
        data.params.useSatProfile = true;
        set(gui.popup_handles.SatProfileType,'Enable','on');

        set(gui.edit_handles.SatProfileTop,'Enable','on',...
            'String',sprintf('%d',data.params.satBounds(1)));
        set(gui.edit_handles.SatProfileBottom,'Enable','on',...
            'String',sprintf('%d',data.params.satBounds(2)));
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
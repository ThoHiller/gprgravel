function onRadioFixRNG(src,~)
%onRadioFixRNG activates/deactivates random seed value input
%
% Syntax:
%       onRadioFixRNG
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioFixRNG(src,~)
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
        data.params.use_customRNG = false;
        data.params.customRNGSEED = data.init.params.customRNGSEED;
        set(gui.edit_handles.customRNG,'String',sprintf('%d',data.params.customRNGSEED));
        set(gui.edit_handles.customRNG,'Enable','off');

    case 1 % on
        data.params.use_customRNG = true;
        set(gui.edit_handles.customRNG,'String',sprintf('%d',data.params.customRNGSEED));
        set(gui.edit_handles.customRNG,'Enable','on');        
end

% update GUI data
setappdata(fig,'data',data);
% update status
% updateStatusInformation(fig);

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
function onRadioExport(src,~)
%onRadioExport activates/deactivates different export options
%
% Syntax:
%       onRadioExport
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioExport(src,~)
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
% tag
tag = get(src,'Tag');

switch tag
    case 'PML'
        switch val
            case 0 % off
                data.params.exportPML = false;
                set(gui.edit_handles.PMLx,'Enable','off');
                set(gui.edit_handles.PMLy,'Enable','off');
                set(gui.edit_handles.PMLz,'Enable','off');
            case 1 % on
                data.params.exportPML = true;
                set(gui.edit_handles.PMLx,'Enable','on');
                set(gui.edit_handles.PMLy,'Enable','on');
                set(gui.edit_handles.PMLz,'Enable','on');
        end
    case 'HDF5'
        switch val
            case 0 % off
                data.params.exportH5 = false;
                % switch off PML
                set(gui.radio_handles.ExportPML,'Value',0);
                setappdata(fig,'gui',gui);
                onRadioExport(gui.radio_handles.ExportPML);
                set(gui.radio_handles.ExportPML,'Enable','off');
            case 1 % on
                data.params.exportH5 = true;
                set(gui.radio_handles.ExportPML,'Value',1);
                % switch on PML
                set(gui.radio_handles.ExportPML,'Enable','on');
                set(gui.radio_handles.ExportPML,'Value',1);
                setappdata(fig,'gui',gui);
                onRadioExport(gui.radio_handles.ExportPML);
        end
    case 'MAT'
        switch val
            case 0 % off
                data.params.exportMAT = false;
            case 1 % on
                data.params.exportMAT = true;
        end
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
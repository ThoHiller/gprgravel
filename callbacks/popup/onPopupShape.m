function onPopupShape(src,~)
%onPopupShape switches the grain shape between "sphere" and "ellipse"
%
% Syntax:
%       onPopupShape(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupShape(src)
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
    
    % get the popup menu entry
    val = get(src,'Value');
    
    % set the corresponding nucleus
    switch val
        case 1
            data.grains.shape = 'sphere';
            set(gui.edit_handles.axesx,'Enable','off');
            set(gui.edit_handles.axesy,'Enable','off');
            set(gui.edit_handles.axesz,'Enable','off');
            set(gui.edit_handles.orientp,'Enable','off');
            set(gui.edit_handles.orienta,'Enable','off');            
        case 2
            data.grains.shape = 'ellipse';
            set(gui.edit_handles.axesx,'Enable','on');
            set(gui.edit_handles.axesy,'Enable','on');
            set(gui.edit_handles.axesz,'Enable','on');
            set(gui.edit_handles.orientp,'Enable','on');
            set(gui.edit_handles.orienta,'Enable','on');
    end
    
    % update the GUI data
    setappdata(fig,'data',data);

else
    warndlg({'onPopupShape:','There is no figure with the GPRGRAVEL Tag open.'},...
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

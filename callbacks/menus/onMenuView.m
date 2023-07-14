function onMenuView(src,~)
%onMenuView handles the extra menu entries
%
% Syntax:
%       onMenuView(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuView(src,~)
%
% Other m-files required:
%       switchToolTips
%       updateStatusInformation
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
    
    switch get(src,'Label')
        case 'Tooltips' % switch on/off Tooltips      
            switch get(src,'Checked')
                case 'on' % if it is on, switch it off
%                     switchToolTips(gui,'off');
                    set(src,'Checked','off');
                    data.info.ToolTips = 0;
                case 'off'
%                     switchToolTips(gui,'on');
                    set(src,'Checked','on');
                    data.info.ToolTips = 1;
            end
            
        case 'Figure Toolbar' % switch on/off the default Figure Toolbar
            switch get(src,'Checked')
                case 'on' % if it is on, switch it off
                    set(src,'Checked','off');
                    viewmenufcn('FigureToolbar');
                case 'off'
                    set(src,'Checked','on');
                    viewmenufcn('FigureToolbar');
            end
    end
    
    % update GUI data
    setappdata(fig,'gui',gui);
    setappdata(fig,'data',data);
    % update status bar
%     updateStatusInformation(fig);
    
else
    warndlg({'onMenuView:','There is no figure with the GPRGRAVEL Tag open.'},...
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

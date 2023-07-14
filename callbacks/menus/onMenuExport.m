function onMenuExport(src,~)
%onMenuExport handles the extra menu entries
%
% Syntax:
%       onMenuExport(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExport(src)
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
%     gui = getappdata(fig,'gui');
%     data = getappdata(fig,'data');
%     
%     % gather the output data to save
%     savedata.data = data;
%     savedata.myui = gui.myui;
    
%     % session file name
%     sfilename = 'GPRGRAVEL';
%     
%     % ask for folder and maybe new name
%     [sfile,spath] = uiputfile('*.mat',...
%         'Save session file',...
%         fullfile(pwd,[sfilename,'.mat']));
%     
%     % if user didn't cancel save session
%     if sum([sfile spath]) > 0
%         save(fullfile(spath,sfile),'savedata');
%         clear savedata;
%         % display info text
%         set(gui.text_handles.Status,'String','GPRGRAVEL session successfully saved.');
%     else
%         % display info text
%         set(gui.text_handles.Status,'String','GPRGRAVEL session not saved');
%     end
    
else
    warndlg({'onMenuExport:','There is no figure with the GPRGRAVEL Tag open.'},...
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

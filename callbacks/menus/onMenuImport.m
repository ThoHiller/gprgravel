function onMenuImport(src,~)
%onMenuImport handles the extra menu entries
%
% Syntax:
%       onMenuImport(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuImport(src)
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
%     % after the import these values should be strings
%     Sessionpath = -1;
%     Sessionfile = -1;
%     % 'pathstr' hold s the name of the chosen data path
%     [pathstr,~,~] = fileparts(pwd);
%     % get the file name
%     [Sessionfile,Sessionpath] = uigetfile(pathstr,...
%         'Choose GPRGRAVEL session file');
%     
%     % only continue if user didn't cancel
%     if sum(Sessionpath) > 0
%         % check if it is a valid session file
%         tmp = load(fullfile(Sessionpath,Sessionfile),'savedata');
%         if isfield(tmp,'savedata') && isfield(tmp.savedata,'data') && ...
%                 isfield(tmp.savedata,'isPulse') && isfield(tmp.savedata,'isPrePol')
%             savedata = tmp.savedata;
%             
%             % plot results (if any)
%             if isfield(savedata.data,'results')
%                 plotResults(fig);
%             end
%             
%         else
%             helpdlg({'onMenuImport:';...
%                 'This seems to be not a valid GPRGRAVEL session file'},...
%                 'No session data found');
%         end        
%     end
    
else
    warndlg({'onMenuImport:','There is no figure with the GPRGRAVEL Tag open.'},...
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

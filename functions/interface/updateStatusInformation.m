function updateStatusInformation(fig)
%updateStatusInformation updates all fields inside the bottom status bar
%
% Syntax:
%       updateStatusInformation(fig)
%
% Inputs:
%       fig - figure handle
%
% Outputs:
%       none
%
% Example:
%       updateStatusInformation(fig)
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

% get GUI data
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

set(gui.text_handles.TimerStat,'String',['Calc. Time: ',sprintf('%5.3f',data.info.Timer),'s']);

switch get(gui.radio_handles.closedSurface,'Value')
    case 1
        set(gui.text_handles.Surface,'String','SURFACE: CLOSED');
    case 0
        set(gui.text_handles.Surface,'String','SURFACE: OPEN');
end

if data.params.useTarget
    set(gui.text_handles.Targets,'String','TARGETS: ON');
else
    set(gui.text_handles.Targets,'String','TARGETS: OFF');
end

if data.params.useSatProfile
    str = get(gui.popup_handles.SatProfileType,'String');
    val = get(gui.popup_handles.SatProfileType,'Value');
    set(gui.text_handles.SatProf,'String',['SATURATION Profile: ',str{val}(1:3)]);
else
    set(gui.text_handles.SatProf,'String','SATURATION Profile: OFF');
end

% switch data.info.ToolTips
%     case 1
%         set(gui.text_handles.TooltipsStat,'String','Tooltips: ON');
%     case 0
%         set(gui.text_handles.TooltipsStat,'String','Tooltips: OFF');
% end

set(gui.text_handles.VersionStat,'String',['Version: ',gui.myui.version]);

% Matlab takes some time
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

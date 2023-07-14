function pos = GPRGRAVEL_setPositionOnScreen
%GPRGRAVEL_setPositionOnScreen sets GUI position depending on monitor size
%
% Syntax:
%       GPRGRAVEL_setPositionOnScreen
%
% Inputs:
%       none
%
% Outputs:
%       pos - four element vector [x y w h]
%
% Example:
%       GPRGRAVEL_setPositionOnScreen
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

% get the monitor layout
scr = get(0,'MonitorPosition');
if size(scr,1) > 1 % dual monitor setup
    ind = find(scr(:,1)==1 & scr(:,2)==1);
    sw = scr(ind,3); % width
    sh = scr(ind,4); % height
else % single monitor
    sw = scr(3); % width
    sh = scr(4); % height
end
% maximal initial GUI width
gw = 1024;
% adjust the GUI width if the screen is not wide enough
if sw < 1024
    gw = 2*sw/3;
end
% GUI height
gh = gw/1.45;

if numel(scr) > 4 % dual monitor position
    % GUI on second screen
    if any(scr(:,1)<0)
        pos = [-sw+(sw-gw)/2 (sh-gh)/2 gw gh];
    else
        pos = [sw+(sw-gw)/2 (sh-gh)/2 gw gh];
    end
else % single monitor position
    pos = [(sw-gw)/2 (sh-gh)/2 gw gh];
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

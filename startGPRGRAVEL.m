function startGPRGRAVEL
%startGPRGRAVEL is the start script that prepares the Matlab path and
%starts the GPRGRAVEL GUI
%
% Syntax:
%       startGPRGRAVEL
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       startGPRGRAVEL
%
% Other m-files required:
%       GPRGRAVEL.m
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

%% add paths
thisfile = mfilename('fullpath');
thispath = fileparts(thisfile);
addpath(genpath(fullfile(thispath,'callbacks')),'-end');
addpath(genpath(fullfile(thispath,'externals')),'-end');
addpath(genpath(fullfile(thispath,'functions')),'-end');
addpath(genpath(fullfile(thispath,'GPRGRAVEL')),'-end');

%% start GUI
GPRGRAVEL;

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

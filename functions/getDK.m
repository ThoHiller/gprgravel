function dk = getDK(dk_in,vol_in)
%getDK calculates dk values based on CRIM forumla
%
% Syntax:
%       dk = getDK(dk_in,vol_in)
%
% Inputs:
%       dk_in - vec (epsilon values of the species)
%       vol_in - vec (volume fraction of the species)
%
% Outputs:
%       dk
%
% Example:
%       dk = getDK(dk_in,vol_in)
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

dk = 0;
dblAlpha = 1/2;

for i = 1:numel(dk_in)
    dk = dk + (dk_in(i).^dblAlpha)*vol_in(i);
end

dk = dk.^(1/dblAlpha);

return

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

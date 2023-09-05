function [target1D,pos] = getTargetPositionVector(target3D,varargin)
%getTargetPositionVector returns all target voxel position within the domain
%
% Syntax:
%       [params] = getTargetPositionVector(params)
%
% Inputs:
%       params - data struct
%
% Outputs:
%       params - data struct
%
% Example:
%       [params] = getTargetPositionVector(params)
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

shift = [0 0 0];
if nargin > 1
    shift = varargin{1};
end

% get box dimensions
szT = size(target3D);
% make vector from array
target1D = target3D(:);
% get array index voxel vector
ind = 1:1:numel(target1D); ind = ind(:);
% only keep voxel with ID>0
ind = ind(target1D>0);
target1D = target1D(target1D>0);

% get the 3D coordinates of target voxels
[ixt,iyt,izt] = ind2sub(szT,ind);
% shift these voxels to the center
ixt = ixt+shift(1);
iyt = iyt+shift(2);
izt = izt+shift(3);
% store coordinates
pos = [ixt iyt izt];

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

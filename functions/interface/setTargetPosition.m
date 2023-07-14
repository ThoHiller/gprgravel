function [data] = setTargetPosition(data)
%setTargetPosition changes the target position within the domain
%
% Syntax:
%       [data] = setTargetPosition(data)
%
% Inputs:
%       data - GUI data struct
%
% Outputs:
%       data - GUI data struct
%
% Example:
%       [data] = setTargetPosition(data)
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

domain = data.domain;
params = data.params;

centOld = params.targetCenterOld;
centNew = params.targetCenter;
% shift vector in real units
shift = centNew-centOld;
% shift vector in voxel units
shiftvox = round(shift./domain.dx);

params.targetIDX(:,1) = params.targetIDX(:,1)+shiftvox(1);
params.targetIDX(:,2) = params.targetIDX(:,2)+shiftvox(2);
params.targetIDX(:,3) = params.targetIDX(:,3)+shiftvox(3);

% now rotate the polar angle around the x-axis
phi0 = deg2rad(params.targetOrientOld(1));
phi1 = deg2rad(params.targetOrient(1));
if phi0~=phi1
    R0 = getRotationMatrixFromAngleandAxis(-phi0,[0 1 0]);
    R1 = getRotationMatrixFromAngleandAxis(phi1,[0 1 0]);
    for i1 = 1:numel(params.target)
        tmp = [params.targetIDX(i1,1) params.targetIDX(i1,2) params.targetIDX(i1,3)]';
        % move to center
        tmp = tmp-centNew'./domain.dx;
        % rotate
        tmp = R0*tmp; % old angle back
        tmp = R1*tmp; % new angle
        % move back
        tmp = round(tmp+centNew'./domain.dx);
        params.targetIDX(i1,1) = tmp(1);
        params.targetIDX(i1,2) = tmp(2);
        params.targetIDX(i1,3) = tmp(3);
    end
end

% now rotate the azimuthal angle around the z-axis
theta0 = deg2rad(params.targetOrientOld(2));
theta1 = deg2rad(params.targetOrient(2));
if theta0~=theta1
    R0 = getRotationMatrixFromAngleandAxis(-theta0,[0 0 1]);
    R1 = getRotationMatrixFromAngleandAxis(theta1,[0 0 1]);
    for i1 = 1:numel(params.target)
        tmp = [params.targetIDX(i1,1) params.targetIDX(i1,2) params.targetIDX(i1,3)]';
        % move to center
        tmp = tmp-centNew'./domain.dx;
        % rotate
        tmp = R0*tmp; % old angle back
        tmp = R1*tmp; % new angle
        % move back
        tmp = round(tmp+centNew'./domain.dx);
        params.targetIDX(i1,1) = tmp(1);
        params.targetIDX(i1,2) = tmp(2);
        params.targetIDX(i1,3) = tmp(3);
    end
end

data.params = params;

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

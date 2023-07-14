function R = getRotationMatrixFromAngleandAxis(phi,n)
%getRotationMatrixFromAngleandAxis calculates rotation matrix R to rotate about
%an axis n by an angle phi
%
% Syntax:
%       getRotationMatrixFromAngleandAxis(phi,n)
%
% Inputs:
%       phi - rotation angle [rad]; size Nx1
%       n - rotation axis vector [x y z]; size Nx3
%
% Outputs:
%       R - 3x3xN rotation matrix
%
% Example:
%       R = getRotationMatrixFromAngleandAxis(pi,[0 0 1]')
%       yields R = -1  0  0
%                   0 -1  0
%                   0  0  1
%       so that R*[1 0 0]' = [-1 0 0]'
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
% See also: BLOCHUS
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: GNU GPLv3 (at end)

%------------- BEGIN CODE --------------

% for only one axis-angle pair
if numel(phi) == 1
    % make "n" a unit vector
    n = n./norm(n);
    % get the individual components
    nx = n(1);
    ny = n(2);
    nz = n(3);
    % matrix terms needed
    omcos = 1-cos(phi);
    cosp = cos(phi);
    sinp = sin(phi);
    
    % assemble rotation matrix R
    R(1,1) = nx*nx*omcos +    cosp;
    R(1,2) = nx*ny*omcos - nz*sinp;
    R(1,3) = nx*nz*omcos + ny*sinp;
    
    R(2,1) = ny*nx*omcos + nz*sinp;
    R(2,2) = ny*ny*omcos +    cosp;
    R(2,3) = ny*nz*omcos - nx*sinp;
    
    R(3,1) = nz*nx*omcos - ny*sinp;
    R(3,2) = nz*ny*omcos + nx*sinp;
    R(3,3) = nz*nz*omcos +    cosp; 

else % for multiple axes and angles
    
    % n should contain only unit vectors!
    % get the individual components
    nx = n(:,1);
    ny = n(:,2);
    nz = n(:,3);
    % matrix terms needed
    omcos = 1-cos(phi);
    cosp = cos(phi);
    sinp = sin(phi);
    
    % assemble rotation matrix R
    R(1,1,:) = nx.*nx.*omcos +     cosp;
    R(1,2,:) = nx.*ny.*omcos - nz.*sinp;
    R(1,3,:) = nx.*nz.*omcos + ny.*sinp;
    
    R(2,1,:) = ny.*nx.*omcos + nz.*sinp;
    R(2,2,:) = ny.*ny.*omcos +     cosp;
    R(2,3,:) = ny.*nz.*omcos - nx.*sinp;
    
    R(3,1,:) = nz.*nx.*omcos - ny.*sinp;
    R(3,2,:) = nz.*ny.*omcos + nx.*sinp;
    R(3,3,:) = nz.*nz.*omcos +     cosp; 
end

return

%------------- END OF CODE --------------

%% License:
% GNU GPLv3
%
% BLOCHUS
% Copyright (C) 2019 Thomas Hiller
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

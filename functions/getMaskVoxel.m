function [index] = getMaskVoxel(curMask,sz,domain,params,type)
%updateIndexList creates a list with free voxel positions within the domain
%
% Syntax:
%       updateIndexList(method,M,marg,r,xyzr0,domain,grains)
%
% Inputs:
%       method - string ('std' | 'hull' | 'hull_tight')
%       M - matrix (marker matrix with occupied voxels)
%       marg - scalar (with of margin in voxel units)
%       r - scalar (current grain radius)
%       xyzr0 - matrix (all already placed grains centers)
%       domain - struct with domain data
%       grains - struct with grain data
%
% Outputs:
%       indexList - List of empty voxels where a grain center could be
%       N - length of indexList
%
% Example:
%      [list,~] updateIndexList('std',M,marg,r,xyzr0,domain,grains)
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

% hardcoded to use new version
version = 2;

if version == 1 % original version

    switch type
        case 'prep'
            maxX = domain.dx*sz(1);
            maxY = domain.dx*sz(2);
            [tmpY,tmpX,tmpZ] = meshgrid(domain.dx*(1:domain.ny),...
                domain.dx*(1:domain.nx),domain.dx*(1:domain.nz));

        case 'export'
            maxX = domain.dx*sz(1);
            maxY = domain.dx*sz(2);
            xPML = domain.dx*((1:sz(2))-domain.marg+params.pml_w(2));
            yPML = domain.dx*((1:sz(1))-domain.marg+params.pml_w(1));
            zPML = domain.dx*((1:sz(3))-domain.marg+params.pml_w(3));
            [tmpY,tmpX,tmpZ] = meshgrid(xPML,yPML,zPML);
    end

    arrSlope = curMask.arrTiltDegXY;

    if isfield(curMask,'zBaseMinTop')
        zBase = curMask.zBaseMinTop + abs( (maxX-curMask.arrBaseXYZ(1)) * tan(arrSlope(1)*pi/180)...
            + abs(maxY-curMask.arrBaseXYZ(2)) * tan(arrSlope(2)*pi/180) );
        curMask.arrBaseXYZ(3) = zBase;
    end
    arrBase = curMask.arrBaseXYZ;


    index = tmpZ <= ( arrBase(3) + (arrBase(1)-tmpX) * tan(arrSlope(1)*pi/180)...
        + (arrBase(2)-tmpY) * tan(arrSlope(2)*pi/180) );

elseif version == 2 % new version

    switch type
        case 'prep'
            x = domain.dx*( (1:domain.nx) - domain.marg);
            y = domain.dx*( (1:domain.ny) - domain.marg);
            z = domain.dx*( (1:domain.nz) - domain.marg);
            [tmpY,tmpX,tmpZ] = meshgrid(y,x,z);
        case 'export'
            x = domain.dx*( (1:sz(1)) - params.pml_w(1) );
            y = domain.dx*( (1:sz(2)) - params.pml_w(2) );
            z = domain.dx*( (1:sz(3)) - domain.marg );
            [tmpY,tmpX,tmpZ] = meshgrid(y,x,z);
    end

    ind = 1:numel(tmpX); ind = ind(:);
    X = tmpX(ind);
    Y = tmpY(ind);
    Z = tmpZ(ind);
    Q = [X Y Z];
    P = params.maskplane.points(2,:);
    N = params.maskplane.normal;

    % variant 1 to use dot product
    % v = dot((Q - P0)', repmat(N,[numel(ind) 1])' );
    % v = v(:);
    % variant 2 is effectively the same but faster
    QmP = Q-P;
    v = QmP*N';
    index = false(numel(v),1);
    index(v<0) = true;

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
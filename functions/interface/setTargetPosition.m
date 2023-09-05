function [data] = setTargetPosition(data,type)
%setTargetPosition changes the target position within the domain
%
% Syntax:
%       [data] = setTargetPosition(data)
%
% Inputs:
%       data - GUI data struct
%       type - string: 'calc' or 'view'
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

% get original target box
target3D = params.targetORG;

switch type
    case 'calc'
        % check if we can make 90° rotations because they are simple
        flipTheta = false;
        if mod(params.targetTheta,90) == 0
            if params.targetTheta == 0
                % nothing to do
            elseif params.targetTheta == 90
                target3D = permute(target3D,[3 2 1]);
                target3D = flip(target3D,1);
            elseif params.targetTheta == 180
                target3D = flip(target3D,3);
            end
        else
            % mark for manual rotation
            flipTheta = true;
        end

        flipPhi = false;
        if mod(params.targetPhi,90) == 0
            if params.targetPhi == 0
                % nothing to do
            elseif params.targetPhi == -90
                target3D = permute(target3D,[2 1 3]);
            elseif params.targetPhi == 90
                target3D = permute(target3D,[2 1 3]);
                target3D = flip(target3D,2);
            elseif abs(params.targetPhi) == 180
                target3D = flip(target3D,1);
            end
        else
            % mark for manual rotation
            flipPhi = true;
        end

        %new target dimensions
        szT = size(target3D);
        xt = szT(1)*0.002;
        yt = szT(2)*0.002;
        zt = szT(3)*0.002;

        %local center of target box
        centT1 = [xt/2 yt/2 zt/2];
        %new target Center
        centT2 = params.targetCenter;
        %shift vector in real units
        shift = centT2-centT1;
        %shift vector in voxel units
        shift0 = round(shift./domain.dx);

        %shift target
        [target1D,pos] = getTargetPositionVector(target3D,shift0);

        params.target = target1D;
        params.targetIDX = pos;
        
        % if theta or phi are not multiples of 90°, we need to find all
        % voxels within the target
        if flipTheta || flipPhi
            % target x,y,z extent in real coordinates
            xr = [min(params.targetSurf.vertices(:,1)) max(params.targetSurf.vertices(:,1))];
            yr = [min(params.targetSurf.vertices(:,2)) max(params.targetSurf.vertices(:,2))];
            zr = [min(params.targetSurf.vertices(:,3)) max(params.targetSurf.vertices(:,3))];

            % target x,y,z extent in voxel coordinates
            xr0 = [floor(xr(1)/domain.dx) ceil(xr(2)/domain.dx)];
            yr0 = [floor(yr(1)/domain.dx) ceil(yr(2)/domain.dx)];
            zr0 = [floor(zr(1)/domain.dx) ceil(zr(2)/domain.dx)];

            % create correspondingly sized array of zeros
            blank = zeros(xr0(2)-xr0(1)+1,yr0(2)-yr0(1)+1,zr0(2)-zr0(1)+1);
            szB = size(blank);
            % get coordinate indices
            indB = 1:1:numel(blank(:)); indB = indB(:);
            [ix,iy,iz] = ind2sub(szB,indB);
            % shift them to get the voxel coordinates
            ix = ix+xr0(1)-1;
            iy = iy+yr0(1)-1;
            iz = iz+zr0(1)-1;

            % transform them to real coordinates
            points = [ix iy iz].*domain.dx;
            % find all points inside the target
            in = inpolyhedron(params.targetSurf,points,'FlipNormals',true);

            % store the new voxel coordinates
            params.targetIDX = [ix(in) iy(in) iz(in)];
            params.target = 2*ones(size(params.targetIDX,1),1);
        end

    case 'view'
        %new target dimensions
        szT = size(target3D);
        xt = szT(1)*0.002;
        yt = szT(2)*0.002;
        zt = szT(3)*0.002;

        %local center of target box
        centT1 = [xt/2 yt/2 zt/2];
        %new target Center
        centT2 = params.targetCenter;
        %shift vector in real units
        shift = centT2-centT1;
        %shift vector in voxel units
        shift0 = round(shift./domain.dx);

        %shift target
        [target1D,pos] = getTargetPositionVector(target3D,shift0);

        params.target = target1D;
        params.targetIDX = pos;

        % calculate new isosurface for plotting
        params.targetSurf = isosurface(permute(target3D,[2 1 3]),1.5);
        params.targetSurf.vertices = params.targetSurf.vertices.*domain.dx;
        params.targetSurf.vertices = params.targetSurf.vertices+shift;

        % surface vertices rotations
        % theta
        R1 = getRotationMatrixFromAngleandAxis(-deg2rad(params.targetTheta),[0 1 0]);
        for i1 = 1:size(params.targetSurf.vertices,1)
            tmp = [params.targetSurf.vertices(i1,1) ...
                params.targetSurf.vertices(i1,2) params.targetSurf.vertices(i1,3)]';
            % move to center
            tmp = tmp-centT2';
            % rotate
            tmp = R1*tmp; % new angle
            % move back
            tmp = tmp+centT2';
            params.targetSurf.vertices(i1,1:3) = tmp';
        end

        % phi
        R1 = getRotationMatrixFromAngleandAxis(-deg2rad(params.targetPhi),[0 0 1]);
        for i1 = 1:size(params.targetSurf.vertices,1)
            tmp = [params.targetSurf.vertices(i1,1) ...
                params.targetSurf.vertices(i1,2) params.targetSurf.vertices(i1,3)]';
            % move to center
            tmp = tmp-centT2';
            % rotate
            tmp = R1*tmp; % new angle
            % move back
            tmp = tmp+centT2';
            params.targetSurf.vertices(i1,1:3) = tmp';
        end
end % switch type

% OLD CODE:
% voxel point rotation
% if flipTheta
%     R1 = getRotationMatrixFromAngleandAxis(-deg2rad(params.targetTheta),[0 1 0]);
%     for i1 = 1:numel(params.target)
%         tmp = [params.targetIDX(i1,1) params.targetIDX(i1,2) params.targetIDX(i1,3)]';
%         % move to center
%         tmp = tmp-centT2'./domain.dx;
%         % rotate
%         tmp = R1*tmp; % new angle
%         % move back
%         tmp = round(tmp+centT2'./domain.dx);
%         params.targetIDX(i1,1) = tmp(1);
%         params.targetIDX(i1,2) = tmp(2);
%         params.targetIDX(i1,3) = tmp(3);
%     end
% end
%
% if flipPhi
%     R1 = getRotationMatrixFromAngleandAxis(-deg2rad(params.targetPhi),[0 0 1]);
%     for i1 = 1:numel(params.target)
%         tmp = [params.targetIDX(i1,1) params.targetIDX(i1,2) params.targetIDX(i1,3)]';
%         % move to center
%         tmp = tmp-centT2'./domain.dx;
%         % rotate
%         tmp = R1*tmp; % new angle
%         % move back
%         tmp = round(tmp+centT2'./domain.dx);
%         params.targetIDX(i1,1) = tmp(1);
%         params.targetIDX(i1,2) = tmp(2);
%         params.targetIDX(i1,3) = tmp(3);
%     end
% end
%
% % experimental!!!
% if flipTheta || flipPhi
%     % we need to interpolate for any free rotation
%     tt = zeros(domain.xm/domain.dx,domain.ym/domain.dx,domain.zm/domain.dx);
%     sztt = size(tt);
%     ind1 = sub2ind(sztt,params.targetIDX(:,1),params.targetIDX(:,2),params.targetIDX(:,3));
%     tt(ind1) = 1;
%     tt = smooth3(tt,'box',3);
%     tt(tt>0.9) = 1;
%     [target1D,pos] = getTargetPositionVector(tt);
%
%     params.target = target1D;
%     params.targetIDX = pos;
% end

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

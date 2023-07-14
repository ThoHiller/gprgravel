function [indexList,N] = updateIndexList(method,M,marg,r,xyzr0,domain,grains)
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

switch method
    case 'std'
        Mv = true(size(M));
        % now mark all inner voxels within for searching a new center point
        r2 = ceil(r/domain.dx);
        ma = 2*marg-r2;
        marg = ma;
        % mark all margin voxels
        Mv(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg) = false;
        % add all spheres from M
        Mv(M) = true;
        % indexList = (1:numel(Mv))';
        % indexList = [indexList(~Mv(:));indexList(Mv(:))];
        % N = numel(Mv(:))-sum(Mv(:));
        indexList_tmp = (1:numel(Mv))';
        indexList = indexList_tmp(~Mv(:));
        N = numel(indexList(:));
        
    case 'hull'
        % old way: mark only voxels in a certain grain hull
        Mv = true(size(M));
        % now mark all inner voxels for searching a new center point
        r2 = ceil(r/domain.dx);
        ma = 2*marg-r2;
        marg = ma;
        
        Mv(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg) = false;
        
        Nxyz = find(xyzr0(:,4)<0,1,'first')-1;
        r_old = 1000;
        
        for nn = 1:Nxyz            
            r_now = xyzr0(nn,4);
            if r_now < r_old
                sphere = getSubBodyCoords(grains.shape,grains.axes,xyzr0(nn,4)+r,domain.dx);
                r_old = r_now;
            end
            
            % move the sphere to the current center point
            spnew = sphere + [xyzr0(nn,1)*ones(length(sphere),1) ...
                xyzr0(nn,2)*ones(length(sphere),1) ....
                xyzr0(nn,3)*ones(length(sphere),1)];
            
            [ix1,~] = find(spnew(:,1)<marg | spnew(:,1)>size(Mv,1)-marg);
            [ix2,~] = find(spnew(:,2)<marg | spnew(:,2)>size(Mv,2)-marg);
            [ix3,~] = find(spnew(:,3)<marg | spnew(:,3)>size(Mv,3)-marg);
            ix = unique([ix1;ix2;ix3]);
            spnew(ix,:) = [];
            
            % get indices of the current sphere into M
            index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));
            % mark the "occupied" region
            Mv(index) = true;
        end
        indexList_tmp = (1:numel(Mv))';
        indexList = indexList_tmp(~Mv(:));
        N = numel(indexList(:));

    case 'hull_tight'
        Mv = true(size(M));
        % now mark all inner voxels for searching a new center point
        r2 = ceil(r/domain.dx);
        ma = 2*marg-r2;
        marg = ma;

        Mv(marg+1:end-marg,marg+1:end-marg,marg+1:end-marg) = false;

        Nxyz = find(xyzr0(:,4)<0,1,'first')-1;
        if isempty(Nxyz)
            error('There is no more free place left in voxel index list.\n');
        end
        r_old = 1000;
        
        indexList = zeros(Nxyz,2);
        for nn = 1:Nxyz
            r_now = xyzr0(nn,4);
            if r_now < r_old
                sphereInner = getSubBodyCoords(grains.shape,grains.axes,xyzr0(nn,4),domain.dx);
                sphereOuter = getSubBodyCoords(grains.shape,grains.axes,xyzr0(nn,4)+2*r,domain.dx);
                r_old = r_now;                
                sphere = setdiff(sphereOuter,sphereInner,'rows');
                nVoxInHull = size(sphere,1);
            end

            % move the sphere to the current center point
            spnew = sphere + [xyzr0(nn,1)*ones(length(sphere),1) ...
                xyzr0(nn,2)*ones(length(sphere),1) ....
                xyzr0(nn,3)*ones(length(sphere),1)];

            [ix1,~] = find(spnew(:,1)<marg | spnew(:,1)>size(Mv,1)-marg);
            [ix2,~] = find(spnew(:,2)<marg | spnew(:,2)>size(Mv,2)-marg);
            %[ix3,~] = find(spnew(:,3)<marg | spnew(:,3)>size(Mv,3)-marg);
            
            % in z-dimension, accept positions in upper margin
            % to create a surface pattern
            [ix3,~] = find(spnew(:,3)>size(Mv,3)-marg);
            ix = unique([ix1;ix2;ix3]);
            spnew(ix,:) = [];

            % get indices of the current sphere into M
            index = sub2ind(size(M), spnew(:,1), spnew(:,2), spnew(:,3));
            
            % get voxels in surrounding hull
            if ~grains.boolPreferClusters
                % relate to free voxels
                indexList(nn,:) = [nn sum(~M(index))/nVoxInHull];
            else
                % relate to filled voxels
                indexList(nn,:) = [nn sum(M(index))/nVoxInHull];
            end
        end
        indexList = indexList(~isnan(indexList(:,2)),:);
        N = size(indexList,1);
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
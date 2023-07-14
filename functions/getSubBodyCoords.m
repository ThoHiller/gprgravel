function [pos,block] = getSubBodyCoords(shape,aspect,r,dx,varargin)
%prepareDomain generates the domain data based on the user entries
%
% Syntax:
%       prepareDomain
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       prepareDomain
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

use_orient = false;
if nargin > 4
    use_orient = true;
    orient = varargin{1};
end

switch shape
    case 'sphere'
        
        % radius in lattice units
        r2 = ceil(r/dx);
        % get the grid points inside the sphere of current size rbins(i)
        [xi,yi,zi] = meshgrid(-r2:1:r2,-r2:1:r2,-r2:1:r2);
        
        dist = sqrt(xi.^2 + yi.^2 + zi.^2);
        
        if r == 1e-3
            pos = [0 0 0];
            in = false(size(dist));
            in(2,2,2) = true;
        else
            % if r<=0.02
            pos = [xi(dist<=r2) yi(dist<=r2) zi(dist<=r2)];
            in = dist<=r2;
            % else
            %     pos = [xi(dist<r2) yi(dist<r2) zi(dist<r2)];
            %     in = dist<r2;
            % end
            
        end
        
    case 'ellipse'
        % three axes in lattice units
        a = ceil(r*aspect(1)/dx);
        b = ceil(r*aspect(2)/dx);
        c = ceil(r*aspect(3)/dx);
        
        % get the grid points inside the sphere of current size rbins(i)
        [xi,yi,zi] = meshgrid(-a:1:a,-b:1:b,-c:1:c);
        dist = xi.^2/a^2 + yi.^2/b^2 + zi.^2/c^2;
        
        if r == 1e-3
            pos = [0 0 0];
            in = false(size(dist));
            in(2,2,2) = true;
        else
            
            pos = [xi(dist<=1) yi(dist<=1) zi(dist<=1)];
            
            if use_orient                
                % get the grid points inside the sphere of current size rbins(i)
                aa = max([a b c]);
                [xi,yi,zi] = meshgrid(-aa:1:aa,-aa:1:aa,-aa:1:aa);
                dist = xi.^2/a^2 + yi.^2/b^2 + zi.^2/c^2;
                pos = [xi(dist<=1) yi(dist<=1) zi(dist<=1)];
                
                % angles needed to parameterize the ellipse surface
                alpha = orient(1); % polar angle
                beta = orient(2); % azimutal angle
                
                % rotation matrices
                Ry = [cosd(alpha) 0 sind(alpha);0 1 0;-sind(alpha) 0 cosd(alpha)];
                Rz = [cosd(beta) -sind(beta) 0;sind(beta) cosd(beta) 0;0 0 1];
                
                % ellispoid surface
                phi = linspace(0,pi,31);
                theta = linspace(0,2*pi,61);
                [pp,tt] = meshgrid(phi,theta);
                x = a.*cos(tt).*cos(pp);
                y = b.*cos(tt).*sin(pp);
                z = c.*sin(tt);
                M = [x(:) y(:) z(:)];
                % apply rotation
                M2 = Ry*Rz*M';
                M2 = M2';
                in = inhull([xi(:) yi(:) zi(:)],M2);
                pos = [xi(in) yi(in) zi(in)];
                
                % apply rotation
                % Mp = Ry*Rz*pos'; clear pos
                % pos = Mp';
                % pos = floor(pos);
            end
            
        end
end

if nargout>1
    block = false(size(xi));
    if use_orient
        block(in) = true;
    else
        block(dist<=1) = true;
    end
end

return

%% the original way
% % get the grid points inside the sphere of current size rbins(i)
% m = 0;
% sphere1 = zeros((2*r2+1)^3,3);
% for a = -r2:r2
%     for b = -r2:r2
%         for c = -r2:r2
%             dist = sqrt( a^2 + b^2 +c^2 );
%             if dx*dist <= r
%                 m = m+1;
%                 sphere1(m,:) = [a b c];
%             end
%         end
%     end
% end
% sphere1 = sphere1(1:m,:);
% nVol = m;

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
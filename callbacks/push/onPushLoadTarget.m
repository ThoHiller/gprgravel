function onPushLoadTarget(src,~)
%onPushLoadTarget starts the import of a user provided target file
%
% Syntax:
%       onPushLoadTarget(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushLoadTarget(src)
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

% get GUI handle
fig = ancestor(src,'figure','toplevel');

if ~isempty(fig) && strcmp(get(fig,'Tag'),'GPRGRAVEL')
    % get GUI data
    gui = getappdata(fig,'gui');
    data = getappdata(fig,'data');
    domain = data.domain;
    params = data.params;

    % get the standard input path for target data if it is not already there
    if ~isfield(params,'targetPath')
        params.targetPath = fullfile(data.params.GPRGRAVELpath,'input','Targets');
    end
    % get the file to open
    [file,path] = uigetfile('.h5','Select the Target h5 file',params.targetPath);
    params.targetPath = path;
    params.targetFile = file;
    % try to import the data
    target = h5read(fullfile(params.targetPath,params.targetFile),'/data');

    % if there is data, proceed
    if ~isempty(target) && sum(target(:)) ~= 0
        % target successfully imported
        params.useTarget = true;
        
        % IMPORTANT:
        % we assume the target grid resolution is 2mm!
        szT = size(target);
        xt = szT(1)*0.002;
        yt = szT(2)*0.002;
        zt = szT(3)*0.002;

        % internally target always gets ID 2
        target(target>0) = 2;

        % domain center
        centD = [domain.xm/2 domain.ym/2 domain.zm/2];
        % local center of target box
        centT = [xt/2 yt/2 zt/2];
        % shift vector to place target at domain center
        shift = centD-centT;
        shift0 = floor(shift./domain.dx);

        % store target dimensions
        params.targetDIM = szT;
        % store original unrotated target array
        params.targetORG = target;

        [target1D,pos] = getTargetPositionVector(target,shift0);
        % get target surface
        params.targetSurf = isosurface(permute(target,[2 1 3]),1.5);
        params.targetSurf.vertices = params.targetSurf.vertices.*domain.dx;
        params.targetSurf.vertices = params.targetSurf.vertices+shift;
        params.targetSurfORG = params.targetSurf;

        params.target = target1D;        
        params.targetIDX = pos;
        params.targetCenter = centD;

        % update the target filename text field
        set(gui.edit_handles.targetfile,'String',params.targetFile);
        % activate control fields
        set(gui.edit_handles.targetx,'Enable','on','String',sprintf('%4.3f',params.targetCenter(1)));
        set(gui.edit_handles.targety,'Enable','on','String',sprintf('%4.3f',params.targetCenter(2)));
        set(gui.edit_handles.targetz,'Enable','on','String',sprintf('%4.3f',params.targetCenter(3)));
        params.targetTheta = 0;
        params.targetPhi = 0;
        set(gui.edit_handles.targetTheta,'Enable','on','String',sprintf('%3.1f',params.targetTheta));
        set(gui.edit_handles.targetPhi,'Enable','on','String',sprintf('%3.1f',params.targetPhi));

        % update GUI data
        data.domain = domain;
        data.params = params;
        setappdata(fig,'data',data);
        % plot the GSD data
        plotDomaindata(fig);
        % update status
        updateStatusInformation(fig);
    else
        warndlg({'onPushLoadTarget:','Target data is empty. Check!'},...
            'GPRGRAVEL error');
    end
else
    warndlg({'onPushLoadTarget:','There is no figure with the GPRGRAVEL Tag open.'},...
        'GPRGRAVEL error');
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

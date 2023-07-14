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

        target = permute(target,[2 3 1]);
        
        % IMPORTANT:
        % we assume the target grid resolution is 2mm!
        [xt,yt,zt] = size(target);
        xt = xt*0.002;
        yt = yt*0.002;
        zt = zt*0.002;

        centD = [domain.xm/2 domain.ym/2 domain.zm/2];
        centT = [xt/2 yt/2 zt/2];
        shift = centD-centT;
        shift = floor(shift./domain.dx);

        szT = size(target);
        params.targetDIM = szT;
        target = target(:);
        ind = 1:1:numel(target); ind = ind(:);
        ind = ind(target>0);
        target = target(target>0);
        % set all targets to index 2
        target(:) = 2;

        [ixt,iyt,izt] = ind2sub(szT,ind);
        ixt = ixt+shift(1);
        iyt = iyt+shift(2);
        izt = izt+shift(3);
        params.target = target;
        params.targetIDX = [ixt iyt izt];
        params.targetCenter = centD;

        % update the GSD file name text fiedl
        set(gui.edit_handles.targetfile,'String',params.targetFile);
        % activate control fields
        set(gui.edit_handles.targetx,'Enable','on');
        set(gui.edit_handles.targety,'Enable','on');
        set(gui.edit_handles.targetz,'Enable','on');
        set(gui.edit_handles.targetp,'Enable','on');
        set(gui.edit_handles.targeta,'Enable','on');

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

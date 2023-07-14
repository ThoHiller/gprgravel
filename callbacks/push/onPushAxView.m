function onPushAxView(src,~)
%onPushAxView sets the view of axes plot to predefined sets
%
% Syntax:
%       onPushAxView(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushAxView(src)
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
    % get button tag
    str = get(src,'String');
    tag = get(src,'Tag');

    switch tag
        case {'domain','monitor'}

            switch tag
                case 'domain'
                    ax = gui.axes_handles.domain;
                case 'monitor'
                    ax = gui.axes_handles.Volume;  
            end

            switch str
                case 'XZ'
                    axes(ax)
                    view([0 0]);
                case 'YZ'
                    axes(ax)
                    view([90 0]);
                case 'XY'
                    axes(ax)
                    view([0 90]);
                case '3D'
                    axes(ax)
                    view([-35 30]);
            end

        case 'slice'
            data.params.showslice = str;
            domain = data.domain;
            % update GUI data
            setappdata(fig,'data',data);

            switch str
                case 'XZ'
                    set(gui.slider_handles.slider,'Min',1,'Max',domain.ny0,...
                        'Value',1,'SliderStep',[1/(domain.ny0-1) 5/(domain.ny0-1)])
                case 'YZ'
                    set(gui.slider_handles.slider,'Min',1,'Max',domain.nx0,...
                        'Value',1,'SliderStep',[1/(domain.nx0-1) 5/(domain.nx0-1)])
                case 'XY'
                    set(gui.slider_handles.slider,'Min',1,'Max',domain.nz0,...
                        'Value',1,'SliderStep',[1/(domain.nz0-1) 5/(domain.nz0-1)])
            end
            % update GUI data
            setappdata(fig,'gui',gui);
            % plot slice
            plotSlicedata(fig,str,1);
    end
    
else
    warndlg({'onPushAxView:','There is no figure with the GPRGRAVEL Tag open.'},...
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

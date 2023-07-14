function onEditValue(src,~)
%onEditValue updates all edit field values, checks for wrong inputs and
%restores a default value if necessary
%
% Syntax:
%       onEditValue(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onEditValue(src)
%
% Other m-files required:
%
% Subfunctions:
%       createDataString
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
    
    % get the value of the field
    val = str2double(get(src,'String'));
    % get the tag of the edit field
    tag = get(src,'Tag');
    % get the user data of the field
    ud = get(src,'UserData');
    
    % get the default values [default min max]
    defaults = ud.defaults;
    
    % check if the value is numeric
    % if not reset to defaults stored in user data
    if isnan(val)
        set(src,'String',num2str(defaults(1)));
        val = str2double(get(src,'String'));
    end
    % check if the value is out of bounds
    % if yes reset to default
    if val < defaults(2) || val > defaults(3)
        set(src,'String',num2str(defaults(1)));
        val = str2double(get(src,'String')); %#ok<*NASGU>
    end
    
    % get the data field to update from the field tag
    out = createDataString(tag);
    % update the corresponding data field
    updstr = [out.updstr,'=val;'];
    eval(updstr);
    
    % update the data inside the GUI
    setappdata(fig,'data',data);
    
    % depending on the particular edit field, further actions are
    % necessary
    switch tag
        % -----------------------------------------------------------------
        % --- DOMAIN ------------------------------------------------------
        % -----------------------------------------------------------------
        case {'domain_xm','domain_ym','domain_zm'}
            plotDomaindata(fig);

        case 'domain_porosity'
            % if porosity is changed adjust matrix fraction and water
            % fraction accordingly
            mat = data.domain.VolSpeciesMTX;
            air = data.domain.VolSpeciesAIR;
            wat = data.domain.VolSpeciesH2O;
            if val < air
                val = air;
                mat = 1 - val;
                wat = val - air;
                data.domain.porosity = val;
                set(gui.edit_handles.porosity,'String',sprintf('%4.3f',val));
            else
                mat = 1 - val;
                wat = val - air;
            end            
            data.domain.VolSpeciesMTX = mat;
            data.domain.VolSpeciesH2O = wat;
            set(gui.edit_handles.volmtx,'String',sprintf('%4.3f',mat));
            set(gui.edit_handles.volh2o,'String',sprintf('%4.3f',wat));

        case 'domain_VolSpeciesAIR'
            % if air fraction is changed adjust water fraction accordingly
            por = data.domain.porosity;
            wat = data.domain.VolSpeciesH2O;
            if val > por
                val = por;
                wat = por - val;
                data.domain.VolSpeciesAIR = val;
                set(gui.edit_handles.volair,'String',sprintf('%4.3f',val));
            else
                wat = por - val;
            end
            data.domain.VolSpeciesH2O = wat;
            set(gui.edit_handles.volh2o,'String',sprintf('%4.3f',wat));

            % -------------------------------------------------------------
            % --- GRAINS --------------------------------------------------
            % -------------------------------------------------------------
        case 'grains_axesx'
            data.grains.axes(1) = val;
        case 'grains_axesy'
            data.grains.axes(2) = val;
        case 'grains_axesz'
            data.grains.axes(3) = val;
            
            % -------------------------------------------------------------
            % --- PARAMS --------------------------------------------------
            % -------------------------------------------------------------
        case {'params_targetCenterx','params_targetCentery',...
                'params_targetCenterz','params_targetOrientp',...
                'params_targetOrienta'}
            data.params.targetCenterOld = data.params.targetCenter;
            data.params.targetOrientOld = data.params.targetOrient;
            switch tag
                case 'params_targetCenterx'
                    data.params.targetCenter(1) = val;
                case 'params_targetCentery'
                    data.params.targetCenter(2) = val;
                case 'params_targetCenterz'
                    data.params.targetCenter(3) = val;
                case 'params_targetOrientp'
                    data.params.targetOrient(1) = val;
                case 'params_targetOrienta'    
                    data.params.targetOrient(2) = val;
            end
            % update the data inside the GUI
            setappdata(fig,'data',data);
            % move target
            data = setTargetPosition(data);
            % update the data inside the GUI
            setappdata(fig,'data',data);
            % update plot
            plotDomaindata(fig);

        case 'params_maskdipx'
            % maximum angle until surface touches bottom in x-direction
            a = atand(data.domain.zm/data.domain.xm);
            if a > val
                data.params.maskdipx = val;
            else
                data.params.maskdipx = a;
                set(gui.edit_handles.maskdipx,'String',sprintf('%4.2f',a));
            end            
            % update the data inside the GUI
            setappdata(fig,'data',data);
            plotDomaindata(fig);

        case 'params_maskdipy'
            % maximum angle until surface touches bottom in y-dircetion
            b = atand(data.domain.zm/data.domain.ym);
            if b > val
                data.params.maskdipy = val;
            else
                data.params.maskdipy = b;
                set(gui.edit_handles.maskdipy,'String',sprintf('%4.2f',b));
            end            
            % update the data inside the GUI
            setappdata(fig,'data',data);
            plotDomaindata(fig);

        case {'params_satProfileTop','params_satProfileBottom'}
            id = findobj('Tag','params_satProfileTop');
            data.params.satBounds(1) = str2double(get(id,'String'));
            id = findobj('Tag','params_satProfileBottom');
            data.params.satBounds(2) = str2double(get(id,'String'));
    end
    
    % update GUI data
    setappdata(fig,'data',data);
else
    warndlg({'onEditValue:','There is no figure with the GPRGRAVEL Tag open.'},...
        'GPRGRAVEL error');
end

end

%% helper function to create the update string
function out = createDataString(tag)
% find the underscore
ind = strfind(tag,'_');
% the panel name is before the underscore
out.panel = tag(1:ind(1)-1);
% the field name afterwards
out.field = tag(ind(1)+1:end);
% replace the underscore with a dot
tag(ind) = '.';
% create the update string
out.updstr = ['data.',tag];

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

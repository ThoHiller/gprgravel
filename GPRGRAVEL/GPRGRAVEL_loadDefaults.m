function data = GPRGRAVEL_loadDefaults
%GPRGRAVEL_loadDefaults loads default GUI data values
%
% Syntax:
%       GPRGRAVEL_loadDefaults
%
% Inputs:
%       none
%
% Outputs:
%       out - default data structure
%
% Example:
%       out = GPRGRAVEL_loadDefaults
%
% Other m-files required:
%       none
%
% Subfunctions:
%       getInitData
%       getMonitordata
%
% MAT-files required:
%       none
%
% See also GPRGRAVEL
% Author(s): see AUTHORS.md
% License: GNU GPLv3 (at end)

%------------- BEGIN CODE --------------

% aux data
data.info.ToolTips = 1;
data.info.Timer = 0;

% get init data
% Note to user: use the "getInitData" function to adjust default
% settings and parameter range
init = getInitData;
data.init = init;

% domain data
data.domain = init.domain;
data.domain.xm = data.domain.xm(1);
data.domain.ym = data.domain.ym(1);
data.domain.zm = data.domain.zm(1);
data.domain.dx = data.domain.dx(1);

data.domain.VolSpeciesAIR = data.domain.VolSpeciesAIR(1);
data.domain.VolSpeciesH2O = data.domain.VolSpeciesH2O(1);
data.domain.VolSpeciesMTX = data.domain.VolSpeciesMTX(1);
data.domain.porosity = data.domain.porosity(1);

% grains data
data.grains = init.grains;

% params data
data.params = init.params;

% monitor data during calculation
data.monitor = init.monitor;

end

% define init values and range
function init = getInitData
% domain dimensions in [m]
init.domain.xm = [0.3 1e-3 1e2];
init.domain.ym = [0.3 1e-3 1e2];
init.domain.zm = [0.3 1e-3 1e2];
% domain discretization in [m]
init.domain.dx = [0.002 1e-4 1e-1]; % [2 mm]

% epsilon values of the species used
init.domain.dkSpeciesAIR = 1;
init.domain.dkSpeciesMTX = 8.12;
init.domain.dkSpeciesH2O = 80;

% give volumetric ratios of air, matrix and water
% Mikrit_dct (dkRock = 8.12, dkBulk = 7.90)
% air:  18.55 %	| water:  5.00 %	| grain:  76.45 % -> phi=  23.55 %
init.domain.VolSpeciesAIR = [30/100 0 1];
init.domain.VolSpeciesH2O = [20/100 0 1];
init.domain.VolSpeciesMTX = [50/100 0 1];
% resulting porosity
init.domain.porosity = [init.domain.VolSpeciesAIR+init.domain.VolSpeciesH2O 0 1];

% grain shape ('sphere' or 'ellipse')
init.grains.shape = 'sphere';
% in case of 'ellipse' give the main radii ratios (x,y,z)
init.grains.axes = [1 0.8 0.6];
init.grains.axes = init.grains.axes./max(init.grains.axes); % normalized
% phi and theta angles to orient the ellipse
init.grains.orient = [0 0];

% use mask(s)
init.params.use_mask = true;
% create a 1-voxel margin on the outside of the inner volume
% if no grain fractions shall be located outside the inner volume
init.params.applyMarginMask = false;
% surface dip in x and y direction
init.params.maskdipx = 0;
init.params.maskdipy = 0;

% use taget(s)
init.params.useTarget = false;
% target center point
init.params.targetCenter = [init.domain.xm(1)/2 init.domain.ym(1)/2 init.domain.zm(1)/2];
% phi and theta angles to orient the target
init.params.targetOrient = [0 0];

% saturation profile (you can switch it on/off here)
init.params.useSatProfile = false;
init.params.satProfileType = 'linear';
init.params.satBounds = [0 1];

% RNG
init.params.use_customRNG = false;
init.params.customRNGSEED = 123456781;

% outpout MASKS values
ID_MASKED.Air.Lr = 0;
ID_MASKED.Water.Lr = 99;
ID_MASKED.PML.Lr = 999;
ID_MASKED.Target.Lr = 9999;
ID_MASKED.Air.M5  = 0;
ID_MASKED.Margin.Lr = -1;
ID_MASKED.Matrix.M5  = 1;
ID_MASKED.Water.M5  = 2;
ID_MASKED.PML.M5  = 3;
ID_MASKED.Target.M5  = 4;
ID_MASKED.Margin.M5 = 0;
init.params.ID_MASKED = ID_MASKED;

% misc parameters
init.params.boolOmitLn = true;  % save RAM, do not create Ln matrix
init.params.visualizePacking = false;

% define porosity at (below) which new grains must touch with existing ones
init.params.requireTouch.por = 0.75;
% define number of voxels that are required 
init.params.requireTouch.nVox = 5;

% every grain smaller than this is not allowed to stick out of
% the surface
init.params.closeSurface = false;
init.params.closeSurfaceR = 0.0099;

% info dump interval
init.params.dump = 100;  % just for backward compatibility
init.params.dumpsPerBin = 10;
init.params.dumpSec = 60;
init.params.updateVisualSec = 120;

% export options
init.params.exportMAT = true;
init.params.exportH5 = true;
init.params.exportPML = true;
init.params.PMLduplicate = false;
init.params.PMLtruncate = false;
init.params.pml_w = [10,10,50];

init.monitor = getMonitordata;

end

function monitor = getMonitordata()

monitor = struct(...
    'nVox',0,...                   % voxel in current bin
    'nLstVox',0,...                % number of voxel in last iteration
    'nVoxAim',0,...                % number of voxels to generate in current bin
    'por_cur',0,...                % current porosity
    'poro_final',0,...             % target porostiy
    'nBin',0,...                   % total number of bins
    'i',0,...                      % number of current bin
    'rbin',0,...                   % grain size of current bin
    'xyzr0',0,...                  % list of grain centers
    'stat',0,...                   % statistic structure variable
    'threshMaxTry',0,...           % threshold to stop grain packing
    'nMinTouch',1,...              % number of voxels for touching grains criterion
    'boolMustTouch',0,...          % grains must be placed next to existing ones
    'boolDrawFromGrainList',0,...  % grain center positions are drawn from list of vacant positons
    'n',0,...                      % number of iterations
    'nxyzr0',0,...                 % buffer size of grain center position list
    'iSwapListBox',0,...           % counter for swapping placing method
    'nSwapListBoxMax',0,...        % threshold for swapping
    'iRandPos',0,...               % counter for random positons
    'nRandPos',0,...               % total number of random positions
    'arrPackVel',0,...             % current packing velocity
    't1',0,...                     % timestamp
    'velPackMax',0,...             % maximal packing velocity
    'arrFailStat',0,...            % statistic of failed grain placing
    'params',0,...                 % params structure variable
    'paramVerbose',true,...        % paramVerbose structure variable
    'domainVOL0',0,...             % total number of voxel positions in volume
    'domainVOL0matrix',0,...       % total number of matrix voxel to generate
    'binStat',0,...                % verbose plot: grain size bins
    'voxHist',0,...                % verbose plot: placed voxels
    'log',0 ...                    % log
    );

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

function [mean_cd_by_dk, time] = get_data_for_granger_analysis(subject_name)


roi_fname = 'scout_Desikan-Killiany_68.mat';
% electrodes_fname = 'channel_GSN_128.mat';
% elcds = load(electrodes_fname);
% channels = [elcds.Channel().Loc];

surface_fname = 'headmodel_surf_openmeeg_02.mat';
sf = load(surface_fname);
grid_points = sf.GridLoc;
grid_orientation = sf.GridOrient;

rois = load(roi_fname);
dk_regions = {rois.Scouts().Vertices};


signal_fname = [subject_name, '\data_block001.mat'];
sgn = load(signal_fname);
events = [sgn.Events().times];
stim = {sgn.Events().label};

data_fname = [subject_name, '\results_MN_EEG_170310_1246.mat'];

% Data file structure:
%  |- ImagingKernel:  []
%   |- ImageGridAmp:   [45006x500 double]
%   |- Std:            []
%   |- Whitener:       [128x128 double]
%   |- SourceDecompSa: [3x15002 double]
%   |- SourceDecompVa: [3x45006 double]
%   |- nComponents:    3
%   |- Comment:        'MN: EEG(Full,Unconstr) 2016'
%   |- Function:       'mn'
%   |- Time:           [1x500 double]
%   |- DataFile:       'Subject01/LINE_M_45/data_block001.mat'
%   |- HeadModelFile:  'Subject01/LINE_M_45/headmodel_surf_openmeeg_02.mat'
%   |- HeadModelType:  'surface'
%   |- ChannelFlag:    [128x1 double]
%   |- GoodChannel:    [1x128 double]
%   |- SurfaceFile:    '@default_subject/tess_cortex_pial_low.mat'
%   |- Atlas:          []
%   |- GridLoc:        []
%   |- GridOrient:     []
%   |- GridAtlas:      []
%   |- Options:        
%   |    |- InverseMethod:   'minnorm'
%   |    |- InverseMeasure:  'amplitude'
%   |    |- SourceOrient:    {'free'}
%   |    |- DataTypes:       {'EEG'}
%   |    |- Comment:         'MN: EEG(Full,Unconstr)'
%   |    |- DisplayMessages: 1
%   |    |- ComputeKernel:   0
%   |    |- Loose:           0.2
%   |    |- UseDepth:        1
%   |    |- WeightExp:       0.5
%   |    |- WeightLimit:     10
%   |    |- NoiseMethod:     'reg'
%   |    |- NoiseReg:        0.1
%   |    |- SnrMethod:       'fixed'
%   |    |- SnrRms:          1e-06
%   |    |- SnrFixed:        3
%   |    |- NoiseCovMat:     
%   |    |    |- NoiseCov:     [128x128 double]
%   |    |    |- Comment:      'No noise modeling'
%   |    |    |- nSamples:     []
%   |    |    |- FourthMoment: []
%   |    |    |- History:      []
%   |    |- ChannelTypes:    {1x128 cell}
%   |    |- DataCovMat:      []
%   |    |- FunctionName:    'mn'
%   |- ColormapType:   []
%   |- DisplayUnits:   []
%   |- ZScore:         []
%   |- nAvg:           1
%   |- History:        {'10-Mar-2017 12:46:47', 'compute', 'Source estimation: minnorm'}
%   |- DataWhitener:   []

data = load(data_fname);
time = data.Time;
current_density_xyz = data.ImageGridAmp;
current_density = cd_normal(current_density_xyz);

mean_cd_by_dk = cellfun(@(vrt) mean(current_density(vrt, :)), dk_regions, 'UniformOutput', 0);
mean_cd_by_dk = cell2mat(mean_cd_by_dk');

% early_cd = mean_cd_by_dk(:, time <= 0.2);
% late_cd = mean_cd_by_dk(:, time >= 0.35 & time <= 0.55);


%display_current_density(current_density, grid_points, time == events(3));

end

function cd_norm = cd_normal(current_density)

idx_x = 1:3:length(current_density);
idx_y = 2:3:length(current_density);
idx_z = 3:3:length(current_density);

cd_norm = sqrt(current_density(idx_x, :).^2 + current_density(idx_y, :).^2 + ...
          current_density(idx_z, :).^2);

end


function display_current_density(cd, grid_points, time_idx)

cd = cd(:, time_idx);
% mean_cd = ones(numel(dk_regions), 1);
% vertices = {dk_regions().Vertices};
% mean_cd = cellfun(@(vrt) mean(cd(vrt, :)), vertices);

figure;

S = ones(length(cd),1) .* cd(:);
min_size = min(S);
max_size = max(S);
S = (S - min_size)/ (max_size - min_size) + 0.5;
idx = S > 0.5;
S = S * 8;
%C = repmat([1,2,3],numel(X),1);

scatter3(grid_points(idx, 1), grid_points(idx, 2), grid_points(idx, 3), S(idx));


end
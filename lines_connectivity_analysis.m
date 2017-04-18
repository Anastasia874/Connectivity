function lines_connectivity_analysis

addpath('..\matlab_toolboxes\fieldtrip\');
addpath('..\matlab_toolboxes\BrainNet\');
addpath('..\matlab_toolboxes\Kurganskiy\VAR\');
addpath('..\matlab_toolboxes\Kurganskiy\3party\');
addpath('..\matlab_toolboxes\Kurganskiy\signal\');
addpath('data\');
addpath('utils\');
addpath('connectivity\');
genpath(pwd);

% data_path = 'data\brainstorm_to_mne\';
[~, time, mean_cd_by_roi, rois] = get_data_for_connectivity;

time_ranges = {time <= 0.2, time >= 0.35 & time <= 0.55};
labels = {'early', 'late'};
methods = {'granger'}; % , 'coh'
NODES = ['data', filesep, 'Desikan-nodes.node'];
QUANTILES = 0; % percentage of left out connections; At least 0.99 if no filtering is applied
DIRECTED = 1;
VAR_ORDER = 10; % from Izyurov
ALPHA = 0.01; % significance for gamma filtering 
GROUPS = { {'LO', 'LF'}, {'LO', 'RO'}, {'Left', 'Right'} };
NGRPS = { 1, 1, 2 }; % one for symmetric case, 2 for assymetric

% mvr parameters:
cfg  = [];
cfg.order  = VAR_ORDER; 
cfg.toolbox = 'biosig';
cfg.output = 'parameters';

% define frequency bands:
bands = struct('name', {'alpha', 'beta', 'gamma'}, ...
               'freqs', {8:15, 16:31, 31:250});


% visualization parameters:
visfcg = [];
viscfg.nodes_fname = NODES;
viscfg.quantiles = QUANTILES;
viscfg.directed = DIRECTED;
viscfg.rois = rois; % {rois.Scouts().Label}
viscfg.output = 'pow';
viscfg.bands = bands;
viscfg.alpha = ALPHA;


rois_names = {rois.Scouts().Label};

for t = 1:length(time_ranges)    
    t_idx = time_ranges{t};
    crnt_density = mean_cd_by_roi(:, t_idx);
    
%     test_mvr(crnt_density, 10)

    for gp = 1:length(GROUPS)
    % extract qroup info:    
    group = GROUPS{gp};
    if NGRPS{t} == 2
        [idx_g1, ~] = create_ROI_group(group{1}, rois);
        [idx_g2, ~] = create_ROI_group(group{2}, rois);
        group1 = group{1};
        group2 = group{2};
    else
        [idx_g1, ~] = create_ROI_group(group, rois);
        idx_g2 = idx_g1; 
        group1 = group{1}; group2 = group1;
    end
    idx_g = unique([idx_g1, idx_g2]);
    % create FieldTrip data structure:
    data = [];
    data.trial{1} = crnt_density(idx_g, :);
    data.time{1} = time(t_idx);
    data.label = rois_names(idx_g);
    data.fsample = 1/mean(diff(time));
    
    
    % MVR-model the data: 
    mdata = ft_mvaranalysis(cfg, data);
    
    % test prediction quality:
    % mvr_prediction(data, mdata, 'residual');
    
    viscfg.tlabel = labels{t};
    viscfg.group = {group1, group2};
    connectivity_from_mvr(mdata, methods, viscfg, idx_g1, idx_g2);   
    end
end

% cfg = [];
% cfg.method = 'mtmfft';
% cfg.taper = 'dpss';
% cfg.output = 'pow';
% cfg.tapsmofrq = 1; 
% datapow = ft_freqanalysis(cfg, data);

end
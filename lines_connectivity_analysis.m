function lines_connectivity_analysis

addpath('..\matlab_toolboxes\fieldtrip\');
addpath('data\');
addpath('utils\');
addpath('connectivity\');
genpath(pwd);

% data_path = 'data\brainstorm_to_mne\';
[~, time, mean_cd_by_roi, rois] = get_data_for_connectivity;

time_ranges = {time <= 0.2, time >= 0.35 & time <= 0.55};
labels = {'early', 'late'};
methods = {'granger', 'coh'};
NODES = ['data', filesep, 'Desikan-nodes.node'];
QUANTILES = [0.99, 0.999]; % less than 0.95 makes no sense
DIRECTED = 1;
GROUPS = { {'Left', 'Right'}, {'LO', 'LF'}, {'LO', 'RO'} };
NGRPS = { 2, 1, 1 };

% mvr parameters:
cfg  = [];
cfg.order  = 10; % from Izyurov
cfg.toolbox = 'biosig';
cfg.output = 'parameters';

% visualization parameters:
visfcg = [];
viscfg.nodes_fname = NODES;
viscfg.quantiles = QUANTILES;
viscfg.directed = DIRECTED;
viscfg.rois = rois; % {rois.Scouts().Label}
viscfg.output = 'pow';


rois_names = {rois.Scouts().Label};

for t = 1:length(time_ranges)    
    t_idx = time_ranges{t};
    crnt_dencity = mean_cd_by_roi(:, t_idx);

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
    data.trial{1} = crnt_dencity(idx_g, :);
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
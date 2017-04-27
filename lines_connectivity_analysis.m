function lines_connectivity_analysis

addpath(genpath('..\matlab_toolboxes'));
addpath('data\');
addpath('utils\');
addpath('connectivity\');
genpath(pwd);

% data_path = 'data\brainstorm_to_mne\';

STIM_START = 0.2800;
STIM_END = 0.3960;
t0 = STIM_END;
UPSAMPLING_RATE = 10;

subjects = {'F_45', 'F_90', 'F_135', 'F_180', 'M_45', 'M_90', 'M_135', 'M_180'}; %

[orig_time, mean_cd_by_roi, rois] = get_data_for_connectivity(subjects{1});

[mean_cd_by_roi, time] = upsample_data(mean_cd_by_roi, orig_time, UPSAMPLING_RATE);

time_ranges = {time >= t0 & time <= t0 + 0.2, ...
               time >= t0 + 0.35 & time <= t0 + 0.55};
labels = {'late', 'early'};
methods = {'time_domain', 'total_interdependence', 'granger'}; % , 'coh'
NODES = ['data', filesep, 'Desikan-nodes.node'];
QUANTILES = 0; % percentage of left out connections; At least 0.99 if no filtering is applied
DIRECTED = 1;
VAR_ORDER = 10; % from Izyurov
ALPHA = 0.25; % gamma filtering quantile
GROUPS = { {'LO', 'LF', 'RO', 'RF'}, {'Left', 'Right'} };
NGRPS = { 1,  2 }; % 1 for symmetric case, 2 for assymetric

% mvr parameters:
cfg  = [];
cfg.order  = VAR_ORDER * UPSAMPLING_RATE; 
cfg.mvr = 'mvgc';  % toolbox for MVAR computation
cfg.toolbox = 'biosig'; % toolbox for MVAR computation, called by filedtrip
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
viscfg.regmode = 'OLS'; % for time-domain  Granger

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
    else
        [idx_g1, ~] = create_ROI_group(group, rois);
        idx_g2 = idx_g1; 
    end
    idx_g = unique([idx_g1, idx_g2]);
    % create FieldTrip data structure:
    data = [];
    x = crnt_density(idx_g, :)';
    [x, minvec, maxvec] = normalize_by_col(x);
    data.trial{1} = x';
    data.time{1} = time(t_idx);
    data.label = rois_names(idx_g);
    data.fsample = 1/mean(diff(time));
    data.minvec = minvec;
    data.maxvec = maxvec;
    
    % MVR-model the data: 
    mdata = mvaranalysis(cfg, data, 1);
    report_mvr(mdata.coeffs, data, 0.05, 1);
    
    % test prediction quality:
    % mvr_prediction(data, mdata, 'residual');
    
    viscfg.tlabel = labels{t};
    viscfg.group = group;
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
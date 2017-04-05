function lines_connectivity_analysis

addpath('..\matlab_toolboxes\fieldtrip\');
genpath(pwd);

data_path = '..\data\brainstorm_to_mne\';

[~, time, mean_cd_by_roi, rois] = get_data_for_connectivity(data_path);

early_idx = time <= 0.2; late_idx = time >= 0.35 & time <= 0.55;
early_cd = mean_cd_by_roi(:, early_idx);
late_cd = mean_cd_by_roi(:, late_idx);


data = [];
data.trial{1} = early_cd;
data.time{1} = time(early_idx);
data.label = {rois.Scouts().Label};
data.fsample = 1/mean(diff(time));

cfg  = [];
cfg.order  = 10;
cfg.toolbox = 'biosig';
cfg.output = 'parameters';
mdata = ft_mvaranalysis(cfg, data);

% mvr_prediction(data, mdata, 'residual');

cfg = [];
cfg.method = 'mvar';
cfg.output = 'pow';
datapow = ft_freqanalysis(cfg, mdata);

cfg = [];
cfg.method = 'granger';
cfg.output = 'pow';
res = ft_connectivityanalysis(cfg, datapow);
grangerspctrm = res.grangerspctrm;
grfreq = res.freq;

cfg.method = 'coh';
res = ft_connectivityanalysis(cfg, datapow);
cohspctrm = res.cohspctrm;
cohfreq = res.freq;

% cfg = [];
% cfg.method = 'mtmfft';
% cfg.taper = 'dpss';
% cfg.output = 'pow';
% cfg.tapsmofrq = 1; 
% datapow = ft_freqanalysis(cfg, data);

end
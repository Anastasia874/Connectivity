function try_connectivity

addpath('..\fieldtrip\');
genpath(pwd);

% try_freqanalysis;

data = load_brainstorm_data;

% MVR model:
cfg  = [];
cfg.order  = 5;
cfg.toolbox = 'bsmart';
mdata = ft_mvaranalysis(cfg, data);

% cfg = [];
% cfg.method = 'mtmfft';
% cfg.taper = 'dpss';
% cfg.output = 'pow';
% cfg.tapsmofrq = 1; 
% cfg.trials = 1;
cfg = [];
cfg.method = 'mvar';
cfg.output = 'pow';
datapow = ft_freqanalysis(cfg, mdata);

% identify the indices of trials with high and low alpha power
freqind = nearest(datapow.freq, 10);
tmp = abs(datapow.crsspctrm(:,:, freqind));

chanind = find(mean(tmp,1)==max(mean(tmp,1)));  % find the sensor where power is max
indlow  = find(tmp(:,chanind)<=median(tmp(:,chanind)));
indhigh = find(tmp(:,chanind)>=median(tmp(:,chanind)));

% compute the power spectrum for the median splitted data
cfg              = [];
cfg.trials       = indlow; 
datapow_low      = ft_freqdescriptives(cfg, datapow);

cfg.trials       = indhigh; 
datapow_high     = ft_freqdescriptives(cfg, datapow);

% compute the difference between high and low
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'divide';
powratio      = ft_math(cfg, datapow_high, datapow_low);

cfg = [];
cfg.method = 'coh';
coh = ft_connectivityanalysis(cfg, freq);

% figure
% plot(data.time{1}, data.trial{1}) 
% legend(data.label)
% xlabel('time (s)')

end
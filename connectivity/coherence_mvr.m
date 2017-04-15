function [cohspctrm, cohfreq] = coherence_mvr(datapow, output)

if nargin < 2
    output = 'pow';
end
% try coherence:
cfg.method = 'coh';
cfg.output = output;
res = ft_connectivityanalysis(cfg, datapow);
cohspctrm = res.cohspctrm;
cohfreq = res.freq;

end
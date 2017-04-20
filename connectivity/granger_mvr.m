function [grangerspctrm, grfreq] = granger_mvr(datapow, output)

% Returns 

if nargin < 2
    output = 'pow';
end

cfg = [];
cfg.method = 'granger';
cfg.output = output;
res = ft_connectivityanalysis(cfg, datapow);

%  this returns log(1 - ...) x --> y values with zeros on main diagonal
grangerspctrm = exp(res.grangerspctrm);
grfreq = res.freq; 


end
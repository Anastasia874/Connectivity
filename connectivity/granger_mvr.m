function res = granger_mvr(cfg, mdata)

% Returns 

if ~isfield(cfg, 'output')
    cfg.output = 'pow';
end
if ~isfield(cfg, 'method')
    cfg.method = 'granger';
end

if strcmp(cfg.method, 'time_domain')
    [gcmatrix, pval, sig] = td_granger(cfg, mdata);   
    res.gcmatrix = gcmatrix;
    res.pval = pval;
    res.sig = sig;
    return;
end

frcfg = [];
frcfg.method = 'mvar';
frcfg.output = 'pow';
datapow = ft_freqanalysis(frcfg, mdata);
    
assrert(~isfield(datapow, 'freq'), 'FieldTrip only supports frequency-domain GC');

cfg = [];
cfg.method = method; %'granger';
cfg.output = output;
%  this returns log(1 - ...) x --> y values with zeros on main diagonal
res = ft_connectivityanalysis(cfg, datapow);
res.grangerspctrm = exp(res.grangerspctrm);



end
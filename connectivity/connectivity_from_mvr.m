function connectivity_from_mvr(mdata, methods, viscfg, group1, group2)

% Computes connectivity metrics based on MVR analysis of the time series
% Inputs:
% mdata - result of ft_mvaranalysis with 'parameters' output
% method - cell array with methods to try
% viscfg - visualisation parameters 
% group1 - indices or names of 'influencing' ROIs we are interested in
% group2 - indices or names of 'influenced' ROIs we are interested in

nodes_fname = viscfg.nodes_fname;
label = viscfg.tlabel; % time period, i.e. 'early'
quantiles = viscfg.quantiles;
directed = viscfg.directed;
rois = viscfg.rois;
output = viscfg.output;
bands = viscfg.bands;
alpha = viscfg.alpha;


group_name = strjoin(viscfg.group, '_'); % specific brain regions


if iscell(group1) && iscell(group2)
    nrois = {rois.Scouts().Label};
else
    nrois = numel(rois.Scouts);
end


cfg = [];
cfg.method = 'mvar';
cfg.output = 'pow';
datapow = ft_freqanalysis(cfg, mdata);

for m = 1:length(methods)
    fname = [methods{m}, '_', label, '_', group_name];
    switch methods{m}
        case {'granger' 'total_interdependence' 'instantaneous_causality'}
            [spectr, freqs] = granger_mvr(datapow, output);
        case 'coh'
            [spectr, freqs] = coherence_mvr(datapow, output);
    end  
    
    for nb = 1:length(bands)
        fname_f = [fname, '_', bands(nb).name];
        connmat = connectivity_by_frband(spectr, bands(nb).freqs, alpha);
        report_graph_stats(connmat, fname_f, 0.75, 'gamma');
        % select relevant group indices:
        connmat = get_full_conn_matrix(connmat, group1, group2, nrois);
        if sum(connmat(:)) > 0
            plot_connectivity(connmat, rois, fname_f, nodes_fname, ...
                                                           quantiles, directed);
        else
            fprinf('No connections found with method %s for %s %s band, ', ...
                'alpha= %0.3f, \n; %s', ...
                methods{m}, label, bands(nb).name, alpha, group_name);
        end
    end

end






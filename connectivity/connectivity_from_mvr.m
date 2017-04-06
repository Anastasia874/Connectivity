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
group_name = strjoin(viscfg.group, '_'); % specific brain regions


if iscell(group1) && iscell(group2)
    nrois = {rois.Scouts().Label};
else
    nrois = numel(rois);
end


cfg = [];
cfg.method = 'mvar';
cfg.output = 'pow';
datapow = ft_freqanalysis(cfg, mdata);

for m = 1:length(methods)
    fname = [methods{m}, '_', label, '_', group_name];
    switch methods{m}
        case 'granger'
            [spectrum, freqs] = granger_mvr(datapow, output);
        case 'coh'
            [spectrum, freqs] = coherence_mvr(datapow, output);
    end  
    for f = 1:50:length(freqs)
        connmat = spectrum(:, :, f);
        % normalize to [0, 1]
        connmat = (connmat - min(connmat(:)));
        connmat = connmat / max(connmat(:));
        % select relevant group indices:
        connmat = get_full_conn_matrix(connmat, group1, group2, nrois);        
        fname_f = [fname, '_fr_', num2str(freqs(f))];
        plot_connectivity(connmat, rois, fname_f, nodes_fname, ...
                                                       quantiles, directed);
    end
end

end



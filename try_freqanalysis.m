function try_freqanalysis(data)

if isempty(data)
    
end

cfg = [];
cfg.method = 'mvar';
cfg.output = 'powandcsd';

if strcmp(cfg.method, 'mvar') && ~isfield(data, 'coeffs')
    mvrcfg  = [];
    mvrcfg.order  = 5;
    mvrcfg.toolbox = 'bsmart';
    mdata = ft_mvaranalysis(mvrcfg, data);
end

% Inputs to ft_freqanalysis
% cfg.method  'mtmfft', 'mtmconvol', 'wavelet', 'tfr', 'mvar'
% cfg.output  'pow'       return the power-spectra
%             'powandcsd' return the power and the cross-spectra
%              'fourier'   return the complex Fourier-spectra
mfreq = ft_freqanalysis(cfg, mdata);
disp(mfreq);

% tsfunc = mfreq.transfer;
% crspectr = mfreq.crsspctrm;
% for j = 1:length(data.label)
%     figure;
%     imagesc(squeeze(tsfunc(j, :, :)));
% end

cfg = [];
cfg.method = 'coh';
% coh = ft_connectivityanalysis(cfg, freq);
cohm = ft_connectivityanalysis(cfg, mfreq);

% pairs = nchoosek(1:length(data.label), 2);
coherence_matrix = reshape(permute(cohm.cohspctrm, [3, 1, 2]), [], length(mdata.label));
figure;
imagesc(coherence_matrix);
colorbar;

cfg = [];
cfg.parameter = 'cohspctrm';
cfg.zlim  = [0 1];
ft_connectivityplot(cfg, cohm);


end
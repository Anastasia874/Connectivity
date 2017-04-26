function mdata = mvaranalysis(cfg, data, selorder)

if nargin < 3
    selorder = 0;
end

if ~isfield(cfg, 'regmode') || isempty(cfg.regmode)
        cfg.regmode = 'OLS';
end

X = cat(3, data.trial{:});

if selorder || ~empty(cfg.order)
    [~, BIC] = tsdata_to_infocrit(X, 60, cfg.regmode);
    [~, cfg.order] = min(BIC);
    fprintf('Using order = %i \n', cfg.order);
end


switch lower(cfg.mvr)    
    case 'mvgc'
        [coeffs, rescov] = tsdata_to_var(X, cfg.order, cfg.regmode);
        mdata = [];
        mdata.coeffs = coeffs;
        mdata.rescov = rescov;   
        mdata.trial = data.trial;
    case 'fieldtrip'
        mdata = ft_mvaranalysis(cfg, data);
%     case 'emvar'
%         [Bm,B0,Sw,Am,Su,Up,Wp,percup,ki]=idMVAR0ng(X, cfg.order, 0);
end
% else
%     mdata = ft_mvaranalysis(cfg, data);
% end


end
function connmat = gamma_filter(connmat, alpha)

% Apply gamma filtering: fit non-diagonal data to gamma distribution and
% set to zero all enties below alpha-th quantile 

data = connmat(:);
idx = reshape(1:numel(connmat), size(connmat));
idx_diag = diag(idx, 0);
data = data(~ismember(idx(:), idx_diag));

% to apply gamma filter, the data has to be greater than zero:
if any(data(:) < 0)
    fprintf('%e of data sample is < 0, no gamma filterin here\n', ...
                                                        mean(data(:) < 0));
    return;
end
phat = gamfit(data);

% % plot histogram against fitted distribution:
% histfit(data, 10, 'gamma');

cutoff = gaminv(alpha, phat(1), phat(2));
nfiltered = mean(connmat(:) <= cutoff);
connmat = connmat.* (connmat > cutoff);
fprintf('%0.3f-th quantile gamma-filtering: %e of data set to 0 \n', ...
                                                    alpha, nfiltered);

end
function connmat = gamma_filter(connmat, alpha)

data = connmat(:);
idx = reshape(1:numel(connmat), size(connmat));
idx_diag = diag(idx, 0);
data = data(~ismember(idx(:), idx_diag));

[phat, pci] = gamfit(data);
cutoff = gaminv(1 - alpha, phat(1), phat(2));

connmat = connmat.* (connmat > cutoff);

end
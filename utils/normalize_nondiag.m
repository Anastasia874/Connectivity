function connmat = normalize_nondiag(connmat)

% normalize to [0, 1]
connmat(eye(size(connmat)) == 1) = nan;
connmat = (connmat - min(connmat(:)));
connmat = connmat / max(connmat(:));

connmat(isnan(connmat)) = 0;

end
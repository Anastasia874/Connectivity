function connmat = normalize_nondiag(connmat, zerodiag)

if nargin < 2
    zerodiag = false;
end

% Scale matrix values globally to [0, 1] 
% % % except for diagonal values. These are focefully set to zero.

% connmat(eye(size(connmat)) == 1) = nan;
connmat = (connmat - min(connmat(:)));
connmat = connmat / max(connmat(:));
% connmat(isnan(connmat)) = 0;

% Normalize sum by columns: (if connectivity is directed, j-th column 
% stores all influences on j-th variable)
connmat = connmat ./ repmat(sum(connmat), size(connmat, 1), 1);


if zerodiag
    % for visualization perposes, set diagonal to zero:
    connmat(eye(size(connmat)) == 1) = 0;
end

end
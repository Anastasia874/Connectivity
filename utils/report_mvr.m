function [preds, res] = report_mvr(coeffs, x, labels, minvec, maxvec, alpha, vbs)

if nargin < 4
   minvec = zeros(1, size(x, 2));
   maxvec = ones(1, size(x, 2));
end

if nargin < 6
    alpha = 0.05;
end

if nargin < 7
    vbs = 0;
end

[preds, res, coeffs] = mvr_predict(coeffs, x);

% return x and predictions and res to the original scale:
preds = normalize_by_col(preds, minvec, maxvec);
res = normalize_by_col(res, zeros(1, size(x, 2)), maxvec-minvec);
x = normalize_by_col(x, minvec, maxvec);

nlags = size(coeffs, 3);
idx_pred = nlags+1:size(x, 1);

eps = 0;
if any(x == 0)
    % calc 'safe' mape with reg term eps:
    eps = min(abs(x(x(:) ~= 0)));
end
mape = mean(abs(res./(x(idx_pred,:) + eps)));
fprintf('MAPE = %e for nlags = %i \n', mean(mape), nlags);

% evaluate model stability via Lyapunov exponent for n_gnt samples generated 
% according to estimated VAR model
n_gnt = 1000;
[is_stable, le] = var_isStable(coeffs, n_gnt);
signstr = {'>', '<'};
fprintf('Lyapunov stability test: is_stable = %i (LE = %e %s 0)\n', ...
                                     is_stable, le, signstr{is_stable + 1});

% Test residuals for normality (same for pow spectrum) and zero mean:
pow = sign_fft(res, 500);
[h0, p0] = ttest(res, 0, 'alpha', alpha);
pn = p0; hn = pn;
pwn = p0; hwn = pwn;
disp('Testing residuals for normality and zero mean');
for i = 1:size(res, 2)
    [hn(i), pn(i)] = swtest(res(:, i), alpha);
    [hwn(i), pwn(i)] = swtest(pow(:, i), alpha);
end

fprintf('Failed normality test (alpha = %0.3f): %i/%i, pow. normality: %i/%i, both: %i/%i \n', ...
            alpha, sum(hn), length(hn), sum(hwn), length(hn), sum(hwn.*hn), length(hn));
fprintf('Failed zero-mean test (alpha = %0.3f): %i/%i \n', alpha, ...
                                                      sum(h0), length(h0));
if vbs
    p0str = arrayfun(@(x) num2str(x), p0, 'UniformOutput', 0);
    pnstr = arrayfun(@(x) num2str(x), pn, 'UniformOutput', 0);
    pwnstr = arrayfun(@(x) num2str(x), pwn, 'UniformOutput', 0);
    pnstr = strjoin(pnstr, ', '); pwnstr = strjoin(pwnstr, ', ');
    p0str = strjoin(p0str, ', ');
    fprintf('normality pval = [%s]; \n (pow: [%s]);\n zero-mean pval = [%s] \n', ...
                                    pnstr, pwnstr, p0str);

else

fprintf(['Normality pval in [%0.3f, %0.3f], (pow: [%0.3f, %0.3f])', ...
           '[zero-mean pval in [%0.3f, %0.3f] \n'], min(pn), max(pn), ...
                                    min(pwn), max(pwn), min(p0), max(p0));
end

end
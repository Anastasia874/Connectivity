function [preds, res, coeffs] = mvr_predict(coeffs, x)

dims = size(x);

if length(dims) == 2
    [nchan, tmp] = size(coeffs);
    nlags = tmp / nchan;
    coeffs = reshape(coeffs, nchan, nchan, nlags);
else
    nlags = size(coeffs, 3);
end

nsamples = size(x, 1);
preds = zeros(nsamples - nlags, nchan)';

for lag = 1:nlags
    preds = preds + coeffs(:, :, lag) * x(nlags-lag+1:end-lag, :)';
end
preds = preds';
res = x(nlags+1:end, :) - preds;

end
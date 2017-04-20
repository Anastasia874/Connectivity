function [x, minvec, maxvec] = normalize_by_col(x, minvec, maxvec)

nrows = size(x, 1);
if nargin < 3
    minvec = min(x);
    maxvec = max(x);
    x = (x - repmat(minvec, nrows, 1))./ repmat(maxvec - minvec, nrows, 1);
else
    x = x .* repmat(maxvec - minvec, nrows, 1) + repmat(minvec, nrows, 1);
end
    

end
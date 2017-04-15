function bmat = connectivity_by_frband(spectrum, freqs, alpha)

bmat = zeros(size(spectrum(:, :, 1)));

for f = 1:length(freqs)
    connmat = spectrum(:, :, f);
    connmat = normalize_nondiag(connmat);
    connmat = gamma_filter(connmat, alpha);        
    bmat = bmat + connmat;
end
bmat = bmat / length(freqs);

% if ~exist('fname', 'var')
%     fname = [num2str(freqs(1)), '_to_', num2str(freqs(end))];
% end


end
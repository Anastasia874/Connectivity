function stats = graph_stats(connmat, quant)

n_nodes = size(connmat, 1);
degrees = 0:n_nodes-1;
[nin, nout] = ndegrees(connmat, quant);

% res = struct('bin', cell(1, 3), 'plaw', [], 'star', []);

% Allocate array for results: rows correspond to in/out/all, columns to
% statistics: binomial, power law, "star number"
stats = zeros(3, 3);

% under binomial distribution: 
pin = 0.5; pout = 0.5; pall = 0.5; % default probability of drawing an edge
bpin = binopdf(nin, n_nodes-1, pin);
bpout = binopdf(nin, n_nodes-1, pout);
bpall = binopdf(nin + nout, 2*(n_nodes-1), pall);

stats(:, 1) = [-mean(log(bpin)),-mean(log(bpout)), -mean(log(bpall))];
% fprintf('-Loglikelihood: in: %0.3f, out %0.3f, all %0.3f\n', -mean(log(bpin)),...
%                                     -mean(log(bpout)), -mean(log(bpall)));
                                

% under power law:
% Fit power law
[log_lpin, ~, ~] = fit_power_law(nin, degrees);
[log_lpout, ~, ~] = fit_power_law(nout, degrees);
[log_lpall, ~, ~] = fit_power_law(nin + nout, degrees);
stats(:, 2) = [-mean(log_lpin), -mean(log_lpout), -mean(log_lpall)];
% fprintf('-Loglikelihood: in: %0.3f, out %0.3f, all %0.3f\n', -mean(log_lpin),...
%                                     -mean(log_lpout), -mean(log_lpall));


% the "star number":
stats(:, 3) = [star_number(nin), star_number(nout), star_number(nin + nout)];


% simitricity 
% % ?? in progress

end

function [nin, nout] = ndegrees(mat, quant)

% calculate number of incoming and outcoming edges for each node, assuming
% that i-th row encodes edge weights from i-th node

mat(eye(size(mat)) == 1) = 0;
thrs = quantile(mat(:), quant);
mat = mat >= thrs;


nin = sum(mat, 2)';
nout = sum(mat, 1);


end


function star_num = star_number(nin)

star_num = (sum(nin)/max(nin) - 1)/length(nin);

end

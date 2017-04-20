function pvals = report_graph_stats(connmat, name, quant, distr)

if nargin < 3
    quant = 0;
end

if nargin < 4
    distr = 'gamma';
end

name = [name, '_', strrep(num2str(quant), '.', 'p'), '_', distr];

% Based on connectivity structure:
% 1) Connectivity is mostly Left-Right symmetric 
% 2) Connectivity has more nodes with high degree compared to the random
% graph

stats = graph_stats(connmat, quant);
fprintf('Binomual distr: -Loglikelihood in: %0.3f, out %0.3f, all %0.3f\n', stats(:, 1));
fprintf('Power law distr: -Loglikelihood in: %0.3f, out %0.3f, all %0.3f\n', stats(:, 2));
fprintf('"Star number": in: %0.3f, out %0.3f, all %0.3f\n', stats(:, 3));                                
                                
% compare graph stats to random:
NGNT = 10000;
rand_stats = zeros([size(stats), NGNT]);
pars = [];
for gnt = 1:NGNT
    [randmat, pars] = generate_random_like(connmat, distr, pars);
    rand_stats(:, :, gnt) = graph_stats(randmat, quant);
end

pvals = compare_stats(stats, rand_stats, {'in', 'out', 'all'}, {'bin', 'plaw', 'star'}, name);

end


function pvals = compare_stats(stats, rand_stats, labelsi, labelsj, name)

nbins = 100;
% nbins = round(15*(size(rand_stats, 3))^(1/3));
pvals = zeros(size(stats));

for i = 1:size(stats, 1)
    for j = 1:size(stats, 2)
        [counts, bins] = histcounts(squeeze(rand_stats(i, j, :)), nbins);
        infbins = bins;
        infbins(1) = -Inf; infbins(end) = Inf;
        cdf = cumsum(counts)/sum(counts);
        idx = stats(i, j) > infbins(1:end - 1) & stats(i, j) <= infbins(2:end);
        pvals(i, j) = cdf(idx);
        plot_histdist(counts, bins, stats(i, j), cdf(idx), [labelsj{j}, ...
                    ': ', labelsi{i}], [name, '_', labelsj{j}, '_', labelsi{i}]);
        fprintf('%s, %s: %0.3f\n', labelsi{i}, labelsj{j}, pvals(i, j));  
    end
end

end
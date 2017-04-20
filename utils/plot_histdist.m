function plot_histdist(counts, bins, stat, cdf, xtext, name)

x = (bins(1:end-1) + bins(2:end))/2;

f = figure;
bar(x, counts); hold on;
lh(1) = plot(x, counts, 'r-', 'linewidth', 2);
miny = min(counts);
maxy = max(counts);
lh(2) = plot([stat, stat], [miny, maxy], 'g-', 'linewidth', 2);

xlabel(xtext, 'FontSize', 20, 'FontName', 'Times',  'Interpreter','latex');
ylabel('Probability', 'FontSize', 20, 'FontName', 'Times',  'Interpreter','latex');
legend(lh, {'pdf', ['test stat.,', num2str(cdf)]}, 'location', 'best', 'fontname', 'Times', 'fontsize', 12, 'Interpreter', 'latex');
hold off;
set(gca, 'FontSize', 15, 'FontName', 'Times');
axis tight;

if ~isempty(name)
savefig(['fig/stats/', name, '.fig']);
saveas(f, ['fig/stats/', name, '.png'])
close(f);
end


end
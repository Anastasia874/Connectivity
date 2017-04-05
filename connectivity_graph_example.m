function connectivity_graph_example

addpath('utils\');
addpath('..\matlab_toolboxes\fieldtrip\');
genpath(pwd);

data_path = 'data\brainstorm_to_mne\';
[~, time, mean_cd_by_roi, rois] = get_data_for_connectivity(data_path);

early_idx = time <= 0.2; late_idx = time >= 0.35 & time <= 0.55;
early_cd = mean_cd_by_roi(:, early_idx);
corrmat = abs(corr(early_cd', early_cd'));
corrmat = triu(corrmat, 0);

% % create_nodes(rois, rois.Name, 'Desikan-nodes.node'); 
QUANTILES = [0.5, 0.75, 0.95];
DIRECTED = 0;
nodes_fname = [data_path, 'Desikan-nodes.node'];
plot_connectivity(corrmat, rois, 'correlations_early', nodes_fname, QUANTILES, DIRECTED);

late_cd = mean_cd_by_roi(:, late_idx);
corrmat = abs(corr(late_cd', late_cd'));
corrmat = triu(corrmat, 0);
plot_connectivity(corrmat, rois, 'correlations_late', nodes_fname, QUANTILES, DIRECTED);

end
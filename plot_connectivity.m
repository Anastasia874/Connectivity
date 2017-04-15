function plot_connectivity(connmat, rois, edges_fname, nodes_fname, quantiles, directed)

if ~exist('quantiles', 'var')
   quantiles = [0.95, 0.75, 0.5]; 
end

if ~exist('quantiles', 'var')
   directed = 0; 
end

% define paths and names:
tmp_res_folder = 'results\';
fig_folder = 'fig';

rois_labels = {rois.Scouts().Label};


% load configuration file for BrainNet visualization:
default_options = 'options\full_nodes_jet_edge_directed_size_same_opacity_9.mat';
options = load(default_options);

% change and save them into temporary file:
VIEW = 'full';
EC = options.EC;
EC.edg.directed = directed; 
tmp_fname = ['options', filesep, 'tmp_brainnet_cfg.mat'];
save(tmp_fname, 'EC');

quantiles = quantiles(:)';
for quant  = quantiles
    qntstr = strrep(num2str(quant), '.', 'p');
    edges_fname_q = [edges_fname, '_', qntstr];
    create_edges(connmat, [tmp_res_folder, edges_fname_q], quant, ...
                          nodes_fname, rois_labels);
                                                
                                                
    % Visualize results with BrainNet:
    fig_fname = [edges_fname_q, '.png'];
    BrainNet_MapCfg('BrainMesh_ICBM152.nv', nodes_fname, ...
        [tmp_res_folder, edges_fname_q, '.edge'], ...
        tmp_fname, ...
        [fig_folder, filesep, fig_fname]);

end

end
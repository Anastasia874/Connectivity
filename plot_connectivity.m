function plot_connectivity(connmat, rois, edges_fname, nodes_fname, quantiles, directed)

addpath('..\matlab_toolboxes\BrainNet\Data\SurfTemplate\');

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
default_options = 'options\full_nodes_gray_edge_directed_size_0p4_opacity_9.mat';
options = load(default_options);

% change and save them into temporary file:
VIEW = {'sagital', 'axial'}; %{'full'}, {'medial', 'medial_ventral', 'coronal'}
EC = options.EC;
EC.edg.directed = directed; 
tmp_fname = ['options', filesep, 'tmp_brainnet_cfg.mat'];

quantiles = quantiles(:)';
for quant  = quantiles
    qntstr = strrep(num2str(quant), '.', 'p');
    edges_fname_q = [edges_fname, '_', qntstr];
    create_edges(connmat, [tmp_res_folder, edges_fname_q], quant, ...
                          nodes_fname, rois_labels);
                                                
                                                
    % Visualize results with BrainNet:
    for vw = VIEW
    EC = set_brainnet_view(EC, vw{1});
    save(tmp_fname, 'EC');
    fig_fname = [edges_fname_q, '_', vw{1}, '.png'];
    BrainNet_MapCfg('BrainMesh_ICBM152.nv', nodes_fname, ...
        [tmp_res_folder, edges_fname_q, '.edge'], ...
        tmp_fname, ...
        [fig_folder, filesep, fig_fname]);
    end

end

end
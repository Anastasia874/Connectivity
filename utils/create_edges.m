function create_edges(connectivity_matrix, fname, quant, nodes_file, roi_names)

if nargin < 3
    quant = 0.5;
end

if ~exist('nodes_file', 'var')
    nodes_file = {};
end

if ~exist('roi_names', 'var')
    roi_names = {};
end

   
    
connectivity_matrix = rearrange_nodes(connectivity_matrix, nodes_file, ...
                                roi_names);




cm = connectivity_matrix(:); cm = cm(cm > 0);
threshold = quantile(cm, quant);
connectivity_matrix = connectivity_matrix .*(connectivity_matrix >= threshold);

% Write connectivity  information into edges
fid = fopen([fname, '.edge'], 'wt');

for row = connectivity_matrix'
    row_str = arrayfun(@(r) num2str(r), row, 'UniformOutput', 0);
    row_str = strjoin(row_str, ' ');
    fprintf(fid, [row_str, '\n']);
end
fclose(fid);

end
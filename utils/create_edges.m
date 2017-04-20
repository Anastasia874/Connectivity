function create_edges(connmat, fname, quant, nodes_file, roi_names)

if nargin < 3
    quant = 0.5;
end

if ~exist('nodes_file', 'var')
    nodes_file = {};
end

if ~exist('roi_names', 'var')
    roi_names = {};
end

   
    
connmat = rearrange_nodes(connmat, nodes_file, ...
                                roi_names);




cm = connmat(:); cm = cm(cm > 0);
threshold = quantile(cm, quant);
connmat = connmat .*(connmat >= threshold);
fprintf('Number of positive connections %i/%i = %0.4f \n', sum(connmat(:)>0), ...
                                       numel(connmat), mean(connmat(:)>0));

% for visualizatio purposes, scale all nonzero connectivity values up:
fprintf('Connectivity values before scaling: in [%e, %e]\n', min(connmat(:)), max(connmat(:)));
scale = 1/mean(connmat(:));
connmat = scale * connmat;
fprintf('Connectivity values after scaling: in [%e, %e]\n', min(connmat(:)), max(connmat(:)));

% Write connectivity  information into edges
fid = fopen([fname, '.edge'], 'wt');

for row = connmat'
    row_str = arrayfun(@(r) num2str(r), row, 'UniformOutput', 0);
    row_str = strjoin(row_str, ' ');
    fprintf(fid, [row_str, '\n']);
end
fclose(fid);

end
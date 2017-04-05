function create_nodes(rois, fname, nodes_fname)

if nargin > 2
    create_nodes_from_oldfile(rois, fname, nodes_fname);
    return;
end

% Write information about nodes
fid = fopen([fname, '.node'], 'wt');
positions = rois.pos;
regions = unique({rois.Scouts().Region});

for roi = rois.Scouts
    color = num2str(find(strcmp(regions, roi.Region)));
    nodes = positions(roi.Vertices, :);
    weight = num2str(size(nodes, 1));
    median_pos = median(nodes);
    str_pos = arrayfun(@(i) num2str(i), median_pos, 'UniformOutput', 0);
    str_pos = strjoin(str_pos, ' ');
    str = strjoin({str_pos, color, weight, roi.Region}, ' ');
    fprintf(fid, [str, '\n']);
end
fclose(fid);

end
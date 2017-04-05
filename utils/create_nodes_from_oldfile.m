function create_nodes_from_oldfile(rois, fname, old_fname)

% Obtain correspondence btw full ROI names and abbreviated versions:
[roi_labels, abbr_labels] = get_dk_abbreviations;

% read old file:
[labels, lines, firstline] = read_labels_from_nodes_file(old_fname);

% Write file with names according to old_fname:
write_labels('old_names.txt', labels);


% Write file with names according to old_fname:
write_labels('new_names.txt', {rois.Scouts().Label});

fid = fopen([fname, '.node'], 'wt');
fprintf(fid, firstline);
for roi = rois.Scouts
%     color = num2str(find(strcmp(regions, roi.Region)));
%     weight = num2str(length(roi.Vertices));
    idx = strcmp(roi_labels, roi.Label);
    idx = strcmp(abbr_labels, labels{idx});
    fprintf(fid, lines{idx});
end
fclose(fid);

end


function write_labels(fname, labels)

fid = fopen(fname, 'wt');
for i = 1:numel(labels)
    fprintf(fid, [labels{i}, '\n']);
end
fclose(fid);

end



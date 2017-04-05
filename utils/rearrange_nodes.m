function connectivity_matrix = rearrange_nodes(connectivity_matrix, ...
                                               new_names, old_names, ...
                                               group1, group2)

if isempty(old_names) && (~isempty(group1) || ~isempty(group2))
    return;
end

if ischar(new_names)
    new_names = read_labels_from_nodes_file(new_names);
end

[roi_labels, abbr_labels] = get_dk_abbreviations;

idx_rearrange = zeros(1, length(new_names));

for i = 1:length(new_names)
    idx = strcmp(abbr_labels, new_names{i});
    idx = strcmp(roi_labels, old_names{idx});
    idx_rearrange(i) = find(idx);    
end

connectivity_matrix = connectivity_matrix(:, idx_rearrange);
connectivity_matrix = connectivity_matrix(idx_rearrange, :);


end
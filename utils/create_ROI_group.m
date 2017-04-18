function [idx_g, group] = create_ROI_group(group_labels, rois)

% returns indices and name of the ROI group specified by group_labels
% qroup_labels - cell array of specificators for the group
% rois - ROI structure, imported from brainstorm

regions = {rois.Scouts().Region};
roi_names = {rois.Scouts().Label};

if ischar(group_labels)    
    group_labels = {group_labels};
end

idx_g = [];
for gpl = 1:numel(group_labels) 
    if any(strcmp(group_labels, 'L')) || any(strcmpi(group_labels, 'left'))
        idx_g = [idx_g, 1:2:length(regions)-1];
    elseif any(strcmp(group_labels, 'R')) || any(strcmpi(group_labels, 'right'))
        idx_g = [idx_g, 2:2:length(regions)];
    else
        idx_g = [idx_g, find_stridx(group_labels, regions)];
    end
end
idx_g = unique(idx_g);
group = roi_names(idx_g);

end
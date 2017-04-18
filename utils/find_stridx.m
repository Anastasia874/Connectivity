function idx_g1 = find_stridx(group1, all_rois)

% Return indices of elements from group1 in all_rois
% Inputs:
% group1 - cell array with particular ROIs names
% all_rois - cell array with all ROIs names

ng1 = length(group1);
idx_g1 = [];
for g = 1:ng1
    idx_g1 = [idx_g1, find(strcmp(all_rois, group1{g}))];
end

end
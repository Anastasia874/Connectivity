function fullmat = get_full_conn_matrix(connmat, group1, group2, nrois)

% Converts group1-to-group2 connectivities into full matrix for all ROIs
% padding missing values with zeros
% Inputs:
% connmat - [ngroup1 x ngroup2] connectvity matrix
% group1 - indices or names of 'influencing' ROIs we are interested in
% group2 - indices or names of 'influenced' ROIs we are interested in
% nrois - number of all ROIs/ names of all ROIs

if iscell(group1) && iscell(group2) && iscell(nrois)
    % find indices of group1 rois:
    idx_g1 = find_stridx(group1, nrois);

    % find indices of group2 rois:
    idx_g2 = find_stridx(group2, nrois);
    nrois = numel(nrois);
else
    idx_g1 = group1;
    idx_g2 = group2;
end

fullmat = zeros(nrois);

idx_g = unique([idx_g1, idx_g2]);
fullmat(idx_g, idx_g) = connmat;

% idx_g1 = ismember(idx_g, idx_all_g1);
% idx_g2 = ismember(idx_g, idx_all_g2);

idx_g2wo1 = idx_g2(~ismember(idx_g2, idx_g1));
idx_g1wo2 = idx_g1(~ismember(idx_g1, idx_g2));
fullmat(idx_g2wo1, :) = 0;
fullmat(:, idx_g1wo2) = 0;


end
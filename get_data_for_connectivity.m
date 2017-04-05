function [data, time, mean_cd_by_roi, rois] = get_data_for_connectivity(data_path)

if nargin < 1
    data_path = '..\data\brainstorm_to_mne\';
end

roi_fname = [data_path, 'scout_Desikan-Killiany_68.mat'];
data_fname = [data_path, 'results_MN_EEG_170310_1246.mat'];


data = load(data_fname);
surface_fname = data.HeadModelFile;
time = data.Time;
current_density_xyz = data.ImageGridAmp;
current_density = cd_normal(current_density_xyz);

rois = load(roi_fname);
dk_regions = {rois.Scouts().Vertices};
mean_cd_by_roi = cellfun(@(vrt) mean(current_density(vrt, :)), dk_regions, 'UniformOutput', 0);
mean_cd_by_roi = cell2mat(mean_cd_by_roi');

surface_fname = strsplit(surface_fname, '/');
surface_fname = [data_path, surface_fname{end}];

sf = load(surface_fname);
rois.pos = sf.GridLoc;


end


function cd_norm = cd_normal(current_density)

idx_x = 1:3:length(current_density);
idx_y = 2:3:length(current_density);
idx_z = 3:3:length(current_density);

cd_norm = sqrt(current_density(idx_x, :).^2 + current_density(idx_y, :).^2 + ...
          current_density(idx_z, :).^2);

end
function [time, cd_by_roi, rois] = get_data_for_connectivity(subject, data_path)

% Read inverse solution, obtained in brainstorm data and aveerage by ROIs
% (Desikan-Killiany regions)
% Inputs:
% data_path - path to data with .mat file
% 
% Outputs:
% data - data structure, returned by brainstorm. Some of its fields are:
%        data.HeadModelFile - stores file name with locations of the nodes
%        data.ImageGridAmp - [n_nodes*3 x T] matrix with 3D current density
%                            time series for each node
% time - [1 x T] vector with time stamps (ms?)
% mean_cd_by_roi - [68 x T] time series of dipole amplitudes, averaged by ROIs
% rois - [1x 68] structure, fields are Name and Scouts. Scouts contain information 
%        such as nodes positions and region name.

if ~exist('data_path', 'var')
    data_path = 'data\brainstorm_to_mne\';
end



fname =  ['results_MN_EEG_KERNEL_', subject, '.mat'];
roi_fname = [data_path, 'scout_Desikan-Killiany_68.mat'];
data_fname = [data_path, fname];


data = load(data_fname);
surface_fname = data.HeadModelFile;
time = data.Time;

if ~isempty(data.ImageGridAmp)
    current_density_xyz = data.ImageGridAmp;
else
    ts = load([data_path, 'lines_', subject{n}, '.mat']);
    current_density_xyz = data.ImagingKernel * ts.F;
    time = ts.Time;
end 
current_density = cd_normal(current_density_xyz);

rois = load(roi_fname);
dk_regions = {rois{n}.Scouts().Vertices};
mean_cd_by_roi = cellfun(@(vrt) mean(current_density(vrt, :)), dk_regions, ...
                                                       'UniformOutput', 0);
cd_by_roi = cell2mat(mean_cd_by_roi');

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
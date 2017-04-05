function try_fieldtrip

% addpath('..\..\fieldtrip-20161206\');

% addpath('C:\Program Files (x86)\OpenMEEG\');
addpath('C:\Users\Krylova\Documents\motrenko\fieldtrip-20170403\');
genpath(pwd);
% load data from braisntorm in .mat format
data_path = '..\data\brainstorm_to_mne\';

data_fname = 'lines_M_45.mat';
montage_fname = 'channel_GSN_128.mat';

raw_data = load(fullfile([data_path, data_fname]));
% n_electrodes = size(raw_data.F, 1);
% labels = arrayfun(@(i) ['E', num2str(i)], 1:n_electrodes, 'UniformOutput', false);
% 
% elec = read_montage_from_bs(montage_fname, data_path);
elec = ft_read_sens('GSN-HydroCel-128.sfp');
if isfield(elec, 'unit') && strcmp(elec.unit, 'cm')
    elec.chanpos = elec.chanpos * 10;
    elec.elecpos = elec.elecpos * 10;
end

% create fieldtrip structure from it:
data = {};
data.trial{1} = raw_data.F;
data.time{1} = raw_data.Time;
data.label = elec.label;
data.elec = elec;
data.fsample = 1/mean(diff(raw_data.Time));
% data.datatype = 'raw';
% data.hassampleinfo = 'yes';

% try addong some processing with fiealdtrip:

% % visual inspection:
% cfg = [];
% cfg.viewmode = 'vertical';
% cfg.method = 'channel';
% ft_databrowser(cfg, data);


% cfg = [];
% cfg.channel = 'EEG';
% ic_data = ft_componentanalysis(cfg, data);
% 
% 
% cfg = [];
% cfg.viewmode = 'component';
% cfg.continuous = 'yes';
% cfg.blocksize = 30;
% cfg.channels = 1:10;
% % ic_data.topolabel = ic_data.label;
% % ft_databrowser(cfg, ic_data);


% head model:

% skin = ft_read_headshape('standard_skin_14038.vol');
% disp(skin)


% Read MRI:
% mri = ft_read_mri('standard_mri.mat');
load('..\standard_mri_aligned.mat');
disp(mri);
if ~isfield(mri, 'coordsys')     
    mri = ft_determine_coordsys(mri);
%     mri.coordsys = 'las';
end

% segment is into tissues:
cfg           = [];
cfg.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mri);

% create a (trianguar) mesh for each tissue:
cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd = ft_prepare_mesh(cfg, segmentedmri);

% Create a volume conduction model using 'dipoli', 'openmeeg', or 'bemcp'.
% Dipoli
cfg        = [];
cfg.method = 'bemcp'; % You can also specify 'openmeeg', 'bemcp', or another method.
vol        = ft_prepare_headmodel(cfg, bnd);


% Now see what you've done!
figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none');


% Visual check of eletride positions:
figure;
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;
% electrodes
ft_plot_sens(elec,'style', 'sk');  


% % atlas zones:
% roi_fname = 'scout_Desikan-Killiany_68.mat';
% 
% rois = load(fullfile([data_path, roi_fname]));
% dk_regions = {rois.Scouts().Vertices};


end
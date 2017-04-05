function create_skull_striped_image(mri_fname, output_fname)

% Creates skullstripped anatomical image

% FreeSurfer can be quite picky with respect to the exact format of the MRI-volumes. 
% One step which in our experience is notorious for not being very robust is automatic 
% skull-stripping. Therefore, we advocate a hybrid approach that uses SPM for an initial 
% segmentation of the anatomical MRI during the preprocessing. With this segmentation, 
% we can create a skull-stripped image, which is a prerequisite for a correct 
% segmentation in FreeSurfer. 


mri = ft_read_mri(mri_fname); % 'Subject01.mgz'
mri.coordsys = 'spm';

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri);
mri.anatomy = mri.anatomy.*double(seg.brain);

cfg             = [];
cfg.filename    = output_fname; % 'Subject01masked'
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);



end
function data = load_brainstorm_data

% load data from braisntorm in .mat format
data_path = '..\Data\brainstorm_to_mne\';
data_fname = 'lines_M_45.mat';
raw_data = load(fullfile([data_path, data_fname]));


% montage_fname = 'channel_GSN_128.mat';
% n_electrodes = size(raw_data.F, 1);
% labels = arrayfun(@(i) ['E', num2str(i)], 1:n_electrodes, 'UniformOutput', false);

% elec = read_montage_from_bs(montage_fname, data_path);
elec = ft_read_sens('GSN-HydroCel-128.sfp');
if length(elec.label) ~= size(raw_data.F, 1)
    elec.label = elec.label(4:end);
    elec.chanpos = elec.chanpos(4:end, :);
    elec.elecpos = elec.elecpos(4:end, :);
    elec.chantype = elec.chantype(4:end);
end
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


end
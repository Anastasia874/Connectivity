function sens = read_montage_from_bs(data_fname, data_path)

% Convert montage structure into FeldTrip layout woth the following fields
%    sens.label    = Mx1 cell-array with channel labels
%    sens.elecpos  = Nx3 matrix with electrode positions
%    sens.chanpos  = Mx3 matrix with channel positions (often the same as electrode positions)
%    sens.tra      = MxN matrix to combine electrodes into channels

montage = load(fullfile([data_path, data_fname]));


sens = [];
sens.label = {montage.Channel().Name};
sens.elecpos = [montage.Channel().Loc]';
sens.chanpos = sens.elecpos;
sens.tra = eye(length(sens.label));

end
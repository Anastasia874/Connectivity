function [labels, lines, firstline] = read_labels_from_nodes_file(fname)

fid = fopen(fname);
firstline = fgets(fid); % read first line
tline = fgets(fid); % the first one is not informative, so read the second
lines = {};
labels = {};
while ischar(tline) % keep reading until EOF is reached
    lines{end+1} = tline;
    tline = strsplit(tline, '\t');
    labels{end+1} = tline{end-1}; % the last one is EOL
    tline = fgets(fid);
end
fclose(fid);

end
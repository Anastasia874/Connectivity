function [labels1, labels2] = get_dk_abbreviations

fid = fopen('..\data\desikan_killiany_abbreviated_atlas.csv');

tline = fgetl(fid);
labels1 = {}; labels2 = {};
while ischar(tline)
    tline = strsplit(tline, ',');
    labels1{end+1} = tline{1};
    labels2{end+1} = tline{2};
    tline = fgetl(fid);
end
fclose(fid);

end
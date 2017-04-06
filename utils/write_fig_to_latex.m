function write_fig_to_latex(folder, tex_filename, method)

if nargin == 0
    folder = 'fig/';
end
if nargin < 2
    tex_filename = 'test.tex';
end

if nargin < 3
    method = '';
end

REPORT_FOLDER = 'reports/';

tex_filename = fullfile(REPORT_FOLDER, tex_filename);
figures_early = dir(fullfile(folder, ['*', method '*early*.png']));
figures_late = dir(fullfile(folder, ['*', method '*late*.png']));

strbeg = [  '\\documentclass[12pt]{article}\n', ...
            '\\extrafloats{100}\n',...
            '\\usepackage{a4wide}\n', ...
            '\\usepackage{multicol, multirow}\n', ...
            '\\usepackage[cp1251]{inputenc}\n',...
            '\\usepackage[russian]{babel}\n',...
            '\\usepackage{amsmath, amsfonts, amssymb, amsthm, amscd}\n',...
            '\\usepackage{graphicx, epsfig, subfig, epstopdf}\n',...
            '\\usepackage{longtable}\n', ...
            '\\graphicspath{ {../', folder, '} }\n',...                      
            '\\begin{document}\n\n'];
strend =    '\\end{document}';

fid = fopen(tex_filename,'w+');
fprintf(fid,strbeg);

tex_str = '';
nfig = length(figures_early);
for i = 1:nfig
    el = strsplit(figures_early(i).name, '.'); el = el{end-1}; 
    el = strsplit(el, '_'); el = el{end};
    tex_str = [tex_str, '\\begin{figure}\n'];
    tex_str = [tex_str, '\\centering\n'];    
    tex_str = [tex_str, '\\includegraphics[width=0.8\\textwidth]{',...
        figures_early(i).name,'}\n'];
    tex_str = [tex_str, '\\includegraphics[width=0.8\\textwidth]{',...
        figures_late(i).name,'}\n'];
    tex_str = [tex_str, '\\caption{', method,'Threshold: ', el,...
        '-th quantile. Top: early, bottom: late.}\n'];
    tex_str = [tex_str, '\\end{figure}\n'];
    tex_str = [tex_str,'\n\n'];  
end

fprintf(fid, tex_str);
fprintf(fid, strend);
fclose(fid);

end
function f_selectslice(showgui,p)


% ==============================================
%%   adjust file names
% ===============================================

files=p.files;
files=strrep(strrep(files,[filesep 'a1_'],[filesep 'warp_']),'.tif','.mat');


% ==============================================
%%   run (gui)
% ===============================================
for i=1:length(files)
    
    file=files{i};
    if  exist(file)~=2
        cprintf([1 0 1],['  missing file..abort \n']);
        disp([' not found: ' file]);
    else
        selectslice(file);
        drawnow;uiwait(gcf);
    end
end






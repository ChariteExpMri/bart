
function f_rotateSlices(showgui,isparallel)

cprintf([0 .5 0],['ROTATE SLICES ..using thumbnails \n']);

dirs=bartcb('getsel');
for i=1:length(dirs)
    
    infomat=fullfile(dirs{i},'a1_info.mat');
    if exist(infomat)==2
        v=load(infomat); 
        v=v.v;
        files=strrep(v.slicefiles,'.tif','.jpg'); %using thumbnails
        
        
        if isfield(v,'rottab')==0
            filesshort=strrep(files,[fileparts(files{1}) filesep],'');
            v.rottab=[filesshort repmat({0},[length(filesshort) 1])];
        end
            
            rottab=rotgui(files,v.rottab);
            if ~isempty(rottab)
                v.rottab=rottab;
                save(infomat,'v');
                disp(['...saving rotations in "a1_info.mat" ']);
            end
        
       
    else
        disp(['Problem with: '  dirs{i} ]);
        disp([ '.. "a1_info.mat" not found ... ']);
    end
    
end

% only a single tiff is imported from an animal folder
function importTiff_multi(tiffgrp, s)
warning off;
% disp(['*** prosessing:' file]);

tiffgrp=cellstr(tiffgrp);
[px name ext]=fileparts2(tiffgrp);
if numel(unique(px))>1;
    msgbox('if several tiffs selected they must be come frome identical directory');
    return;
end

pa=px{1};

[~ , outdirShort ]=fileparts(pa);

if s.SliceInOwnDir==0  % don't use own DIR
    outDir0=outdirShort;
    outDir=regexprep(outDir0,{'\.', '\s+' ,'#'},{'_' ,'_',''});
    fpoutDir=fullfile(s.dat ,outDir);
    mkdir(fpoutDir);
end

for i=1:length(tiffgrp)
    file=tiffgrp{i};
    disp(['*** prosessing: ' file]);
    [pa, fi ,ext]=fileparts(file);
    
    if s.SliceInOwnDir==1  %use own DIR 
        outDir=regexprep(fi,{'\.', '\s+' ,'#'},{'_' ,'_',''});
        fpoutDir=fullfile(s.dat ,outDir);
         mkdir(fpoutDir);
    end
    
    
   
   
    
    %
    % ==============================================
    %%   ! output path is LAST- folder-name
    % ===============================================
 
    disp(['copying....[' fi ext ']' ]);
    filog=fullfile(fpoutDir,'importlog.txt');
    if s.SliceInOwnDir==1  %use own DIR
        num=1;
        lg0=[];
    else
        if exist(filog)==2
            lg0=importdata(filog,'\n'););
            iorig=find(~cellfun(@isempty,strfind(lg0,'[origin]')));
            or={}; im={};
            for j=1:length(iorig)
                or{j,1}=regexprep(lg0{iorig(j)},'#import_TIFF \[origin]: ','');
                im{j,1}=regexprep(lg0{iorig(j)+1},'#import_TIFF \[BART]  : ','');
            end
            [~, nameIM ,~]=fileparts2(im);
            maxnum=max(str2num(char(regexprep(nameIM,'a1_',''))));
            num=maxnum+1;
            
            %OK, FILE ALREADY COPIED
            is=find(strcmp(or,file));
            if ~isempty(is)
                ix=or{is(1)};
                nameimp=im{is(1)};
                [~, nameIM ,~]=fileparts2(nameimp);
                num=str2num(char(regexprep(nameIM,'a1_','')));
            end
        else %NO LOGFILE
            k=dir(fpoutDir);
            isfilesInDir=find(([k.isdir])==0);
            if isempty(isfilesInDir)
                num=1;
            else
                num=10;
            end
        end
    end
    fiout=fullfile(fpoutDir, ['a1_' pnum(num,3) ext]);
    
   
    
    
    
    
    % ==============================================
    %%  APPROACH-2 isolate image, to remove other frames
    % ===============================================
    ha = imfinfo(file);
    ha = ha(s.frameNumber);
    a  = imread(file,s.frameNumber);
    
    % % % % % % fout=fullfile(pwd,'a1.tif');
    try
        imwrite(a,fiout, 'tif','Compression',ha.Compression);
    catch
        imwrite(a,fiout, 'tif','Compression','none');
    end
    
    % b=imread(fout);
    % ib=imfinfo(fout);
    % ==============================================
    %%  log file
    % ===============================================
        lg={[ 'DATE: '  timestr(now) ]};
        lg(end+1,1) ={['#import_TIFF [origin]: '  file]};
        lg(end+1,1) ={['#import_TIFF [BART]  : '  fiout]};
    % ==============================================
    %%   save log
    % ===============================================
    
    if s.SliceInOwnDir==1
        pwrite2file(filog,[lg]);
    else
        if exist(filog)==0
            pwrite2file(filog,lg);
        else
            %lg0=importdata(filog);
            pwrite2file(filog,[lg0; lg]);
        end
    end
    
    % ==============================================
    %%   thumbnail
    % ===============================================
    
    a2=imresize(a,[400 400]);
    a2=imadjust(mean(mat2gray(a2),3));
    a2=uint8(round(255.*a2 ));
    
    F2=fullfile(fpoutDir, ['a1_' pnum(num,3) '.jpg']);
    imwrite(a2,F2);
    

    % ==============================================
    %%   copy other dir-content stuff
    % ===============================================
    
    if s.copyfoldercontent==1 && s.SliceInOwnDir==1
        [filesaux] = spm_select('FPList',pa,'.*'); filesaux=cellstr(filesaux);
        [py name ext]=fileparts2(filesaux);
        idel=find(strcmp(ext,'.tif'));
        py(idel)=[];
        name(idel)=[];
        ext(idel)=[];
        if ~isempty(name)
            fx1=cellfun(@(a,b,c){[a filesep [b c]]}, py,name,ext );
            fx2=replacefilepath(fx1,fpoutDir);
            copyfilem(fx1,fx2);
        end
    end

    
end %all TIFFS

% ==============================================
%%   copy other dir-content stuff
% ===============================================

if s.copyfoldercontent==1 && s.SliceInOwnDir==0
    [filesaux] = spm_select('FPList',pa,'.*'); filesaux=cellstr(filesaux); 
    [py name ext]=fileparts2(filesaux);
    idel=find(strcmp(ext,'.tif'));
    py(idel)=[];
    name(idel)=[];
    ext(idel)=[];
    if ~isempty(name)
        fx1=cellfun(@(a,b,c){[a filesep [b c]]}, py,name,ext );
        fx2=replacefilepath(fx1,fpoutDir);
        copyfilem(fx1,fx2);
    end
end

%% ===============================================






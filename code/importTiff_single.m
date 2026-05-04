
% only a single tiff is imported from an animal folder
function importTiff_singleTiff(file, s)
warning off;
file=char(file);

disp(['*** prosessing:' file]);
[pa fi ext]=fileparts(file);

%
% ==============================================
%%   ! output path is LAST- folder-name
% ===============================================
[~ , outdirShort ]=fileparts(pa);

outDir0=outdirShort;
if ~isempty(char(s.addFolderSuffix))
    outDir0=[ outDir0 char(s.addFolderSuffix) ];
end
outDir=regexprep(outDir0,{'\.', '\s+' ,'#'},{'_' ,'_',''});
fpoutDir=fullfile(s.dat ,outDir);
mkdir(fpoutDir);
% fiout=fullfile(fpoutDir, [outDir ext])
fiout=fullfile(fpoutDir, ['a1_' pnum(1,3) '.tif']);
disp(['copying/creating....[' fi '.tif' ']' ]);


% ==============================================
%%   APPROACH-1: copy image --> problem: other frames!!!
% ===============================================
if 0
  copyfile( file, fiout, 'f');  
end

% ==============================================
%%  APPROACH-2 isolate image, to remove other frames
% ===============================================
ha = imfinfo(file);
ha = ha(s.frameNumber);

if ~isempty(strfind(lower(ext),'tif'))  %tif
    a  = imread(file,s.frameNumber);
else  %all other images
    a  = imread(file);
end

if ~isnan(s.channel)
    if s.channel<=size(a,3)
        a=a(:,:,s.channel);
    end 
end


% % % % % % fout=fullfile(pwd,'a1.tif');
try
    imwrite(a,fiout, 'tif','Compression',ha.Compression);
catch
    try
        imwrite(a,fiout, 'tif','Compression','none');
    catch
        % Writing single image data to a TIFF file is not supported with IMWRITE.
        a=uint8(255 * mat2gray(a));
        imwrite(a,fiout, 'tif','Compression','none');
    end

end

% b=imread(fout);
% ib=imfinfo(fout);

% ==============================================
%%   thumbnail
% ===============================================

a2=imresize(a,[400 400]);
a2=imadjust(mean(mat2gray(a2),3));
a2=uint8(round(255.*a2 ));

F2=fullfile(fpoutDir, ['a1_' pnum(1,3) '.jpg']);
imwrite(a2,F2);

showinfo2('thumbnail',F2);


%% ===============================================

lg={[ 'DATE: '  timestr(now) ]};
lg(end+1,1) ={['#import_TIFF [origin]: '  file]};
lg(end+1,1) ={['#import_TIFF [BART]  : '  fiout]};


% disp(char(lg))





% ==============================================
%  if copyfoldercontent
% ===============================================
if s.copyfoldercontent==1
    [files] = spm_select('FPList',pa,'.*');
    files=cellstr(files);
    
    for i=1:length(files)
        try
        [~, namex,extx]=fileparts(files{i});
        f2=files{i};
        f3=fullfile( fpoutDir, [namex,extx] );
        lg(end+1,1) ={['#import_other: [origin] '  f2 '  [BART] '  f3 ] };
        copyfile(f2,f3,'f');
        end
    end
end
% ==============================================
%%   save log
% ===============================================

filog=fullfile(fpoutDir,'logmsg.txt');
if exist(filog)==0
    pwrite2file(filog,lg);
else
    lg0=importdata(filog);
    pwrite2file(filog,[lg0; lg]);
end
    







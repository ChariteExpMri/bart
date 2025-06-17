




function varargout=cell2region2(showgui,x)
%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end
if exist('x')~=1;        x=[]; end

% ==============================================
%%   predefined images
% ===============================================
global ak
%%  generate list of nifit-files within pa-path
[pa] = spm_select('FPList',ak.dat,'dir');
pa=cellstr(pa);
fi2={};
siz=[];
for i=1:length(pa)
    [files,~] = spm_select('FPList',pa{i},['.*.csv$']);
    if ~isempty(files)
    files=cellstr(files);  
    fis=strrep(files,[pa{i} filesep],'');
    
    for j=1:length(files)
        fid = fopen(files{j});
        fseek(fid, 0, 'eof');
        filesize = ftell(fid);
        filesize=filesize/1e6;
        fclose(fid);
        siz=[siz; filesize];
    end
    fi2=[fi2; fis];
    end
end
% cordfiles=unique(fi2);
[cordfiles is]=unique(fi2);
siz=siz(is);
tbc  =[cordfiles num2cell(siz)];   tbc=cellfun(@(a){[num2str(a)  ]}, tbc);
htbc ={'cellFile' 'size(MB)'};


%% ===============================================


% ==============================================
%%   struct
% ===============================================

para={...
% 'inf1'    'TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
% '' '' '' ''
% 'image'  1       '[1] use original input image, [0]use  lowresscreenshot(jpg) from original  {0|1} '  'b'
% 'niftis2warp'                  ''         'select NIFTI-file(s); '  'mf'
% 'niftis2warp'      {''}       'select NIFTI-file(s) to warp to histoSpace'  {@selector2,li,{'NIFTI'},'out','list','selection','multi','position','auto','info','select NIFTI-image(s)'}

'cordinate_file'          {''}    'select cordinate-file (csv)' {@getCordfiles,tbc, htbc} 
% 'cordinate_file'          {''}    'select cordinate-file (csv)'  {@selector2,cordfiles,{'cellcountFile'},'out','list','selection','multi','position','auto','info','select cellcounts-file(s)'}
'cordinate_size'          2            'cordinate reference size defined by [1] input-image, [2] logfile ' {1 2}
'cordinate_headerlines'   'auto'  'number of header lines ( number or ''auto'' to autodetect number of header lines)'  {0 1 2 3 'auto'}
'cordinate_columns'       [2 3] 'columns of xy cordinate ; default: [2 3]  (columns: 2 & 3)' {'[1 2]'; '[2 3]' ;'[3 2]'}'

'mask'   ''   'optional, use binary mask (lesionmask)' {@getmaskfile} 

'' '' '' ''
'inf2' '___SAVE SETTINGS___' '' ''
'saveTable'               1   'save table as excelfile , {0|1}' 'b'
'save_prefix'            'counts_'   'file prefix of output table'   {'counts_'  'countsRegion_'}
'save_addCordinateFileNameString'   1   'add filename of cordinate_file to resulting filename' 'b'
'' '' '' ''
'inf3' '___PLOT SETTINGS___' '' ''
'showtable'               0   'show table with cell-counts , {0|1}' 'b'
'showplot'                0   'show plot with histo-image with cells, {0|1}' 'b'



};

% ==============================================
%% show GUI
% ===============================================
p=paramadd(para,x);%add/replace parameter
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.1 .2 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end
xmakebatch(z,p, mfilename); % ## BATCH
%% ===============================================
if showgui==1
    varargout{1}=z;
    if ischar(parse)==1 && strcmp(parse,'parse')
        showgui=-1;
    end
end
% ==============================================
%%   Parse parameter without runnning rest
% ===============================================
if showgui==-1
    p2=struct2param(p,z);
    p2=[{['@' mfilename] 0 'FunctionName' ''}; p2]; % add functionName
    varargout{1}=p2;
    return
end
% ==============================================
%%   files
% ===============================================
if isfield(x,'files') && ~isempty(char(x.files))
    z.files=x.files;
else
    fidi=bartcb('getsel')  ;
    z.files=fidi(strcmp(fidi(:,2),'file'),1);
end


z.templatePath=ak.template;
% ==============================================
%%   PROCEED
% ===============================================
cprintf([0 0 1],[' cell2region2. '  '\n']);
z.files=cellstr(z.files);
z.cordinate_file=cellstr(z.cordinate_file);
if isempty( char(z.files)); return; end
timex=tic;
for i=1:length(z.files)
    for j=1:length(z.cordinate_file)
        z2=z;
        z2=rmfield(z2,'files');
        z2.file=z.files{i};
        z2.cordinate_file=z.cordinate_file{j};
        
        localCordfile=(fullfile(fileparts(z2.file),z2.cordinate_file));
        if exist(localCordfile)==2
            subcell2region(z2);
        else
            disp(['not found:'   localCordfile ]);
        end
        
    end
end
cprintf([0 0 1],[' done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);

%% ============================================================================================
%%   subs
% =============================================================================================

function file=getCordfiles(tbc, htbc)
file='';
%  {@selector2,tbc,htbc,'out','list','selection','multi','position','auto','info','select cellcounts-file(s)'}
try
    %  %ix=selector2(tbc,htbc);
    % ix=selector2(fi2,{'maskFile'},'selection','multi','position','auto','info','select cellcounts-file(s)');
    ix=selector2(tbc, htbc,'selection','multi','position','auto','info','select cellcounts-file(s)');
    if ix(1)==-1; return; end
    file=tbc(ix,1);
end

function file=getmaskfile
%% ===============================================
file='';
try
    global ak
    %%  generate list of nifit-files within pa-path
    [pa] = spm_select('FPList',ak.dat,'dir');
    pa=cellstr(pa);
    fi2={};
    siz=[];
    for i=1:length(pa)
        [files,~] = spm_select('FPList',pa{i},['.*.nii$']);
        if ~isempty(files)
            files=cellstr(files);
            fis=strrep(files,[pa{i} filesep],'');
            
            for j=1:length(files)
                fid = fopen(files{j});
                fseek(fid, 0, 'eof');
                filesize = ftell(fid);
                filesize=filesize/1e6;
                fclose(fid);
                siz=[siz; filesize];
            end
            fi2=[fi2; fis];
        end
    end
    fi2=unique(fi2);
    %ix=selector2(fi2,{'maskFile'});
    ix=selector2(fi2,{'maskFile'},'selection','single','position','auto','info','select maskfile');
    if ix(1)==-1;
        return;
    end
    file=fi2(ix,1);
end
%% ===============================================

 


function subcell2region(z)

warning off
timeTot=tic;

[z.pa z.name ext]=fileparts(z.file);           %name: "'a1_004'"
z.numberstr      =regexprep(z.name,'.*_','_'); % such as '_004'
[~,z.animal]     =fileparts(z.pa);
z.fin_prefix     =[regexprep(z.name,'^a1_', 's') '_'];


try
    cprintf([0 0 1],['  [' mfilename  ']: ']);
    cprintf([1 0 1],['processing "[' z.name ']" of "'  strrep(z.pa,[filesep],[filesep filesep])   '"\n']);
catch
    fprintf(['  [' mfilename  ']: ']);
    fprintf(['processing "[' z.name ']" of "'  strrep(z.pa,[filesep],[filesep filesep])   '"\n']);
end


%% =======[read data]========================================
cordfile       =fullfile(z.pa,z.cordinate_file);
numheaderlines =z.cordinate_headerlines;
% ======[alternative readin if header is unclear]=========================================
if ischar(numheaderlines) && strcmp(numheaderlines,'auto')
    a0=preadfile(cordfile);
    a0=a0.all;
    for jj=1:min([size(a0,1), 100] )
        val=str2num(char(a0(jj)));
        if ~isempty(val)
            break;
        end
    end
    disp(['  num of headerlines: ' num2str(jj)-1 ]);
    a=str2num(char(a0(jj:end)));
else
    a=csvread(cordfile,numheaderlines); 
end
siz=size(a);%[transpose]
if siz(2)>siz(1);  a=a'; end
siz=size(a);
%% =====[assign x-y-column]==================================
% co=a;
% if size(a,2)>2 && max(diff(a(:,1)))==1  % here: 3-columns, 1st is a CLL-ID which is increasing 
% co=a(:,[ 2 3]);
% end
% co=co(:,[2 1]);
co=a(:,z.cordinate_columns);
co=co(:,[2 1]);
% ==============================================
%%   get size
% ===============================================
% [z.pa name ext]=fileparts(z.file);
pafin=fullfile(z.pa,'fin');
% f1=fullfile(pafin, 's001_AVGT.mat');
f1=fullfile(pafin,[z.fin_prefix 'AVGT.mat']);
b=load(f1);
size_histo=size(b.v);


hi=imfinfo(z.file);
z.size_histo= [hi.Height hi.Width]  ;%[ 16648       11146]

% ==============================================
%   get alternative size from logfile
%  get targetsize by logfile (c.finalsize==2)
% ===============================================
if z.cordinate_size==2 % logfile
    lfile=fullfile(z.pa, 'logmsg.txt');
    if exist(lfile)==2
        l=preadfile(lfile); l=l.all;
        [xpa xname xext]= fileparts(z.file);
        tifname_orig=[xname xext];
        
        iv=regexpi2(l,['#import_TIFF \[BART\].*' tifname_orig]);
        iv_orig=iv-1;
        %raw_img={'F:\data5_histo\markus_Tet2_Batch1\raw\Tet2_m006_A_2_1_DAPI\Tet2_m006_A_2_1_DAPI.tif'};
        raw_img=l{iv_orig};
        raw_img=regexprep(raw_img,'.*\[origin\]:\s+','');
        
        [~,rawTifname,~]=fileparts2(raw_img);
        if length(rawTifname)==1
            rawname=[char(rawTifname) ,'.txt'  ];
            configfile=fullfile(z.pa, rawname);
            if exist(configfile)==2
                k=preadfile(configfile); k=k.all;
                iv=regexpi2(k,'^size:');
                if ~isempty(iv)
                    target_size=str2num(char(regexprep(k{iv},{'size:', 'x' },{'', ' '})));
                    % --obtain correct order of WxH  
                    inputsize=[hi.Height hi.Width];
                    ratiosWH=[...
                        target_size./inputsize; 
                        fliplr(target_size)./inputsize];
                    diffratiosWH=sqrt((ratiosWH(:,1)-ratiosWH(:,2)).^2);
                    fliporder_WH=0;
                    if min(find(diffratiosWH==min(diffratiosWH)))==2  % flip order : The Graphics' industry standard is width by height
                        target_size=  target_size([2 1]);
                    end
                    z.size_histo_inputimage =[hi.Height hi.Width];
                    z.size_histo            =target_size;
                    disp([sprintf('  image-SIZE: input: [%d x %d] , logSize: [%d x %d]',z.size_histo_inputimage,z.size_histo  )]);
                    
                end
                
            else
                error(['configfile <' rawname  '>  not found in path']);
            end
            
        else
            error(['more than one raw-file found']);
        end
        
    end
end


% ==============================================
%%   macth cordinates with intern size
% ===============================================
if z.cordinate_size==2 % logfile
    factor=z.size_histo./z.size_histo_inputimage;
    co2=co./repmat(factor,[size(co,1) 1]);
else
    co2=co;
end




%% ===============================================

% f2=fullfile(pafin,'s001_REF.mat');
f2=fullfile(pafin,[z.fin_prefix 'REF.mat']);
b2=load(f2);
% fg,imagesc(b2.v);

if 0
    fg;imagesc(b.v);
    hold on;
    plot(co2(:,2),co2(:,1),'r.');
end

%% =====check  super large image==========================================
if 0
    q=imresize(b2.v, [z.size_histo]);
    fg;imagesc(q);
    hold on;
    plot(co(:,2),co(:,1),'r.');
end


%% ===============================================


% plot(co2(1,1),co2(1,2),'go','markersize',4,'markerfacecolor','g')
% disp(['first CORD: '  num2str(round(co2(1,:)))   ]);
%  ix=100
%  co_1=round([co2(ix,1),co2(ix,2)])
% % b.v(co_1(1),co_1(2))
% 
% plot(co_1(1,2),co_1(1,1),'go','markersize',4,'markerfacecolor','g')
% disp(['first CORD: '  num2str(round(co2(1,:)))   ]);
%% ===============================================
co3=round(co2);
% co3=co3(randi(size(co3,1),  10, 1),:)
ind = sub2ind(size(b.v),co3(:,1),co3(:,2));
% d=zeros( numel(b.v),1);
d=zeros( size(b.v));
d(ind)=1;
if 0
    fg;
    imoverlay(b.v,imdilate(d,ones(4)));
end


% Fo_img=fullfile(pafin, [  'test.jpg']  )
% bt=imfuse(b.v,imdilate(d,ones(4)));
% imwrite(bt,Fo_img);
% showinfo2('img', Fo_img)


%% ===============================================

% ==============================================
%%   get counts
% ===============================================
% fano =fullfile(pafin,'s001_ANO.mat');
% fhemi=fullfile(pafin,'s001_AVGThemi.mat');
fano   =fullfile(pafin,[z.fin_prefix 'ANO.mat']);
fhemi  =fullfile(pafin,[z.fin_prefix 'AVGThemi.mat']);
ano=load(fano);
hem=load(fhemi);

[ids] = unique(ano.v);% all Slice-IDs
ids(ids==0)=[];
hemval=hem.v(ind);
anoval=ano.v(ind);

% ===using a mask-file============================================
maskname='';
z.mask=char(z.mask);
if isempty(z.mask)
    le=anoval.*(hemval==1);
    ri=anoval.*(hemval==2);
    
else
    [~, maskname]=fileparts(z.mask);
    fmask  =fullfile(pafin,[z.fin_prefix [maskname '.mat']]);
    if exist(fmask)
        mask=load(fmask);
        mask.v=double(mask.v>0.5); % to be shure to binarize
        maskval=mask.v(ind);
        
        le=anoval.*(hemval==1).*maskval;
        ri=anoval.*(hemval==2).*maskval;
    else
        cprintf('*[1 0 1]',['  not found [' z.animal  ']: ' strrep(fmask,filesep,[filesep filesep]) '\n']);
        return
    end
    
end

% ===============================================


le_counts = histc(le, ids);
ri_counts = histc(ri, ids);

% ==============================================
%%   get regions-based number of voxels -->later calc to area
% ===============================================
ind2=find(hem.v>0);
hemval=hem.v(ind2);
anoval=ano.v(ind2);
le=anoval.*(hemval==1);
ri=anoval.*(hemval==2);
le_counts2 = histc(le, ids);
ri_counts2 = histc(ri, ids);

%% ===============================================
% % Sample array with repeated integers
% A =val;% [3, 1, 2, 3, 1, 3, 2, 2, 2, 1];
% [u, ~, idx] = unique(A);% Find unique values
% % Count occurrences of each unique value
% counts = histc(A, u);
% disp(table(u(:), counts(:), 'VariableNames', {'Value', 'Count'}));% Display results

% ==============================================
%%   get area of mask
% ===============================================
% ======[path]=========================================
% global ak
% pa=z.pa
nametag_dl=regexprep(z.name,'a1_','a3_');
nametag_manwarp=regexprep(z.name,'a1_','a4_');
path_dl=fullfile(z.pa,[ 'deepsl_' nametag_dl  ]);
file_dlest=fullfile(path_dl,'');
file_xml  =fullfile(file_dlest,'est.xml');

% ==============================================
%%   use slice from deepslice
% ===============================================
clear g;
[co st]=getestimation_xml(file_xml,'loadhistoimage',1); %get histoImage
% fi1= fullfile(ak.template,'AVGT.nii')
fi1  = fullfile(z.templatePath,'AVGThemi.nii');
h    =spm_vol(fi1);
vmat =spm_imatrix(h.mat);
vox  =vmat(7:9);

g.mask =getslice_fromcords(fi1,co,  st.histo_size, 0);
g.template_mask     =imresize(g.mask, [h.dim([2 3])]   ,'nearest' );
g.template_voxels   =length(find(g.template_mask>0));
g.template_voxres2D =vox(2:3);
g.template_voxres   =prod(g.template_voxres2D);
g.template_area     =g.template_voxres*g.template_voxels;
% ===============================================
g.histo_voxels      =length(find(hem.v>0));
g.histo_voxres      = g.template_area/g.histo_voxels;
g.histo_voxres2D    =repmat(sqrt(g.histo_voxres),[1 2]);

% ==============================================
%   calc area
% ===============================================
le_area=le_counts2.*g.histo_voxres;
ri_area=ri_counts2.*g.histo_voxres;
% ==============================================
%   calc density
% ===============================================
le_dens=le_counts./le_area;
ri_dens=ri_counts./ri_area;
le_dens(isnan(le_dens))=0; %remove nans
ri_dens(isnan(ri_dens))=0;

% ==============================================
%%   get labels
% ===============================================
fatlas=fullfile(z.templatePath,'ANO.xlsx');
[~,~,a0] =xlsread(fatlas);
a0=xlsprunesheet(a0,1);
hat=a0(1,:);
at=a0(2:end,:);
atids=cell2mat(at(:,4));

regs=repmat({''},[ length(ids) 1 ]);
for j=1:length(ids)
   ix= find(atids==ids(j));
   regs(j,1)=at(ix,1);
end


% ==============================================
%%   table
% ===============================================
ht1={'region' 'regID' 'counts_L' 'counts_R'  'regionpixel_L' 'regionpixel_R'   'area_L' 'area_R'  'density_L' 'density_R'};
dx=[ids le_counts ri_counts  le_counts2 ri_counts2 le_area ri_area  le_dens  ri_dens];
t1=[regs num2cell(dx)  ];
if z.showtable==1
    title_tb=['cellcounts: ' z.animal ' [' z.name '] ' z.cordinate_file  ];
    %uhelp(plog([],[ht1; t1],0, title_tb,'s=1;al=1;'),1);
    ic_sort=find(strcmp(ht1,'density_L'));
    uhelp(plog([],[ht1; flipud(sortrows(t1,ic_sort))],0, [title_tb ' (sorted)'],'s=1;al=1;'),1);
end

% uhelp(plog([],[ht1; flipud(sortrows(t1,3))],0, 'cellcounts','s=1;al=1;'),1);


% ==============================================
%%   save table
% ===============================================
[~,cellcountNameIn,~]=fileparts(z.cordinate_file);
if z.save_addCordinateFileNameString==0;            cellcountNameIn='';    end
if isempty(maskname)
    masknameTag='';
else; masknameTag=[ '_' maskname   ];
end
nameout=[  z.save_prefix   cellcountNameIn masknameTag '.xlsx'];
Fo1=fullfile(pafin,nameout );

% image for JPG, and to show
f3=fullfile(pafin,[z.fin_prefix 'REF.mat']);
r=load(f3);
imgsize=[2000 2000];
if isempty(z.mask)
    br=imfuse(   imresize(r.v,imgsize)  ,  imresize(imdilate(d,ones(3)),imgsize,'nearest')    );
else    
    br=imfuse(   imresize(r.v,imgsize)  ,  imresize(mask.v.*imdilate(d,ones(3)),imgsize,'nearest')    );
end
% br=imresize(br,[2000 2000]);
% % % % if isempty(z.mask)
% % % %     br=imfuse(r.v,          imdilate(d,ones(3)));
% % % % else    
% % % %     br=imfuse(r.v,  mask.v.*imdilate(d,ones(3))); 
% % % % end
% % % % br=imresize(br,[2000 2000]);
% fg,imagesc(br)



% bt=imfuse(b.v,imdilate(d,ones(4)));
% bt=imresize(bt,[2000 2000]);

if z.saveTable==1
    if exist(Fo1)==2;         delete(Fo1);     end;
    % ===============================================
    l={'animal'          z.animal
        'slice'          z.name
        'path'           z.pa
        'cordinate_file' z.cordinate_file
        'tifName'        raw_img
        'mask'           z.mask
        'date'           datestr(now);
        };
    hl={'info' ''};
    pwrite2excel(Fo1,{1 'info'},hl,[],l);
    pwrite2excel(Fo1,{2 'cellcounts'},ht1,[],t1);
    showinfo2('  ..saved excelfile',Fo1);
    
    % ======[save plot]=========================================
    Fo2=strrep(Fo1,'.xlsx','.jpg');
    imwrite(br,Fo2);
    showinfo2('  ..saved jpg', Fo2);
end
%% ===============================================

if z.showplot==1
   fg,imagesc(br);
   axis off; 
   masktag='';
   if ~isempty(maskname); 
       masktag=[  ' (mask:'  maskname ')' ]; 
   end
   ti=title([ ['cells: ' z.animal ' [' z.name '] ' z.cordinate_file    masktag ]  ]);
   set(ti,'interpreter','none','fontsize',7);
end

%% ===============================================




%% ===============================================


% ==============================================
%%   msg
% ===============================================
try
    cprintf([0 .5 0],['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
catch
    fprintf(['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
end




















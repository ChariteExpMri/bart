
function cell2region(p0)
% cf; 
warning off

% ==============================================
%%   test
% ===============================================



% ==============================================
%%   struct-parameter
% ===============================================
p.file         ='';
p.plot         =1;
p.save         =1;

% ==============================================
%%   test
% ===============================================
if 0
    cprintf([0 0 1],['TESTMODE!!!!\n']);
    p0.file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_001.tif';


end
% ==============================================
%%   
% ===============================================

p=catstruct(p,p0);
% ==============================================
%%   
% ===============================================


[px name ext]=fileparts(p.file); %check path of atlasregistration
findir=fullfile(px,'fin');
if exist(findir)~=7; 
    disp(['"fin-dir" not found for: [' p.file ']']); return
end
cellfile=fullfile(px,['cellcounts_' name],'predmsk.tif');
if exist(cellfile)~=2; 
    disp(['cellfile "predmsk.tif" not found for: [' p.file ']']); 
    disp('..run cell-detection before using this function!');
    return
end

disp(['regionwise cellcounting: ' p.file ]);

% ==============================================
%%   load cell-count image
% ===============================================
c=imread(cellfile);
% c=mat2gray(c);
c=c(:,:,1);
c_temp=imdilate(c,ones(5));
% fg; imagesc(c_temp);

% ==============================================
%%   
% ===============================================
name2=strrep(name,'a1_','s');
% dir(fullfile(findir,[name2 '*']))

% s001_ANO.mat              
% s001_AVGThemi.mat       
% s001_AVGT.mat 
% s001_HISTO.mat  
% % -----
% s001_ANO_affine.mat 
% s001_AVGT_affine.mat      
% s001_AVGThemi_affine.mat 
% ==============================================================================
% ==============================================
%%  [1] warp data -cellCOUNTS
% ===============================================
% ==============================================================================


f_ano =fullfile(findir,[ name2 '_ANO.mat']);
f_hemi=fullfile(findir,[ name2 '_AVGThemi.mat']);

if exist(f_ano)~=2;     disp(['warped "ano" does not exist']); return ;end
if exist(f_hemi)~=2;     disp(['warped "hemi" does not exist']); return ;end

an=load(f_ano);
he=load(f_hemi);
% ==============================================
%%   cell-counts
% ===============================================
c2 =   c(:)>0;
an2=an.v(:);
he2=he.v(:);

cl=c2.*(he2==1).*an2;
cr=c2.*(he2==2).*an2;

cl2=cl; cl2(cl2==0)=[];
cr2=cr; cr2(cr2==0)=[];

ul=unique(cl2);
ur=unique(cr2);
ids=unique([ul;ur]);

nl=histc(cl2,ids);
nr=histc(cr2,ids);

t1=[ids nl nr];

% ==============================================
%%   check histc_readout
% ===============================================
if 0
    t1_chk=zeros(size(t1));
    for i=1:length(ids)
        t1_chk(i,:)=  [ ids(i) length(find(cl==ids(i)))  length(find(cr==ids(i)))];
    end
    cheksum=(t1-t1_chk)
end
% ==============================================================================
% ==============================================
%%  [2] warp data-regionwise pixelCounts
% ===============================================
% ==============================================================================
al=(he2==1).*an2;
ar=(he2==2).*an2;

al2=al; al2(al2==0)=[];
ar2=al; ar2(ar2==0)=[];

vwl=histc(al2,ids); %voxels warped LEFT and RIGHT
vwr=histc(ar2,ids);
tw=[ids vwl vwr];
% ==============================================================================
% ==============================================
%%  [3] affine data-regionwise pixelCounts
% ===============================================
% ==============================================================================
f_ano =fullfile(findir,[ name2 '_ANO_affine.mat'     ]);
f_hemi=fullfile(findir,[ name2 '_AVGThemi_affine.mat']);

if exist(f_ano)~=2;     disp(['affine "ano" does not exist']); return ;end
if exist(f_hemi)~=2;    disp(['affine "hemi" does not exist']); return ;end

anf=load(f_ano);
hef=load(f_hemi);
an2=single(anf.v(:));
he2=single(hef.v(:));
al=(he2==1).*an2;
ar=(he2==2).*an2;
al2=al; al2(al2==0)=[];
ar2=al; ar2(ar2==0)=[];

val=histc(al2,ids); %voxels affine LEFT and RIGHT
var=histc(ar2,ids);
ta=[ids val var];

% ==============================================================================
% ==============================================
%%  [4] make table
% ===============================================
% ==============================================================================
imgnum=str2num(regexprep(name2,'s',''));
t2=[repmat(imgnum,[length(ids) 1])  t1 ta(:,2:3) tw(:,2:3)];
v=struct();
v.t=t2;
v.ht={'imgNum' 'ID' 'ccL' 'ccR' 'affNpixL' 'affNpixR' 'warpNpixL' 'warpNpixR'};


if p.plot==1
    uhelp(plog([],[v.ht;num2cell(v.t)],0, p0.file),1);
end

% ==============================================
%%   save results
% ===============================================


if p.save==1
    pz=fullfile(px,'fin');
    fiout=fullfile(pz,[name2 '_cellcountsRegion.mat']);
    save(fiout,'v');
    
end



          




















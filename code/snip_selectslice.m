
function snip_selectslice
clc

file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\warp_001.mat';


% ==============================================
%%   add paths
% ===============================================
pa_template=strrep(which('bart.m'),'bart.m','templates');
if isempty(which('@slicedetection.m')) %set paths
    pabart=fileparts(which('bart.m'));
    addpath(pabart);
    addpath(genpath( fullfile(fileparts(which('bart.m')),'slicedetection')  ));
end
% % ==============================================
% %%   get ATLAS and mask by Atlasmask
% % ===============================================
% disp('...getting template');
% if 0
%     [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
% end
% if 1
%     [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
%     [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
%     cv=cv.*uint8(cvmask);
% end

% ==============================================
%%   
% ===============================================
load(file);
% ==============================================
%%   
% ===============================================

clear global bf
global bf
bf.ismodified=0;
bf.ss=ss;
bf.file=file;

bf.cmap={'gray' 'hot' 'parula','jet'};
bf.cmapValue=1;
bf.sortcolumn=5;
%===================================================================================================



%===================================================================================================




makefigure();
makelist();

updateplot(1);
sortafter([],[], bf.sortcolumn);

% ==============================================
%%   updateplot
% ===============================================
function updateplot(num)

ax1=findobj(gcf,'tag','ax1');

global bf
% if exist('')
fignum=bf.tb(num,1);
cla;
hc=findobj(gcf,'tag','cmap'); hc=hc(1);
% % % get(hc)
imoverlay(bf.ss.q(:,:,fignum),bf.ss.hi,[],[],hc.String{hc.Value},[],ax1);
set(gca,'tag','ax1');
axis off;

function lb1_cb(e,e2)
if strcmp(get(gcf,'selectiontype'),'open')
%     disp('here you write write code, which you wanna be executed afer double-click');
    
    us=get(gcf,'userdata');
    mod(us.toggle,2)
    if mod(us.toggle,2)==0
        set(us.hF,'AlphaData',1);%ones(size(us.alphadata)));%'R'
    else
        set(us.hF,'AlphaData',us.alphadata.*0);%'L'
    end
    us.toggle=us.toggle+1;
    set(gcf,'userdata',us);
    
    
else
    hl=findobj(gcf,'tag','lb1');
    listnum=hl.Value;
    updateplot(listnum);
 end

% ==============================================
%%   list
% ===============================================
function makefigure()
global bf
delete(findobj(gcf,'tag','selectbest'));
fg;
set(gcf,'units','norm','tag','selectbest');
set(gcf,'position',[  0.2500    0.2267    0.5549    0.6100]);
set(gcf, 'name','selectSlice','numberTitle','off');
f2=gcf;
ax1=axes('position', [0.2 .5 .7 .4],'tag','ax1');
set(gca,'position',[0.0029    0.2000    0.6300    0.7600],'tag','ax1');
% imoverlay(ss.q(:,:,1),ss.hi,[],[],[],[],ax1);
set(gca,'tag','ax1');
axis off;
% LISTBOX
hl=uicontrol('style','listbox','units','norm');
set(hl,'position',[ 0.6300    0.2000    0.3800    0.7600],'tag','lb1');
set(hl,'callback',@lb1_cb,'fontname','courier','fontsize',8);

%%  cmap 
hb=uicontrol('style','popupmenu','units','norm','tag','cmap');
set(hb,'position', [0.92109 0.965 0.0793 0.0289],'callback',@cmap_cb);
set(hb,'string',bf.cmap);
set(hb,'value',bf.cmapValue);

%%  sort 
hb=uicontrol('style','popupmenu','units','norm','tag','sortafter');
set(hb,'position',[0.67204 0.965 0.12 0.0289],'callback',@sortafter);
set(hb,'string',{'ImgNumber' 'Slice' 'Pitch' 'YAW' 'HOGwarp' 'MIwarp' 'HOGaffine'});
set(hb,'value',1);


%% find slice manally
hb=uicontrol('style','pushbutton','units','norm','tag','findslice_manually');
set(hb,'position',[0.0113    0.1557    0.0793    0.0388]);
set(hb,'string','find manually','callback', @findslice_manually);
%% get slicing parameter(from manal)
hb=uicontrol('style','pushbutton','units','norm','tag','getslice_paramter_manually');
set(hb,'position',[0.0939    0.1557    0.1000    0.0388]);
set(hb,'string','get parameter','callback', @getslice_paramter_manually);
%% edit new slicing parameter(from manal)
hb=uicontrol('style','edit','units','norm','tag','edit_slice_paramter_manually');
set(hb,'position',[0.1965    0.1557    0.2501    0.0363]);
set(hb,'string','','fontsize',8);
%% pb warp slice
hb=uicontrol('style','pushbutton','units','norm','tag','warp_slice');
set(hb,'position',[ 0.4480    0.1539    0.0793    0.0403]);
set(hb,'string','warp slice','callback', @warp_slice,'backgroundcolor',[0.9294    0.6941    0.1255]);


%% pb accept
hb=uicontrol('style','pushbutton','units','norm','tag','accept');
set(hb,'position',[ 0.8898    0.0865    0.0793    0.0403]);
set(hb,'string','accept','callback', @accept,...
    'backgroundcolor',[ 0.4667    0.6745    0.1882]);

%% pb cancel
hb=uicontrol('style','pushbutton','units','norm','tag','cancel');
set(hb,'position',[ 0.8047    0.0865    0.0793    0.0403]);
set(hb,'string','cancel','callback', @cancel);

function cancel(e,e2)
close(gcf);

function accept(e,e2)
global bf
hl=findobj(gcf,'tag','lb1');
bestID=hl.Value;

row=bf.tb(bestID,:);

slice=bf.ss.q(:,:,row(1));
ref   =imresize(bf.ss.img,[size(slice)]);

% ==============================================
%%   save info
% ===============================================

[pa name ext]=fileparts(bf.file);
nameout1=['bestslice_' regexprep(name,'.*_','') '.mat'];
fileout1=fullfile(pa,nameout1);

s2=struct();
s2.file  =bf.file;
s2.hog   =row(5);
s2.mi    =row(6);

s2.q     =uint8(slice);
s2.ref   =ref;
s2.param =row(2:4);
s2.ix    =row(1);

cprintf([0 0 1],['Best-Slice : ' sprintf('[%d] %2.2f %2.2f %2.2f ',row(1),row(2:4))  '\n']);
disp(['..saving: ' fileout1 ]);
save(fileout1,'s2');

% ==============================================
%%   animated gif
% ===============================================

nameout2=['bestslice_' regexprep(name,'.*_','') '.gif'];
fileout2=fullfile(pa,nameout2);
disp(['..make gif: '  nameout2]);

ref2=imresize( imadjust(s2.ref)  ,[1.5]);
img2=imresize( imadjust(s2.q)  ,[1.5]);
tx=text2im(sprintf('%2.2f %2.2f %2.2f',s2.param));
tx=imcomplement(tx);
% col=[0.4667    0.6745    0.1882];
% tx2=uint8(zeros([size(tx,1)  size(ref2,2) 3]));
tx2=uint8(  zeros([size(tx,1)  size(ref2,2) 1])   )  ;
tx2(:, 1:size(tx,2),1 )=round(tx.*255);

ref2=[tx2; ref2 ];
img2=[tx2; img2 ];

try
    imwrite(ref2  ,fileout2,'gif', 'Loopcount',inf);
    imwrite(img2  ,fileout2,'gif','WriteMode','append');
    disp('image written');
catch ME
    
    uiwait(msgbox({ME.message '---> CLOSE IMAGE-VIEWER to proceed!!'},'ERROR','modal'));
    try
        imwrite(ref2  ,fileout2,'gif', 'Loopcount',inf);
        imwrite(img2  ,fileout2,'gif','WriteMode','append');
        disp('image written');
    catch
        disp('..could not write gif-image')
    end
end

% ==============================================
%%   update list if manual warping was performed
% ===============================================
hl=findobj(gcf,'tag','lb1');
if bf.ismodified==1
    disp('..saving struct');
    
    
    ss=bf.ss;
    nameout3=['warp_' regexprep(name,'.*_','') '.mat'];
    fileout3=fullfile(pa,nameout3);
    save(fileout3,'ss');
    
    
end

close(gcf);


% ==============================================
%%   list
% ===============================================
function makelist()
global bf
ss=bf.ss;
%  num  slic, ang1,ang2, hog, mi, hogAffine 
tb=[ [1:size(ss.q,3)]'  ss.s(:,1:3)    [ss.hog ss.mi  ss.s(:,4)]   ];

ls=repmat({''},[size(ss.q,3) 1]);
for i=1:size(ss.q,3)
    par=sprintf(' <span style="background-color:#FFFFE0;"> %5.1f %5.1f %5.1f</span>',tb(i,2:4));
    met=sprintf(' %6.3f</b> %6.3f %6.3f',tb(i,5:7));
 ls{i,1} = ['<html><pre><font color=blue><b>' pnum(i,3) ':' '<font color=black>' par ...
    '<font color=green>' met  ];
end

% ls=strrep(ls,'','&nbsp;');
hl=findobj(gcf,'tag','lb1');
set(hl,'string',ls);

bf.tb=tb;
bf.ls=ls;


function getslice_paramter_manually(e,e2)
he=findobj(gcf,'tag','edit_slice_paramter_manually');
hf3=findobj(0,'tag','histview');
newparams=get(findobj(hf3,'tag','ed_values'),'string');
set(he,'string',newparams);

function cmap_cb(e,e2)
hl=findobj(gcf,'tag','lb1');
listnum=hl.Value;
updateplot(listnum);

function sortafter(e,e2, column)
hr=findobj(gcf,'tag','sortafter');
if exist('column')==1
    col2sort=column;
    hr.Value=col2sort;
else
    
    col2sort=hr.Value;
end
hb=findobj(gcf,'tag','lb1');
currentString=hb.String{hb.Value};
global bf

[~,isort]=sort(bf.tb(:,col2sort));
bf.ls=bf.ls(isort);
bf.tb=bf.tb(isort,:);
newValue=min(find(strcmp(bf.ls,currentString)));
if exist('column')==1
    newValue=1;
end
set(hb,'string',bf.ls,'value',newValue);

function findslice_manually(e,e2)

global bf
hb=findobj(gcf,'tag','lb1');
cord=bf.tb(hb.Value,[2:4]);
%  cv=getappdata(gcf,'cv');
 global cv
if isempty(cv)
    disp('...loading 3d-template..');
    pa_template=strrep(which('bart.m'),'bart.m','templates');
   [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
%    setappdata(gcf,'cv',cv);
end
histview(cv,cord);



function warp_slice(e,e2)

he=findobj(gcf,'tag','edit_slice_paramter_manually');
par=str2num(he.String);
if isempty(par); msgbox('no parameter in edit-field found'); end

p.parameter=par; %[266.7753 32.4534 -33.36408]
global bf;
ss=bf.ss;
global cv
[s2 ]=warpestSlice_single(p,ss,cv);


% ==============================================
%%   update
% ===============================================
ix_old=size(ss.q,3);
ix_new=ix_old+1;
% ==============================================
%%   update
% ===============================================
disp('...updating struct ');
bf.ismodified=1;
ss.q(:,:,ix_new) =s2.q;
ss.hog(ix_new,1) =s2.hog;
ss.mi(ix_new,1)  =s2.mi;
ss.s(ix_new,:)   =[ p.parameter  nan ];
hr=findobj(gcf,'tag','sortafter');
previousSortID=get(hr,'value');
bf.ss=ss;
bf.sortcolumn=1;
makelist();

hl=findobj(gcf,'tag','lb1');
set(hl,'value',ix_new);
line=hl.String(ix_new);


% set(hr,'value',1);
sortafter([],[],previousSortID);

ix_resorted=find(strcmp(hl.String,line));
set(hl,'value',ix_resorted);
updateplot(ix_resorted);


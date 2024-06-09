
% no help here

function manwarp2d(varargin)

% addpath('F:\data5_histo\test_deepslice\nonrigid_version23');
%% ===============================================

p.busy     =1;
p.warpfile =[];
p.warpfile2=[];
p.xmlfile  =[];
p.fixfile  =[];
p.pntfile  =[];
% ------
p.dot_col         =[1 1 0];
p.refdot_col      =[1 0 0];
p.dotline_col     =[0 1 0];
% -------
p.dot_marksize    =5;
p.refdot_marksize =3;
p.dotline_lw      =1;

p.checker_pixel   =1;
p.downsamplefactor=1 ;
% ----
% p.ovlmode='check';
p.ovlmode='overlay';
p.ovlalpha=0.5;

p.axis='image';
% ---
p.outdir     ='';
p.pnt_out    ='fixpoints.txt';
p.oname_suffix ='_warped';
p.savewarpimage=1;


%% ===============================================
if ~isempty(varargin)
    pin =cell2struct(varargin(2:2:end),varargin(1:2:end),2);
    p=catstruct(p,pin);
end

u=p;
%% ===============================================
% ==============================================
%%   tests
% ===============================================

if 0
    cf; clc
    warning off
    addpath('F:\data5_histo\test_deepslice\nonrigid_version23');
    
    pain        =fullfile('C:\paul_projects\python_deepslice\paul_histoIMG\test3');
    warpfile    ='F:\tools\bart_template\AVGT.nii';
    warpfile2   ='F:\tools\bart_template\ANO.nii';
    xmlfile     =fullfile(pain,'est.xml');
    fixfile     =[];
end
if 0
    %% ===============================================
    pain   ='C:\paul_projects\python_deepslice\paul_histoIMG\test3'
    f1     ='F:\tools\bart_template\AVGT.nii';
    f2      ='F:\tools\bart_template\ANO.nii';
    f3     =fullfile(pain,'est.xml');
    
    manwarp2d('warpfile',f1,'warpfile2',f2,'xmlfile',f3,'outdir',pwd,'pnt_out' ,'dum.txt' );
    %  manwarp2d('warpfile',f1,'warpfile2',[],'xmlfile',f3)
    
    %% ===============================================
end
if 0
    %% ===============================================
    pain   ='C:\paul_projects\python_deepslice\paul_histoIMG\test4'
    f1     =fullfile(pain,'a1_s005.jpg')
    f2      =fullfile(pain,'test2.jpg')
    
    manwarp2d('fixfile',f1,'warpfile',f2,'outdir',pain,'pnt_out' ,'dum.txt' );
    %  manwarp2d('warpfile',f1,'warpfile2',[],'xmlfile',f3)
    
    %% ===============================================
end
if 0
    %% ===============================================
    pain   ='C:\paul_projects\python_deepslice\paul_histoIMG\test5'
    
    f1      =fullfile(pain,'l2.jpg')
    f2     =fullfile(pain,'l2.jpg')
    manwarp2d('fixfile',f1,'warpfile',f2,'outdir',pain,'pnt_out' ,'dum.txt' );
    %  manwarp2d('warpfile',f1,'warpfile2',[],'xmlfile',f3)
    
    %% ===============================================
end


% ==============================================
%%
% ===============================================

if exist(p.xmlfile)==2
    [co st]=getestimation_xml(p.xmlfile,'loadhistoimage',1); %get histoImage
    x.fiximg_file= st.histimage;
    x.movimg_file =p.warpfile;
    moveimg0 =getslice_fromcords(p.warpfile,co,  st.histo_size,1);
    
    a   =st.image;
    b   =uint8(mat2gray(moveimg0)*255);
    
else
    x.fiximg_file=p.fixfile;
    x.movimg_file =p.warpfile;
    [a ]=imread(p.fixfile);
    if size(a,3)==3;  a=rgb2gray(a); end
    
    [b]=imread(p.warpfile);
    if size(b,3)==3;  b=rgb2gray(b); end  
end

if 1
    % both exist (using mod-file)
    if exist(p.xmlfile)==2 && exist(p.fixfile)==2
        
        [anew ]=imread(p.fixfile);
        if sum(abs(size(anew)-size(a)))~=0
            anew=imresize(anew,size(a),'nearest');
        end
        a=anew;
        p.fixfile=[];
        
    end
end

%% ===============================================


x.fiximg_orig=a(:,:,1);
x.movimg_orig=b(:,:,1);
clear a b
x.fiximg_orig=uint8(round(255*imadjust(mat2gray(double(x.fiximg_orig)))));
x.movimg_orig=uint8(round(255*imadjust(mat2gray(double(x.movimg_orig)))));
% ===============================================

if ~isempty(p.warpfile2)
    anoimg      =getslice_fromcords(p.warpfile2,co,  st.histo_size,0);
    x.anoimg_orig=anoimg;
    x.anoimg_file=p.warpfile2;
    [anoimg]=pseudocolor2D(anoimg);
end

u.fiximg=x.fiximg_orig; %histoimg
u.movimg=x.movimg_orig;


u.moving_size_Orig=size(u.fiximg);
u.moving_size_display=round(u.moving_size_Orig./u.downsamplefactor);
if ~isempty(p.warpfile2)
    u.ano         = uint8(mat2gray(anoimg)*255);
    u.anoboundary = boundarymask(anoimg);
    
    bw=u.anoboundary;
    %bw=bwskel(bw);
    % q=imfill(bw,'holes');
   
    [w2]=smoothmask(bw, 2, 55);
    w2=imdilate(w2,ones(2));
    u.anoboundary =logical(w2);

    
end


x.info='base';
x.fiximg     =u.fiximg;
x.movimg     =u.movimg;
x.warped     =u.movimg;
if ~isempty(p.warpfile2)
    x.ano        =u.ano;
    x.anoboundary=u.anoboundary;
end

u.fiximg        =imresize(u.fiximg,[u.moving_size_display]);
u.movimg        =imresize(u.movimg,[u.moving_size_display]);
u.warped=u.movimg;
if ~isempty(p.warpfile2)
    u.ano           =imresize(u.ano,[u.moving_size_display]);
    u.anoboundary   =imresize(u.anoboundary,[u.moving_size_display]);
end




%% ===============================================

u.ndot=0;
%% ===============================================

u=makefig(u,x);
set(gcf,'userdata',u);

setimage_call();

% ==============================================
%%   read poinsfile ..if exist
% ===============================================
if exist(u.pntfile)==2
    d=preadfile(u.pntfile);
    d=str2num(char(d.all));
    
    hx=findobj(gcf,'tag','base');
    x=get(hx,'userdata');
    x.points_raw=d;
    set(hx,'userdata',x);
    
    d=d./u.downsamplefactor;
    for i=1:size(d)
        co    =d(i,[4 3]);
        co_ref=d(i,[2 1]);
        plotdots(co,co_ref);
    end
    move();
end



uiwait(gcf);


% ==============================================
%%   makefig
% ===============================================
function u=makefig(u,x)
delete(timerfindall('tag','timertoggle'));
delete(findobj(gcf,'tag','manwarp2d'));
fg;
set(gcf,'tag','manwarp2d','units','norm','menubar','none','name',[ '[' mfilename ']'],'NumberTitle','off');
set(gcf,'position',[0.3316    0.1439    0.5403    0.5656]);
image(imfuse(u.fiximg,u.movimg)); colormap gray
% axis off;
set(gca,'xColor','w','yColor','w');
set(gca,'xticklabels','','yticklabels','');
grid on;
set(gca,'linewidth',1);
axis(u.axis);

set(gca,'position',[0 0 1 1]);
% set(gca,'position',[0.1 0.1 .8 .8]);
% axis off;
hold on
set(gcf,'WindowKeyPressFcn',@keys);
set(gcf,'WindowButtonMotionFcn',@motion);
set(gcf,'CloseRequestFcn',[]);
set(gcf,'WindowButtonDownFcn', @mouseclicked);


% ls = addlistener(gcf,'CurrentCharacter','PostSet',@keys2);

UseMyKeypress(gcf,@keys)


% set(gcf,'userdata',u);
%% ===============================================

list={'histo' 'AVGT' 'overlay'  'check' 'edge'  'atlas' 'atlasboundary' 'fuse1' 'fuse2'  'toggle'};
if isempty(u.warpfile2)
    list= setdiff(list,{'atlas' 'atlasboundary'});
end
hb=uicontrol('style','listbox','string',list,'callback', @setimage_call,'units','norm');
set(hb,'position',[0.0025707 0.6 0.15 0.25],'units','norm','tag','setimage');
hb.Value=find(strcmp(list,u.ovlmode));
%% ====[check-pixsize]===========================================
hb=uicontrol('style','edit','string',u.checker_pixel,'tag','checker_pixelsize',...
    'callback', @checker_pixelsize,'units','norm');
set(hb,'position',[[0.96075 0.9449 0.03 0.025]]);
% ----
hb=uicontrol('style','text','units','norm','string','check-size', 'horizontalalignment','right',...
    'backgroundcolor','w');
set(hb,'position',[[0.87849 0.9449 0.08 0.025]]);


%% ===========[transparency]====================================
hb=uicontrol('style','edit','string',u.ovlalpha,'tag','transparency',...
    'callback', @transparency,'units','norm');
set(hb,'position',[0.95979 0.97633 0.03 0.025]);
% ----

hb=uicontrol('style','text','units','norm','string','transparency', 'horizontalalignment','right',...
    'backgroundcolor','w');
set(hb,'position',[[0.87625 0.97829 0.08 0.025]]);

%% ====[clear points]===========================================
hb=uicontrol('style','push','string','clear all points','tag','clearallpoints',...
    'callback', @clearallpoints,'units','norm');
set(hb,'position',[0.0057841 0.18271 0.1 0.03]);

%% ====[reset points]===========================================
hb=uicontrol('style','push','string','reset all points','tag','resetpoints',...
    'callback', @resetpoints,'units','norm');
set(hb,'position',[0.007064 0.21411 0.1 0.03]);

%% ====[fixpounts-outputname]===========================================
hb=uicontrol('style','edit','string',u.pnt_out,'tag','ed_outname',...
    'units','norm');
set(hb,'position',[0.87335 0.18857 0.1 0.025],'horizontalalignment','left','backgroundcolor','w');
% ----------
hb=uicontrol('style','text','units','norm','string','outfile', 'horizontalalignment','right',...
    'backgroundcolor','w');
set(hb,'position',[0.82708 0.18857 0.04 0.025]);
% ------------


%% ====[save points]===========================================
hb=uicontrol('style','push','string','save points','tag','savepoints',...
    'callback', @savepoints,'units','norm');
set(hb,'position',[0.82837 0.15517 0.08 0.025]);

%% ====[radio save warpe image]===========================================
hb=uicontrol('style','radio','string','save warpimage','tag','savewarpimage',...
    'units','norm','backgroundcolor','w');
set(hb,'position',[0.82841 0.222 0.12 0.025]);
set(hb,'value',u.savewarpimage)



%% ====[image axis]===========================================
hb=uicontrol('style','radio','string','image fit figure','tag','imgwholeScreen',...
    'callback', @imgwholeScreen,'units','norm','backgroundcolor','w');
set(hb,'position',[0.87849 0.90954 0.12 0.025]);
if strcmp(u.axis,'image');    set(hb,'value',0) ;else;  set(hb,'value',1);end

%% ====[zoom on]===========================================
hb=uicontrol('style','toggle','string','zoom','tag','zoomimage',...
    'callback', @zoomimage,'units','norm','value',0);
set(hb,'position',[0.82969 0.79961 0.08 0.035]);



%% ====[pointwise select]===========================================
hb=uicontrol('style','push','string','pointwiseselect','tag','pointwiseselect',...
    'callback', @pointwiseselect,'units','norm');
set(hb,'position',[0.007064 0.47735 0.12 0.025]);




%% ====[close fig]===========================================
hb=uicontrol('style','push','string','close','tag','closefig',...
    'callback', @closefig,'units','norm');
set(hb,'position',[0.093179 0.0098028 0.06 0.03]);

%% ====[help ]===========================================
hb=uicontrol('style','push','string','help','tag','xhelp',...
    'callback', @xhelp,'units','norm');
set(hb,'position',[0.007064 0.0098028 0.06 0.03]);


%% ====[colors]===========================================
% ----------
hb=uicontrol('style','text','units','norm','string','colors', 'horizontalalignment','right',...
    'backgroundcolor','w','foregroundcolor','b');
set(hb,'position',[0.83094 0.88007 0.04 0.025]);
% ------------
hb=uicontrol('style','push','string','fixPnt','tag','col_fixpnt',...
    'units','norm');
set(hb,'position',[0.83094 0.84471 0.05 0.035],'backgroundcolor','w','callback',{@setcolor,'col_fixpnt'});
set(hb,'cdata', [repmat(reshape(u.refdot_col,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);
% ------------
hb=uicontrol('style','push','string','newPnt','tag','col_newpnt',...
    'units','norm');
set(hb,'position',[0.88235 0.84471 0.05 0.035],'backgroundcolor','w','callback',{@setcolor,'col_newpnt'});
set(hb,'cdata', [repmat(reshape(u.dot_col,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);
% ------------
hb=uicontrol('style','push','string','line','tag','col_line',...
    'units','norm');
set(hb,'position',[0.93248 0.84471 0.05 0.035],'backgroundcolor','w','callback',{@setcolor,'col_line'});
set(hb,'cdata', [repmat(reshape(u.dotline_col,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);


%% ====[resize]===========================================
% ----------
hb=uicontrol('style','text','units','norm','string','resize Img', 'horizontalalignment','right',...
    'backgroundcolor','w','foregroundcolor','b');
set(hb,'position',[0.83094 0.71309 0.1 0.025]);
% ------------

list={'1' '1/2' '1/3' '1/4' '1/8' '1/16'  '1/25'};
hb=uicontrol('style','popupmenu','string',list,'tag','rd_resizeImg',...
    'units','norm');
set(hb,'position',[0.93762 0.71309 0.05 0.03],'backgroundcolor','w','callback',@rd_resizeImg,...
    'backgroundcolor','w');
df=find(str2num(char(list))-1./u.downsamplefactor==0);
hb.Value=df;

%% ====[menu]===========================================
mh = uimenu(gcf,'Label','Tools');
mh2 = uimenu(mh,'Label',' --not implmented', 'Callback',{@menubarCB, '--'});



%% ======store baseINFO=========================================
hb=uicontrol('style','push','string','BASE','tag','base',...
    'units','norm','backgroundcolor',[0 .5 0]);
set(hb,'position',[0.11888 0.96061 0.05 0.035]);
set(hb,'userdata',x);


function zoomimage(e,e2)
 hb=findobj(gcf,'tag','zoomimage');
 
 if hb.Value==1
     zoom on;
     set(hb,'backgroundcolor',[0.9294    0.6941    0.1255]);
 else
     zoom off;
      set(hb,'backgroundcolor',[0.9400    0.9400    0.9400]);
 end

function menubarCB(e,e2,task)
'---'
 

function pointwiseselect(e,e2)

%% ===============================================


u =get(gcf,'userdata');

% cpselect(MOVING,FIXED) 
[movp fixp]=cpselect(u.movimg,u.fiximg,'wait',true);


% movp=[  544.1250  319.8750
%   544.1250  423.8750
%   571.1250  378.8750
%   514.1250  373.8750
%   524.1250  346.8750
%   569.1250  349.3750]
% 
% fixp=[  512.7500  274.7500
%   512.7500  477.7500
%   591.7500  372.7500
%   436.7500  375.7500
%   454.7500  322.7500
%   574.7500  317.7500]
% 
d=[movp fixp ]

for i=1:size(d)
        co    =d(i,[3 4]);
        co_ref=d(i,[1 2]);
        plotdots(co,co_ref);
 end
move();


%% ===============================================


function deletePoints()

delete(findobj(gcf,'tag','dot'));
delete(findobj(gcf,'tag','dotline'));
delete(findobj(gcf,'tag','refdot'));

u =get(gcf,'userdata');
u.ndot=0;
set(gcf,'userdata',u);

function resetpoints(e,e2)
% 'a'
deletePoints();


hx=findobj(gcf,'tag','base');
u =get(gcf,'userdata');
x=get(hx,'userdata');
if ~isfield(x,'points_raw'); return; end
d=x.points_raw;

% hr=findobj(gcf,'tag','rd_resizeImg');


d=d./u.downsamplefactor;
for i=1:size(d)
    co    =d(i,[4 3]);
    co_ref=d(i,[2 1]);
    plotdots(co,co_ref);
end
move();

function rd_resizeImg(e,e2)
%% ===============================================

hx=findobj(gcf,'tag','base');
x=get(hx,'userdata');
u=get(gcf,'userdata');
% =get orig positions==============================================
pos=[];
for i=1:(u.ndot)
    hr=findobj(gcf,'tag','refdot','-and','userdata' ,i);
    
    if ~isempty(hr)
        
        hm=findobj(gcf,'tag','dot','-and','userdata' ,i);
        pos(end+1,:)=[hr.YData hr.XData  hm.Position([2 1])];  % !!!!!!!!!!!!!!!!!
    end
end
pos=pos.*u.downsamplefactor;
% remove positions
delete(findobj(gcf,'tag','dot'));
delete(findobj(gcf,'tag','dotline'));
delete(findobj(gcf,'tag','refdot'));
delete(findobj(gca,'tag','helpdot'));
% ---copy originals back to dir
u.downsamplefactor= 1/str2num(char(e.String{e.Value}));
u.fiximg     = imresize(x.fiximg,      [ u.moving_size_Orig./u.downsamplefactor ]) ;
u.movimg     = imresize(x.movimg,      [ u.moving_size_Orig./u.downsamplefactor ])  ;
u.warped     = imresize(x.warped,      [ u.moving_size_Orig./u.downsamplefactor ]) ;

if ~isempty(u.warpfile2)
    u.ano        = imresize(x.ano,         [ u.moving_size_Orig./u.downsamplefactor ]) ;
    u.anoboundary= imresize(x.anoboundary, [ u.moving_size_Orig./u.downsamplefactor ]) ;
end

hm=findobj(gca,'type','image');
% imagesc(u.fiximg); colormap gray
hm.CData=u.fiximg;
hold on;
set(gcf,'userdata',u);
drawnow
%% ======= plot points ========================================
d=pos./u.downsamplefactor;
for i=1:size(d)
    co    =d(i,[4 3]);
    co_ref=d(i,[2 1]);
    plotdots(co,co_ref);
end
move();



%% ===============================================
function mouseclicked(e,e2)


persistent chk
if isempty(chk)
      chk = 1;
      pause(0.5); %Add a delay to distinguish single click from a double click
      if chk == 1
          %fprintf(1,'\nI am doing a single-click.\n\n');
          chk = [];
      end
      
else
      chk = [];
      %fprintf(1,'\nI am doing a double-click.\n\n');
      if strcmp(get(gcf,'SelectionType'),'open')
          doubleclicked
      end
end

function doubleclicked(obj,evt)


    co=get(gca,'CurrentPoint');
    co=round(co(1,1:2));
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    % Define the boundaries as the max and min X- and Y- values
    outOfBoundsX = (xlim(1) <= co(1,1) && xlim(2) >= co(1,1));
    outOfBoundsY = (ylim(1) <= co(1,2) && ylim(2) >= co(1,2));
    if outOfBoundsX && outOfBoundsY
        plotdots(co,[]);
    end




function setcolor(e,e2,mode)

%% ===============================================
oldcol=[];
u=get(gcf,'userdata');
if strcmp(mode, 'col_fixpnt')
    hd=findobj(gcf,'tag','refdot');
    tx='set color of reference/fix points';
    try; oldcol=hd(1).Color; end
    newcol       = uisetcolor([oldcol],tx);
    u.refdot_col = newcol;
    hb=findobj(gcf,'tag','col_fixpnt');
    set(hb,'cdata', [repmat(reshape(newcol,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);
    set(hd,'MarkerFaceColor',newcol);
elseif strcmp(mode, 'col_newpnt')
    hd=findobj(gcf,'tag','dot');
    tx='set color of new points';
    try; oldcol=hd(1).Color; end
    newcol    = uisetcolor([oldcol],tx);
    u.dot_col = newcol;
    hb=findobj(gcf,'tag','col_newpnt');
    set(hb,'cdata', [repmat(reshape(newcol,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);
    set(hd,'color',newcol);
elseif strcmp(mode, 'col_line')
    hd=findobj(gcf,'tag','dotline');
    tx='set color of line';
    try; oldcol=hd(1).Color; end
    newcol       = uisetcolor([oldcol],tx);
    u.dotline_col = newcol;
    hb=findobj(gcf,'tag','col_line');
    set(hb,'cdata', [repmat(reshape(newcol,[1 1 3]),[2 50 1]); repmat(cat(3,1,1,1),[13 50 1]) ]);
    set(hd,'color',newcol);
end
set(gcf,'userdata',u);

setfocus(gca);



%% ===============================================



u=get(gcf,'userdata');


if isempty(hd); end



function xhelp(e,e2)
uhelp([mfilename '.m']);

function closefig(e,e2)
set(gcf,'CloseRequestFcn','closereq');
delete(timerfindall('tag','timertoggle'));
close(gcf);


function imgwholeScreen(e,e2)
hr=findobj(gcf,'tag','imgwholeScreen');
if hr.Value==0; axis image;
else          ; axis normal;
end

function savepoints(e,e2)
%% ===============================================
hx=findobj(gcf,'tag','base');
x=get(hx,'userdata');
[mdir name ext]=fileparts(x.fiximg_file);


%% ===============================================
hsave=findobj(gcf,'tag','savepoints');
bgcol=get(hsave,'backgroundcolor');
set(hsave,'backgroundcolor',[1 0 1]); drawnow;
outname=get(findobj(gcf,'tag','ed_outname'),'string');
u=get(gcf,'userdata');
pos=[];
for i=1:(u.ndot)
    hr=findobj(gcf,'tag','refdot','-and','userdata' ,i);
    
    if ~isempty(hr)
        
        hm=findobj(gcf,'tag','dot','-and','userdata' ,i);
        pos(end+1,:)=[hr.YData hr.XData  hm.Position([2 1])];  % !!!!!!!!!!!!!!!!!
    end
end

if isempty(u.outdir)
    outdir=pwd;
else
    outdir=u.outdir;
end
% Oname=[outtag  u.oname_suffix ];
%outtag=strrep(name,'_deepsliceIN','');
outtag=u.pnt_out;
Oname=[outtag   ];
filenameFP=fullfile(outdir,[Oname '.txt']);

pos=pos.*u.downsamplefactor;
if ~isempty(pos)
    pwrite2file(filenameFP,pos);
    showinfo2('saved points',filenameFP);
else
    disp('could not store points...no points found');
end
%% =====warp-image==========================================
hx=findobj(gcf,'tag','base');
x=get(hx,'userdata');

Xmoving=pos(:,3:4);
Xstatic=pos(:,1:2);

[O_trans,Spacing,Xreg]=point_registration(size(x.movimg),Xmoving,Xstatic);
img=bspline_transform(O_trans,x.movimg_orig,Spacing,3);
if all(unique(img(:))==round(unique(img(:))))==0
    img=round(mat2gray(double(img))*255);
end
if strcmp(class(img),'unit8')==0; img=uint8(img); end

if isempty(u.outdir);   outdir=pwd;
else                ;  outdir=u.outdir;
end
% filenameFP=fullfile(outdir,[u.oname_suffix, '.png']);
filenameFP=fullfile(outdir,[Oname '.png']);

imwrite(img,filenameFP);
showinfo2('saved warpedImage',filenameFP);
%% ===============================================




% ==============================================
%%   anim-gif
% ===============================================
% img2=imread(x.fiximg_file);
img2=x.fiximg_orig;

if all(unique(img2(:))==round(unique(img2(:))))==0
    img2=round(mat2gray(double(img2))*255);
end
loops=65535;
delay=.4;
% filenameFP=fullfile(outdir,[u.oname_suffix, '.gif']);
filenameFP=fullfile(outdir,[Oname 'QA.png']);

c_map=gray;
sizdim3=[size(img,3) size(img2,3)];
if sizdim3(1)~=sizdim3(2)
    if sizdim3(1)==3; img =rgb2gray(img); end
    if sizdim3(2)==3; img2=rgb2gray(img2); end
end


imwrite(img,c_map,[filenameFP],'gif','LoopCount',loops,'DelayTime',delay)
imwrite(img2,c_map,[filenameFP],'gif','WriteMode','append','DelayTime',delay)
showinfo2('saved warpedImage',filenameFP);




%% ===============================================

set(hsave,'backgroundcolor',bgcol); drawnow;

%% ===============================================




function clearallpoints(e,e2)
u=get(gcf,'userdata');
u.not=0;
set(gcf,'userdata',u);
% addlistener(findobj(gcf,'tag','dot'), 'ObjectBeingDestroyed', []);
delete(findobj(gcf,'tag','dot'));
delete(findobj(gcf,'tag','dotline'));
delete(findobj(gcf,'tag','refdot'));
drawnow
move();

function transparency(e,e2)
u=get(gcf,'userdata');
hb=findobj(gcf,'tag','transparency');
u.ovlalpha=str2num(hb.String);
set(gcf,'userdata',u);

hl=findobj(gcf,'tag', 'setimage');
if strcmp(hl.String{hl.Value},'overlay')
    move
end




function checker_pixelsize(e,e2)
u=get(gcf,'userdata');
hb=findobj(gcf,'tag','checker_pixelsize');
u.checker_pixel=str2num(hb.String);
set(gcf,'userdata',u);

hl=findobj(gcf,'tag', 'setimage');
if strcmp(hl.String{hl.Value},'check')
    move
end

function toggle_image(e,e2)
u=get(gcf,'userdata');
if isfield(u,'toggleimg_state')==0
    u.toggleimg_state=1;
end
hm=findobj(gca,'type','image');
if u.toggleimg_state==1
    
    hm.CData=u.fiximg;
else
    hm.CData=u.warped;
end
u.toggleimg_state=~u.toggleimg_state;
set(gcf,'userdata',u);


function toggle_image2(e,e2)
u=get(gcf,'userdata');
if isfield(u,'toggleimg_state')==0
    u.toggleimg_state=1;
end
hm=findobj(gca,'type','image');
if u.toggleimg_state==1
    
    hm.CData=u.fiximg;
else
    [Ireg backtrafo]=bspline_transform(u.O_trans,u.movimg,u.Spacing       ,1);
    hm.CData=uint8(Ireg.*255);
end
u.toggleimg_state=~u.toggleimg_state;
set(gcf,'userdata',u);



function setimage_call(e,e2)
hb=findobj(gcf,'tag','setimage');
mode=hb.String{hb.Value};
hm=findobj(gca,'type','image');
u=get(gcf,'userdata');

if strcmp(mode,'atlas')
    hm.CData=imfuse(u.fiximg,u.ano);
    u.warped=u.ano;
    set(gcf,'userdata',u);
elseif  strcmp(mode,'atlasboundary')
    
%     u.anoboundary = boundarymask(u.ano);
%     bw=u.anoboundary;  
%     [w2]=smoothmask(bw, 2, 55);
%     u.anoboundary=w2;
    
    hm.CData=imfuse(u.fiximg,u.anoboundary);
    u.warped=u.ano;
    set(gcf,'userdata',u);
    
end

% setimage(e,e2)
move


function setimage(e,e2)
hb=findobj(gcf,'tag','setimage');
mode=hb.String{hb.Value};
hm=findobj(gca,'type','image');
u=get(gcf,'userdata');
% delete(timerfindall('tag','timertoggle'))
if strcmp(mode,'histo')
    hm.CData=u.fiximg;
elseif strcmp(mode,'AVGT')
    hm.CData=(u.warped(:,:,1));
elseif strcmp(mode,'edge')
    
    if u.downsamplefactor<=2
        nlevels=10;
    elseif u.downsamplefactor>2 && u.downsamplefactor<8
        nlevels=8;
    else
        nlevels=3;
    end
    
    nlevels=10;
    
    %     c=contourc(double(u.warped),nlevels);
    %     c2=contourdata(c);
    %     imsize=[size(u.warped)];
    %     cm=zeros(imsize);
    %     cm=cm(:);
    %     for i=1:length(c2)
    %         %[c2(i).xdata c2(i).ydata]-repmat(cc,[length(c2(i).xdata) 1]);
    %         if 1% length(c2(i).xdata)>200
    %             xx=round(c2(i).xdata);
    %             yy=round(c2(i).ydata);
    %             cm(sub2ind(imsize,yy,xx))=1;
    %         end
    %         %   ml   = double(poly2mask(c2(i).xdata,c2(i).ydata,imsize(1),imsize(1)));
    %         %     cm(ml==1)=i;
    %     end
    %     cm=reshape(cm,imsize);
    
    o=otsu(u.warped,nlevels);
    cm=edge(o,'sobel');
    %         cm=boundarymask(o);
    %         o=bwmorph(cm,'skel',2);
    hm.CData=imfuse(u.fiximg,cm);
    
    %     movimg=edge(u.warped,'prewitt');
    %     hm.CData=imfuse(u.fiximg,movimg);
elseif strcmp(mode,'overlay')
    
    %% ===============================================
    
    np=u.checker_pixel;
    p=ones(np);
    siz=[size(u.fiximg,1) size(u.fiximg,2)];
    check=repmat([ [p p-1]; [ p-1 p]  ],round(siz./(2*np)+1));
    check=check(1:siz(1),1:siz(2));
  %% ===============================================
  
%     f=repmat(u.fiximg,[1 1 3]);
    f=uint8(round(ind2rgb(gray2ind( imadjust( mat2gray(double(u.fiximg)),[.15 .8])   ,256),...
        flipud(bone))*255));
    w=uint8(round(ind2rgb(gray2ind(  imadjust( mat2gray(double(u.warped))  ,[.2 .9]) ...
        ,256),flipud(jet))*255));
    
%      wd=imsharpen(u.warped,'Amount',size(u.warped,1)/30);
%      w=uint8(round(ind2rgb(gray2ind( mat2gray(double(wd)) ...
%         ,256),flipud(jet))*255));
    hb=findobj(gcf,'tag','transparency');
    alpha=str2num(hb.String);
 g=w*alpha+f*(1-alpha);
  hm.CData=g;
 
 
% fg,image(g)
%% ===============================================
 
    
%     
%     hm.CData=check.*(255-double(u.fiximg))+~check.*(double(u.warped));
    %figure(10),imagesc(check.*double(u.fiximg)+~check.*double(u.warped))
    
    %% ===============================================
% elseif strcmp(mode,'fuse1')    
    
elseif strcmp(mode,'check')
    
    %% ===============================================
    
    np=u.checker_pixel;
    p=ones(np);
    siz=[size(u.fiximg,1) size(u.fiximg,2)];
    check=(repmat([ [p p-1]; [ p-1 p]  ],round(siz./(2*np)+1)));
    check=check(1:siz(1),1:siz(2));
  hm.CData=uint8(check).*u.fiximg+uint8(~check).*u.warped;
    
    %% ===============================================
elseif strcmp(mode,'fuse1')
    hm.CData=imfuse(u.fiximg,u.warped);
elseif strcmp(mode,'fuse2')
    hm.CData=imfuse(u.fiximg,u.warped,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
elseif strcmp(mode,'atlas')
    %hm.CData=imfuse(u.fiximg,u.warped);
    hm.CData=imfuse(u.fiximg,u.warped,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
elseif strcmp(mode,'atlasboundary')
    hm.CData=imfuse(u.fiximg,u.warped);
    %     hm.CData=imfuse(u.fiximg,u.anoboundary,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    
elseif strcmp(mode,'toggle')
    starttoggle();
end


if strcmp(mode,'toggle') ==0
    delete(timerfindall('tag','timertoggle'))
end

drawnow limitrate
% drawnow limitrate nocallbacks
% 'hu'


function motion(e,e2)
% co=get(gcf,'CurrentPoint')


% function keys2(e,e2)
% % rand(1)
% e2
% % ls = addlistener(gcf,'CurrentCharacter','PostSet',@keys2);


function keys(e,e2)
%  e2
% currPtPixels=MouseDisplay
% get (gca, 'CurrentPoint')

% return'
if strcmp(e2.Key,'backspace')
    %     'del'
elseif strcmp(e2.Key,'z')
    hb=findobj(gcf,'tag','zoomimage');
    hb.Value=~hb.Value;
    zoomimage();
elseif strcmp(e2.Key,'rightarrow')
    %     'toggle'
    toggle_image([],[]);
elseif strcmp(e2.Key,'downarrow')
    %     'toggle'
    toggle_image2([],[]);
elseif strcmp(e2.Key,'leftarrow')
    setimage
elseif strcmp(e2.Key,'o')   
     %% ===============================================
     
    u=get(gcf,'userdata');
    him=findobj(gca,'type','image');
    b=get(him,'Cdata');
    
    
    set(him,'cdata',u.movimg);
    drawnow;
    pause(1)
    
  set(him,'Cdata',b);
  %% ===============================================
  
     
elseif strcmp(e2.Key,'space')
    %% ===============================================
        return;
    u=get(gcf,'userdata');
    him=findobj(gca,'type','image')
    b=get(him,'Cdata');
    
    
    set(him,'cdata',u.movimg)
    ginput(1)
    doubleclicked()
%     co=get(gca,'CurrentPoint');

  set(him,'Cdata',b);
    
    
    %% ===============================================
    
    return;
    
    
    
    co=get(gca,'CurrentPoint');
    co=round(co(1,1:2))
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    % Define the boundaries as the max and min X- and Y- values
    % displayed within the Axes
    outOfBoundsX = (xlim(1) <= co(1,1) && xlim(2) >= co(1,1));
    outOfBoundsY = (ylim(1) <= co(1,2) && ylim(2) >= co(1,2));
    % Only print the mouse position (relative to the figure in pixels)
    % if the mouse is within the boundaries of the Axes
    if outOfBoundsX && outOfBoundsY
        %disp(co)    % Simply prints to Command Window
        %% ===============================================
        plotdots(co,[]);
        %         u=get(gcf,'userdata');
        %         u.ndot=u.ndot+1;
        %         hp=plot(co(1),co(2),'o','markerfacecolor','r','markersize',3)
        %         set(hp,'tag','refdot','userdata',  (u.ndot))
        %         roi = drawpoint("Color","y",'deletable',1,...'HandleVisibility','callback',...
        %             'position',[co],'userdata','dot');
        %         set(roi,'tag', 'dot', 'userdata' , (u.ndot));
        %         set(gcf,'userdata',u);
        %         % addlistener(roi,'ROIMoved',@move);
        %         addlistener(roi,'MovingROI',@move);
        %% ===============================================
        
    else
        'outside'
        
    end
    
    
    %     roi = drawpoint("Color","y",'deletable',1,'HandleVisibility','callback',...
    %         'position',[co])
end


function plotdots(co,co_ref)
u=get(gcf,'userdata');
u.ndot=u.ndot+1;

if isempty(co_ref)
    if isfield(u,'backtrafo')==0
    hp=plot(co(1),co(2),'o','markerfacecolor',u.refdot_col,'markersize',u.refdot_marksize);
    else
     
    he=plot(co(1),co(2),'o','markerfacecolor','c','markersize',u.refdot_marksize,'tag','helpdot',...
        'userdata',  u.ndot);    
     %% ===============================================
%     delete( findobj(gca,'tag','dumx'))
     trans=squeeze(round(u.backtrafo(co(1),co(2),:)))';
%     he=plot(co(1)+trans(2),co(2)+trans(1),'o','markerfacecolor','g','markersize',u.refdot_marksize);
%     he=plot(co(1)+trans(1),co(2)+trans(2),'o','markerfacecolor','b','markersize',u.refdot_marksize);
% 
%     set(he,'tag','dumx')
%     
    hp=plot(co(1)+trans(2),co(2)+trans(1) ,'o','markerfacecolor',u.refdot_col,'markersize',u.refdot_marksize);
    %% ===============================================
    
    
        
    end
    
    set(hp,'tag','refdot','userdata',  (u.ndot));
else
    hp=plot(co_ref(1),co_ref(2),'o','markerfacecolor',u.refdot_col,'markersize',u.refdot_marksize);
    set(hp,'tag','refdot','userdata',  (u.ndot));
end

roi = drawpoint("Color",u.dot_col,'deletable',0,...'HandleVisibility','callback',...
    'position',[co],'userdata','dot','MarkerSize',u.dot_marksize );
set(roi,'tag', 'dot', 'userdata' , (u.ndot));
set(gcf,'userdata',u);
% addlistener(roi,'ROIMoved',@move);
addlistener(roi,'MovingROI',@move);
% addlistener(roi, 'ObjectBeingDestroyed', @deletePoint);
cm = uicontextmenu;
m1 = uimenu(cm,'Text','delete','callback',{@dot_menu,'deleteDot',u.ndot});
m2 = uimenu(cm,'Text','---');
set(roi,'ContextMenu',cm);

if ~isempty(co_ref)
    delete(findobj(gcf,'tag','dotline','-and','userdata' ,u.ndot));
    pl=plot([co(1) co_ref(1)],[co(2) co_ref(2)],'g');
    set(pl,'tag','dotline','userdata',u.ndot);
end

function dot_menu(e,e2,task,thisdotnum)
if strcmp(task, 'deleteDot' ) 
    u=get(gcf,'userdata');
    u.not=u.ndot-1;
    if u.not<0; u.not=0; end
    set(gcf,'userdata',u);
    delete(findobj(gcf,'tag','dot','-and','userdata' ,thisdotnum));
    delete(findobj(gcf,'tag','dotline','-and','userdata' ,thisdotnum));
    delete(findobj(gcf,'tag','refdot','-and','userdata' ,thisdotnum));
    delete(findobj(gcf,'tag','helpdot','-and','userdata' ,thisdotnum));
    drawnow;
    move()
end


% function deletePoint(e,e2)
% %% ===============================================
% thisdotnum=get(e,'Userdata');
% u=get(gcf,'userdata');
% u.not=u.ndot-1;
% if u.not<0; u.not=0; end
% set(gcf,'userdata',u);
% delete(findobj(gcf,'tag','dot','-and','userdata' ,thisdotnum));
%  delete(findobj(gcf,'tag','dotline','-and','userdata' ,thisdotnum));
%  delete(findobj(gcf,'tag','refdot','-and','userdata' ,thisdotnum));
%  drawnow;
%  move()


%% ===============================================



function move(e,e2)
%% ===============================================
u=get(gcf,'userdata');
try
    hm=e2.Source;
    n=get(hm,'userdata');
    % %
    
    hr=findobj(gcf,'tag','helpdot','-and','userdata' ,n);
   
    if isempty(hr)
      hr=findobj(gcf,'tag','refdot','-and','userdata' ,n);
    end
    cor=[hr.XData hr.YData];
    com=hm.Position;
%     delete(hr);
    delete(findobj(gcf,'tag','dotline','-and','userdata' ,n));
    pl=plot([cor(1) com(1)],[cor(2) com(2)],'g','color',u.dotline_col);
    set(pl,'tag','dotline','userdata',n);
    %     hr=findobj(gcf,'tag','refdot');
end

%% ===============================================

pos=[];%zeros(u.ndot,4);
for i=1:u.ndot
    hr=findobj(gcf,'tag','refdot','-and','userdata' ,i);
    if ~isempty(hr)
        [hr.XData hr.YData];
        
        hm=findobj(gcf,'tag','dot','-and','userdata' ,i);
        pos(end+1,:)=[hr.YData hr.XData  hm.Position([2 1])];  % !!!!!!!!!!!!!!!!!
    end
end
%% ===============================================
if isempty(pos)
    pos=[1 1 1 1];
end
Xmoving=pos(:,3:4);
Xstatic=pos(:,1:2);
% cb1=fliplr(cb1);
% cb2=fliplr(cb2);

hl=findobj(gcf,'tag','setimage');



[O_trans,Spacing,Xreg]=point_registration(size(u.movimg),Xmoving,Xstatic);
% Transform the 2D image
% Ireg=bspline_transform(O_trans,u.movimg,Spacing,3);
% fus=imfuse(u.fiximg,uint8(255*mat2gray(Ireg)),'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
% Ireg=edge(Ireg,'prewitt');
if strcmp(hl.String{hl.Value},'atlas')
    [Ireg backtrafo]=bspline_transform(O_trans,u.ano,Spacing         ,1);
elseif strcmp(hl.String{hl.Value},'atlasboundary')
    [Ireg backtrafo]=bspline_transform(O_trans,u.anoboundary,Spacing  ,1);
    
else
    %Ireg=bspline_transform(O_trans,u.movimg,Spacing,3);
    
    [Ireg backtrafo]=bspline_transform(O_trans,u.movimg,Spacing       ,1);
% Ireg=bspline_transform(O_trans,u.warped,Spacing,3);
end




fus=imfuse(u.fiximg,Ireg);

% fg, imshow(fus)


% set(findobj(gca,'type','image'),'cdata',fus);
u.warped=uint8(mat2gray(Ireg)*255);
u.backtrafo=backtrafo;
u.O_trans=O_trans;
u.Spacing=Spacing;
set(gcf,'userdata',u);

setimage();


% if 0
%     ww=bspline_trans_points_double(O_trans,Spacing,[Xstatic(:,[1 2])])
%     try
%     disp(['moved:' num2str(Xstatic)]);
%     disp(['ww:' num2str(ww)]);
%     end
%     
%     %Xmoving
%     
% end

% function getpoints(e,e2)
%% ===============================================

% u=get(gcf,'userdata');
% pos=zeros(length(u.ndot),4);
% for i=1:(u.ndot)
%     hr=findobj(gcf,'tag','refdot','-and','userdata' ,i);
%     [hr.XData hr.YData];
%
%     hm=findobj(gcf,'tag','dot','-and','userdata' ,i);
%     pos(i,:)=[hr.YData hr.XData  hm.Position([2 1])];  % !!!!!!!!!!!!!!!!!
% end
%
% pwrite2file('fixpoints.txt',pos);



%% ==toogle=============================================
function starttoggle
if isempty(timerfindall('tag','timertoggle'))
    delete(timerfindall('tag','timertoggle'))
    t = timer( 'Period', .3,      'ExecutionMode', 'fixedRate');
    t.TimerFcn=@toggleimage
    t.tag='timertoggle';
    t.userdata=1;
    t.start
end


function toggleimage(e,e2)
ht=timerfind('tag','timertoggle');
hm=findobj(gca,'type','image');
u=get(gcf,'userdata');
if ht.userdata==2
    hm.CData=u.fiximg;
    ht.userdata=1;
else
    hm.CData=(u.warped(:,:,1));
    ht.userdata=2;
end
drawnow


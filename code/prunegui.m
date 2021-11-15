


function prunegui(filelist)
warning off;
% cf;
% ==============================================
%%   test
% ===============================================

if 0
    filelist={...
        'F:\data3\histo2\josefine\dat\14_000000000001F059\a2_001.mat'
        'F:\data3\histo2\josefine\dat\14_000000000001F059\a2_002.mat'
        'F:\data3\histo2\josefine\dat\14_000000000001F059\a2_003.mat'};
    prunegui(filelist);
    
end

% ==============================================
%%   
% ===============================================
% file='F:\data3\histo2\josefine\dat\14_000000000001F059\a2_002.mat'
filelist=cellstr(filelist);
file=filelist{1};
s=load(file);s=s.s;

u.file     = file;
u.filelist = filelist;

u.im =s.img;
u.imb=s.img;
% u.imb=cat(3,s.img,flipud(s.img));
u.stepnum=1;
u.ismodfile=0;

u.maxteps=200;
u.rotstp                     =  zeros(1,u.maxteps)                   ; %rotation per step   #### ROTATION
u.bordstp                    =  zeros(1,u.maxteps)                   ; %rotation per step   #### ROTATION



im=s.img;

makefig();

setupimage(u);
setuplist();
showimage(1);
% ==============================================
%%
% ===============================================
function setuplist()
u=get(gcf,'userdata');

hl=findobj(gcf,'tag','imagelist');
set(hl,'string',u.filelist,'value',1);


function setupimage(u)
hf=findobj(0,'tag','prune');
ha=findobj(hf,'tag','ax1');
him=findobj(ha,'tag','him');
im=u.imb(:,:,1);
if isempty(him)
    him=imagesc(ha,im);
    set(him,'tag','him')
else
    error('not defined');
end

colormap gray;
set(ha,'tag','ax1');
set(hf,'userdata',u);

function imagelist_cb(e,e2)
e=findobj(gcf,'tag','imagelist');
%% change image
u=get(gcf,'userdata');
if size(u.imb,3)>1
    % ==============================================
    %% save-Question befor going to next image
    % ===============================================
    opts.Interpreter = 'tex';
    % Include the desired Default answer
    opts.Default = 'Yes';
    % Use the TeX interpreter to format the question
    quest = ['PROCEED???  ..image is not saved! :' char(10) 'YES) goto NEXT image. ' char(10) ' NO) keep THIS image. '];
    answer = questdlg(quest,'PROCEED',...
        'Yes','No...let me save this image',opts);
    if ~isempty(strfind(answer,'No'))
        return
    end
    % ==============================================
    %%
    % =============================================== 
end

hx=findobj(gcf,'tag','loadModImage');
li=get(e,'string');
va=get(e,'value');
newfile=li{va};

img=[];
is_Loadmodfile =get(hx,'value');
if is_Loadmodfile==1
    [pa name ext]   =fileparts(newfile);
    modfile=fullfile(pa,[ name 'mod.tif' ]);
    if exist(modfile)==2
        img=imread(modfile);
        u.ismodfile=1;
    end
end
s=load(newfile);s=s.s;

if isempty(img)
    img=s.img;
    u.ismodfile=0;
end

u.file=newfile;
u.im  =img;
u.imb =img;
u.stepnum=1;
set(gcf,'userdata',u);
showimage(1);




function makefig
delete(findobj(0,'tag','prune'));
fg;
set(gcf,'units','norm','tag','prune','menubar','none', 'NumberTitle','off','name', ['PRUNE TIFF' '[' mfilename '.m]' ]);
hf=gcf;
set(hf,'position',[0.2875    0.1000    0.5750    0.7911]);
set(hf,'WindowKeyPressFcn',@keys);

ha=axes('position',[0 0 .9 .9]);
set(ha,'tag','ax1');


% him=imagesc(ha,im);
% set(him,'tag','him');
% colormap gray;
% set(ha,'tag','ax1');
% set(hf,'userdata',u);

%% load modified files
hb=uicontrol('style','radio','units','norm','tag','loadModImage','string','load mod. Image');
set(hb,'position',[0.73068 0.95015 0.15 0.02],'fontsize',6);
set(hb,'backgroundcolor','w','value',0);
set(hb,'tooltipstring','[0]load original image [1] load modified image');
set(hb,'callback',@cb_loadModImage);

%% ===============================================


%% UNDO
hb=uicontrol('style','pushbutton','units','norm','tag','undo','string','<');
set(hb,'position',[0.35024 0.901 0.072464 0.02809]);
set(hb,'callback',{@undoredo,-1});
set(hb,'tooltipstring','undo last step');
%% REDO
hb=uicontrol('style','pushbutton','units','norm','tag','redo','string','>');
set(hb,'position',[0.35024+0.072464 0.901 0.072464 0.02809]);
set(hb,'callback',{@undoredo,1});
set(hb,'tooltipstring','redo last step');


%% ===============================================

%% remove background
hb=uicontrol('style','pushbutton','units','norm','tag','removeBackground','string','removeBackground');
set(hb,'position',[0.90217 0.802 0.098 0.02809],'fontsize',6);
set(hb,'callback',@removeBackground);
set(hb,'tooltipstring',...
    ['<html><b>remove background </b>--> click location to remove this and neighbouring background intensity <br>'...
    ' shortcut [b]']);
%% ===============================================
%% remove tissue
hb=uicontrol('style','pushbutton','units','norm','tag','removeTissue','string','deleteTissue');
set(hb,'position',[0.90217 0.7602 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@removeTissue);
set(hb,'tooltipstring',...
    ['<html><b>remove tissue </b>--> draw region/selection via mouse <br>'...
    ' shortcut [d]']);

%% ===============================================
%% add tissue
hb=uicontrol('style','pushbutton','units','norm','tag','addTissue','string','addTissue');
set(hb,'position',[0.90097 0.7184 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@addTissue);
set(hb,'tooltipstring',...
    ['<html><b>add tissue </b>--> draw region/selection via mouse <br>'...
    ' shortcut [a]']);

%% radio fill tissue-replacetissue
hb=uicontrol('style','radio','units','norm','tag','replacefilledTissue','string','replace Tissue');
set(hb,'position',[0.90097 0.69874 0.12 0.02],'fontsize',6);
set(hb,'backgroundcolor','w','value',0);
set(hb,'tooltipstring','[0]do not replace tissue within ROI [1]replace tissue within ROI');

%% ===============================================
%% move tissue
hb=uicontrol('style','pushbutton','units','norm','tag','moveTissue','string','moveTissue');
set(hb,'position',[0.90097 0.65661 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@moveTissue);
set(hb,'tooltipstring',...
    ['<html><b>move tissue </b>--> draw region/selection via mouse <br>'...
    ' shortcut [m]']);

%% radio move tissue replace-tissue
hb=uicontrol('style','radio','units','norm','tag','replaceTissue','string','replaceTissue');
set(hb,'position',[0.90217 0.62992 0.12 0.02809],'fontsize',6);
set(hb,'backgroundcolor','w','value',1);
set(hb,'tooltipstring','');
set(hb,'tooltipstring','[0]do not replace tissue within ROI [1]replace tissue within ROI');



%% ===============================================
%% at border
hb=uicontrol('style','pushbutton','units','norm','tag','rotateImage','string','addBorder');
set(hb,'position',[[0.90338 0.42206 0.072464 0.02809]],'fontsize',6);
set(hb,'callback',@addborder);
set(hb,'tooltipstring',...
    ['<html><b>add border around image/padarray </b><br>' ...
    'if the image is to large or does not fit into the image <br>'...
    ' shortcut: none']);
%% ===============================================


%% ===============================================
%% rotate image
hb=uicontrol('style','pushbutton','units','norm','tag','rotateImage','string','rotateImage');
set(hb,'position',[[0.90459 0.38975 0.072464 0.02809]],'fontsize',6);
set(hb,'callback',@rotateImage);
set(hb,'tooltipstring',...
    ['<html><b>rotate slice </b>--> rotate image <br>'...
    ' shortcut [r]']);
%% ===============================================

%% glue tissue
hb=uicontrol('style','pushbutton','units','norm','tag','glueTissue','string','glueTissue');
set(hb,'position',[0.90097 0.54284 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@glueTissue);
set(hb,'tooltipstring','');
set(hb,'tooltipstring',['<html><b>glue tissue (RUPTURE/TEAR)</b><br> click pair-wise points along the rupture<br> '...
    'point-order: A1,A2,B1,B2,..N1,N2, such that the point A1 is contracted with point A2, <br>' ...
    ' B1 with B2...N1 with N2 <br>' ...
    ' shortcut [g]']);

%% glue iter
hb=uicontrol('style','edit','units','norm','tag','glueTissueiter','string','3');
set(hb,'position',[0.90097 0.47121 0.04 0.028],'fontsize',6);
set(hb,'tooltipstring','number of iteraton for deformation ...larger value--> larger deformation');

hb=uicontrol('style','text','units','norm','tag','glueTissueiterTxt','string','N-iteration');
set(hb,'position',[0.94324 0.47121 0.054246 0.0209],'fontsize',6);
set(hb,'backgroundcolor','w','value',1);
%% ===============================================

%% deform midline
%% glue tissue
hb=uicontrol('style','pushbutton','units','norm','tag','deformmidline','string','deformmidline');
set(hb,'position',[0.90097 0.51616 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@deformmidline);
set(hb,'tooltipstring','');
set(hb,'tooltipstring',['<html><b>deform Midline</b><br> <br> '...
    'point-order: ACTUAL-STATE: A1,B1,C1,..N1 <br>'...
    'point-order: TARGET-STATE: A2,B2,C2,..N2 <br>'...
    'deformation is done such that:  A1-->A2, B1-->B2,...N1-->N2<br>'...
    '<font color=red> set "N-iteration"-Paramtert to low value ...such as 1 '
    %     ' B1 with B2...N1 with N2 '...
    ]);


%===================================================================================================
%% save
hb=uicontrol('style','pushbutton','units','norm','tag','saveImg','string','save Img');
set(hb,'position',[0.90338 0.22262 0.072464 0.02809],'fontsize',6);
set(hb,'callback',@saveImg);
set(hb,'tooltipstring','save saveImg--> as "a2_00#mod.tif "');
set(hb,'backgroundcolor',[ 1 1 0]);

%===================================================================================================
%% close
hb=uicontrol('style','pushbutton','units','norm','tag','closefig','string','close GUI');
set(hb,'position',[0.90338 0.00070226 0.072464 0.02809],'fontsize',6);
set(hb,'callback','close(gcf);');
set(hb,'tooltipstring','close GUI');
% set(hb,'backgroundcolor',[ 1 1 0]);

%===================================================================================================
%% image listbox
hb=uicontrol('style','listbox','units','norm','tag','imagelist','string','..');
set(hb,'position',[0.901 .84 .108 .15],'fontsize',6);
set(hb,'callback',@imagelist_cb);
set(hb,'tooltipstring','select image here');
set(hb,'backgroundcolor','w');
set(hb,'KeyPressFcn',@keys)

%===================================================================================================
%% filename
hb=uicontrol('style','pushbutton','units','norm','tag','filename','string','..');
% set(hb,'position',[0.901 .84 .108 .15],'fontsize',6);
set(hb,'position',[0.001 .98 .85 .02],'fontsize',8);
set(hb,'backgroundcolor','w');

% ==============================================
%%
% ===============================================
function cb_loadModImage(e,e2)
% 'a'
% hl=findobj(gcf,'tag','imagelist');
imagelist_cb([],[]);


function deformmidline(e,e2)
delete(findobj(gcf,'type','text'));
delete(findobj(gcf,'type','line'));

try
    
    he=findobj(gcf,'tag','glueTissueiter');
    niter=str2num(get(he,'string'));
    
    % ==============================================
    %%
    % ===============================================
    % hs=findobj(gcf,'type','surface');
    him=findobj(gcf,'tag','him');
    img=him.CData;
    % ==============================================
    %%
    % ===============================================
    % Requiring the pivots:
    % f=figure; imshow(img);
    p1 = getpoints;
    p1=round(p1);
    % close(f);
    bb=bwboundaries(img>0);
    x0=bb{1}';
    x=x0([2 1],1:100:end);
    
    z=x';
    px=p1';
    del=[];
    for i=1:size(px,1)
        dis=round(sqrt(sum((z-repmat(px(i,:),[size(z,1) 1])).^2,2)));
        tres=400;
        del(:,i)=(dis<tres);
    end
    ikeep=find(sum(del,2)==0);
    x2=x(:,ikeep);
    % fg;imshow(img); hold on; plotpointsLabels(x,'r.');
    % fg;imshow(img); hold on; plotpointsLabels(x2,'r.');
    %
    p=[x2 px'];
    
    % ==============================================
    %
    % ===============================================
    
    % Requiring the new pivots:
    % f=figure; imshow(img); hold on; plotpointsLabels(p,'r.');
    hold on; plotpointsLabels(p,'r.');
    q1 = getpoints;
    
    % sx=repmat(round(mean([px(1:2:end,1) px(2:2:end,1)],2)),[ 1 2 ])';
    % sy=repmat(round(mean([px(1:2:end,2) px(2:2:end,2)],2)),[ 1 2 ])';
    % q1=[sx(:) sy(:)];
    % f=figure; imshow(img); hold on; plotpointsLabels(q1','r.');
    % f=figure; imshow(img); hold on; plotpointsLabels(px','r.');
    % q1=round(([p1(:,1:2:end) p1(:,1:2:end)]+[p1(:,2:2:end) p1(:,2:2:end)])./2)
    q=[x2 q1];
    % close(f);
    % ==============================================
    %
    % ===============================================
    imx=img;
    for i=1:niter
        % Generating the grid:
        step=15;
        [X,Y] = meshgrid(1:step:size(img,2),1:step:size(img,1));
        gv = [X(:)';Y(:)'];
        % Generating the mlsd:
        mlsd = MLSD2DpointsPrecompute(p,gv);
        % The warping can now be computed:
        [imgo pn pw] = MLSD2DWarp(imx,mlsd,q,X,Y);
        % Plotting the result:
        %figure; imshow(imgo); hold on; plotpoints(q,'r.');
        imx=imgo;
    end
    % figure; imshow(imgo); hold on; plotpoints(q,'r.');
    % set(him,'cdata',imx);
    
    delete(findobj(gcf,'type','text'));
    delete(findobj(gcf,'type','line'));
    % ---------------------------------------------------------------------
    u=get(gcf,'userdata');
    u.stepnum=u.stepnum+1;
    u.imb(:,:,u.stepnum)=imx;
    set(gcf,'userdata',u);
    showimage(u.stepnum);
    
catch ME
    cprintf([1 0 1],['ERROR:  '  '\n']);
    disp(['Num-POINTS: "points1": ' num2str(size(p1,2))  '; "points2": ' num2str(size(q1,2))]);
    disp(['ID: ' ME.identifier]);
    rethrow(ME);
    
end

% ==============================================
%%
% ===============================================

function glueTissue(e,e2)
delete(findobj(gcf,'type','text'));
delete(findobj(gcf,'type','line'));

he=findobj(gcf,'tag','glueTissueiter');
niter=str2num(get(he,'string'));

% ==============================================
%%
% ===============================================
% hs=findobj(gcf,'type','surface');
him=findobj(gcf,'tag','him');
img=him.CData;
% ==============================================
%%
% ===============================================
% Requiring the pivots:
% f=figure; imshow(img);
p1 = getpoints;
p1=round(p1);
% close(f);
bb=bwboundaries(img>0);
x0=bb{1}';
x=x0([2 1],1:100:end);

z=x';
px=p1';
del=[];
for i=1:size(px,1)
    dis=round(sqrt(sum((z-repmat(px(i,:),[size(z,1) 1])).^2,2)));
    tres=400;
    del(:,i)=(dis<tres);
end
ikeep=find(sum(del,2)==0);
x2=x(:,ikeep);
% fg;imshow(img); hold on; plotpointsLabels(x,'r.');
% fg;imshow(img); hold on; plotpointsLabels(x2,'r.');
%
p=[x2 px'];

% ==============================================
%
% ===============================================

% Requiring the new pivots:
% f=figure; imshow(img); hold on; plotpointsLabels(p,'r.');
hold on; plotpointsLabels(p,'r.');
% q1 = getpoints;
sx=repmat(round(mean([px(1:2:end,1) px(2:2:end,1)],2)),[ 1 2 ])';
sy=repmat(round(mean([px(1:2:end,2) px(2:2:end,2)],2)),[ 1 2 ])';
q1=[sx(:) sy(:)];
% f=figure; imshow(img); hold on; plotpointsLabels(q1','r.');
% f=figure; imshow(img); hold on; plotpointsLabels(px','r.');
% q1=round(([p1(:,1:2:end) p1(:,1:2:end)]+[p1(:,2:2:end) p1(:,2:2:end)])./2)
q=[x2 q1'];
% close(f);
% ==============================================
%
% ===============================================
imx=img;
for i=1:niter
    % Generating the grid:
    step=15;
    [X,Y] = meshgrid(1:step:size(img,2),1:step:size(img,1));
    gv = [X(:)';Y(:)'];
    % Generating the mlsd:
    mlsd = MLSD2DpointsPrecompute(p,gv);
    % The warping can now be computed:
    [imgo pn pw] = MLSD2DWarp(imx,mlsd,q,X,Y);
    % Plotting the result:
    %figure; imshow(imgo); hold on; plotpoints(q,'r.');
    imx=imgo;
end
% figure; imshow(imgo); hold on; plotpoints(q,'r.');
% set(him,'cdata',imx);

delete(findobj(gcf,'type','text'));
delete(findobj(gcf,'type','line'));
% ---------------------------------------------------------------------
u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=imx;
set(gcf,'userdata',u);
showimage(u.stepnum);
% delete(h);


function changeINfo()
ht=findobj(gcf,'tag','filename');
u=get(gcf,'userdata');
[pa name ext]=fileparts(u.file );

SP='&nbsp;';

if u.ismodfile==0
  imgtype=  '<b> <font color=Black> ORIG-IMAGE</b>';
else
  imgtype=  '<b> <font color=Orange> Modified-IMAGE</b>'  ;
end

s=['<html><font color=black>' [pa filesep]  '<font color=green><b>'  [ name ext repmat(SP,[1 10])] ...
    ...
    [repmat(SP,[1 5]) imgtype repmat(SP,[1 5]) ]...
    '</b><font color=blue> History: ' num2str(u.stepnum) '/' num2str(size(u.imb,3)) ];
set(ht,'string',s);
% set(ht,'HorizontalAlignment','left');


% ==============================================
%%
% ===============================================
function showimage(num)
u=get(gcf,'userdata');
him=findobj(gcf,'tag','him');
d=u.imb(:,:,num);
set(him,'cdata',d);
set(him,'tag','him');
u.stepnum=num;
set(gcf,'userdata',u);

delete(findobj(gcf,'type','text'));
delete(findobj(gcf,'type','line'));
changeINfo();

ax1=findobj(gcf,'tag','ax1');
grid on; ax1.GridColor=[1 0 1]; 
ax1.GridAlpha=1;

% ==============================================
%%
% ===============================================
function undoredo(e,e2,stp)
u=get(gcf,'userdata');
num=u.stepnum+stp;
if stp>0 && num<=size(u.imb,3)
    showimage(num);
elseif stp<0 && num>0
    showimage(num);
end

function removeBackground(e,e2)

cp=ginput(1);
cp=round(cp);
him=findobj(gcf,'tag','him');
d=get(him,'Cdata');
% d=medfilt2(d,[11 11]);
o=otsu(d,3);
val=o(cp(2),cp(1));
os=o==val;
cl=bwlabeln(os);
sel=cl==cl(cp(2),cp(1));
dx=d.*cast(imcomplement(sel),'like',d);
% -----------------------;
u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=dx;
set(gcf,'userdata',u);
showimage(u.stepnum);


function removeTissue(e,e2)
h = drawfreehand;
pos=round(h.Position);
% ---------------
him=findobj(gcf,'tag','him');
d=get(him,'Cdata');
% bd = sub2ind(size(d), pos(:,2), pos(:,1))
% m=zeros(size(img));
% m(bd)=1;
m=createMask(h);
d(m)=0;
% -----------------------;
u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=d;
set(gcf,'userdata',u);
showimage(u.stepnum);


delete(h);

function addTissue(e,e2)
h = drawfreehand;
pos=round(h.Position);
% ---------------
him=findobj(gcf,'tag','him');
d=get(him,'Cdata');
% bd = sub2ind(size(d), pos(:,2), pos(:,1))
% m=zeros(size(img));
% m(bd)=1;
dm=d>0;
m=createMask(h);
hb=findobj(gcf,'tag','replacefilledTissue');
if hb.Value==0
    m2=(m-dm)==1;
else
    m2=m;
end
d(m2)=50;
% #####################
u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=d;
set(gcf,'userdata',u);
showimage(u.stepnum);
delete(h);




function moveTissue(e,e2)
h = drawfreehand;
pos=round(h.Position);
% ---------------
him=findobj(gcf,'tag','him');
d=get(him,'Cdata');
% bd = sub2ind(size(d), pos(:,2), pos(:,1))
% m=zeros(size(img));
% m(bd)=1;
% dm=d>0;
m=createMask(h);


m2 =bwperim(m);

d2=d.*uint8(m);
dv=d2(:);
mv=m(:);
ix=find(mv==1);
val=dv(ix);
[I,J] = ind2sub(size(d2),ix);
ts=[J I double(val)];

% xw=[];
% [xw(:,1) xw(:,2)]=find(m==1)
dm=d;
rb=findobj(gcf,'tag','replaceTissue');
if rb.Value==1
    dm(m)=0;
    him=findobj(gcf,'tag','him');
    him.CData=dm;
end


% d2=d()
% x=bwtraceboundary(m,[],'W',8,Inf,'counterclockwise')
[X,L] = bwboundaries(m2,'noholes');
% dum=X{1};
% xy=fliplr(dum);
if 1
    dum=[];
    for i=1:length(X)
        dum=[dum;X{i}];
    end
    xy=fliplr(dum);
end
% fg,imagesc(m2); hold on; plot(xy(:,1),xy(:,2),'m.'); zoom on;
% ==============================================
%%
% fg,imagesc(m2); hold on;
% h2=patch([20 50  50 20 ],[10 10 40 40],'g','facealpha',.8)
% h = impoly(gca,xy)
delete(findobj(gcf,'tag','ROI'));
hp=patch(xy(:,1),xy(:,2),'g','facealpha',.01,'tag','ROI');
set(hp,'LineWidth',1,'linestyle','--','EdgeColor',[0 1 0]);
delete(h);

% ==============================================
%%
% ===============================================
delete(findobj(gcf,'tag','surface'));
rp=regionprops( d2>0, 'BoundingBox');
bo=round(rp(1).BoundingBox);

ds=d2(bo(2):bo(2)+bo(4),bo(1):bo(1)+bo(3));
% ds(ds==0)=nan;
% fg;
% imagesc(d)
% img_2 = imshow(msr_mask);
% set(img_2,'AlphaData', msr_mask_alpha,'AlphaDataMapping','direct')
hold on;

xx=repmat([[bo(2) bo(2)+bo(4)] ],[2 1]);
yy=repmat([[bo(1) bo(1)+bo(3)]' ],[1 2]);
if 0
    hs=surface(yy,xx, zeros(2), ...
        'FaceColor', 'texturemap', ...
        'CData', ds','tag','surface');
    %     'CDataMapping', 'direct',
    set(hs,'facealpha',.8)  ;
end


if 1
    % ==============================================
    %%
    % ===============================================
    
    delete(findobj(gcf,'tag','surface'))%
    
    %fg
    xl=unique(xx);
    yl=unique(yy);
    [vx,vy] = meshgrid(xl(1):xl(2), yl(1):yl(2));
    %vq = griddata(x,y,v,xq,yq);
    hs=surface(vy,vx, zeros(size(vy)),'tag','surface'); %NEW
%     hs=surface(yy,xx, zeros(2),'tag','surface'); %ORIG
    set(hs,'CData',ds');%,ds,'FaceColor','texturemap','edgecolor','none');
    hs.AlphaData = (ds'~=0); %hide  between 0 and 1:(Z<=0) | (Z>=1);
    hs.FaceColor = 'texturemap';
    hs.FaceAlpha = 'texturemap';
    set(hs,'EdgeColor','none');
    % ==============================================
    %%
    % ===============================================

end

ur.type='surface_origPosition: surface(vy,vx, zeros(size(vy)),''tag'',''surface'')';
ur.vx=vx;
ur.vy=vy;
ur.cdata=ds;
ur.inf1='patch: hp=patch(xy(:,1),xy(:,2),''g'',''facealpha'',.01,''tag'',''ROI''); '
ur.xy=xy;

set(hs,'userdata',ur);
set(hs,'ButtonDownFcn',@surface_btnDown);

% ==============================================
%%
% ===============================================

% 'a'
% d4=double(d2);
% d4(d2==0)=nan;
% hold on
% hs=surface([1, size(d,2); 1, size(d,2)], [1,1; size(d,1), size(d,1)], zeros(2), ...
%        'FaceColor', 'texturemap', ...
%        'CData', d4, 'CDataMapping', 'direct','tag','surface');
% set(hs,'facealpha',.5)  ;

% ==============================================
%%
% ===============================================
%% dragg

% handicon=geticon('handicon');

mouseposfig=get(gcf,'CurrentPoint');
delete(findobj(gcf,'tag','ROI_drag'));
% h33=uicontrol('style','pushbutton','cdata',handicon,'backgroundcolor','w');
h33=uicontrol('style','pushbutton','string','c','backgroundcolor','w');
set(h33,'backgroundcolor','w');%,'callback',@slid_thresh)
set(h33,'units','pixels','position',[100 100 16 16]);
set(h33,'units','norm')
poshand=get(h33,'position');
poshand=[mouseposfig(1) mouseposfig(2) poshand(3:4)];
set(h33,'position',[mouseposfig(1) mouseposfig(2) poshand(3:4)]);
set(h33,'string','!','tooltipstring','click object to move; see also context menu','tag','ROI_drag');
drawnow
% je = findjobj(h33); % hTable is the handle to the uitable object
% drawnow;
% set(je,'MouseDraggedCallback',@patch_drag  );
set(h33,'callback', @surface_btnDown);
% set (gcf, 'WindowButtonMotionFcn', @patch_drag);

delete(findobj(gcf,'tag','patch_remove'));
hcl=uicontrol('style','pushbutton','backgroundcolor','w','string','x','callback',@patch_remove);
set(hcl,'units','norm');
posclear=[poshand(1) poshand(2)+poshand(4) poshand(3) poshand(4)];
set(hcl,'position',posclear);
set(hcl,'tooltipstring','cancel ..remove patch ','tag','patch_remove');

delete(findobj(gcf,'tag','ROI_rotateslider'));
hs=uicontrol('style','slider','backgroundcolor','w');%,'callback',@patch_rotate);
set(hs,'units','norm','value',0,'min',-180,'max',180);
posslider=[poshand(1)+poshand(3) poshand(2) poshand(3)*3 poshand(4)];
set(hs,'position',posslider);
set(hs,'string','rr','tooltipstring','rotate ','tag','ROI_rotate');
addlistener(hs,'ContinuousValueChange',@patch_rotate);


c = uicontextmenu;
hs.UIContextMenu = c;
m1 = uimenu(c,'Label','reset to original position','Callback',{@patch_fun,'reset'},'separator','on');

rotangles=[45:45:180  -45:-45:-180];
for i=1:length(rotangles)
    m1 = uimenu(c,'Label',['rotate ' num2str(rotangles(i)) '°'],...
        'Callback',{@patch_rotate_fixangle, num2str(rotangles(i))});
end
m1 = uimenu(c,'Label','rotate angle input','Callback',{@patch_rotate_fixangle,'input'},'separator','on');
m1 = uimenu(c,'Label','rotate to origin','Callback',{@patch_rotate_fixangle,'origin'},'separator','on');
m1 = uimenu(c,'Label','flip horizontally','Callback',{@patch_rotate_fixangle,'fliph'},'separator','on');
m1 = uimenu(c,'Label','flip vertically','Callback',{@patch_rotate_fixangle,'flipv'});

m1 = uimenu(c,'Label','help','Callback',{@patch_rotate_fixangle,'helppatch'},'separator','on');




v.inf1='--handles----';
v.hp   =hp;
v.hdrag=h33;
v.hs   =hs;
v.hcl  =hcl;
v.hall=[v.hp v.hdrag v.hs v.hcl];
v.inf2='------';
v.m  =dm;
v.xy =xy;
v.id =1;
v.mouseposfig=mouseposfig;
v.img=d;
v.ts=ts;


x=get(hp,'xdata');
y=get(hp,'ydata');
xm=mean(x);
ym=mean(y);
v.rotcent=[xm ym];
set(hp,'userdata',v);
% ==============================================
% c = uicontextmenu;
% hp.UIContextMenu = c;
% m1 = uimenu(c,'Label','reset to original position','Callback',{@patch_fun,'reset'},'separator','on');
v.hdrag.UIContextMenu = c;


function patch_fun(e,e2,arg)
if strcmp(arg,'reset')
    hs=findobj(gcf,'type','surface');
    ur=get(hs,'userdata');
    set(hs,'xdata',ur.vy,'ydata',ur.vx,'zdata',zeros(size(ur.vy)),'cdata',ur.cdata');
    
    hp=findobj(gcf,'tag','ROI');
    %set(hp,'edgecolor','r')
    set(hp,'xdata',ur.xy(:,1),'ydata',ur.xy(:,2),'zdata',[]);
end


% ==============================================
%%   add border
% ===============================================

function addborder(e,e2)

ub  =get(gcf,'userdata');
d   =ub.im;
dbk =d;

delete(findobj(gcf,'tag','bord_frame'));
him=findobj(gcf,'tag','him');
% d=get(him,'Cdata');
% dbk=d;
defval=300;


%% ----setup controls
%frame   -------------
colbg=[0.4667    0.6745    0.1882];
h=uipanel('units','norm','position',[0 .5 1 .01]);
set(h,'position',[0 .2 1 .09],'backgroundcolor',colbg);
set(h,'title','add border','HighlightColor','w','tag','bord_frame');
set(h,'position',[0.2 0.01 .3 .07]);
uistack(h,'bottom');
%edit   -------------
hb=uicontrol(h, 'style','edit','units','norm','string',num2str(defval));
set(hb,'fontsize',7,'tag','bord_ed','callback',{@bord_cb,'edit'});
set(hb,'position',[0.1   0.1    0.25  0.5]);
set(hb,'tooltipstring','rows/columns to add as border on all sides')
%show   -------------
hb=uicontrol(h, 'style','pushbutton','units','norm','string','show');
set(hb,'fontsize',7,'tag','bord_show','callback',{@bord_cb,'show'});
set(hb,'position',[0.4   0.1    0.15  0.5],'backgroundcolor',[1 .5 0]);
set(hb,'tooltipstring','show result');
%ok   -------------
hb=uicontrol(h, 'style','pushbutton','units','norm','string','OK');
set(hb,'fontsize',7,'tag','bord_ok','callback',{@bord_cb,'ok'});
set(hb,'position',[0.6   0.1    0.15  0.5]);
set(hb,'tooltipstring','accept result');
%cancel   -------------
hb=uicontrol(h, 'style','pushbutton','units','norm','string','Cancel');
set(hb,'fontsize',7,'tag','bord_cancel','callback',{@bord_cb,'cancel'});
set(hb,'position',[0.75   0.1    0.15  0.5]);
set(hb,'tooltipstring','dismiss');
%    -------------   -------------
u.dbk   =d;
u.defval=defval;
set(h,'userdata',u);
d2=(imresize(padarray(d,[u.defval u.defval],0,'both'),[size(d) ]));
set(him,'Cdata',d2);

function bord_cb(e,e2,arg)
h=findobj(gcf,'tag','bord_frame');
u=get(h,'userdata');
if strcmp(arg,'edit') || strcmp('task','show')
    he=findobj(gcf,'tag','bord_ed');
    val=str2num(get(he,'string'));
    d2=(imresize(padarray( u.dbk ,[val val],0,'both'),[size(u.dbk) ]));
    him=findobj(findobj(0,'tag','prune'),'tag','him');
    set(him,'Cdata',d2);
    
elseif strcmp(arg,'ok') || strcmp(arg,'cancel') 
    if strcmp(arg,'ok')
        %--update userdata-main--
       
       
        
        
        u=get(gcf,'userdata');
        nextstep=u.stepnum+1;
         he=findobj(gcf,'tag','bord_ed');
        val=str2num(get(he,'string'));
        %         disp(val)
        if val~=0
            u.bordstp(nextstep)=val;
        end
        set(gcf,'userdata',u);
        
        % -----------------------;
        him=findobj(gcf,'tag','him');
        d=get(him,'Cdata');
        u=get(gcf,'userdata');
        u.stepnum=u.stepnum+1;
        u.imb(:,:,u.stepnum)=d;
        set(gcf,'userdata',u);
        showimage(u.stepnum);
        
        
        
    elseif strcmp(arg,'cancel')
        hr=findobj(gcf,'tag','bord_frame');
        u=get(hr,'userdata');
        him=findobj(gcf,'tag','him');
        set(him,'Cdata',u.dbk);
    end
    delete(h);
    
end

    



% ==============================================
%%   ROTATE SLICE
% ===============================================
function rotateImage(e,e2)
% keyboard
if ~isempty(findobj(gcf,'tag','rotsl_frame')) %avoid doublicates
    return
end

him=findobj(gcf,'tag','him');
d=get(him,'Cdata');
dbk=d;

%% ----setup controls
colbg=[0.4667    0.6745    0.1882];
h=uipanel('units','norm','position',[0 .5 1 .01]);
set(h,'position',[0 .2 1 .09],'backgroundcolor',colbg);
set(h,'title','rotate slice','HighlightColor','w','tag','rotsl_frame');
set(h,'position',[0.2 0.01 .3 .07]);
uistack(h,'bottom');

%ok
hb=uicontrol(h, 'style','pushbutton','units','norm','string','OK');
set(hb,'fontsize',7,'tag','rotsl_ok','callback',{@rotsl_cb,'ok'});
set(hb,'position',[0.6   0.1    0.15  0.5]);
%cancel
hb=uicontrol(h, 'style','pushbutton','units','norm','string','Cancel');
set(hb,'fontsize',7,'tag','rotsl_cancel','callback',{@rotsl_cb,'cancel'});
set(hb,'position',[0.75   0.1    0.15  0.5]);
%help
hb=uicontrol(h, 'style','pushbutton','units','norm','string','<html><b>&#63;<b>');
set(hb,'fontsize',7,'tag','rotsl_help','callback',{@rotsl_cb,'help'});
set(hb,'position',[ .4 .1  0.08  0.5]);
set(hb,'backgroundcolor',[1 .7 .1]);


%reset
hb=uicontrol(h, 'style','pushbutton','units','norm','string','reset');
set(hb,'fontsize',7,'tag','rotsl_reset','callback',{@rotsl_cb,'reset'});
set(hb,'position',[0.01   0.1    0.15  0.5]);
%edit
hb=uicontrol(h, 'style','edit','units','norm','string','0');
set(hb,'fontsize',7,'tag','rotsl_edit','callback',{@rotsl_cb,'edit'});
set(hb,'position',[0.18   0.1    0.15  0.5]);
%edit-msg
hb=uicontrol(h, 'style','text','units','norm','string','angle(°)');
set(hb,'fontsize',7,'tag','rotsl_editmsg');
set(hb,'backgroundcolor',colbg);
set(hb,'position',[0.18   0.5    0.15  0.5]);
uistack(hb,'bottom');
%info
hb=uicontrol(h, 'style','text','units','norm','string','use L/R arrow-keys to rotate slice');
set(hb,'fontsize',7,'tag','rotsl_msg');
set(hb,'backgroundcolor',[1 1 0.06]);
set(hb,'position',[.35 .65 .68  0.35]);
uistack(hb,'bottom');

% ----------------------userdata in fr---
hr=findobj(gcf,'tag','rotsl_frame');
u.task='rotate slice';
u.dbk=dbk;
% u.angle=0;
set(hr,'userdata',u);

drawnow;
axes(findobj(gcf,'tag','ax1')); %FOCUS AXES



% ==============================================
%%   
% ===============================================
function rotsl_cb(e,e2,arg,value)
% arg
if strcmp(arg,'reset')
    rotsl_cb([],[],'rotate',0);
elseif strcmp(arg,'edit')
    val=str2num(get(findobj(gcf,'tag','rotsl_edit'),'string'));
    if isempty(val); return; end
    rotsl_cb([],[],'rotate',val);
elseif strcmp(arg,'ok') || strcmp(arg,'cancel') 
    if strcmp(arg,'ok')
        u=get(gcf,'userdata');
        nextstep=u.stepnum+1;
        val=str2num(get(findobj(gcf,'tag','rotsl_edit'),'string'));
%         disp(val)
        if val~=0
            u.rotstp(nextstep)=val;
        end
        set(gcf,'userdata',u);
        
%         disp([u.rotstp(1:10)])
        
        
        % -----------------------;
        him=findobj(gcf,'tag','him');
        d=get(him,'Cdata');
        u=get(gcf,'userdata');
        u.stepnum=u.stepnum+1;
        u.imb(:,:,u.stepnum)=d;
        set(gcf,'userdata',u);
        showimage(u.stepnum);
    elseif strcmp(arg,'cancel')
        hr=findobj(gcf,'tag','rotsl_frame');
        ur=get(hr,'userdata');
        him=findobj(gcf,'tag','him');
        set(him,'Cdata',ur.dbk);
    end
    hr=findobj(gcf,'tag','rotsl_frame');
    delete(hr);
elseif strcmp(arg,'rotate')
    him=findobj(gcf,'tag','him');
    %d=get(him,'Cdata');
    hr=findobj(gcf,'tag','rotsl_frame');
    ur=get(hr,'userdata');
    %ur.angle=ur.angle+;
    if (value)==0
        e=ur.dbk;
        set(findobj(gcf,'tag','rotsl_edit'),'string',num2str(0));
    else
        %
        %disp(['rot-GUI: ' num2str(value)]);
        e=imrotate(ur.dbk,value,'bilinear','crop');
    end
    set(him,'Cdata',e);
elseif strcmp(arg,'help')
    %% ===============================================
    
    w={ ''
        '<html><h1><font size=40>      ___ROTATE_SLICE___'
        ''
        ' #cb __Shortcuts___'
        ' #b           [left/right arrow]   #n - rotate slice -/+ 1°'
        ' #b [shift] + [left/right arrow]   #n - rotate slice -/+ 5°'
        ' #b [ctrl]  + [left/right arrow]   #n - rotate slice -/+ 0.5°'
        ' #b [alt]   + [left/right arrow]   #n - rotate slice -/+ 0.1°'
        ''};
    uhelp(w,0,'name','rotate slice');
    %% ===============================================
    
end

axes(findobj(gcf,'tag','ax1')); %FOCUS AXES

% ==============================================
%%   
% ===============================================



function surface_btnDown(e,e2)
% hs=findobj(gcf,'type','surface')
cb=get(gcf,'WindowButtonMotionFcn');
if isempty(cb)       %-----MOVING----
    % hs=findobj(gcf,'type','surface');
    %set(hs,'EdgeColor',[1 1 0],'linestyle','--','linewidth',.1);
    
    hp=findobj(gcf,'tag','ROI');
    set(hp,'LineWidth',2,'linestyle','--','EdgeColor',[1 0 0]);
    set(findobj(gcf,'tag','ROI_drag'),'backgroundcolor',[1 0 0]);
    set(gcf, 'WindowButtonMotionFcn',@patch_drag);
    
else          %-----FIX----
    % hs=findobj(gcf,'type','surface');
   % set(hs,'EdgeColor',[0 0 0],'linestyle','-','linewidth',0.5);
    
     hp=findobj(gcf,'tag','ROI');
    set(hp,'LineWidth',1,'linestyle','--','EdgeColor',[0 1 0]);
    set(findobj(gcf,'tag','ROI_drag'),'backgroundcolor',[0 1 0]);
    set(gcf, 'WindowButtonMotionFcn',[]);
end


function keys(e,e2)
% e2
if strcmp(e2.Key,'escape')
    set(gcf, 'WindowButtonMotionFcn',[]);
elseif strcmp(e2.Key,'d')
    removeTissue([],[]);
elseif strcmp(e2.Key,'a')
    addTissue([],[]);
elseif strcmp(e2.Key,'g')
    glueTissue([],[]);
elseif strcmp(e2.Key,'b')
    removeBackground([],[]);
elseif strcmp(e2.Key,'m')
    moveTissue([],[]);
elseif strcmp(e2.Key,'r')
    rotateImage([],[]);
end
if strcmp(e2.Key,'leftarrow')   || strcmp(e2.Key,'rightarrow')
    if ~isempty(findobj(gcf,'tag','rotsl_frame')) %ROTATE SLICE IF PANEL EXIST
        val=str2num(get(findobj(gcf,'tag','rotsl_edit'),'string'));
        step=1;
        if any(strcmp(e2.Modifier,'shift'))
            step=5;
        elseif any(strcmp(e2.Modifier,'alt')) %control+shift
            step=.1
        elseif  any(strcmp(e2.Modifier,'control'))
            step=.5;
        end
        if strcmp(e2.Key,'leftarrow')
            val=val+1*step;
        else
            val=val-1*step;
            
        end
        set(findobj(gcf,'tag','rotsl_edit'),'string',num2str(val));
        rotsl_cb([],[],'rotate',val);
    end
end

if ~isempty(findobj(gcf,'tag','ROI_rotate')) %ROTATE SLICE IF PANEL EXIST
%     e2
    val= get(findobj(gcf,'tag','ROI_rotate'),'value');
   
    
    if ~any(strcmp(e2.Modifier,'shift'))   
         % TRAMSLATE________________
         nstep=1;
         if any(strcmp(e2.Modifier,'control'))
            nstep=5;
            if any(strcmp(e2.Modifier,'alt')) %control+shift
                nstep=50;
            end
        end
        if strcmp(e2.Key,'downarrow')
            patch_drag([],[],[0 1*nstep]);
        elseif strcmp(e2.Key,'uparrow')
            patch_drag([],[],[0 -1*nstep]);
        elseif strcmp(e2.Key,'leftarrow')
            patch_drag([],[],[ -1*nstep 0]);
        elseif strcmp(e2.Key,'rightarrow')
            patch_drag([],[],[ 1*nstep 0]);
        end
        
        
    else
        step=1;
        %ROTATE________________
        if any(strcmp(e2.Modifier,'control'))
            step=5;
            if any(strcmp(e2.Modifier,'alt')) %control+shift
                step=20;
            end
        end
        if strcmp(e2.Key,'leftarrow')
            val=val-1*step;
            set(findobj(gcf,'tag','ROI_rotate'),'value',val);
            patch_rotate([],[],val);
        elseif strcmp(e2.Key,'rightarrow')
            val=val+1*step;
            set(findobj(gcf,'tag','ROI_rotate'),'value',val);
            patch_rotate([],[],val);
            
        end
        
        
    end
    
    
    
end




function patch_remove(e,e2)

hp=findobj(gcf,'tag','ROI');
v=get(hp,'userdata');
test=0;
if test==0
    delete(v.hall);
end
try;          setfocus(gca);   end         % deFocus edit-fields
% fg,imagesc(v.m);


% him=findobj(gcf,'tag','him');
% d=get(him,'Cdata');
hs=findobj(gcf,'type','surface');

ax1=findobj(gcf,'tag','ax1');
him=findobj(gcf,'tag','him');

sif=size(him.CData);
d=v.m;
dx=hs.CData;
xl=round(hs.XData);
yl=round(hs.YData);
% ==============================================
%%
% ===============================================

% xl=round(hs.XData(:,1));%orig
% yl=round(hs.YData(1,:));




t=[xl(:)  yl(:) double(dx(:))];
%t=[yl(:)  xl(:) double(dx(:))];
t(t(:,3)==0,:)=[];
t(find(t(:,1)<1),:)=[];
t(find(t(:,2)<1),:)=[];
t(find(t(:,1)>sif(2)),:)=[];
t(find(t(:,2)>sif(1)),:)=[];
try
ix=sub2ind(sif,t(:,2),t(:,1));
catch
    keyboard
end

b=(zeros(prod(sif(1:2)),1));
b(ix)=t(:,3);
b2=reshape(b,[sif(1:2) ]);
% fg,imagesc(b2)


b3=imfill(b2>0,'holes');
bc=double(imcomplement(b3));
b4=bc;
b4(b4==1)=-1;
b5=b4+b2;
b5(b5==0)=nan;
% b5a=fillmissing(b5,'nearest');
% b5b=inpaint_nans(b5);
b5=fillmissing(b5,'nearest');
b5(bc==1)=0;

%%  ========final image ====================================== 

d0=b5;
d3=uint8(d0==0).*d+uint8(d0~=0).*uint8(d0);

if test==1
    keyboard
end

% ==============================================
%% update
% ===============================================
u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=d3;
set(gcf,'userdata',u);
showimage(u.stepnum);
delete(findobj(gcf,'type','surface'));
% ==============================================
%%   
% ===============================================
return


'a'
if 0
    x=hs.XData;y=hs.YData; x,y
    b=poly2mask( ([x(1,:) fliplr(x(2,:))  ]), ([y(1,:) fliplr(y(2,:))  ]),2000,2000);fg,imagesc(b)
    bd=imdilate(b,strel(ones(2)));
    delta=abs([sum(b(:))-numel(dx) sum(bd(:))-numel(dx)])
    if find(delta==min(delta))==2
        b=bd;
    end
    
    b2=b(:);
    dx2=dx(:);
    
    % b2(b2==1)=dx;
    
    numel(dx)
    sum(b2)
    
    
    % ==============================================
    %%
    % ===============================================
    
    
    sid=size(dx)
    x=hs.XData;y=hs.YData; x,y
    
    lin=1
    tx=[...
        x(lin,1)-x(lin,2) x(lin,1) x(lin,2)
        x(1,lin)-x(2,lin) x(1,lin) x(2,lin)
        ];
    ty=[...
        y(lin,1)-y(lin,2) y(lin,1) y(lin,2)
        y(1,lin)-y(2,lin) y(1,lin) y(2,lin)
        ];
    tx=round(tx)
    ty=round(ty)
    
end


% ==============================================
%%
% ===============================================


% xl= sort(round(hs.XData(2,:)));
% yl= sort(round(hs.YData(:,1)));

stepx=1; stepy=1;
% if xl(1)>xl(2); stepx=-1; end
% if yl(1)>yl(2); stepy=-1; end

xs=length(xl(1):stepx:xl(end));
ys=length(yl(1):stepy:yl(end));
% (xs)
% (ys)
disp(['img: '     num2str(size(d))]);
disp(['inlay: '  num2str(size(dx))]);
disp(['xs: '  num2str( (xs))]);
disp(['ys: '  num2str( (ys))]);
% ==============================================
%%
% ===============================================
dt=dx';
xdf=size(dt,2)-xs;
ydf=size(dt,1)-ys;
xdf1=floor(xdf/2);
ydf1=floor(ydf/2);
xv=[xl(1)-xdf1:xl(2)+xdf-xdf1];
yv=[yl(1)-ydf1:yl(2)+ydf-ydf1];

% ==============================================
%
% ===============================================
disp(['img: '     num2str(size(d))]);
disp(['inlay: '  num2str(size(dt))]);
disp(['xv: '  num2str(size(xv))]);
disp(['yv: '  num2str(size(yv))]);

%% 
d0=zeros(size(d));
d0(yv,xv)=dt;
d3=uint8(d0==0).*d+uint8(d0~=0).*uint8(d0);
% fg,imagesc(d3)




% ==============================================
%%
% ===============================================

u=get(gcf,'userdata');
u.stepnum=u.stepnum+1;
u.imb(:,:,u.stepnum)=d3;
set(gcf,'userdata',u);
showimage(u.stepnum);
delete(findobj(gcf,'type','surface'));


function patch_drag(e,e2,userval)


hf1=findobj(0,'tag','prune');
hp=findobj(hf1,'tag','ROI');
hh=findobj(hf1,'tag','ROI_drag');

v=get(hp,'userdata');

% drag icon
pos=get(hh,'position');
if exist('userval')==~1   % NO-userINPUT
    set(gcf, 'WindowButtonMotionFcn', @patch_drag);
    coFig=get(gcf,'CurrentPoint');
    posdrag=[ coFig(1:2)  pos(3:4) ];
    set(hh,'position', posdrag);
    posdiff=posdrag-pos;
    posrot  =get(v.hs,'position');  set(v.hs  ,'position',posrot+posdiff );
    posclear=get(v.hcl,'position'); set(v.hcl ,'position',posclear+posdiff );
% else %userINPUT
%     posdrag=[ pos(1)+userval(1)   pos(2)+userval(2)   pos(3:4) ];
%     getpixelposition(hh)
end



% disp(co);
x=get(hp,'xdata');
y=get(hp,'ydata');
xm=mean(x);
ym=mean(y);

% -------drag patch
hs=findobj(gcf,'type','surface');
if exist('userval')==~1   % NO-userINPUT
    co=get(gca,'CurrentPoint');
    co=round(co(1,1:2));
    set(hp,'xdata',x-xm+co(1));
    set(hp,'ydata',y-ym+co(2));
    v.ts(:,1)=v.ts(:,1)-xm+co(1);
    v.ts(:,2)=v.ts(:,2)-ym+co(2);
    v.rotcent=[xm ym];
    xy=round([ mean(x-(x-xm+co(1)))  mean(y-(y-ym+co(2))) ]);
    hs.XData=hs.XData-xy(1);
    hs.YData=hs.YData-xy(2);
    set(hp,'userdata',v);
else %userINPUT
    co=[[userval]+[xm ym]];
  %userval
    %co=get(gca,'CurrentPoint');
    co=round(co(1,1:2));
    set(hp,'xdata',x-xm+co(1));
    set(hp,'ydata',y-ym+co(2));
    v.ts(:,1)=v.ts(:,1)-xm+co(1);
    v.ts(:,2)=v.ts(:,2)-ym+co(2);
    v.rotcent=[xm ym];
    xy=round([ mean(x-(x-xm+co(1)))  mean(y-(y-ym+co(2))) ]);
    hs.XData=hs.XData-xy(1);
    hs.YData=hs.YData-xy(2);
    set(hp,'userdata',v);
    
     ax1=findobj(gcf,'tag','ax1');
    set(ax1,'units','normalized');
    x=get(hp,'xdata');
    y=get(hp,'ydata');
    xm=mean(x);
    ym=mean(y);
    xv=round([xm ym]);
    xl=round(xlim); yl=round(ylim);
    perc=[xv(1)./xl(2)*100  (yl(2)-xv(2))/yl(2)*100 ];  %x,y (y is from above0..convertet to down0)
    
    
    pn=get(ax1,'position');
%     set(ax1,'units','pixels');
%     pp=get(ax1,'position');
%     set(ax1,'units','normalized');
    
    
    cx= (perc.*pn(3:4))/100;
    
    
    posdrag=[ cx(1:2)  pos(3:4) ];
    set(hh,'position', posdrag);
    posdiff=posdrag-pos;
    posrot  =get(v.hs,'position');  set(v.hs  ,'position',posrot+posdiff );
    posclear=get(v.hcl,'position'); set(v.hcl ,'position',posclear+posdiff );
    
    
end
% -------------------------------------
% set(hp,'xdata',x-xm+co(1));
% set(hp,'ydata',y-ym+co(2));
% v.ts(:,1)=v.ts(:,1)-xm+co(1);
% v.ts(:,2)=v.ts(:,2)-ym+co(2);
% v.rotcent=[xm ym];
% xy=round([ mean(x-(x-xm+co(1)))  mean(y-(y-ym+co(2))) ]);
% hs.XData=hs.XData-xy(1);
% hs.YData=hs.YData-xy(2);
% -------------------------------------



function patch_rotate_fixangle(e,e2,task )
hp=findobj(gcf,'tag','ROI');
v=get(hp,'userdata');
slidval=get(v.hs,'value');

ang=str2num(task);
if isempty(ang)
    if strcmp(task,'helppatch')       
        w={ ''
            '<html><h1><font size=40>      ___move tissue___'
            ''
            ' #ko __Shortcuts___'
            ' TRANSLATION'
            ' #b              [&#x21e6;/&#x21e7;/&#x21e8;/&#x21e9; arrow] #n - translate patch -/+  1pix'
            ' #b [ctrl]+      [&#x21e6;/&#x21e7;/&#x21e8;/&#x21e9; arrow] #n - translate patch -/+  5pix'
            ' #b [ctrl]+[alt]+[&#x21e6;/&#x21e7;/&#x21e8;/&#x21e9; arrow] #n - translate patch -/+ 20pix'
            ''
            ' ROTATION'
            ' #b [shift]+             [&#x21e6;/&#x21e7; arrow] #n - translate patch -/+  1°'
            ' #b [shift]+[ctrl]+      [&#x21e6;/&#x21e7; arrow] #n - translate patch -/+  5°'
            ' #b [shift]+[ctrl]+[alt]+[&#x21e6;/&#x21e7; arrow] #n - translate patch -/+ 20°'

            ''};
        uhelp(w,0,'name','move tissue');
        
        return
    elseif strcmp(task,'input')
        prompt = {[...
            'Enter single rotation angle.                            ' char(10)  ...
            ' Example: 90, -90, 270 etc' char(10) '']};
        dlg_title = 'rotation angle';
        num_lines = 1;
        defaultans = {'180'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        ang=str2num(answer{1});
        if isnan(ang);
            return
        end
    elseif strcmp(task,'fliph')
        hp=findobj(gcf,'tag','ROI');
        %set(hp,'edgecolor','r');
        y = get(hp, 'YData');
        %y2=flipud(x)
        y2 = max(y) - y + min(y);
        set(hp, 'YData', y2);
        %----------image
        hs=findobj(gcf,'type','surface');
        hs.YData=fliplr(hs.YData);
        return
    elseif strcmp(task,'flipv')
        
        hp=findobj(gcf,'tag','ROI');
        %set(hp,'edgecolor','r');
        x = get(hp, 'XData');
        %y2=flipud(x)
        x2 = max(x) - x + min(x);
        set(hp, 'XData', x2);
        %----------image
        hs=findobj(gcf,'type','surface');
        hs.XData=flipud(hs.XData);
        
%         y = get(hp, 'YData');
%         y2 = max(y) - y + min(y);
%         set(hp, 'YData', y2);
%         %----------image
%         hs=findobj(gcf,'type','surface');
%         hs.CData=flipud(hs.CData);
        return
    end
end

% stp=ang/360;
% newslidval=slidval+stp;
newslidval=ang;
% if newslidval>1;       newslidval=mod(newslidval,1);   end
% if newslidval<0;       newslidval=mod(newslidval,1);   end

if  strcmp(task,'origin') ==1
    set(v.hs,'value',0);
else
    set(v.hs,'value',newslidval);
end
patch_rotate([],[]);

function patch_rotate(e,e2,arg)                              %'ROTATION'
hf1=findobj(0,'tag','prune');
hp=findobj(hf1,'tag','ROI');
v=get(hp,'userdata');
hs=findobj(gcf,'tag','ROI_rotate');
val=get(hs,'value');
if val>180; val=-175;
    set(hs,'value',val);
    patch_rotate([],[]);
elseif val<-180; val=175;
    set(hs,'value',val);
    patch_rotate([],[]);
end
% rotangle=val*360;

% disp(val);
rotangle=val;
% return

% set(hs,'sliderstep',[0.00500 0.05000] ); %[0.0100 0.1000]
x=round(get(hp,'xdata')); y=round(get(hp,'ydata'));
xm=round(mean(x)); ym=round(mean(y));
w=get(hs,'userdata');
if isempty(w)
    w.xm=[xm];  w.ym=[ym];
    w.newrot=0;
    w.lastrot=0;
    w.xdata=get(hp,'xdata');
    w.ydata=get(hp,'ydata');
    w.zdata=get(hp,'zdata');
    w.Vertices=get(hp,'Vertices');
    set(hs,'userdata',w);
    drawnow;
end
if w.lastrot==w.newrot
    w.newrot=rotangle;
end
rot=w.newrot-w.lastrot;
w.lastrot=w.newrot;
w.newrot =rotangle;
set(hs,'userdata',w);
rotate(hp,[0 0 1],rot,[v.rotcent 0]);
drawnow;



hs=findobj(gcf,'type','surface');
rotate(hs,[0 0 1],rot,[v.rotcent 0]);

% if 0
%     
%     ds=hs.CData;
%     ds2=imrotate(ds,rot,'bilinear');
%     
%     xs=hs.XData;
%     ys=hs.YData;
%     
%     sizdf=size(ds2)-size(ds);
%     w1=ceil(sizdf/2);
%     % -------------
%     xs2=[xs(1,:)-w1(1); xs(2,:)+( sizdf(1)-w1(1))];
%     % length(xs2(1,1):xs2(2,1))
%     ys2=[ys(:,1)-w1(2)  ys(:,2)+(sizdf(2)-w1(2) )];
%     % length(ys2(1,1):ys2(1,2))
%     
%     hs.CData=ds2;
%     hs.XData=xs2;
%     hs.YData=ys2;
% end
drawnow;

% fg,imagesc(hs.CData)
% round(hs.XData)
% round(hs.YData)

return
% ==============================================
%%
% ===============================================
ts=v.ts;
vm = [ts(:,1)';ts(:,2)'];
% choose a point which will be the center of rotation
x_center = mean(vm(1,:));
y_center = mean(vm(2,:));
% create a matrix which will be used later in calculations
center = repmat([x_center; y_center], 1, size(vm,2));
% define a 60 degree counter-clockwise rotation matrix
% theta = pi/3;       % pi/3 radians = 60 degrees
theta=deg2rad(rot);
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
% do the rotation...
s = vm - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;   % shift again so the origin goes back to the desired center of rotation
% this can be done in one line as:
% vo = R*(v - center) + center
% pick out the vectors of rotated x- and y-data
x_rotated = vo(1,:);
y_rotated = vo(2,:);

v.ts(:,1:2)=[x_rotated(:) y_rotated(:)];
set(hp,'userdata',v);

if 0
    % make a plot
    fg
    plot(vm(1,:), vm(2,:), 'k-', x_rotated, y_rotated, 'r-', x_center, y_center, 'bo');
    axis equal
end

% hold on;
% hs=findobj(gcf,'type','surface')
% if isempty(hs)
%
%
% end



% ==============================================
%%   save
% ===============================================

function saveImg(e,e2)
bgcol=get(e,'backgroundcolor');
set(e,'backgroundcolor',[ 1.0000    0.4118    0.1608]);
drawnow();pause(.1);

u=get(gcf,'userdata');
[pa name ext]   =fileparts(u.file);
newname=[ name 'mod.tif' ];
fout=fullfile(pa,newname);

him=findobj(gcf,'tag','him');
d=him.CData;
% fout=fullfile(pwd,'a2_005modif.jpg')
% imwrite(d,fout,'Mode','lossless');
%     d2=imread(fout);
% fg,imagesc(d-d2)
% fout2=fullfile('F:\data3\histo2\josefine\dat\14_000000000001F059\','a2_005mod.tif')

% ==============================================
%% save-Question file EXIST
% ===============================================
if exist(fout)==2
  opts.Interpreter = 'none';
    % Include the desired Default answer
    opts.Default = 'Yes';
    % Use the TeX interpreter to format the question
    quest = ['PROCEED???  ..image "' newname '" exist--> :' char(10) 'YES) OVERWRITE. ' char(10) ' NO) CANCEL. '];
    answer = questdlg(quest,'PROCEED',...
        'Yes','No ...cancel',opts);
    if ~isempty(strfind(answer,'No'))
        return
    end
end
% ==============================================
%%   
% ===============================================


if 1
    imwrite(d,fout,'compression','none');
end
% d2=imread(fout);
% fg,imagesc(d-d2)
showinfo2('saved modified image',fout);

set(e,'backgroundcolor',[ 1 1 0]);

%% ===============================================
%save rotation vector
% ==============================================
%%   update-s.structure
% ===============================================


s=load(u.file);
s=s.s;
s.rotationmod = sum(u.rotstp(  1:u.stepnum));
s.bordermod   = max(u.bordstp( 1:u.stepnum));
save(u.file, 's');

disp(['  rotation    : ' num2str(s.rotationmod) ]);
disp(['  add border  : ' num2str(s.bordermod)   ]);

% ==============================================
%%   reset
% ===============================================
% u.imb=d;
% u.stepnum=1;
% set(gcf,'userdata',u);
changeINfo();



% ==============================================
%%   update image-thumpbnail
% ===============================================
thumpname=[ name '.jpg' ];
fthump=fullfile(pa,thumpname);

t =imread(fthump);
if size(t,2)>4000
    t=t(:,1:4000,:);
end

d2=255.*mat2im(d,parula);

txt=(text2im([ newname]));
txt=imcomplement(txt);
resfac=round((size(t,2).*.4)./size(txt,2));
txt=uint8(round(mat2gray(imresize(txt,[resfac]))*255));
txt3=cat(3,round(txt.*1) ,round(txt.*0.8),round(txt.*0) ); %color Red
% txt3=repmat(txt,[1 1 3]);
txt4=padarray([txt3],[1 size(d2,2)-size(txt3,2) ],'post');
bm=[txt4;d2];
% fg,image(bm)

b2=[ t [bm;zeros(size(t,1)-size(bm,1) ,size(bm,2),3)] ];
% fg,image(b2)


imwrite(b2,fthump);%'horst.jpg')





% ==============================================
%%   
% ===============================================





function icon=geticon(iconname)

if strcmp(iconname, 'handicon')
    handicon=[...
        129	129	129	129	129	129	129	0	0	129	129	129	129	129	129	129
        129	129	129	0	0	129	0	215	215	0	0	0	129	129	129	129
        129	129	0	215	215	0	0	215	215	0	215	215	0	129	129	129
        129	129	0	215	215	0	0	215	215	0	215	215	0	129	0	129
        129	129	129	0	215	215	0	215	215	0	215	215	0	0	215	0
        129	129	129	0	215	215	0	215	215	0	215	215	0	215	215	0
        129	0	0	129	0	215	215	215	215	215	215	215	0	215	215	0
        0	215	215	0	0	215	215	215	215	215	215	215	215	215	215	0
        0	215	215	215	0	215	215	215	215	215	215	215	215	215	0	129
        129	0	215	215	215	215	215	215	215	215	215	215	215	215	0	129
        129	129	0	215	215	215	215	215	215	215	215	215	215	215	0	129
        129	129	0	215	215	215	215	215	215	215	215	215	215	0	129	129
        129	129	129	0	215	215	215	215	215	215	215	215	215	0	129	129
        129	129	129	129	0	215	215	215	215	215	215	215	0	129	129	129
        129	129	129	129	129	0	215	215	215	215	215	215	0	129	129	129
        129	129	129	129	129	0	215	215	215	215	215	215	0	129	129	129];
    
    handicon(handicon==handicon(1,1))=255;
    if size(handicon,3)==1; handicon=repmat(handicon,[1 1 3]); end
    icon=double(handicon)/255;
end




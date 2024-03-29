
function selectslice(file)
% clc
if 0
    file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\warp_001.mat';
    selectslice(file);
    
    selectslice('F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\warp_001.mat')
end


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
%% get a2_XXX.mat
% ===============================================
[pas name ext]=fileparts(file);
F1=fullfile(pas,[strrep(name,'warp_','a2_') '.mat']);
s2=load(F1);
s2=s2.s;


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
bf.sortcolumn=6;

if isfield(s2,'hemi')
    bf.hemi=s2.hemi;
end
%===================================================================================================



%===================================================================================================




makefigure();
makelist();

updateplot(1);
sortafter([],[], bf.sortcolumn);

%———————————————————————————————————————————————
%%   
%———————————————————————————————————————————————
function docontour(e,e2)
hl=findobj(gcf,'tag','lb1');
listnum=hl.Value;
updateplot(listnum)


% ==============================================
%%   updateplot
% ===============================================
function updateplot(num)

ax1=findobj(gcf,'tag','ax1');

global bf
% if exist('')
fignum=bf.tb(num,2);
cla;
hc=findobj(gcf,'tag','cmap'); hc=hc(1);
% % % get(hc)
dooverlay=get(findobj(gcf,'tag','dooverlay'),'value');
docontour=get(findobj(gcf,'tag','docontour'),'value');

hp=findobj(gcf,'tag','sliderPlotType');
hj=get(hp,'JavaPeer');
plotmode=get(hj,'Value');


if plotmode==1 %overlay
    imoverlay(bf.ss.q(:,:,fignum),bf.ss.hi,[],[],hc.String{hc.Value},[],ax1);
    xlim([1 size(  bf.ss.hi ,2)]);    ylim([1 size(bf.ss.hi,1)]); drawnow
    
elseif plotmode==2%sideBySide
    b=[imadjust(mat2gray(bf.ss.q(:,:,fignum)))   imadjust(mat2gray(bf.ss.hi))];
    b(find(sum(b,2)==0),:)=[];
    b(:,find(sum(b,1)==0))=[];
    %     fg,
    imagesc(b);colormap(hc.String{hc.Value});
    caxis('auto');
    xlim([1 size(b,2)]);    ylim([1 size(b,1)]);
    linstp=20;
    lin= 1:linstp:size(b,1);
    hl=hline(lin,'color',[0 .5 1]);
 elseif plotmode==3
    imagesc(imfuse(bf.ss.hi,bf.ss.q(:,:,fignum),'falsecolor','Scaling','joint'));
    xlim([1 size(  bf.ss.hi ,2)]);    ylim([1 size(bf.ss.hi,1)]); drawnow
    
elseif plotmode==4 || plotmode==5 %contour
    if plotmode==4
        c1=imadjust(mat2gray(bf.ss.q(:,:,fignum)))  ;
        c2=imadjust(mat2gray(bf.ss.hi));
    else
        
        c2=imadjust(mat2gray(bf.ss.q(:,:,fignum)))  ;
        c1=imadjust(mat2gray(bf.ss.hi));
    end
    %     figure(10);
    %     cla
    imagesc(c1);colormap(hc.String{hc.Value});%colormap(gray);
    hold on;
    contour(c2,2,'r','linewidth',1);
    caxis('auto');
    xlim([1 size(c1,2)]);    ylim([1 size(c1,1)]);
    linstp=20;
    lin= 1:linstp:size(c1,1);
    hl=hline(lin,'color',[0 .5 1]); 

    
end
 set(gca,'tag','ax1');
axis off;   
    
hl=findobj(gcf,'tag','lb1');
uicontrol(hl);

% 
% if docontour==1
% %     %———————————————————————————————————————————————
% %     %%
% %     %———————————————————————————————————————————————
% %     mode=1;
% %     if mode==1
% %         c1=imadjust(mat2gray(bf.ss.q(:,:,fignum)))  ;
% %         c2=imadjust(mat2gray(bf.ss.hi));
% %     else
% %         
% %         c2=imadjust(mat2gray(bf.ss.q(:,:,fignum)))  ;
% %         c1=imadjust(mat2gray(bf.ss.hi));
% %     end
% %     
% %     
% % %     figure(10);
% % %     cla
% %     imagesc(c1);colormap(hc.String{hc.Value});%colormap(gray);
% %     hold on;
% %     contour(c2,2,'r','linewidth',1);
% %     caxis('auto');
% %     xlim([1 size(c1,2)]);    ylim([1 size(c1,1)]);
% %     linstp=20;
% %     lin= 1:linstp:size(c1,1);
% %     hl=hline(lin,'color',[0 .5 1]);
% %     
% %     %
% %     %     b=[imadjust(mat2gray(bf.ss.q(:,:,fignum)))   imadjust(mat2gray(bf.ss.hi))];
% %     %     b(find(sum(b,2)==0),:)=[];
% %     %     b(:,find(sum(b,1)==0))=[];
% %     %     %     fg,
% %     %     imagesc(b);colormap(hc.String{hc.Value});
% %     %     caxis('auto');
% %     %     xlim([1 size(b,2)]);    ylim([1 size(b,1)]);
% %     %     linstp=20;
% %     %     lin= 1:linstp:size(b,1);
% %     %     hl=hline(lin,'color',[0 .5 1]);
% %     %———————————————————————————————————————————————
% %     %%
% %     %———————————————————————————————————————————————
% %     
%     
% else
%     if dooverlay==1
%         imoverlay(bf.ss.q(:,:,fignum),bf.ss.hi,[],[],hc.String{hc.Value},[],ax1);
%         xlim([1 size(  bf.ss.hi ,2)]);    ylim([1 size(bf.ss.hi,1)]); drawnow
%     else
%         if 1
%             b=[imadjust(mat2gray(bf.ss.q(:,:,fignum)))   imadjust(mat2gray(bf.ss.hi))];
%             b(find(sum(b,2)==0),:)=[];
%             b(:,find(sum(b,1)==0))=[];
%             %     fg,
%             imagesc(b);colormap(hc.String{hc.Value});
%             caxis('auto');
%             xlim([1 size(b,2)]);    ylim([1 size(b,1)]);
%             linstp=20;
%             lin= 1:linstp:size(b,1);
%             hl=hline(lin,'color',[0 .5 1]);
%         end        
%         %     fg;
%         if 0
%             hold on
%             contour(b,2,'k');
%             set(gca,'ydir','reverse');
%         end
%         
%         
%     end
% end
% set(gca,'tag','ax1');
% axis off;

function lb1_cb(e,e2)
if strcmp(get(gcf,'selectiontype'),'open')
    %     disp('here you write write code, which you wanna be executed afer double-click');
    try
        us=get(gcf,'userdata');
        mod(us.toggle,2)
        if mod(us.toggle,2)==0
            set(us.hF,'AlphaData',1);%ones(size(us.alphadata)));%'R'
        else
            set(us.hF,'AlphaData',us.alphadata.*0);%'L'
        end
        us.toggle=us.toggle+1;
        set(gcf,'userdata',us);
      
    end
    
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
delete(findobj(0,'tag','selectbest'));
fg;
set(gcf,'units','norm','tag','selectbest');
set(gcf,'position',[  0.2500    0.2267    0.5549    0.6100]);
set(gcf, 'name','selectSlice','numberTitle','off');
set(gcf,'WindowKeyPressFcn',@keys);
f2=gcf;
ax1=axes('position', [0.2 .5 .7 .4],'tag','ax1');
set(gca,'position',[0.0029    0.2000    0.6300    0.7600],'tag','ax1');
% imoverlay(ss.q(:,:,1),ss.hi,[],[],[],[],ax1);
set(gca,'tag','ax1');
axis off;
% LISTBOX
hl=uicontrol('style','listbox','units','norm');
set(hl,'position',[ 0.6300    0.2000    0.3800    0.7500],'tag','lb1');
set(hl,'callback',@lb1_cb,'fontname','courier','fontsize',7);

%%  cmap 
hb=uicontrol('style','popupmenu','units','norm','tag','cmap');
set(hb,'position', [0.92109 0.965 0.0793 0.0289],'callback',@cmap_cb);
set(hb,'string',bf.cmap);
set(hb,'value',bf.cmapValue);
set(hb,'tooltipstring','select colormap');

if 0
    %overlay
    hb=uicontrol('style','radio','units','norm','tag','dooverlay');
    set(hb,'position', [0.85   0.9632    0.07    0.0289],'callback',@dooverlay);
    set(hb,'string','overlay','fontsize',6,'backgroundcolor','w');
    set(hb,'value',0);
    %% contour
    hb=uicontrol('style','radio','units','norm','tag','docontour');
    set(hb,'position', [0.77967 0.96625 0.07 0.0289],'callback',@docontour);
    set(hb,'string','contour','fontsize',6,'backgroundcolor','w');
    set(hb,'value',0);
end


%%  sort 
sortlist={'tag' 'ImgNumber' 'Slice' 'Pitch' 'YAW' 'HOGwarp' 'MIwarp' 'HOGaffine'};
hb=uicontrol('style','popupmenu','units','norm','tag','sortafter');
set(hb,'position',[0.63 0.965 0.1 0.0289],'callback',@sortafter);
set(hb,'string',sortlist);
set(hb,'value',1);
set(hb,'tooltipstring',[...
    '<html><b>sort listbox after paramter(columns) </b><br>' ...
    strjoin(sortlist,',') ...
    ]);


%________________________________________________
%% tag slice
hb=uicontrol('style','pushbutton','units','norm','tag','tag_slice');
set(hb,'position',[0.68085 0.1612 0.07 0.04]);
set(hb,'string','tag slice','callback', {@tag_slice,1},'backgroundcolor',[0.8863    0.9804    0.5490]);
set(hb,'tooltipstring',[...
    '<html><b><u>tag</u> this slice as a "favourite" </b>...ADD TO FAVOURITE-LIST <br>'  ...
    '<font color=blue> shortcut [t] in listbox <font color=black>  <br>' ...
    'several slices can be tagged as "favourite" (marked as [x] in 1st column of listbox) <br>'  ...
    'slices can be re-sorted in tagged -->untagged order via pulldown/tag" <br>' ...
    'FINALLY, select one of the favourites as the best matching slice'
    ]);


%% untag slice
hb=uicontrol('style','pushbutton','units','norm','tag','untag_slice');
set(hb,'position',[0.76215 0.16115 0.07 0.04]);
set(hb,'string','untag slice','callback', {@tag_slice,0},'backgroundcolor',[0.8902    0.7529    0.4627]);
set(hb,'tooltipstring',[...
    '<html><b><u>untag </u> this slice</u></b>...REMOVE FROM FAVOURITE-LIST<br>'  ...
    '<font color=blue> shortcut [u] in listbox <font color=black>  <br>' ...
     'use this to unselect a slice from the tagged list <br>' ...
    'several slices can be tagged as "favourite" (marked as [x] in 1st column of listbox) <br>'  ...
    'slices can be re-sorted in tagged -->untagged order via pulldown/tag" <br>' ...
    'FINALLY, select one of the favourites as the best matching slice'
    ]);
%%________________________________________________


msg_warpslice=[...
    '<html><b>find slice manually </b><br>' ...
    '  1) select a closely matching slice from the listbox <br>' ...
    '  2) hit [find-manually]-button <br>' ...
    '  3) from new figure select the optimal slice <br>' ...
    '  4) hit [get parameter]-button <br>' ...
    '  5) hit [warp slice]-button <br>' ...
    ];

%% find slice manally
hb=uicontrol('style','pushbutton','units','norm','tag','findslice_manually');
set(hb,'position',[0.0113    0.1557    0.0793    0.0388]);
set(hb,'string','find manually','callback', @findslice_manually);
set(hb,'tooltipstring',msg_warpslice);

%% AVGT-temlpate
hb=uicontrol('style','radio','units','norm','tag','isAVGT');
set(hb,'position', [0.010012 0.12472 0.07 0.0289]);
set(hb,'string','AVGT','fontsize',6,'backgroundcolor','w');
set(hb,'value',0);
set(hb,'tooltipstring','use AVGT template for manual slice-selection');


%% get slicing parameter(from manal)
hb=uicontrol('style','pushbutton','units','norm','tag','getslice_paramter_manually');
set(hb,'position',[0.0939    0.1557    0.1000    0.0388]);
set(hb,'string','get parameter','callback', @getslice_paramter_manually);
set(hb,'tooltipstring',msg_warpslice);

%% edit new slicing parameter(from manal)
hb=uicontrol('style','edit','units','norm','tag','edit_slice_paramter_manually');
set(hb,'position',[0.1965    0.1557    0.2501    0.0363]);
set(hb,'string','','fontsize',8);
set(hb,'tooltipstring',msg_warpslice);

%% pb warp slice
hb=uicontrol('style','pushbutton','units','norm','tag','warp_slice');
set(hb,'position',[ 0.4480    0.1539    0.0793    0.0403]);
set(hb,'string','warp slice','callback', @warp_slice,'backgroundcolor',[0.9294    0.6941    0.1255]);
set(hb,'tooltipstring',msg_warpslice);

%% ===============================================
%% pb accept
hb=uicontrol('style','pushbutton','units','norm','tag','accept');
set(hb,'position',[ 0.8898    0.0865    0.0793    0.0403]);
set(hb,'string','accept','callback', @accept,...
    'backgroundcolor',[ 0.4667    0.6745    0.1882]);
set(hb,'tooltipstring',[...
    '<html><b><font color=blue>accept & save the best slice<font color=black> </b><br>' ...
    'The <font color=red>currently selected <font color=black> slice from the listbox is saved </b><br>' ...
    'as best matching slice' ...
    ]);


%% pb cancel
hb=uicontrol('style','pushbutton','units','norm','tag','cancel');
set(hb,'position',[ 0.8047    0.0865    0.0793    0.0403]);
set(hb,'string','cancel','callback', @cancel);
set(hb,'tooltipstring',[...
    '<html><b><font color=blue>close gui </b><br>' ...
     '..nothing is stored or updated..' ...
    ]);

%% filename-pb
hb=uicontrol('style','pushbutton','units','norm','tag','name');
set(hb,'position',[ 0.01 .96  0.62 .03],'backgroundcolor','w');
set(hb,'string',bf.ss.file,'fontweight','bold','foregroundcolor','b');
set(hb,'callback', @txt_cb);

%% previus best image
hb=uicontrol('style','text','units','norm','tag','previousbest');
set(hb,'position',[  0.0175    0.0037    0.3629    0.0300],'backgroundcolor',[0.9020    0.9020    0.9020]);
set(hb,'string','<not found>','fontweight','bold','foregroundcolor','b');
% set(hb,'callback', @txt_cb);
[pa name ext]=fileparts(bf.file);
f2=fullfile(pa,[strrep(name,'warp_','bestslice_') '.mat']);
if exist(f2)==2
    bx=load(f2);
    beststr=['previous best slice: ['  num2str(bx.s2.ix) '] ' sprintf('%2.1f %2.1f %2.1f',bx.s2.param)];
    set(hb,'string',beststr);
else
  set(hb,'string','best slice not defined jet');  
end

%———————————————————————————————————————————————
%%   
%———————————————————————————————————————————————


% Standard Java JSlider (20px high if no ticks/labels, otherwise use 45px)
jSlider = javax.swing.JSlider;
[hg hb]=javacomponent(jSlider,[10,70,200,45]);
set(hb,'units','norm');%,'position',[ .01 .4 .2 .06 ]);
set(jSlider, 'Value',0, 'MajorTickSpacing',1, 'PaintLabels',true,'Minimum',1,'Maximum',5);  % with labels, no ticks
set(jSlider,'SnapToTicks',1);
set(jSlider,'value',1);
% set(jSlider, 'Orientation',jSlider.VERTICAL);
set(hb,'units','norm','position',[ .74 .94 .15 .07 ]);

lab={'OVL' 'SbS' 'fus' 'con1' 'con2'};
% ticknum=[0 33 66 99]
ticknum=[1 2 3 4 5];
labelTable = java.util.Hashtable;
% font = java.awt.Font('Tahoma',java.awt.Font.PLAIN, 8);
for i=1:length(lab) 
    key=ticknum(i);
    mLabel = lab{i}; %Matlab Char
    jLabel = javaObjectEDT('javax.swing.JLabel', mLabel); % Java JLabel
    font=jLabel.getFont;
    font2 = java.awt.Font(font.getName,font.getStyle,font.getSize.*.8  );
    set(jLabel,'font',font2);
    labelTable.put(int32(key), jLabel);
end
jSlider.setLabelTable(labelTable);
 jbh = handle(jSlider,'CallbackProperties');
set (jbh, 'StateChangedCallback', @sliderPlotType_cb)
set(jSlider,'Background',java.awt.Color.white);
set(hb,'tag','sliderPlotType');

uistack(hb,'bottom');
set(jSlider,'ToolTipText',[...
    '<html><b><font color=blue> visualization modality </b><br>' ...
    '[OVL] : overlay<br>' ...
    '[SbS] : side-by-side<br>' ...
    '[fus] : fuse image<br>' ...
    '[con1]: contour1<br>' ...
    '[con2]: contour2<br>' ...
    ]);

set(gcf,'menubar','none');
%———————————————————————————————————————————————
%%   
%———————————————————————————————————————————————

function sliderPlotType_cb(e,e2)
hl=findobj(gcf,'tag','lb1');
listnum=hl.Value;
updateplot(listnum);
drawnow;drawnow;
uicontrol(findobj(gcf,'tag','lb1')); %focus to LB


function tag_slice(e,e2,modus)
hl=findobj(gcf,'tag','lb1');
listnum=hl.Value;
% li=get(hl,'string');
lbtop=get(hl,'ListboxTop');
% -----
global bf
bf.tb(listnum,1) = modus;      %update table
line=bf.ls(listnum);
if modus==1                     %update list in listbox
    line=strrep(line,'[&nbsp;]','[x]');
else
   line=strrep(line,'[x]','[&nbsp;]');
end
bf.ls(listnum)=line;
set(hl,'string',bf.ls);
set(hl,'ListboxTop',lbtop); %set listboxtop to prev.state

uicontrol(findobj(gcf,'tag','lb1')); %focus to LB

% function totop(e,e2)
% hl=findobj(gcf,'tag','lb1');
% listnum=hl.Value
% % li=get(hl,'string');
% 
% 
% global bf
% ls=bf.ls;
% ontop=ls(listnum);
% ls(listnum)=[];
% bf.ls=[ontop; ls   ];
% % ------------------
% tb=bf.tb;
% ontop=tb(listnum,:);
% tb(listnum,:)=[];
% bf.tb=[ontop; tb   ];
% % ---------------
% set(hl,'string',bf.ls);





function keys(e,e2)
% e2
if strcmp(e2.Key,'o')
    hr=findobj(gcf,'tag','dooverlay');
    set(hr,'value',~get(hr,'value'));
    drawnow;
    hgfeval(get(hr,'callback'));
elseif strcmp(e2.Key,'t') 
    tag_slice([],[],1);
elseif strcmp(e2.Key,'u') 
    tag_slice([],[],0);
elseif strcmp(e2.Key,'uparrow')  || strcmp(e2.Key,'downarrow') 
    
    if strcmp(get(gco,'tag'),'lb1')==0
        hl=findobj(gcf,'tag','lb1');
        val=get(hl,'value')
        maxsi=size(get(hl,'string'),1);
        if strcmp(e2.Key,'uparrow')
            val2=val-1;
            if val2>0;
                set(hl,'value',val2);
                hgfeval(get(hl,'callback')); drawnow;
            end
        else
            val2=val+1;
            if val2<=maxsi;
                set(hl,'value',val2);
                hgfeval(get(hl,'callback'));
            end
        end
    end
end

function dooverlay(e,e2)
hl=findobj(gcf,'tag','lb1');
listnum=hl.Value;
updateplot(listnum)

function txt_cb(e,e2)
global bf;
pa=fileparts(bf.file);
explorer(pa)

function cancel(e,e2)
close(gcf);

function accept(e,e2)
global bf
hl=findobj(gcf,'tag','lb1');
bestID=hl.Value;

row=bf.tb(bestID,:);
row=row(2:end); %remove tag;


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

%% ==========get tagged slices =====================================
try
    it=find(bf.tb(:,1)==1);
    tagged=bf.tb(it,3:5); %tagged
    tagged=[tagged; [ s2.param ] ];%currently selected best slice
    tagged=unique([tagged],'rows');
    s2.tagged=tagged;
end

%% ===============================================




cprintf([0 0 1],['Best-Slice : ' sprintf('[%d] %2.2f %2.2f %2.2f ',row(1),row(2:4))  '\n']);
disp(['..saving: ' fileout1 ]);
save(fileout1,'s2');

% ==============================================
%%   animated gif
% ===============================================

nameout2=['bestslice_' regexprep(name,'.*_','') '.gif'];
fileout2=fullfile(pa,nameout2);
disp(['..make gif: '  nameout2]);

ref2=imresize( imadjust(mat2gray(s2.ref))  ,[1.5]);
img2=imresize( imadjust(mat2gray(s2.q))  ,[1.5]);
tx=text2im(sprintf('%2.2f %2.2f %2.2f',s2.param));
tx=imcomplement(tx);
% col=[0.4667    0.6745    0.1882];
% tx2=uint8(zeros([size(tx,1)  size(ref2,2) 3]));
tx2=uint8(  zeros([size(tx,1)  size(ref2,2) 1])   )  ;
tx2(:, 1:size(tx,2),1 )=round(tx.*255);

ref2=[tx2; uint8(round(ref2.*255))  ];
img2=[tx2; uint8(round(img2.*255))  ];

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
if size(bf.ss.s,1)>length(bf.ss.mi) % less warped than 
   bf.ss.s= bf.ss.s(1:length(bf.ss.mi),:); % same size
end


ss=bf.ss;
%  num  slic, ang1,ang2, hog, mi, hogAffine
tagvec=zeros(length([1:size(ss.q,3)]'),1);
% tagvec([10:13 5])=1; %#TEST



tb=[tagvec [1:size(ss.q,3)]'  ss.s(:,1:3)    [ss.hog ss.mi  ss.s(:,4)]    ]; %8 columns


tbold=[];
if isfield(bf,'tb')
    tbold=bf.tb;
    ixtag=find(tbold(:,1)==1);
    for i=1:length(ixtag)
        idold=tbold(ixtag(i),2);
       tb( find(tb(:,2)==idold),1)=1; 
    end
    %  disp(tb(find(tb(:,1)==1),:))  %check
end

%% ========[load existing best slice...if exist ]=======================================

[pa name ext]=fileparts(bf.file);
f2=fullfile(pa,[strrep(name,'warp_','bestslice_') '.mat']);
if exist(f2)==2
    bx=load(f2);
    if isfield(bx.s2,'tagged')==1
        ix_tagged=[];
        for i=1:size(bx.s2.tagged,1)
            it=find(sum(abs(tb(:,3:5)-repmat(bx.s2.tagged(i,:),[size(tb,1) 1])),2)==0);
            if length(it)>1; it=it(1); end
            if ~isempty(it)
            ix_tagged=[ix_tagged it]; 
            end
        end
        ix_tagged=unique(ix_tagged);
        tb(ix_tagged,1)=1;
    end
end
%% ===============================================


ls=repmat({''},[size(ss.q,3) 1]);
for i=1:size(ss.q,3)
    if tb(i,1)==0
        tag='[&nbsp;]';
    else
        tag='[x]';
    end
    par=sprintf(' <span style="background-color:#FFFFE0;"> %5.1f %5.1f %5.1f</span>',tb(i,3:5));
    met=sprintf(' %6.3f</b> %6.3f %6.3f',tb(i,6:8));
 ls{i,1} = ['<html><pre>' tag '<font color=blue><b>' pnum(i,3) ':' '<font color=black>' par ...
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

if strcmp(hr.String{hr.Value},'tag')
    [~,isort]=sort(bf.tb(:,col2sort),'descend');
else
    [~,isort]=sort(bf.tb(:,col2sort));
end
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
cord=bf.tb(hb.Value,[3:5]);
%  cv=getappdata(gcf,'cv');

if isfield(bf,'hemi')
    global ak
    pa_template=ak.template;
    [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGThemi.nii' )) ;
    if strcmp(lower(bf.hemi),'r') || strcmp(lower(bf.hemi),'right')
        cvmask=single(cvmask==2);
        %cv=cv.*uint8(cvmask);
    elseif strcmp(lower(bf.hemi),'l') || strcmp(lower(bf.hemi),'left')
        cvmask=single(cvmask==2);
        %cv=cv.*uint8(cvmask);   
    end
else
      global ak
    pa_template=ak.template;
     [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ; 
end

hx=findobj(gcf,'tag','isAVGT');
isAVGT=get(hx,'value');
if isAVGT==0
    global cv
    if isempty(cv)
        disp('...loading 3d-template..');
        global ak
        pa_template=ak.template;
        
        [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
        cv=cv.*uint8(cvmask); 
    end
%     histview(cv,cord,[1 1 1],bf.ss.hi);
    histview(cv,cord,[1 1 1]);
elseif isAVGT==1
    global cv2
    if isempty(cv2)
        disp('...loading 3d-template..');
        global ak
        pa_template=ak.template;
        %[ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
        [ cv2    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
        cv2=cv2.*uint8(cvmask);
    end
    %     histview(cv2,cord,[1 1 1],bf.ss.hi);
    histview(cv2,cord,[1 1 1]);
end











function warp_slice(e,e2)

he=findobj(gcf,'tag','edit_slice_paramter_manually');
par=str2num(he.String);
if isempty(par); msgbox('no parameter in edit-field found'); end

p.parameter=par; %[266.7753 32.4534 -33.36408]
hx=findobj(gcf,'tag','isAVGT');


global bf;
ss=bf.ss;
isAVGT=get(hx,'value');
if isAVGT==0
    global cv
    [s2 ]=warpestSlice_single(p,ss,cv);
elseif isAVGT==1
    global cv2
    [s2 ]=warpestSlice_single(p,ss,cv2);
end




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


uicontrol(hl); %focus to LB







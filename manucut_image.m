
% manually cut multiSlice-Tiff

function c4=manucut_image(c)


%% ===============================================
delete(findobj(0,'tag','cutManu'));
fg;
% set(gcf,)
set(gcf,'tag','cutManu',  'units','norm','name',[mfilename],...
    'numbertitle','off');
set(gcf,'position',[0.0035    0.4200    0.6910    0.4667]);
imagesc(c)
set(gca,'fontsize',6);
hf=gcf;

u.c=c;
% morph-param
u.medflt     =15;
u.imclose    =15;
u.imopen     =15;
u.bwareaopen =1000;


ismanualcut=0;


set(gcf,'userdata',u);
%% ===============================================
% --TX- MEDIAN-FILTER
hb=uicontrol('style','text','units','norm','string','median FLT');
set(hb,'position',[0.90646 0.82494 0.07 0.04]);
set(hb,'backgroundcolor','w','horizontalalignment','left');
% --ED-
hb=uicontrol('style','edit','units','norm','string',num2str(u.medflt));
set(hb,'position',[0.96776 0.82732 0.03 0.04],         'tag','medflt');
set(hb,'backgroundcolor','w');
set(hb,'tooltipstring','median filter size for mask creation');

% --TX- IMCLOSE
hb=uicontrol('style','text','units','norm','string','imclose size');
set(hb,'position',[0.90646 0.7678 0.07 0.04]);
set(hb,'backgroundcolor','w','horizontalalignment','left');
% --ED-
hb=uicontrol('style','edit','units','norm','string',num2str(u.imclose));
set(hb,'position',[0.96776 0.77256 0.03 0.04],          'tag','imclose');
set(hb,'backgroundcolor','w');
set(hb,'tooltipstring','Morphologically close image using this value');

% --TX- IMOPEN
hb=uicontrol('style','text','units','norm','string','imopen size');
set(hb,'position',[0.90746 0.72495 0.07 0.04]);
set(hb,'backgroundcolor','w','horizontalalignment','left');
% --ED-
hb=uicontrol('style','edit','units','norm','string',num2str(u.imopen));
set(hb,'position',[0.96776 0.72971 0.03 0.04],         'tag','imopen');
set(hb,'backgroundcolor','w');
set(hb,'tooltipstring','Morphologically open image using this value');

% --TX- bwareaopen
hb=uicontrol('style','text','units','norm','string','imopen size');
set(hb,'position',[0.90646 0.66781 0.07 0.04]);
set(hb,'backgroundcolor','w','horizontalalignment','left');
% --ED-
hb=uicontrol('style','edit','units','norm','string',num2str(u.bwareaopen));
set(hb,'position',[0.96776 0.67019 0.03 0.04],         'tag','bwareaopen');
set(hb,'backgroundcolor','w');
set(hb,'tooltipstring','Remove small objects from mask below this value');


%% ===============================================
% draw borders-radio
hb=uicontrol('style','radio','units','norm','tag','rd_cutborders','string','cut borders');
set(hb,'position',[0.01 0.05 0.08 0.05],'value',1);
set(hb,'callback',{@proc,'rd_cutborders'},'backgroundcolor','w');
set(hb,'tooltipstring','cut borders manually');

hb=uicontrol('style','pushbutton','units','norm','tag','cutl','string','draw rigidLine');
set(hb,'position',[0.01 0.0 0.15 0.05]);
set(hb,'callback',{@proc,'drawline'});
set(hb,'tooltipstring','define a cutting line bettween slices');

hb=uicontrol('style','pushbutton','units','norm','tag','cutf','string','draw drawpolyline');
set(hb,'position',[0.16 0.0 0.15 0.05]);
set(hb,'callback',{@proc,'drawpolyline'});
set(hb,'tooltipstring','define a cutting line bettween slices');

if ismanualcut==0
   set(findobj(hf,'tag','rd_cutborders'),'value',0);
   set(findobj(hf,'tag','cutl'),'enable','off');
   set(findobj(hf,'tag','cutf'),'enable','off');
end

%---otsu #cluster
% TX
hb=uicontrol('style','text','units','norm','string','otsu cluster');
set(hb,'position',[0.51451 0.051187 0.05 0.025],'backgroundcolor','w','fontsize',7);
% --ED-
hb=uicontrol('style','edit','units','norm','tag','ed otsu','string','3');
set(hb,'position',[0.51351 0.005952 0.05 0.04],'backgroundcolor','w',                 'tag','otsuclasses');
set(hb,'tooltipstring','set ottsu threshold (>1)');
%---otsu-BGcluster
% TX
hb=uicontrol('style','text','units','norm','string','BG-cluster');
set(hb,'position',[0.56778 0.051187 0.065 0.025],'backgroundcolor','w','fontsize',7);
% --ED-
hb=uicontrol('style','popupmenu','units','norm','string',{'lowest','highest'},           'tag','BGcluster');
set(hb,'position',[0.5728 0.020237 0.06 0.025],'backgroundcolor','w','fontsize',7);
set(hb,'tooltipstring','background is lowest/or highest otsu cluster (default: lowest)');
set(hb,'value',2);

%--CHECK
hb=uicontrol('style','pushbutton','units','norm','tag','check','string','check');
set(hb,'position',[0.34969 0.005952 0.15 0.05]);
set(hb,'callback',{@proc,'check'},'backgroundcolor',[1.0000    0.7333    0.1608]);
set(hb,'tooltipstring','show segmentation after setting cuts');

%--OK
hb=uicontrol('style','pushbutton','units','norm','tag','ok','string','OK');
set(hb,'position',[0.75269 0.005952 0.08 0.05]);
set(hb,'callback',{@proc,'ok'});
set(hb,'tooltipstring','OK accept cutting and mask');
set(hb,'enable','off');

% --Cancel
hb=uicontrol('style','pushbutton','units','norm','tag','cancel','string','Cancel');
set(hb,'position',[0.83518 0.0071429 0.08 0.05]);
set(hb,'callback',{@proc,'cancel'});
set(hb,'tooltipstring','abort...do nothing');

% --destroi
hb=uicontrol('style','pushbutton','units','norm','tag','destroi','string','destroi');
set(hb,'position',[0.83518 0.5071429 0.08 0.04]);
% set(hb,'callback',{@proc,'cancel'});
set(hb,'tooltipstring','destroi','visible','off');
hbdestroi=hb;

testmode=0;

hf=findobj(0,'tag','cutManu');
if testmode==0
   %uiwait(hf);  
   waitfor(hbdestroi)
end

%% ===============================================
% ==============================================
%%   
% ===============================================
hf=findobj(0,'tag','cutManu');
u=get(hf,'userdata');


close(findobj(0,'tag','segm'));
close(findobj(0,'tag','otsumask'));
close(findobj(0,'tag','FINAL'));


if u.isok==0  
    c4=[];  
    close(findobj(0,'tag','cutManu'));
    return
end
% ==============================================
%%   extract data
% ===============================================
% keyboard

u=get(hf,'userdata');

% uni=unique(u.seg);uni(uni==0)=[];
% m=imfill(u.otsu,'holes');
% c=(u.c.*uint8(m));
% 
% s={};
% for i=1:length(uni)
%     su=sum(u.seg==i,1);
%     ix(1)=min(find(su~=0));
%     ix(2)=max(find(su~=0));
%     im=uint8(u.seg==i).*c;
%     im1=im(:,[ix(1):ix(2) ]);
%     s{i,1}=im1;
% end
c4=u.seg2;

close(findobj(0,'tag','cutManu'));

return
%% ===============================================



function proc(e,e2,task)
hf=findobj(0,'tag','cutManu');
him=findobj(hf,'type','image');
si=size(him.CData);



if strcmp(task,'rd_cutborders')
    if get(findobj(hf,'tag','rd_cutborders'),'value')==1
        set(findobj(hf,'tag','cutl'),'enable','on');
        set(findobj(hf,'tag','cutf'),'enable','on');
    else
        set(findobj(hf,'tag','cutl'),'enable','off');
        set(findobj(hf,'tag','cutf'),'enable','off');
    end
elseif  strcmp(task,'ok')
    u=get(hf,'userdata');
    u.isok=1;
    set(hf,'userdata',u);
    uiresume(hf);
    delete(findobj(hf,'tag','destroi'));
elseif strcmp(task,'cancel')
    u=get(hf,'userdata');
    u.isok=0;
    set(hf,'userdata',u);
    uiresume(hf);
    delete(findobj(hf,'tag','destroi'));
    
elseif strcmp(task,'drawline')
    %% ---
    [x y]=ginput(1);
    %delete(findobj(hf,'tag','imline'))
    h=drawline('Position',[x x; 1 si(1)]','StripeColor','r');
    %h=drawfreehand('StripeColor','r')
    set(h,'tag','imline');
    set(h,'linewidth',.5);
    %addlistener(h,'ROIMoved',{@rand,1});
%     h = imline(gca,[1000 1000],[1 si(1)]);%[x x][y y] ([LL,DD])
%     setColor(h,[1 0 0]);
%     st=['Ncuts: ' num2str(length((findobj(gcf,'tag','imline'))))]
%     id = addNewPositionCallback(h,@(pos) title([st]));
    %% ---
elseif strcmp(task,'drawpolyline')
    %% ---
     h=drawpolyline('StripeColor','r');
    set(h,'tag','imline');
    set(h,'linewidth',.5);
    %addlistener(h,'ROIMoved',{@rand,1});
%     h = imline(gca,[1000 1000],[1 si(1)]);%[x x][y y] ([LL,DD])
%     setColor(h,[1 0 0]);
%     st=['Ncuts: ' num2str(length((findobj(gcf,'tag','imline'))))]
%     id = addNewPositionCallback(h,@(pos) title([st]));
    %% ---
end


if strcmp(task,'check')
    hc=findobj(hf,'tag','check');
    hccol=get(hc,'backgroundcolor');
    hcstr=get(hc,'string');
    set(hc,'string','..wait..','backgroundcolor',[1 0 1] );
    drawnow;
    
    %% ===============================================
%     hf=findobj(0,'tag','cutManu');
%     him=findobj(hf,'type','image');
%     hl=findobj(hf,'tag','imline')
%     u=get(hf,'userdata');
%     
%     for i=1:length(hl)
%         
%         b=zeros(size(u.c));
%         if i==1
%             v=h(i).createMask;
%             yv=find(sum(v,2)>0);
%             yv=[yv(1) yv(end)];
%             xv=[find(v(yv(1),:))  find(v(yv(2),:))];
%             v(1:yv(1),xv(1))=1; % extend to image-border
%             v(yv(2):size(v,1),xv(2))=1;
%             b=b+v;
%         end
%     end
%     [bl num]=bwlabeln(imcomplement(b>0),4);
%     u.seg=bl;
%     set(hf,'userdata',u);
    %% ===============================================
   
    segimage();
    
    hf=findobj(0,'tag','cutManu');
    him=findobj(hf,'type','image');
    u=get(hf,'userdata');
    
 
    g  =get(him,'Cdata');
    bl  =u.seg;
    o   =u.otsu;
    num=unique(bl); num(num==0)=[];
    
    %--------------------------
    figure(112);
    set(gcf,'tag','segm','units','norm','menubar','none','name','manually cutted');
    set(gcf,'position',[  0.6944    0.7533    0.2917    0.1867]);
    imagesc(imfuse(bl,g));
    %imagesc(imfuse(double(o),double(g)));
    ti=title(['segmented output; #Slice(s)=' num2str(length(num))  ],...
        'fontsize',8);
     colorbar;
    zoom on;
     %--------------------------
    figure(113);
    set(gcf,'tag','otsumask','units','norm','menubar','none','name','OTSU Segmentation');
    set(gcf,'position',[0.6958    0.5533    0.2917    0.1867]);
    imagesc(o);
    ti=title(['otsu mask:' num2str(u.nobj) ' objects found'   ],...
        'fontsize',8);
    colorbar;
    zoom on;
     %--------------------------
    figure(114);
    set(gcf,'tag','FINAL','units','norm','menubar','none','name','FINAL IMAGE'); 
    set(gcf,'position',[0.6958    0.3556    0.2917    0.1867]);
    set(gcf,'color','w')
    imagesc(u.seg2);
    ti=title(['FINAL RESULT: image consists of: ' num2str(u.nslices) ' slices'   ],...
        'fontsize',8,'color',[0 0 1]);
    colorbar;
    zoom on;
    %% ===============================================
    set(findobj(hf,'tag','ok'),'enable','on');
    
    
    set(hc,'string',hcstr,'backgroundcolor',hccol );
end


function segimage


%% ===============================================

hf=findobj(0,'tag','cutManu');
him=findobj(hf,'type','image');
h=findobj(hf,'tag','imline');
u=get(hf,'userdata');
  b=double(zeros(size(u.c)));
for i=1:length(h)
        v=h(i).createMask;
        %disp(round(h(i).Position));
        yv=find(sum(v,2)>0);
        yv=[yv(1) yv(end)];
        xv=[find(v(yv(1),:))  find(v(yv(2),:))];
        v(1:yv(1),xv(1))=1; % extend to image-border
        v(yv(2):size(v,1),xv(2))=1;
        b=b+double(v);

end
% [bl num]=bwlabeln(imcomplement(b>0),4);num
[bl num]=bwlabeln(imcomplement(imdilate(b,ones(3)) >0),4);
% num;
% drawnow;
ho=findobj(hf,'tag','otsuclasses');
hb=findobj(hf,'tag','BGcluster');
notsu=str2num(get(ho,'string'));
BGclass=hb.String{hb.Value};
if strcmp(BGclass,'lowest');
   BGclassnum=1;
else
    BGclassnum=notsu;
end

u.seg=bl;
if notsu>1
    o=otsu(u.c, notsu);
    o(o==BGclassnum)=0;
    o(o~=0)=1;
    %% ______make mask remove small stuff_______
    p_medflt    = str2num(get(findobj(hf,'tag','medflt'),'string'));
    p_imclose   = str2num(get(findobj(hf,'tag','imclose'),'string'));
    p_imopen    = str2num(get(findobj(hf,'tag','imopen'),'string'));
    p_bwareaopen= str2num(get(findobj(hf,'tag','bwareaopen'),'string'));
    
    
    o2=medfilt2(   o,     [p_medflt p_medflt]);
    o2=imclose(   o2, ones(p_imclose));
    o2=imopen(    o2, ones(p_imopen));
    o2=imfill(    o2,'holes');
    o2=bwareaopen(o2,      p_bwareaopen);
    
    [seg nobj]=bwlabeln(o2);
    %fg,imagesc(seg)
   
    u.otsu=seg;
    u.nobj=nobj;
   
    
    if get(findobj(hf,'tag','rd_cutborders'),'value')==1  %cut borders
        %% _______cut slices______
        uni=unique(u.seg); uni(uni==0)=[];
        seg2=zeros(size(u.seg));
        for i=1:length(uni)
            m=(u.seg==uni(i));
            seg2=[seg2+((m.*seg)>0).*i];
        end
        u.nslices=length(uni);
        u.seg2   =seg2;
    else
        %% ===============================================
        
        %% two objects belong to same slice --> FUSE OBJECTS
        uni=unique(seg); uni(uni==0)=[];
        bo=[];
        for i=1:length(uni)
            is=sum(seg==uni(i),1);
            bo(i,:)=[min(find(is>0)) max(find(is>0))];
        end
        
        perc=[0];
        for i=1:length(uni)-1
            b1=bo(i,:);
            b2=bo(i+1,:);
            perc(i+1,:)=(b1(2)-b2(1))/(b1(2)-b1(1))*100;
        end
        TR=75   ;%THRESHOLD OVERLAPP PERCENT TO pairwise 1st IMAGE
        ix=find(perc>TR);
        if ~isempty(ix)
            fusm=[ix-1 ix ];
            seg3=seg;
            for i=1:size(fusm,1)
                seg3(seg3==uni(fusm(i,2)))=uni(fusm(i,1));
            end
            uni2=unique(seg3); uni2(uni2==0)=[];
            seg4=zeros(size(seg)); %reassign IDs
            for i=1:length(uni2)
                seg4(seg3==uni2(i))=i;
            end
            uni3=unique(seg4); uni3(uni3==0)=[];
            u.nslices =length(uni3);
            u.seg2    =seg4;
        else
            u.nslices=nobj;
            u.seg2   =seg;
            
        end
        
    
        %% ===============================================
        
        
      
        
    end
     
     
     
     
     %% _____________
else
     u.otsu= u.c; 
     u.nobj=nan;
end
% u.otsu=o;
set(hf,'userdata',u);
%% ===============================================






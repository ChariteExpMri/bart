

% bartcfm: case-file-matrix for bart: visualize data (files x dirs), basic file-manipulation
function bartcfm

u.params='----------';
u.metric= 1;
u.isreduceTable=1;
u.allcasesSelected=1;


u=getfileNfolders(u);
if isfield(u,'v2')==1
    makefig(u,1); %new fig
end


% ==============================================
%%   update
% ===============================================

function rd_reduce(e,e2)
reduce=get(findobj(gcf,'tag','rd_reduce'),'value');
u=get(gcf,'userdata');
u.isreduceTable=reduce;
set(gcf,'userdata',u);

set(findobj(gcf,'tag','pop_metric'),'value',1);
pb_update([],[]);




function pb_update(e,e2)

hp=findobj(gcf,'tag','pb_update');
str=get(hp,'string');          col=get(hp,'backgroundcolor');
set(hp,'string','..wait..');   set(hp,'backgroundcolor',[1 0 0]);
drawnow;
u=get(gcf,'userdata');
u=getfileNfolders(u);
makefig(u,0);%update

% pause(.1);
set(hp,'string',str);          set(hp,'backgroundcolor',col);


% ==============================================
%%  getfileNfolders
% ===============================================
function u=getfileNfolders(u)

% fidi=bartcb('getsel');
if u.allcasesSelected==1
    fidi=bartcb('getall');
else
    fidi=bartcb('getsel');
end
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);

if isempty(w.files); return ;end

[pas slice ext]=fileparts2(w.files);
[~, mdir ]=fileparts2(pas);




% ==============================================
%%     get files
% ===============================================
% k=dir(pas{i});
mdirused={};
t2={};
for i=1:length(mdir)
    
    
    animal=mdir{i};
    thispa=pas{i};
    
    if isempty(find(strcmp(mdirused,animal)))==1
        mdirused=[mdirused; animal];
        
        
        
        dirx={'' 'fin'};
        t={};
        for jj=1:length(dirx)
            k=dir(fullfile(thispa,dirx{jj}));
            k([k(:).isdir])=[];
            if ~isempty(k)
                t=[t;
                    [{k(:).name}' ...
                    repmat(dirx(jj),[length(k) 1]) ...
                    num2cell([k(:).bytes]'./1e6) ...
                    {k(:).date}' ];
                    ];
            end
        end
        %===================================================================================================
        
        
        nmaxslice=20;
        slicnums={};
        % t2={};
        for j=1:nmaxslice
            slicnums =  pnum(j,3);
            ix=regexpi2(t(:,1),slicnums);
            %tt=t(ix,:)
            tt=[repmat([ {thispa animal slicnums 'assigned'} ],[length(ix) 1]) t(ix,:)];
            if ~isempty(tt)
                t(ix,:)=[];
                t2=[t2; tt];
            end
        end
        % unassigned-mdir
        ix=find(cellfun('isempty',t(:,2)));
        tt=[repmat([ {thispa animal 'none' 'unassigned'} ],[length(ix) 1]) t(ix,:)];
        if ~isempty(tt)
            t(ix,:)=[];
            t2=[t2; tt];
        end
        
        % unassigned-finDir
        ix=regexpi2(t(:,2),'fin');
        tt=[repmat([ {thispa animal 'none' 'unassigned'} ],[length(ix) 1]) t(ix,:)];
        if ~isempty(tt)
            t(ix,:)=[];
            t2=[t2; tt];
        end
        
    end% mdir was allready used
end% over mdirs

% ==============================================
%%  keep selected slices
% ===============================================
slicesel=unique(regexprep(slice,'a1_',''));
slicesel(end+1,1)={'none'};
[~,ia ]=ismember(t2(:,3),slicesel);
t3=t2(ia>0,:);


% ==============================================
%%   unique filenames
coltype={
    'Accent'
    'Dark2'
    'Paired'
    'Pastel1'
    'Pastel2'
    'Set1'
    'Set2'
    'Set3'
    };
% ===============================================
[unifiles ia]=unique(t3(:,5));
% aux=t3(ia,[5 4 6 [6] 2 3]);
aux=t3(ia,[5 4 6 ]);
[unifiles ia]=unique(regexprep(unifiles,'\d\d\d','###'));
aux= aux(ia,:) ;
aux(:,4)=unifiles;
aux=sortrows(aux,[3 2 1]);
if u.isreduceTable==1
    aux(regexpi2(aux(:,2),'unassigned'),:)=[]; %remove unassigned
    aux(regexpi2(aux(:,1),'^_'),:)=[]  ;%remove files starting with '_'
end
unifiles=aux(:,4);


slices=unique(regexprep(slice,'a1_',''));

%% ======== DIRS =======================================

% mdir_slice_tb=allcomb(unique(mdir),slices);
% mdirslice=cellfun(@(a,b){[a '_a' b]},mdir_slice_tb(:,1),mdir_slice_tb(:,2));
mdir_slice_tb=t3(:,[2 3]);
mdirslice=cellfun(@(a,b){[a '_a' b]},mdir_slice_tb(:,1),mdir_slice_tb(:,2));
mdir_slice_tb=[mdir_slice_tb mdirslice];
mdir_slice_tb(regexpi2(mdir_slice_tb(:,2),'none$'),:)=[]; %remove 'none'-assingment

[dum,ib]=unique(mdir_slice_tb(:,3));
mdir_slice_tb=mdir_slice_tb(ib,:);
mdirslice=mdir_slice_tb(:,3);

%% ===============================================


v=zeros(length(unifiles),length(mdirslice));
ncol=10;
col=cbrewer('qual',coltype{3},ncol,'spline');
col=repmat(col, [ ceil((size(v,1)/ncol))  1 ]);
v2=ones([size(v) 3 ]);
vinfo=repmat({''},[size(v)]);
for j=1:length(mdirslice)
    for i=1:length(unifiles)
        %         ix=find(strcmp(t3(:,2), mdir_slice_tb{j,1}) & strcmp(t3(:,3), mdir_slice_tb{j,2} ) );
        %         td=t3(ix,:);
        %         ix=regexpi2(td(:,5), regexprep(unifiles{i},'###','.*'));
        
        str=regexprep(unifiles{i},'###', mdir_slice_tb{j,2});
        %
        ix=find(strcmp(  t3(:,2), mdir_slice_tb{j,1}) & strcmp(  t3(:,5), str    ) );
        td=t3(ix,:);
        ix=1;
        if ~isempty(td)
            v(i,j)=1;
            v2(i,j,:)=col(i,:);
            vinfo(i,j)={td(ix,:)};
        end
    end
end


%===================================================================================================
% ==============================================
%%   struct
% ===============================================

% u.mdirslice2=mdirslice2;
u.mdirslice =mdirslice;
u.mdir_slice_tb =mdir_slice_tb;

u.unifiles =unifiles;
u.aux=aux;

u.col=col;
u.coltype=coltype;

u.ht3={'path: ' 'animal: ' 'slice: ' 'slice-assigned: ' 'file: ' 'subdir: ' 'size(MB): ' 'date: '};
u.t3=t3;
u.v2=v2;
u.v1=v;
u.vinfo=vinfo;

% set(gcf,'userdata',u);

return


function pop_metric(e,e2)
u=get(gcf,'userdata');

hm=findobj(gcf,'tag','pop_metric');
% metric=get(hm,'value');
metric=hm.String{hm.Value};
delete(findobj(gcf,'tag','cbar'));
if strcmp(metric, 'normal')
    him=findobj(gcf,'type','image');
    set(him, 'Cdata',u.v2);
    set(him,'CDataMapping','direct');
    return
    
end
% metric
% 
% return


%% ===============================================
clc

cbarlabelpos=[1 .5 0 ];

% metric=2
vi=u.vinfo(:);
v1=u.v1(:);
siz=size(u.v1);
is=find(v1==1);
if ~isempty(strfind(metric,'extension'))==1
    fis=cellfun(@(a){[a{5}   ]}, vi(is) );
    [~,~,ext]=fileparts2(fis);
    uniext=unique(ext);
    ix=regexpi2(uniext,{'.gif|.jpg|.tif'});
    uniext=[uniext(ix); uniext(setdiff([1:length(uniext)], ix)); ];
    ix=regexpi2(uniext,{'.mat|.txt|.log|.xls|xlsx'});
    uniext=[uniext(ix); uniext(setdiff([1:length(uniext)], ix)); ];
     ix=regexpi2(uniext,{'.nii'});
    uniext=[uniext(ix); uniext(setdiff([1:length(uniext)], ix)); ];
    
    [~,ia]=ismember(ext,uniext);
    met=ia;
    mb=zeros(size(v1));
    mb(is,1)=met;
    mb=reshape(mb,siz);
    clabel='Extension';

    xticklabel=[{'-none-'} ;uniext];
    %xtick=  [.5  [1:max(mb(:))] ]
    xtick=linspace(0.5,max(mb(:))-.5, length(xticklabel) );
    cbarlabelpos=[7 .5 0 ];
    
elseif ~isempty(strfind(metric,'size'))
    met=cell2mat(cellfun(@(a){[a{7}   ]}, vi(is) ));


    if strcmp(metric, 'size(rank)')
        [~,ii]=sort(met,'Ascend');
        [~,r]=sort(ii);
        met=r;
        clabel='Size';
        
    elseif strcmp(metric, 'size(MB)')
         minsize=max(met)/50;
         met(met<minsize)=minsize;
        clabel='Size(MB)';
    else
        tr=str2num(regexprep(metric,{'size(<' ,'MB)'},{''}));
        met(met>tr)=tr;
        met(met<tr/10)=tr/10;
        clabel=metric;
    end
        

   
   mb=zeros(size(v1));
   mb(is,1)=met;
   mb=reshape(mb,siz);
   
   xtick     =[round(min(mb(:)))  round(max(mb(:))) ];
   xticklabel={num2str(min(mb(:)))  ['>' num2str(round(max(mb(:))))] };
   if strcmp(metric, 'size(rank)')
        xticklabel=[{'small'} ;{'large'}];
   end
    
elseif ~isempty(strfind(metric,'date'))
    fsiz=(cellfun(@(a){[a{8}   ]}, vi(is) ));
    dum=(cellfun(@(a){[a{1}   ]}, vi(is) ));
    dn = (datenum(fsiz, 'dd-mmm-yyyy  HH:MM:SS'));
    tmax=max(dn);
    tmin=min(dn);
   % days=cell2mat(arrayfun(@(a){[ etime(datevec(a), datevec(tmax)  )./(3600*24)   ]}, dn ));
     days=cell2mat(arrayfun(@(a){[ etime(datevec(a), datevec(tmin)  )./(3600*24)   ]}, dn ));
%      days=abs(days)
    %  [fsiz num2cell(days)]
    if strcmp(metric,'date(rank)')
        [~,ii]=sort(days,'Ascend');
        [~,r]=sort(ii);
        met=r;

%         [~,isort]=sort(days);
%         met=isort;
        xl={datestr(tmin,'dd.mmm.yy HH:MM') datestr(tmax,'dd.mmm.yy HH:MM')};
    elseif strcmp(metric,'date')
        tmed=median(dn);
        days=cell2mat(arrayfun(@(a){[ etime(datevec(a), datevec(tmed)  )./(3600*24)   ]}, dn ));
        TRminday=-20;
        days(find(days<TRminday))=TRminday;
        met=days;
        met(met==0)=.1;
        
        xl={datestr(tmin,'dd.mmm.yy HH:MM') datestr(tmax,'dd.mmm.yy HH:MM')};
    elseif strcmp(metric,'date(newest)')
        ts=flipud(sortrows([days [1:length(days)]'],1));
        ts(:,3)=1;
        if size(ts,1)>5;
            ts(1:5,3)=flipud([1:5]'+1);
        end
        ts=sortrows(ts,2);
        met=ts(:,3);
        xl={datestr(tmin,'dd.mmm.yy HH:MM') datestr(tmax,'dd.mmm.yy HH:MM')};
    else
        
        met=days;
        met(met==0)=.1;
        tr=0-str2num(regexprep(metric,'\D+',''));
        val=max(days)+tr;
        met(met<val)=1;
        
        time1=datestr(datevec(addtodate(tmax, tr, 'day')),'dd.mmm-yy');
        time2=datestr(datevec(tmax));
        xl={ ['<' time1] [time2]  };
        
        
    end


%     tr=-15
%     val=max(days)+tr
%     met(met<val)=val
%     
%     time1=datestr(datevec(addtodate(tmax, tr, 'day')),'dd.mmm-yy')
%     time2=datestr(datevec(tmax))
%     xl={ ['<' time1] [time2]  }
    
    
    mb=zeros(size(v1));
    mb(is,1)=met;
    mb=reshape(mb,siz);
    clabel=metric;
    xtick     =[(min(mb(:)))  (max(mb(:))) ];
    xticklabel=xl;
end


% ===============================================


%  fg;
%  him=imagesc(mb, [(min(mb(:))) (max(mb(:))) ]   ) ;
 him=findobj(gcf,'type','image');
 set(him, 'Cdata',mb);
 set(him,'CDataMapping','scaled');
 
 vnan=double(mb~=0);
%  vnan(vnan==0)=nan;
set(him,'AlphaData',vnan);

 
%  imAlpha(isnan(Data_Array))=0;
 
% map=hsv
delete(findobj(gcf,'tag','cbar'));
if ~isempty(strfind(metric,'extension'))
    %     map=flipud(cbrewer('qual','Set1',length(xticklabel),'spline'));
    
    Ncol=10;
    if length(xticklabel)<=Ncol
        %map=(cbrewer('qual','Set1',Ncol));
        map=distinguishable_colors(Ncol,{'w','k'});
    else
        %map=(cbrewer('qual','Accent',length(xticklabel)));
        map=distinguishable_colors(length(xticklabel),{'w','k'});
    end
    map=map(1:length(xticklabel),:);
    %     map(end+1,:)=(repmat(.7,[1 3]));
    map(1,:)=(repmat(1,[1 3]));
else
    map=flipud(cbrewer('div','Spectral',50,'spline'));
    %map(1,:)=(repmat(.7,[1 3]));
    
end
 map(map>1)=1;
% caxis([0 round(max(mb(:))) ])
colormap(map); 
hc=colorbar('west');
 set(hc,'Position',[0.906 0.1 0.008 .23],'FontSize',5);
set(hc,'tag','cbar');

hc.Label.String = clabel;
set(hc,'xtick',xtick,'xticklabel',xticklabel);
% set(hc.Label,'Position',cbarlabelpos,'fontsize',5,'fontweight','bold');
set(hc,'FontSize',6);
% drawnow



% if strcmp(metric, 'size')
%     hc.Label.String = 'Size(MB)';
%     set(hc,'xtick',[round(min(mb(:)))  round(max(mb(:))) ]);
%     set(hc.Label,'Position',[1 .5 0 ],'fontsize',8,'fontweight','bold');
%     set(hc,'FontSize',6);
% elseif strcmp(metric, 'date')
%     hc.Label.String = 'Date';
%     set(hc,'xtick',[(min(mb(:)))  (max(mb(:))) ]);
%     set(hc,'xticklabel',{datestr(tmin,'dd.mmm.yy HH:MM') datestr(tmax,'dd.mmm.yy HH:MM')});
% end
set(hc.Label,'units','norm');
set(hc.Label,'Position',[1 .5 0 ],'fontsize',7,'fontweight','bold');
set(hc.Label,'Position',cbarlabelpos,'fontsize',6,'fontweight','bold');


% hot2=flipud(hot)
% mb2 = double2rgb(mb, hot2, [0  max(mb(:))]);
%  fg,image(mb2) ;
% colormap(hot2); colorbar




%% ===============================================


% ==============================================
%%   FIGURE
% ===============================================
function makefig(u,isnewfig)

% ==============================================
%%   make figure
% ===============================================
if isnewfig==1
    delete(findobj(0,'tag','cfmatrix'));
    fg;
    set(gcf,'units','norm','tag','cfmatrix','numbertitle','off','name',['cfm [' mfilename ']']);
    image(u.v2);
else
    him=findobj(0,'Type','image');
    set(him,'AlphaData',1);
    set(him,'Cdata',u.v2);
end
ax=gca;
set(gca,'position',[0.1    0.15    0.8 0.75]);
set(gca,'ytick',[1: length(u.unifiles) ]);%,'yticklabels',unifiles)
set(gca,'xtick',[1: length(u.mdirslice) ]);%,'yticklabels',unifiles)
% drawnow;
%  set(gca,'XLimMode','auto','yLimMode','auto');

xlim([.5 length(u.mdirslice)+.5]); ylim([.5  length(u.unifiles)+.5]);
delete(findobj(gcf,'tag','cbar'));
% ==============================================
%%   lines
% ===============================================
delete(findobj(gcf,'tag','line'));
delete(findobj(gcf,'tag','sel'));
hittest='on';
h1=hline([.5:1:length(u.unifiles)],'color','k','HitTest',hittest,'LineWidth',0.1 ,'tag','line');
h2=vline([.5:1:length(u.mdirslice)],'color','k','HitTest',hittest,'LineWidth',0.1,'tag','line');
try
    ix_unassigned=min(regexpi2(u.aux(:,2),'unassigned'));
    h2=hline([ix_unassigned-0.5],'color','k','HitTest',hittest,'LineWidth',2,'tag','line');
    h2=hline([ix_unassigned-0.5],'color',['y' ],'linestyle','--','HitTest','off','LineWidth',2,'tag','line');
end
try
    ix_fin=min(regexpi2(u.aux(:,3),'fin'));
    h2=hline([ix_fin-0.5],'color','k','HitTest',hittest,'LineWidth',2,'tag','line');
    h2=hline([ix_fin-0.5],'color',['m' ],'linestyle','--','HitTest','off','LineWidth',2,'tag','line');
end
%% __ lines between different animal folders __
mdir2=regexprep(u.mdirslice,'_a\d\d\d$','');
[~,ia]=unique(mdir2);

if ~isempty(ia)
    try
    h3=vline([ia(2:end)]-.5,'color','k','HitTest',hittest,'LineWidth',2 ,'tag','line');
    end
end


% ==============================================
%%   limits, x/ylabel
% ===============================================

files=regexprep(u.unifiles, {'_','###'} ,{'\\_' '#'});
mdirslice2=strrep(u.mdirslice, '_' ,'\_');
set(gca,'xtick',[1: length(mdirslice2) ],'xticklabels',mdirslice2);
set(gca,'XTickLabelRotation',30,'fontsize',5);
for i=1:length(files)
    ax.YTickLabel{i}=['\color[rgb]{' sprintf('%f,%f,%f',u.col(i,:) )  '}' files{i} ];
end



col2=cbrewer('qual',u.coltype{7},5,'spline');
col2=repmat(col2, [ ceil((size(u.v2,2)))  1 ]);
colcnt=1;
lastmdir=u.mdir_slice_tb{1,1};
for i=1:length(mdirslice2)
    if strcmp(lastmdir,u.mdir_slice_tb{i,1})~=1
        colcnt=colcnt+1;
    end
    lastmdir=u.mdir_slice_tb{i,1};
    ax.XTickLabel{i}=['\color[rgb]{' sprintf('%f,%f,%f',col2(colcnt,:) )  '}' mdirslice2{i} ];
end

set(gca,'TickLength',[0 0]);
set(gca,'fontweight','bold');


set(gcf,'WindowButtonMotionFcn',@motion);
set(gcf,'menubar','none');
set(gcf,'WindowButtonDownFcn',@mouseclick);
set(gcf,'WindowKeyPressFcn',@keys);
% ==============================================
%%   uicontrols
% ===============================================
if isnewfig==1
    
    %% radio_info
    hb=uicontrol('style','radio','units','norm','tag','rd_info','string','info');
    set(hb,'backgroundcolor','w','fontsize',6);
    set(hb,'position',[0.64107 0.9631 0.1 0.045]);
    set(hb,'callback',@rd_info);
    set(hb,'tooltipstring',['obtain file information when hovering']);
    
    %% radio_tooltip
    hb=uicontrol('style','radio','units','norm','tag','rd_tt','string','TT');
    set(hb,'backgroundcolor','w','fontsize',6);
    set(hb,'position',[0.64107 0.93929 0.1 0.032]);
     set(hb,'tooltipstring',['obtain file information next to mouse pointer']);
    
    %% txt-info
    hb=uicontrol('style','text','units','norm','tag','tx_info','string','');
    set(hb,'backgroundcolor','w');
    posInfo=[.7 .9 .3 .1];
    set(hb,'position',posInfo,'fontsize',5, 'userdata',posInfo);
    try;
        set(hb,'FontName','Consolas');
    catch
        set(hb,'FontName','Courier New');
    end
    set(hb,'HorizontalAlignment','left');
    
    q.FontName           =get(hb,'FontName');
    q.fontsize           =get(hb,'fontsize');
    q.HorizontalAlignment=get(hb,'HorizontalAlignment');
    
    
    %% dummy-text to obtain the width
    hb=uicontrol('style','text','units','norm','tag','tx_dummy','string','');
    set(hb,'fontsize',q.fontsize,'FontName',q.FontName,'HorizontalAlignment',q.HorizontalAlignment );
    set(hb,'visible','off');
   
    %% update
    hb=uicontrol('style','pushbutton','units','norm','tag','pb_update','string','update');
    set(hb,'backgroundcolor',[1.0000    0.7333    0.1608],'fontsize',6);
    set(hb,'position',[0.90893 0.84228 0.08 0.032]);
    set(hb,'callback',@pb_update);
    set(hb,'tooltipstring',['update files/folders']);
    
    %% delselection
    hb=uicontrol('style','pushbutton','units','norm','tag','pb_delselection','string','deSel.');
    set(hb,'backgroundcolor',['w'],'fontsize',6);
    set(hb,'position',[0.90714 0.56548 0.05 0.032]);
    set(hb,'callback',@pb_delselection);
     set(hb,'tooltipstring',['deselect all']);
    
     %% radio_multiselect
    hb=uicontrol('style','radio','units','norm','tag','rd_multiSel','string','multiSel');
    set(hb,'backgroundcolor','w','fontsize',6);
    set(hb,'position',[0.9 0.60357 0.1 0.032]);
    set(hb,'tooltipstring',['single-/multi-select files']);
    
    %% reduce table
    hb=uicontrol('style','radio','units','norm','tag','rd_reduce','string','reduce');
    set(hb,'backgroundcolor','w','fontsize',6,'value',1);
    set(hb,'position',[0.90714 0.74881 0.1 0.032]);
    set(hb,'callback',@rd_reduce);
    set(hb,'tooltipstring',['show full table (all files) / show reduced table']);
    
    %% metric 
    metric={'normal'...
        'extension'...
        'size(MB)'...
        'size(rank)' ...
        'size(<1MB)' 'size(<10MB)' 'size(<20MB)' ...
        'size(<50MB)' 'size(<100MB)' 'size(<200MB)' 'size(<500MB)' 'size(<1000MB)' ...
        ...
        ...
        'date' 'date(rank)'...
        'date(newest)' ...
        'date(last 1 day)' 'date(last 5 days)' 'date(last 10 days)' 'date(last 20 days)'...
        };
    hb=uicontrol('style','popupmenu','units','norm','tag','pop_metric','string',metric);
    set(hb,'backgroundcolor','w','fontsize',6,'value',u.metric);
    set(hb,'position',[[0.90536 0.7131 0.1 0.032]]);
    set(hb,'callback',@pop_metric);
    set(hb,'tooltipstring',['displaying metric {normal/FileSize/Date} ']);
    



hm=findobj(gcf,'tag','pop_metric');
if strcmp(hm.String{hm.Value},'normal')==0
    pop_metric([],[]);
end


 %% radio_info
    hb=uicontrol('style','radio','units','norm','tag','rd_axEqual','string','axEqual');
    set(hb,'backgroundcolor','w','fontsize',6);
    set(hb,'position',[0.91071 0.80833 0.1 0.031]);
    set(hb,'callback',@rd_axEqual);
    set(hb,'tooltipstring',['set axis [0] normal or [1] equal(image) ']);
    
    
    
    
end

% ==============================================
%%   contextMenu
% ===============================================

% cmenu = uicontextmenu;
% uimenu(cmenu, 'Label', '<html><b><font color =green> DIR: open DIRECTORY', 'Callback', {@context, 'opdenDIR'});
% uimenu(cmenu, 'Label', '<html><b><font color =black> DIR: select in BART', 'Callback', {@context, 'selectBart'});

% set(findobj(gcf,'type','image'),'ContextMenu',cmenu);
% set(hl,'ContextMenu',cmenu);
setcontextmenu();
% setcontextmenu(findobj(gcf,'type','image'));
% setcontextmenu(hl);
% setcontextmenu(gcf);

%===================================================================================================
% ==============================================
%%   struct
% ===============================================
% u.mdirslice2=mdirslice2;
% u.mdirslice =mdirslice;
% u.mdir_slice_tb =mdir_slice_tb;
%
% u.unifiles =unifiles;
% u.aux=aux
%
% u.ht3={'path: ' 'animal: ' 'slice: ' 'slice-assigned: ' 'file: ' 'subdir: ' 'size(MB): ' 'date: '};
% u.t3=t3;
% u.v2=v2;
% u.vinfo=vinfo;
%
u.mdirslice2=mdirslice2;
set(gcf,'userdata',u);

function rd_axEqual(e,e2)
value=get(findall(gcf,'tag','rd_axEqual'),'value');
if value==0
    axis normal;
else
    axis image;
end


function pb_delselection(e,e2)
delete(findobj(gcf,'tag','sel'))

%===================================================================================================
function rd_info(e,e2)
hr=findobj(gcf,'tag','tx_info');
if hr.Value==0
    set(hr,'visible','off');
else
    set(hr,'visible','on','position','userdata',hr.UserData);
end


function setcontextmenu()

ha=[findobj(gcf,'tag','line'); findobj(gcf,'type','image'); gcf; findobj(gcf,'tag','sel')];

cmenu = uicontextmenu;
uimenu(cmenu, 'Label', '<html><b><font color =green> open DIRECTORY', 'Callback', {@context, 'opdenDIR'});
uimenu(cmenu, 'Label', '<html><b><font color =black> select files in BART', 'Callback', {@context, 'selectBart'});

uimenu(cmenu, 'Label', '<html><b><font color =black> get file information', 'Callback', {@context, 'getInfo'});

uimenu(cmenu, 'Label', '<html><b><font color =blue>export entire folder', 'Callback', {@context, 'exportDirs'});
uimenu(cmenu, 'Label', '<html><b><font color =blue>export seleted files', 'Callback', {@context, 'exportFiles'});

uimenu(cmenu, 'Label', '<html><b><font color =red>delete files', 'Callback', {@context, 'deleteFiles'},'separator','on');


set(ha,'ContextMenu',cmenu);


% ==============================================
%%   context
% ===============================================

function context(e,e2,task)
u=get(gcf,'userdata');
cc=get(gca,'CurrentPoint');
cc=cc(1,1:2);
% co=ceil(cc-.5);

hp=findobj(gcf,'tag','sel');
co=([get(hp,'xdata') get(hp,'ydata')]);
if iscell(co)
    co=cell2mat(co);
end
if isempty(hp)
    co=ceil(cc-.5);
end




if strcmp(task, 'opdenDIR')
    pax={};
    for i=1:size(co,1)
        t=u.vinfo{co(i,2),co(i,1)};
        if ~isempty(t)
            pax(end+1,1)=t(1);
        end
    end
    pax=unique(pax);
    if ~isempty(pax)
        for i=1:length(pax)
            explorer(pax{i});
        end
    end
elseif strcmp(task, 'selectBart')
    t={};
    for i=1:size(co,1)
        dx=u.vinfo{co(i,2),co(i,1)};
        %dx
        if ~isempty(dx)
            t(end+1,:)=dx;
        end
    end
    if ~isempty(t)
        f1=unique(cellfun(@(a,b){[a filesep 'a1_' b]},t(:,1),t(:,3)));
        bartcb('sel','filename',f1);
    end
elseif strcmp(task, 'getInfo')
    t={};
    for i=1:size(co,1)
        dx=u.vinfo{co(i,2),co(i,1)};
        if ~isempty(dx)
            t(end+1,:)=dx;
        end
    end
    uhelp(plog([],[u.ht3;t],0, '#lk FILE-FOLDER-INFO #n','s=4;al=1;'),1,'name','CFMinfo');
elseif strcmp(task, 'exportDirs') || strcmp(task, 'exportFiles')
    warning off;
    t={};
    for i=1:size(co,1)
        dx=u.vinfo{co(i,2),co(i,1)};
        if ~isempty(dx)
            t(end+1,:)=dx;
        end
    end
    
    pamainout=uigetdir(pwd,'select targe-folder');
    if isnumeric(pamainout); return, end
    
    if strcmp(task, 'exportDirs')
        mdirs=unique(t(:,1));
        if isempty(mdirs); return; end
        [~, animal]=fileparts2(mdirs);
        fprintf('..exporting..');
        for i=1:length(mdirs)
            d1=fullfile(pamainout,animal{i});
            fprintf( [ '|' animal{i} '..' ]);
            mkdir(d1);
            copyfile(mdirs{i},d1,'f');
        end
        fprintf('\n');
        fprintf('..Done!\n');
    elseif strcmp(task, 'exportFiles')
        %% ===============================================
        
        fis=cellfun(@(a,b,c){[a filesep b filesep c]},t(:,1),t(:,6),t(:,5));
        fis=strrep(fis,[filesep filesep],filesep);
        t2=[t(:,1) t(:,6) fis];
        
        [~,ia]=unique(t2(:,3));
        if isempty(ia); return; end
        t2=t2(ia,:);
        
        [pam, animal]=fileparts2(t2(:,1));
        
        fprintf(['..exporting (' num2str(size(t2,1)) ' files)..']);
        for i=1:size(t2,1)
            f1=t2{i,3};
            fprintf( [ '|' animal{i} '..' ]);
            d1=fullfile(pamainout,animal{i});
            if ~isempty(t2{i,2})
                d1=fullfile(d1,t2{i,2});
            end
            mkdir(d1);
            copyfile(f1,d1,'f' );
        end
        fprintf('\n');
        fprintf('..Done!\n');
        %% ===============================================
    end
elseif strcmp(task, 'deleteFiles')
    warning off;
    t={};
    for i=1:size(co,1)
        dx=u.vinfo{co(i,2),co(i,1)};
        if ~isempty(dx)
            t(end+1,:)=dx;
        end
    end
    fis=cellfun(@(a,b,c){[a filesep b filesep c]},t(:,1),t(:,6),t(:,5));
    fis=strrep(fis,[filesep filesep],filesep);
    t2=[t(:,1) t(:,6) fis];
    
    [~,ia]=unique(t2(:,3));
    if isempty(ia); return; end
    t2=t2(ia,:);
     [pam, animal]=fileparts2(t2(:,1));
    
    fprintf(['..delete files (' num2str(size(t2,1)) ' files)..']);
    for i=1:size(t2,1)
        f1=t2{i,3};
        fprintf( [ '|' animal{i} '..' ]);
        try; 
            delete(f1);
        catch
            fprintf('\n');
            disp(['could not delete: ' f1]);
            
        
        end
    end
    fprintf('\n');
    fprintf('..Done!\n');
    
    pb_update([],[]);
    
    
    
end


function keys(e,e2)
% e2
if isempty(e2.Modifier)
if strcmp(e2.Character,'+')
    hl=gca;
    fs=get(hl,'fontsize');
    set(hl,'fontsize',fs+1);
elseif strcmp(e2.Character,'-')
    hl=gca;
    fs=get(hl,'fontsize');
    if fs<2; return; end
    set(hl,'fontsize',fs-1);
end
elseif strcmp(e2.Modifier,'control')
    if strcmp(e2.Key,'rightarrow')
        set( gca, 'xTickLabelRotation', get(gca,'xTickLabelRotation')-1);
    elseif strcmp(e2.Key,'leftarrow')
        set( gca, 'xTickLabelRotation', get(gca,'xTickLabelRotation')+1);
    
    
    elseif strcmp(e2.Character,'+') || strcmp(e2.Character,'-')
        hl=[ [findall(gcf,'tag','tx_dummy') findall(gcf,'tag','tx_info')] ];
        fs=get(hl(1),'fontsize');
        if strcmp(e2.Character,'+')
            set(hl,'fontsize',fs+1);
        else
            if fs<2; return; end
            set(hl,'fontsize',fs-1);
        end 
    end
end

% YTickLabelRotation




%% ===============================================
function mouseclick(e,e2)

mtype = get(gcf,'selectiontype');
if strcmp(mtype,'alt') %normal/alt
    return
end


% return



u=get(gcf,'userdata');
hmulti=findobj(gcf,'tag','rd_multiSel');

cc=get(gca,'CurrentPoint');
cc=cc(1,1:2);
co=ceil(cc-.5);

%----------outside array-----------------
if co(1)>length(u.mdirslice) || co(2)>length(u.unifiles) ||...%'outside'
        co(1)<1 || co(2)<1
    
    if co(1)<length(u.mdirslice) && co(2)>=1 && co(2)<=length(u.unifiles) %FILES
        %'select this files across folder'
        v=u.vinfo(co(2),:);
        ifound=find(~cellfun(@isempty,v));
        
        cp=[ ifound(:) repmat(co(:,2),[ length(ifound)  1]) ];
        hsel=findobj(gcf,'tag','sel');
        iSameExist=[];
        if ~isempty(hsel)
            selpos=[[hsel.XData]' [hsel.YData]'];
            for i=1:length(ifound)
                is=find(selpos(:,1)==cp(i,1) & selpos(:,2)==cp(i,2));
                iSameExist=[iSameExist; is(:)];
            end
        end
        if isempty(iSameExist)
            for i=1:length(ifound) %PLOT
                hold on;
                hp=plot(cp(i,1),cp(i,2),'x','color','k','tag','sel','linewidth',2);
                setcontextmenu();
            end
        else
            if  ~isempty(hsel)%  DELETE FILES
                for i=1:length(iSameExist)
                    delete(hsel(iSameExist));
                end
            end
        end
    end
    %-----------------
    if co(2)>length(u.unifiles) && co(1)>=1 && co(1)<=length(u.mdirslice) %FOLDERS
        %'select all files from this folder'
        v=u.vinfo(:,co(1));
        ifound=find(~cellfun(@isempty,v));
        %length(ifound)
        cp=[ repmat(co(:,1),[ length(ifound)  1]) ifound(:)  ];
        hsel=findobj(gcf,'tag','sel');
        iSameExist=[];
        if ~isempty(hsel)
            selpos=[[hsel.XData]' [hsel.YData]'];
            for i=1:length(ifound)
                is=find(selpos(:,1)==cp(i,1) & selpos(:,2)==cp(i,2));
                iSameExist=[iSameExist; is(:)];
            end
        end
        if isempty(iSameExist)
            for i=1:length(ifound) %PLOT
                hold on;
                hp=plot(cp(i,1),cp(i,2),'x','color','k','tag','sel','linewidth',2);
                setcontextmenu();
            end
        else
            if  ~isempty(hsel)%  DELETE FILES
                for i=1:length(iSameExist)
                    delete(hsel(iSameExist));
                end
            end
        end
    end
    
    
    return
end


% ---- IF EXIST at same POSTION ---> return ---------------
hsel=findobj(gcf,'tag','sel');
if ~isempty(hsel)
    selpos=[[hsel.XData]' [hsel.YData]'];
    iSameExist=find(selpos(:,1)==co(1) & selpos(:,2)==co(2));
    delete(hsel(iSameExist))
    if ~isempty(iSameExist); return; end
end

%----------------%delete all other selections-------
if hmulti.Value==0
    delete(findobj(gcf,'tag','sel'));
end


% ---- IF file does not exist ---> return ---------------
if isempty(u.vinfo{co(2),co(1)}); return; end

% ------- plot point ----
hold on;
hp=plot(co(1),co(2),'x','color','k','tag','sel','linewidth',2);
setcontextmenu();




function motion(e,e2)
%% ===============================================

cc=get(gca,'CurrentPoint');
% cx=cc(1:2);
% co=round(cc(1,1:2)-.5);
%  cc

downadj=cc(1,2)-.5;
down= ceil(downadj);

rightadj=cc(1,1)-.5;
right= ceil(rightadj);
co=[right down];

u=get(gcf,'userdata');
try
    
    %     try
    %         if co(2)>length(u.unifiles)
    %             fileStr='';
    %         else
    %             fileStr=regexprep(u.aux{co(2),1},'_', '\\_') ;
    %         end
    %     end
    try
        tb=u.vinfo{co(2),co(1)}';
        if isempty(tb)
            title('');
            set(findobj(gcf,'tag','tx_info'),'visible','off');
            return
            
        end
        
        if co(1)<1
            sliceStr='';
        else
            sliceStr=u.mdirslice2{co(1)};
            
            if get(findobj(gcf,'tag','rd_info'),'value')==1
                % 'this'
                si=size(char(u.ht3(:)),2);
                %tb=u.vinfo{co(2),co(1)}';
                ts=cellfun(@(a,b){[a repmat(' ',[1 si-length(a)]) num2str(b)]},u.ht3(:),tb);
                ts([1 4 6],:)=[];
                %disp(char(tb));
                set(findobj(gcf,'tag','tx_info'),'string',ts,'visible','on');
            end
            if get(findobj(gcf,'tag','rd_tt'),'value')==1
                si=size(char(u.ht3(:)),2);
                %tb=u.vinfo{co(2),co(1)}';
                ts=cellfun(@(a,b){[a repmat(' ',[1 si-length(a)]) num2str(b)]},u.ht3(:),tb);
                ts([1 4 6],:)=[];
                %disp(char(tb));
                ht  =findobj(gcf,'tag','tx_info');
                hdum=findobj(gcf,'tag','tx_dummy');
                set(hdum,'string',ts);
                posext=get(hdum,'Extent');
                
                set(ht,'string',ts);
                postx=get(ht,'position');
                mp=get(gcf,'CurrentPoint');
                %set(ht,'position',[ mp(1:2)  postx(3:4)],'visible','on','backgroundcolor',[0.9922    1.0000    0.8706]);
                if co(1)>(length(u.mdirslice)/2) % jump Tooltip to right
                    set(ht,'position',[ mp(1)-posext(3)  mp(2)  posext(3:4) ],'visible','on','backgroundcolor',[0.9922    1.0000    0.8706]);

                else
                    set(ht,'position',[ mp(1:2)  posext(3:4) ],'visible','on','backgroundcolor',[0.9922    1.0000    0.8706]);
                end
                
                %[ mp(1:2)  postx(3:4)]
            end
        end
        
        
        
        fileStr=regexprep(tb{5},'_', '\\_') ;
        ti=title({sliceStr, fileStr },'fontsize',10,'fontweight','bold');
        
        set(ti,'units','norm');
        posti=get(ti,'position');
        set(ti,'position',[ 0.4 posti(2:end)]);
        drawnow;
        axpos=get(gca,'position');
    catch
        ht=findobj(gcf,'tag','tx_info');
        set(ht,'string','','position',ht.UserData,'backgroundcolor','w');
    end
    
    
    %%-------- XTICKS-resize
    if co(1)>=1 && co(1)<=length(u.mdirslice)
        xtl=get(gca,'XTickLabel');
        %htmls='\color{red}';
        %htmls='\fontsize{8}';
        %xtl=strrep(xtl,htmls,'');
        %xtl{co(1)} = [htmls xtl{co(1)}];
        xtl=regexprep(xtl,['\\fontsize\{\d+}'],'');
        xtl{co(1)} = ['\fontsize{' num2str(get(gca,'fontsize')+3) '}' xtl{co(1)}];
        set(gca,'XTickLabel',xtl);
        
    end
    %%-------- YTICKS-resize
    if co(2)>=1 && co(2)<=length(u.unifiles)
        ytl=get(gca,'YTickLabel');
        %htmls='\color{red}';
        %ytl=strrep(ytl,htmls,'');htmls='\fontsize{8}';
        ytl=regexprep(ytl,['\\fontsize\{\d+}'],'');
        
        ytl{co(2)} = ['\fontsize{' num2str(get(gca,'fontsize')+3) '}' ytl{co(2)}];
        set(gca,'yTickLabel',ytl);
        
    end
    set(gca,'position',axpos);
    
    
    
catch
    %     title('');
end
% drawnow;
%% ===============================================



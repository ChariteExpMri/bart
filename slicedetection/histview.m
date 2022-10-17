% histview(cv,[90 3 3],[5 5 5])

function histview(cv,sul,step,ovl)
warning off;
% ==============================================
%%   tests
% ===============================================
if 0
    load('testbed4_josephine5.mat',    'cv');
    cv;
    sul=[169.318      16.91558     -4.574649];
    step=[1 1 1];
end
% ==============================================
%%   
% ===============================================

if exist('cv')==1
    p.cv=cv;
end
% if exist('step')~=1
%     step=[1 1 1];
% end
if exist('ovl')==1
  p.ovl=ovl;
end


if exist('sul')==1
    p.x0=sul;
else
    p.x0=[size(cv,3)/2 0 0];
end
if exist('step')==1
   p.step=step; 
else
   p.step=[1 1 1];
end
    

if 0
   p.cv= smooth3(p.cv,'box',3); 
    
end


p.cvsmall=imresize(p.cv,[70 70]);
p.x0orig =p.x0;


hf=findobj(0,'tag','histview');
close(hf);
% if isempty(hf)
fg;
set(gcf,'tag','histview');
set(gcf,'WindowKeyPressFcn',@keys);
set(gcf,'ToolBar','none','name',[ '[' mfilename ']' ]);
set(gcf,'WindowButtonMotionFcn',@motion);
% end

xx=p.x0;


set(gcf,'userdata',p);
ax2=axes('position',[.6 .06 .2 .2],'tag','ax2');     axis off;


% ==============================================
%%   controls
% ===============================================

% ==============================================
%%   slises
% ===============================================

pos1=[ 0.5072    0.0000    0.0500    0.0500];
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'position',pos1,'string','<html>&#8602;','tag' ,'pb_forw');
set(hb,'callback',{@update, 1, -1});

%===================================================================================================

hb=uicontrol('style','pushbutton','units','norm');
pos2=pos1;
pos2(1)=pos1(1)+pos1(3);
set(hb,'position',pos2,'string','<html>&#8603;','tag' ,'pb_back');
set(hb,'callback',{@update, 1, +1});
%===================================================================================================
%% slider
hb=uicontrol('style','slider','units','norm');
pos3=pos1;
pos3(1)=pos1(1)+pos1(3)*2;
pos3(3)=pos1(3)*4;
set(hb,'position',pos3,'string','v','tag' ,'sl_slide');
set(hb,'callback',{@update, 1, 0});
set(hb,'min',1, 'Max', size(p.cv,3),'value', 100);

jScrollBar = findjobj(hb);
% % jScrollBar.AdjustmentValueChangedCallback = {@jslid};
% set(jScrollBar,'MouseReleasedCallback',@slidupdate);

jScrollBar.MousePressedCallback           = @(h,e) sliderMousPress(h, e, 'clicked');
jScrollBar.MouseReleasedCallback          = @(h,e) sliderMousPress(h, e, 'released');
% ==============================================
%%   up-down angle
% ===============================================

pos1=[ 0.3322    0.0548    0.0500    0.0500];
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'position',pos1,'string','<html>&#8593;','tag' ,'pb_noseup');
set(hb,'callback',{@update, 2, 1});

pos2=pos1;
pos2(2)=pos1(2)-pos1(4);
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'position',pos2,'string','<html>&#8595;','tag' ,'pb_nosedown');
set(hb,'callback',{@update, 2, -1});

% ==============================================
%%   Le-Ri angle
% ===============================================

pos1=[0.3858    0.0310    0.0500    0.0500];
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'position',pos1,'string','<html>&#8592;','tag' ,'pb_left');
set(hb,'callback',{@update, 3, -1});

pos2=pos1;
pos2(1)=pos1(1)+pos1(3);
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'position',pos2,'string','<html>&#8594;','tag' ,'pb_right');
set(hb,'callback',{@update, 3, +1});

% ==============================================
%%   edit -values
% ===============================================
hb=uicontrol('style','edit','units','norm');
set(hb,'position',[0 .96 .27 .04],'string',['sliceNo  noseUpDown  LeftRight '])
set(hb,'tooltipstring',['sliceNo  noseUpDown  LeftRight ']);
set(hb,'tag' ,'ed_values','callback',{@update, 4, 0});
% -------context
cmenu=uicontextmenu;
         uimenu(cmenu,'label','<html><b><font color="red"> change Parameter:');
         uimenu(cmenu,'label','round values','callback',{@context_ed_paramter,'round'});
         uimenu(cmenu,'label','set angles to "0°"','callback',{@context_ed_paramter,'anglesZero'});
         uimenu(cmenu,'label','go to middle slice"','callback',{@context_ed_paramter,'middleSlice'});
         uimenu(cmenu,'label','use INPUT parameter"','callback',{@context_ed_paramter,'defaultParameter'});
   
 set(hb,'ContextMenu',cmenu);

% ==============================================
%%   edit stepsize
% ===============================================
hb=uicontrol('style','edit','units','norm');
set(hb,'position',[.05 .0 .15 .04],'string',regexprep(num2str(p.step),'\s+',' ') )
set(hb,'tooltipstring',['stepSize of: sliceNo  noseUpDown  LeftRight --> see contextmenu ']);
set(hb,'tag' ,'ed_stepsize');%'callback',{@update, 4, 0});
% -------context
cmenu=uicontextmenu;
         uimenu(cmenu,'label','<html><b><font color="red"> set stepsize:');
          uimenu(cmenu,'label','1 1 1','callback',@context_stepsize);
          uimenu(cmenu,'Label','2 2 2','callback',@context_stepsize);
          uimenu(cmenu,'Label','.5 .5 .5','callback',@context_stepsize);
          uimenu(cmenu,'Label','.1 .1 .1','callback',@context_stepsize);
          uimenu(cmenu,'Label','1 .1 .1','callback',@context_stepsize);
 set(hb,'ContextMenu',cmenu);
 
 % ==============================================
%%   txt info
% ===============================================
hb=uicontrol('style','text','units','norm');
set(hb,'position',[0 .96 .2 .04],'string','Slice','fontsize',7,'backgroundcolor','w');
set(hb,'tag','info','foregroundcolor','b','fontweight','bold','visible','off');
% ==============================================
%%
% ===============================================

rotation_cube();
update([],[],0,0);


function update(e,e2,task,code)
ax1=findobj(gcf,'tag','ax1');
axes(ax1);
p=get(gcf,'userdata');
hstep=findobj(gcf,'tag' ,'ed_stepsize');
step=str2num(get(hstep,'string'));

info=findobj(gcf,'tag','info');
[msg1 msg2 msg3 msg4]=deal('');
if task==1
    if code~=0
        if p.x0(1)+code<1;
            % 'below-1'
            return;
        end
        if p.x0(1)+code>size(p.cv,3);
            % 'above-max'
            return;
        end
        if code==-1; msg1='slice backw.'; end
        if code==+1; msg1='slice forw.'; end
            
        p.x0(1)=p.x0(1)+(code*step(1));
        hs=findobj(gcf,'tag' ,'sl_slide');
        set(hs,'value',p.x0(1));
        %         get(hs,'value')
    else
        hs= findobj(gcf,'tag' ,'sl_slide');
        val=get(hs,'value');
        p.x0(1)=round(val);
        msg1='slice change';
    end
    set(gcf,'userdata',p);
end
if task==2
    if code~=0
        if code==-1; msg2='nose down'; end
        if code==+1; msg2='nose up'; end
        p.x0(2)=p.x0(2)+(code*step(2));
    else
        %        hs= findobj(gcf,'tag' ,'sl_slide')
        %        val=get(hs,'value')
        %         p.x0(2)=val;
    end
    set(gcf,'userdata',p);
end
if task==3
    if code~=0
        if code==-1; msg3='nose right'; end
        if code==+1; msg3='nose left'; end
        p.x0(3)=p.x0(3)+(code*step(3));
    else
        %        hs= findobj(gcf,'tag' ,'sl_slide')
        %        val=get(hs,'value')
        %         p.x0(2)=val;
    end
    set(gcf,'userdata',p);
end
if task==4 %edit
    ed=findobj(gcf,'tag','ed_values');
    vals=str2num(get(ed,'string'));
    msg4='change from parameter-field';
    if vals(1)<1;
        % 'below-1'
        vals(1)=1;
        %         return;
    end
    if vals(1)>size(p.cv,3);
        % 'above-max'
        vals(1)=size(p.cv,3);
        %         return;
    end
    
    p.x0=(vals);
    set(gcf,'userdata',p);
end


set(info,'string',[msg1 '-' msg2 '-' msg3 '-' msg4 ]);

% -----------------------
xx=p.x0;
% disp(xx);

slicenum=xx(1);
X=xx(2);
Y=xx(3);
[xd,yd,zd,corners ]=deal([]);
[tx,ty,tz,moveNorm,]=deal(0);
cent    =[size(p.cv,2)/2 size(p.cv,1)/2];
vol_center=[cent slicenum];
if 0
    [s xd yd zd next_corners vol_center ] = getslice4(cv,corners,[], [], [],[vol_center],...
        tx,ty,tz,rx,ry,rz,moveNorm,0);
    % toc
    dat=(s.CData);
end


axpos=[0 0 .85 1];
d=obliqueslice(p.cv, vol_center, [Y -X 90]);
ax1=findobj(gcf,'tag','ax1');
if isempty(ax1)
   ax1=axes('position',axpos ,'tag','ax1');
end
axes(ax1);



if isfield(p,'ovl')
    r=imfuse(p.ovl,imadjust(mat2gray(d))  );
     him=imagesc(r);
else
    him=imagesc(imadjust(mat2gray(d)));
    colormap gray
end
% hv=vline([1:20:size(d,2)],'color','m','tag','lines');
% hv=hline([1:20:size(d,1)],'color','m','tag','lines');
hv=vline([linspace(1,size(d,2),16)],'color','m','tag','lines');
hv=hline([linspace(1,size(d,1),16)],'color','m','tag','lines');

set(him,'ButtonDownFcn',@imageclick)
xlim=[1 size(d,2)];
ylim=[1 size(d,1)];
axis off;
set(gca,'position',axpos,'tag','ax1');

%  EDIT
ed=findobj(gcf,'tag','ed_values');
set(ed,'string',[ regexprep(num2str(p.x0),'\s+',' ')]);

%slice-slider
hs= findobj(gcf,'tag' ,'sl_slide');
set(hs,'value', p.x0(1));
drawnow

axes((findobj(gcf,'tag','ax3')));
view([p.x0(3) p.x0(2)]);

%% ==========lines=====================================


%% ===============================================


function imageclick(e,e2)
axes(findobj(gcf,'tag','ax1'));
% get(gca,'tag')
cp=get(gca,'currentpoint'); %x than y
cp=cp(1,1:2);

xl=xlim;
yl=ylim;


xs=round(linspace(1,xl(2),4)); xs([1 end])=[];
ys=round(linspace(1,yl(2),4)); ys([1 end])=[];
cv=zeros(1,3);
if cp(1)<xs(1);
    cv(1,1)=1;
elseif cp(1)>xs(1) && cp(1)<xs(2);
    cv(1,2)=1;
else cp(1)>xs(2)  ;
    cv(1,3)=1;
end
% cv
% --------------
mv=zeros(3,1);
if cp(2)<ys(1);
    mv(1,1)=1;
elseif cp(2)>ys(1) && cp(2)<ys(2);
    mv(2,1)=1;
else cp(2)>ys(2)  ;
    mv(3,1)=1;
end
% mv


% cv
% mv
w=cv.*mv;

qw={'left-up' 'up' 'right-up'
    'left'    ''   'right'
    'left-down' 'down' 'righ-down'};

[ud lr]=find(w);
% return
if ud==1;    update([],[],2,1) ;end %up
if ud==3;    update([],[],2,-1) ;end %down
if lr==1;    update([],[],3,-1) ;end %left
if lr==3;    update([],[],3,+1) ;end %right

info=findobj(gcf,'tag','info');
set(info,'string',['move:' qw{ud,lr}]);




% uistack(ax3,'top');
%--------------
% axes(ax1);

function keys(e,e2)
% e2

if strcmp(e2.Modifier,'shift')
    if strcmp(e2.Key,'leftarrow' )
        update([],[],3,-1);
    elseif strcmp(e2.Key,'rightarrow' )
        update([],[],3,+1);
    elseif strcmp(e2.Key,'uparrow' )
        update([],[],2,+1);
    elseif strcmp(e2.Key,'downarrow' )
        update([],[],2,-1);
    end
    
    
else
    if strcmp(e2.Key,'leftarrow' )
        if strcmp(get(gco,'tag'),'sl_slide')
            return
        end
        update([],[],1,-1);
    elseif strcmp(e2.Key,'rightarrow' )
        if strcmp(get(gco,'tag'),'sl_slide')
            return
        end
        update([],[],1,+1);
    end
    
end

function context_ed_paramter(e,e2,task)
ed=findobj(gcf,'tag','ed_values');
val=get(ed,'string');
p=get(gcf,'userdata');
if strcmp(task,'round')
    p.x0=round(str2num(val));
elseif strcmp(task,'anglesZero')
    p.x0(2:3)=0;
elseif strcmp(task,    'middleSlice')
    p.x0(1)=round(size(p.cv,3)/2);
elseif strcmp(task,    'defaultParameter')
    p.x0=p.x0orig;
end
set(gcf,'userdata',p);
update([],[],0,0);


function context_stepsize(e,e2)
str=get(e,'Text');
ed=findobj(gcf,'tag','ed_stepsize');
set(ed,'string',str);

function jslid(e,e2)
% update([],[],1,0);
% return
% ax2=;
ax2=(findobj(gcf,'tag','ax2'));
axes(ax2);
if isempty(ax2)
    ax2=axes('position',[.6 .06 .2 .2],'tag','ax2');     axis off;
end


p=get(gcf,'userdata');
hs=findobj(gcf,'tag','sl_slide');
val=round(get(hs,'value'));
thump=p.cvsmall(:,:,val);
 
imagesc(thump);
set(gca,'tag','ax2');
 axis off;

return

% 
% u=get(hs,'userdata')
% if isfield(u,'mouseup')==0
%     u.mouseup=0;
%     set(hs,'userdata',u);
% end
% if u.mouseup==1; 
%    u.mouseup=0;
%     set(hs,'userdata',u);
%     update([],[],0,0);
%     return;
% end
% 
% val=round(get(hs,'value'));
% % thump=p.cvsmall(:,:,val);
% thump=p.c(:,:,val);
% imagesc(thump);
% disp('move');
% % set(e,'MouseReleasedCallback',@slidupdate);

% function slidupdate(e,e2)
% 'released'
% {@update, 1, 0}

function sliderMousPress(SliderH, EventData, task)
hs=findobj(gcf,'tag','sl_slide');
jScrollBar = findjobj(hs);
if strcmp(task,'clicked')
    set(hs,'callback',[]);
    jScrollBar.AdjustmentValueChangedCallback = {@jslid};
else %released
    jScrollBar.AdjustmentValueChangedCallback=[];
   
    update([],[],1,0);
    update([],[],1,0);
    set(hs,'callback',{@update, 1, 0});
end


% disp(Event)
% hs=findobj(gcf,'tag','sl_slide');
% u=get(hs,'userdata')
% u.mouseup=1;
% set(hs,'userdata',u);

% set(hb,'position',pos3,'string','v','tag' ,'sl_slide');
% % set(hb,'callback',{@update, 1, 0});
% set(hb,'min',1, 'Max', size(p.cv,3),'value', 100);

% jScrollBar = findjobj(hb);
% % % jScrollBar.AdjustmentValueChangedCallback = {@jslid};



% ==============================================
%%   ROTATION CUBE
% ===============================================
function rotation_cube()

ax3=axes('position',[.3 .3 .1 .1],'tag','ax3');
axes(ax3)
set(gca,'position',[.82 .82 .2 .19]);
drawnow
% ==============================================
%%   
% ===============================================

% fg
 X = [0, 1, 1, 0
    0, 1, 1, 0
    0, 0, 0, 0
    0, 1, 1, 0
    1, 1, 1, 1
    1, 1, 0, 0] ;
Y = [0, 0, 1, 1
    0, 0, 1, 1
    0, 0, 1, 1
    0, 0, 0, 0
    0, 1, 1, 0
    1, 1, 1, 1] ;
Z = [0, 0, 0, 0
    1, 1, 1, 1
    0, 1, 1, 0
    0, 0, 1, 1
    0, 0, 1, 1
    0, 1, 1, 0] ;
X=(X*2)-1;
Y=(Y*2)-1;
Z=(Z*2)-1;

C = {'blue' ;'red' ; 'green' ; 'yellow' ; 'magenta' ; 'cyan'};
% figure
hold on
for i = 1:6
   hp(i)= patch(X(i,:), Y(i,:), Z(i,:),C{i}) ;
end
axis square
 view(3);
 set(hp,'FaceAlpha',.1);
 set(hp,'edgecolor','w');
 % ==============================================
%  Plot the unit sphere centered at the origin.
% ===============================================
delete(findobj(0,'tag','sphere'));
[xp,yp,zp] = sphere;
% hs=surf(xp*.15    ,yp.*.15+.6  ,zp.*.15);set(hs,'tag','sphere','FaceLighting','phong');
% 
% hs=surf(xp*.3     ,yp.*.3+.3   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');
% hs=surf(xp*.3     ,yp.*.3-.2   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');
% hs=surf(xp*.25    ,yp.*.3-.0   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');
% 
% hs=surf(xp*.15-.1,yp.*.15-.4   ,zp.*.15-.1);set(hs,'tag','sphere','FaceLighting','phong');
% hs=surf(xp*.15+.1,yp.*.15-.4   ,zp.*.15-.1);set(hs,'tag','sphere','FaceLighting','phong');
% hs=surf(xp*.15   ,yp.*.15-.4   ,zp.*.15-.2);set(hs,'tag','sphere','FaceLighting','phong');
% hs=surf(xp*.15   ,yp.*.12-.5   ,zp.*.15-.3);set(hs,'tag','sphere','FaceLighting','phong');

hs=surf(xp*.15    ,yp.*.15-.6  ,zp.*.15);set(hs,'tag','sphere','FaceLighting','phong');

hs=surf(xp*.3     ,yp.*.3+.3   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');
hs=surf(xp*.3     ,yp.*.3-.2   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');
hs=surf(xp*.25    ,yp.*.3-.0   ,zp.*.3);set(hs,'tag','sphere','FaceLighting','phong');

hs=surf(xp*.15-.1,yp.*.15+.5   ,zp.*.15-.1);set(hs,'tag','sphere','FaceLighting','phong');
hs=surf(xp*.15+.1,yp.*.15+.5   ,zp.*.15-.1);set(hs,'tag','sphere','FaceLighting','phong');
hs=surf(xp*.15   ,yp.*.15+.5   ,zp.*.15-.2);set(hs,'tag','sphere','FaceLighting','phong');
hs=surf(xp*.15   ,yp.*.12+.6   ,zp.*.15-.3);set(hs,'tag','sphere','FaceLighting','phong');


set(findobj(0,'tag','sphere'),'facecolor',[ 0.3922    0.8314    0.0745],'edgecolor','none');
light('Position',[-1 1 0],'Style','local');
camlight('headlight');
% ==============================================
%   
% ===============================================

% function MAKEARROW
% ==============================================
%
% ===============================================
aroffset =.1;
arlength =.15;
lims=[xlim; ylim; zlim];
%start 10% from left side
arStart=(lims(:,2)-lims(:,1)).*aroffset+lims(:,1);
arStop=(lims(:,2)-lims(:,1)).*arlength+arStart;

arStart=repmat([-1 ],[3 1]);
arStop =repmat([ 1 ],[3 1]);

xlim([-1.1 1]);
ylim([-1.1 1]);
zlim([-1.1 1]);
% ==============================================

% disp('astartstop');
% disp(lims);
% disp('astartstop');
% disp([arStart arStop]);
delete(findobj(gcf,'tag','arrow'));
delete(findobj(gcf,'tag','arrowtxt'));
artx={'L' 'P' 'S'};
txt=[];
har=[];
for i=1:3
    ar=[arStart arStart];
    ar(i,2)=arStop(i);
    h = mArrow3(ar(:,1),ar(:,2),'color','red','stemWidth',.03,'facealpha',1);
    set(h,'tag','arrow');
    
    ht=text(ar(1,2),ar(2,2),ar(3,2),artx{i});
    set(ht,'fontsize',6,'tag','arrowtxt','fontweight','bold','color','k');
    set(ht,'VerticalAlignment','baseline');
    txt(i,1)=ht;
    har(i,1)=ht;
end

% ==============================================
%%   
% ===============================================

hdl2color=[txt; har; hp(:)];
set(hdl2color,'ButtonDownFcn',{@ax3rotate,0});


axis off
view(3)
axis vis3d
h=rotate3d;
set(gca,'tag','ax3');

p=get(gcf,'userdata');
view([p.x0(3) p.x0(2)])
h.ActionPostCallback = @postrotate;

u.info='h..rotate3d-hdl';
u.h=h;
u.hdl2color=hdl2color;
set(ax3,'userdata',u);


function ax3rotate(e,e2,task)
ax3=(findobj(gcf,'tag','ax3'));
u=get(ax3,'userdata');

if strcmp(get(u.h,'Enable'),'Enable')==0      % MAKE 'ON'
    set(u.h,'Enable','on');
    
else
     set(u.h,'Enable','off');
    
end




function postrotate(e,e2)
ax3=(findobj(gcf,'tag','ax3'));
axes(ax3);
[az el]=view; [az el];
% 'dum'

p=get(gcf,'userdata');
p.x0(2:3)=[ el az ];
set(gcf,'userdata',p);
update([],[],0,0);

function motion(e,e2)

ax = overobj2();
tag=get(ax,'tag');

if strcmp(tag,'ax1')==1
    try
        ax3=(findobj(gcf,'tag','ax3'));
        u=get(ax3,'userdata');
        
        if strcmp(get(u.h,'Enable'),'on')==1
            try
                set(u.h,'Enable','off');
            end
        end
    end
end

return






if strcmp(tag,'ax3')==1
    axes(ax3);
    h=rotate3d(ax3);
    if strcmp(get(h,'Enable'),'Enable')==0
        h.Enable = 'on';
    end
else
%     ax3=(findobj(gcf,'tag','ax3'));
%     axes(ax3);
%     h=rotate3d(ax3);
%     if strcmp(get(h,'Enable'),'Enable')==1
%         h.Enable = 'off';
%     end
    
end

return

hf=findobj(0,'tag','histview');
ax3=(findobj(gcf,'tag','ax3'))
hd=hittest(hf);
li={get(hd,'tag') get(get(hd,'parent'),'tag')}
if any(strcmp(li,'ax1'))==1
    ax3=(findobj(gcf,'tag','ax3'))
    %axes(ax3);
    h=rotate3d(ax3);
    if strcmp(get(h,'Enable'),'Enable')==0
        h.Enable = 'on';
    end
else
    h=rotate3d;
    ax3=(findobj(gcf,'tag','ax3'));
    %axes(ax3);
    h=rotate3d(ax3);
    if strcmp(get(h,'Enable'),'Enable')==1
        h.Enable = 'off';
    end
    
end

function h = overobj2(varargin)
%OVEROBJ2 Get handle of object that the pointer is over.
%   H = OVEROBJ2 searches all objects in the PointerWindow
%   looking for one that is under the pointer. Returns first
%   object handle it finds under the pointer, or empty matrix.
%
%   H = OVEROBJ2(FINDOBJ_PROPS) searches all objects which are
%   descendants of the figure beneath the pointer and that are
%   returned by FINDOBJ with the specified arguments.
%
%   Example:
%       h = overobj2('type','axes');
%       h = overobj2('flat','visible','on');
%
%   See also OVEROBJ, FINDOBJ
% Ensure root units are pixels
oldUnits = get(0,'units');
set(0,'units','pixels');
% Get the figure beneath the mouse pointer & mouse pointer pos
try
   fig = get(0,'PointerWindow');  % HG1: R2014a or older
catch
   fig = matlab.ui.internal.getPointerWindow;  % HG2: R2014b or newer
end
p = get(0,'PointerLocation');
set(0,'units',oldUnits);
% Look for quick exit (if mouse pointer is not over any figure)
if fig==0,  h=[]; return;  end
% Compute figure offset of mouse pointer in pixels
figPos = getpixelposition(fig);
x = (p(1)-figPos(1));
y = (p(2)-figPos(2));
% Loop over all figure descendants
c = findobj(get(fig,'Children'),varargin{:});
for h = c'
   % If descendant contains the mouse pointer position, exit
   r = getpixelposition(h);  % Note: cache this for improved performance
   if (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4))
      return
   end
end
h = [];

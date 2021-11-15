function plotslice(xx,fvel, cv,ref,tit,sol2)
% plotslice(xx1,fvel1,cv, s.img,{'ref' 'dd'})
% ==============================================
%%   get slice
% ===============================================
% xx=[166   13.1462   -2.39]

slicenum=xx(1);
X=xx(2);
Y=xx(3);

[xd,yd,zd,corners ]=deal([]);
[tx,ty,tz,moveNorm,]=deal(0);
cent    =[size(cv,2)/2 size(cv,1)/2];
vol_center=[cent slicenum];
rx=X ;%up-down
ry=Y; % tb(2);  %LEFT RIGHT
rz=0;


msg={['-BEST: ' sprintf('%2.2f ',xx)   '[' num2str(fvel) '] '   ]};


dat=obliqueslice(cv, vol_center, [Y -X 90]);
figure;
set(gcf,'units','norm');
if exist('ref')==1 & ~isempty(ref)
    montage({imadjust(dat), imadjust(imresize(mat2gray(ref),[size(dat) ])) });
else
    imagesc(imadjust(dat)); colormap gray
end
% title(msg,'fontsize',9,'color','b'); drawnow;
set(gca,'position',[0 0.1 1 .9] );
set(gcf,'color','k');
if ~exist('tit')==1
    tit=msg;
else
    if ischar(tit); tit=[ tit '  :  ' char(msg)];
    else
        tit{end}=[ tit{end} '-' char(msg)];
    end
end


hb=uicontrol('style','text','units','norm','tag','info');
set(hb,'position',[0 0 1 .1],'string',tit,'fontweight','bold');
set(hb,'fontsize',9,'backgroundcolor','k','foregroundcolor',[ 1.0000    1.0000    0.0667]);

% ==============================================
%%   add buttons
% ===============================================
if exist('sol2')==1
    u.sol=sol2;
    u.msg=tit;
    set(gcf,'userdata',u);
    %-----------
    hb=uicontrol('style','pushbutton','units','norm','string','metric');
    set(hb,'callback',@plotmetric);
    pos=get(hb,'position');
    %-----------
    hb=uicontrol('style','pushbutton','units','norm','string','table');
    set(hb,'callback',@showtable);
    set(hb,'position', [ pos(1)+pos(3) pos(2:end)]);
end

function showtable(e,e2)
u=get(gcf,'userdata');
% sol=sortrows(u.sol,[1 2 3]);

%% ===============================================

l={' #wk *** PARAMTER ESTIMATION ***'};
l=[l; u.msg(1); {[' #b '  u.msg{2} ] } ];
[l2 l]=plog(l,[{'slice' 'pitch' 'yaw' 'metric'};num2cell(sortrows(u.sol,[4 1 2 3 ]))],0,...
    'SORT: #ky METRIC ');
[l2 l]=plog(l,[{'slice' 'pitch' 'yaw' 'metric'};num2cell(sortrows(u.sol,[1 2 3]))],0,...
    'SORT: #ko SLICE ');
[l2 l]=plog(l,[{'slice' 'pitch' 'yaw' 'metric'};num2cell(sortrows(u.sol,[2 1 3]))],0,...
    'SORT: #kl PITCH ');
[l2 l]=plog(l,[{'slice' 'pitch' 'yaw' 'metric'};num2cell(sortrows(u.sol,[3 1 2 ]))],0,...
    'SORT: #kc YAW ');
l=[l; {''}; {''} ];
uhelp(l,1,'name','metrics');
%===================================================================================================

function plotmetric(e,e2)
u=get(gcf,'userdata');
sol=sortrows(u.sol,[1 2 3]);
% ==============================================
%%   
% ===============================================

fg; 
% disp(sol)
plot(sol(:,1),sol(:,4),'-k.');
set(gca,'fontweight','bold','fontsize',7);
xlabel('slice');ylabel('metric');
imin=find(sol(:,4)==min(sol(:,4)));
hold on;
solmin=sol(imin,:);
plot(solmin(:,1),solmin(:,4),'ro','markerfacecolor','r','markeredgecolor','k','markersize',5);

m=solmin(1,:);
ti=title([ sprintf('BEST: %d %d %d [Metric: %f]', m(1),m(2),m(3),m(4))  ]);

% return
%% ==============lable =================================
% delete(findobj(gcf,'tag','labsol'));
% y=min(sol(:,4))-(median(min(sol(:,4)))*.01);
for i=1:size(sol,1)
    str=(sprintf('%2.0f\n%2.0f\n%2.0f', sol(i,1),sol(i,2),sol(i,3)));
    y=sol(i,4);
   text(sol(i,1),  y, str ,'tag','labsol' ,'fontsize',5,'color','b') ;
end
ch=findobj(gcf,'tag','labsol');
% set(ch,'userdata',5);
set(ch,'VerticalAlignment','top');
% yl=ylim;
% ylim([y yl(2)]);
xlim([ sol(1,1)-1  sol(end,1)+1 ])
set(ch,'ButtonDownFcn','fs=get(gco,''fontsize''); set(gco,''fontsize'',15); pause(.1); set(gco,''fontsize'',fs)'   );








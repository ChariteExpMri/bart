function plotslice(xx,fvel, cv,ref,tit)
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


msg={['[' num2str(fvel) '] ' sprintf('%2.2f ',xx)   ]};


dat=obliqueslice(cv, vol_center, [Y -X 90]);
figure;
set(gcf,'units','norm');
if exist('ref')==1 & ~isempty(ref)
    montage({imadjust(dat), imadjust(imresize(mat2gray(ref),[size(dat) ])) });
else
    imagesc(imadjust(dat)); colormap gray
end
title(msg,'fontsize',9,'color','b'); drawnow;
set(gca,'position',[0 0.1 1 .9] );
set(gcf,'color','k');
if ~exist('tit')==1
    tit=msg;
else
    if ischar(tit); tit=[ tit '  :  ' char(msg)];
    else
        tit{end}=[ tit{end} '  :  ' char(msg)];
    end
end

hb=uicontrol('style','text','units','norm');
set(hb,'position',[0 0 1 .1],'string',tit,'fontweight','bold');
set(hb,'fontsize',9,'backgroundcolor','k','foregroundcolor',[ 1.0000    1.0000    0.0667]);





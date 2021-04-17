
% ==============================================
% https://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/
%%   
%               DataSource: 'Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif'
%               SourceDetails: [1×1 struct]
%                  LevelSizes: [55040 180224]
%                   BlockSize: [1024 4096]
%                    Channels: 3
%             ClassUnderlying: "uint8"
%     CoarsestResolutionLevel: 1
%       FinestResolutionLevel: 1
%    Read Write Properties.
%          SpatialReferencing: [1×1 imref2d]
%               UnloadedValue: [1×1×3 uint8]
% ===============================================

% f0='Wildlinge fr_h #20.2_000000000001EADF.ndpi'
f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
bim = bigimage(f0)

bshow = bigimageshow(bim);


coordStart = [1 1];
%Ending Coordinates
coordEnd = [1000,1000];
%Extract the region between the aforementioned coordinates
tic
blk1 = getRegion(bim,1,coordStart, coordEnd);
toc
% ==============================================
%%   large
% ===============================================



% f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% i0 = bigimage(f0)

f1='Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif';
% f1='Wildlinge fr_h #20.2_000000000001EADF.tif'
img = bigimage(f1)

% ==============================================
%%   
% ===============================================
x0=11000
coordStart = [1      20000];
coordEnd =   [180224  20050 ];%[30000,30000];
%Extract the region between the aforementioned coordinates
tic
blk2 = getRegion(img,1,coordStart, coordEnd);
toc
%Display the image
% bigimageshow(bigimage(blk2))
fg,imagesc(blk2(:,:,3))

% ==============================================
%%   LOAD ENTIRE DATA, resolution 10
% ===============================================

clear
tic
f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
s=imfinfo(f0);
% ==============================================
%  reading: 162sec-->2.7min
% ===============================================
cf

% rows=[s.Height/2-100 s.Height/2+100]-3000
% cols=[1 s.Width]
w=imread(f0);%,'PixelRegion',{[1 10977+100],[10977 10977]}) %cell array in the form {rows,cols}
% w=imread(f0,'PixelRegion',{rows,cols}); %cell array in the form {rows,cols}
% fg,imagesc(w(:,:,1))
toc



% ==============================================
%%   
% ===============================================
ws=mean(w(:,:,1),1);
wsflt=movmean(ws,[11]);
ot=otsu(wsflt,2)-1;
mask   = logical(ot(:).')==0;    %(:).' to force row vector
starts = strfind([false, mask], [0 1]);
stops = strfind([mask, false], [1 0]);
t=[strfind([false, mask], [0 1])' strfind([mask, false], [1 0])']
numObj=size(t,1)

fg,
plot(ws,'k'); hold on
vline(t(:,1),'color','m');
vline(t(:,1),'color','r')
% t([1 end],:)=[];


% ==============================================
%%   split , display, save
% ===============================================
maxsi=max(t(:,2)-t(:,1));
maxadd=maxsi.*.1;
si=round(maxsi+maxadd);
chan=1:3
cf
for i=1:size(t,1)
    tx=t(i,:);
    add=si-(tx(2)-tx(1));
    addhalf=(add/2);
    if addhalf==round(addhalf)
        addA=addhalf;
        addB=addhalf;
    else
        addA=floor(addhalf);
        addB=ceil(addhalf);
    end
    u=w(:,tx(1)-addA:tx(2)+addB,chan);
    disp(sprintf( '%d) %d ',i, size(u,2) ));
     fg; imagesc(u); title(i);
     if 1
         u2=permute(u,[2 1 3]);
         imwrite(u2, fullfile(pwd,['out_' pnum(i,3) '.tif']), 'tif','Compression','none');
     end
end


% ==============================================
%%   
% ===============================================

% ==============================================
%%   'YCbCr'
% ===============================================

% s2=struct();
% s2.Width=size(u,2)
% s2.Height=size(u,1)









% ==============================================
%%   small: problem: stripped form not tiled form ...not efficient
% ===============================================


 f1='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% i0 = bigimage(f0)

% f1='Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif';
% f1='Wildlinge fr_h #20.2_000000000001EADF.tif'
img = bigimage(f1)

% ==============================================
%%   
% ===============================================
x0=11000
coordStart = [1      20000];
coordEnd =   [180224  20050 ];%[30000,30000];
%Extract the region between the aforementioned coordinates
tic
blk2 = getRegion(img,1,coordStart, coordEnd);
toc
%Display the image
% bigimageshow(bigimage(blk2))
fg,imagesc(blk2(:,:,3))
















%% cut large tiff into slices
% x.transpose =1;         transpose image {0,1}
% x.outstr    ='a1_';     output-string of the slice ...followed by numeric number
% x.verb      =0;         give extra info  {0,1}
% x.outdir    ='up1';     out-put directory: {explicit path,'same' 'up1'}
%                           explicit path: explicit output-directory
%                           'same': same directory as input-image
%                           'up1' 1st. upper directory of input-image
% x.thumbnail =1;         save thumbnail image (jpg) {0,1}
%% EXAMPLE:
% file='F:\data3\histo2\data_Josephine\Wildlinge_fr_h_20_2_000000000001EADF\raw\Wildlinge_fr_h_20_2_000000000001EADF_x10_z0.tif'
% cuttiff(file,struct('transpose',1,'verb',0));

function cuttiff(file,xp)

% ==============================================
%%   testbed
% ===============================================

if 0
    file='F:\data3\histo2\data_Josephine\Wildlinge_fr_h_20_2_000000000001EADF\raw\Wildlinge_fr_h_20_2_000000000001EADF_x10_z0.tif'
    cuttiff(file,struct('transpose',1,'verb',0));
    
end

timeTot=tic;
% ==============================================
%%   defaults
% ===============================================
x.transpose =1;
x.outstr    ='a1_';
x.verb   =0;
x.outdir    ='up1';
x.thumbnail =1;

% ==============================================
%%   
% ===============================================

if exist('xp')==1
    if isstruct(xp)
        x=catstruct(x,xp);
    else
        error('2nd input is not a struct');
    end
end


% ==============================================
%%   
% ===============================================

if strcmp(x.outdir,'same')
    x.outpath=     (fileparts(file));
elseif strcmp(x.outdir,'up1')
    x.outpath=fileparts(fileparts(file));
else
    x.outpath=x.outdir;
end


% ==============================================
%%   read tif
%  reading: 162sec-->2.7min
% ===============================================
f0=file;
disp(' ------------------------------------------------------------------------------------------ ');
disp(['cut file: ' f0]);
disp(' ------------------------------------------------------------------------------------------ ');
disp([' ...reading file:' num2str(f0)]);
tic
s=imfinfo(f0);
% rows=[s.Height/2-100 s.Height/2+100]-3000
% cols=[1 s.Width]
w=imread(f0);%,'PixelRegion',{[1 10977+100],[10977 10977]}) %cell array in the form {rows,cols}
% w=imread(f0,'PixelRegion',{rows,cols}); %cell array in the form {rows,cols}
% fg,imagesc(w(:,:,1))
disp([ '...reading file Time: ' sprintf('%2.2f',toc/60) 'min']);


% ==============================================
%%   find number of slices
% ===============================================
disp([' ...find number of slices in image']);

chan=1;
ws=mean(w(:,:,chan),1);
mx=max(ws);
imx=find(ws==mx);
% samevec=zeros(size(ws));
% samevec(imx)=1;
borderValue=median([w(:,1,chan); w(:,end,chan); w(1,:,chan)'; w(end,:,chan)']);
ws(imx)=borderValue;

% isame=find(diff(ws)==0);
% samevec=zeros(size(ws));
% samevec(isame)=1;

wsflt=movmean(ws,[1000]);%previous:11
% ot=otsu(wsflt,2)-1; %outside is '1'
ot=wsflt>220;
% ot=otsu(wsflt,10)==10;
mask   = logical(ot(:).')==0;    %(:).' to force row vector
starts = strfind([false, mask], [0 1]);
stops = strfind([mask, false], [1 0]);
t=[strfind([false, mask], [0 1])' strfind([mask, false], [1 0])'];
% t(find(t(:,2)-t(:,1)<500),:)=[];%minSuperior-anterior-size

numObj=size(t,1);
disp(['number of objects found: ' num2str(numObj)]);

if x.verb==1
    fg;
    subplot(2,2,1);
    plot(ws,'k'); hold on;
    vline(t(:,1),'color','m');
    vline(t(:,2),'color','r');
    plot(ot.*max(ws),'color','b','linewidth',1.2)
    title(['Slices in image:' num2str(numObj) 'slices found']);
    
    subplot(2,2,2);
    imagesc(w)
   vline(t(:,1),'color','m');
    vline(t(:,2),'color','r');
    title(['Slices in image:' num2str(numObj) 'slices found']);
end


% ==============================================
%%   split , display, save slice
% ===============================================

maxsi=max(t(:,2)-t(:,1));
maxadd=maxsi.*.15;
% maxadd=maxsi.*.3;
si=round(maxsi+maxadd);
chan=1:3;
slicefiles={};
ut2=[]; %all thumbs
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
    imgcuts(i,:)=[tx(1)-addA tx(2)+addB];
    
    
    try
        u=w(:,tx(1)-addA:tx(2)+addB,chan);
    catch
        
        if size(w,2)<tx(2)+addB
            uh= w(:,tx(1)-addA:end,chan);
            u=[uh  repmat(uh(:,end,:), [1 si-size(uh,2)  1 ]) ];
        elseif (tx(1)-addA)<1
            uh  =w(:,1:tx(2)+addB,chan);
            u =[ repmat(uh(:,1,:), [1 si-size(uh,2)  1 ])  uh];
        end
    end
    
    
    %disp(sprintf( '%d) %d ',i, size(u,2) ));
   
   
    if x.transpose==1
        u2=permute(u,[2 1 3]);
    else
        u2=u; 
    end
    if x.verb==1
        fg; imagesc(u2); title(['cutted slice-' num2str(i)]);
    end
    
     if 1
         if exist(x.outpath)~=7; mkdir(x.outpath); end
         fiout=fullfile(x.outpath,[x.outstr pnum(i,3) '.tif']);
         disp(['..writing slice-' num2str(i) ': ' fiout]);
         imwrite(u2, fiout, 'tif','Compression','none');
         slicefiles{i,1}=fiout;
         
         ut=  imresize(u2,[1000 1000]);
         
         if x.thumbnail==1
           
           fioutThump=fullfile(x.outpath,[x.outstr pnum(i,3) '.jpg']);
           imwrite(ut,fioutThump);
           disp(['..writing thumbnail-' num2str(i) ': ' fiout]);
         end 
     end
     ut2(:,:,i) = ut(:,:,3);
end
% ==============================================
%%   make montage plot
% ===============================================
tif3=imresize(w(:,:,3),[ size(ut2,1)  size(ut2,2) ]);
% ==============================================
%%   
% ===============================================

ut3=cat(3,tif3,ut2);
ut3=imresize(ut3,[500 500]);
ut3=padarray(ut3,[3 3],0,'both');
ms=['orig' cellstr(num2str([1:5]'))'];
for i=1:size(ut3,3)
   tm=text2im(ms{i});
   ut3(1:size(tm,1),1:size(tm,2) ,i)=tm.*255;
end
mon=montageout(permute(ut3,[1 2 4 3 ]));
% fg,imagesc(mon)


% imwrite(mon,'dum.jpg');
fioutMon=fullfile(x.outpath,['a0_cut.jpg']);
imwrite(mon,fioutMon);
showinfo2('..cutting..Infoimage',fioutMon);


% ==============================================
%%    %-------write info struct
% ===============================================

v.s=s;
v.imgcuts=imgcuts;
v.x =x;
v.file=file;
v.slicefiles=slicefiles;

fioutinfo=fullfile(x.outpath,[x.outstr 'info' '.mat']);
disp(['..writing info: '  fioutinfo]);
save(fioutinfo,'v');

% ==============================================
%%   
% ===============================================

disp([ '...Total time for cutting this file: ' sprintf('%2.2f',toc(timeTot)/60) 'min']);



% % 
% % % ==============================================
% % % https://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/
% % %%   
% % %               DataSource: 'Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif'
% % %               SourceDetails: [1×1 struct]
% % %                  LevelSizes: [55040 180224]
% % %                   BlockSize: [1024 4096]
% % %                    Channels: 3
% % %             ClassUnderlying: "uint8"
% % %     CoarsestResolutionLevel: 1
% % %       FinestResolutionLevel: 1
% % %    Read Write Properties.
% % %          SpatialReferencing: [1×1 imref2d]
% % %               UnloadedValue: [1×1×3 uint8]
% % % ===============================================
% % 
% % % f0='Wildlinge fr_h #20.2_000000000001EADF.ndpi'
% % f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% % bim = bigimage(f0)
% % 
% % bshow = bigimageshow(bim);
% % 
% % 
% % coordStart = [1 1];
% % %Ending Coordinates
% % coordEnd = [1000,1000];
% % %Extract the region between the aforementioned coordinates
% % tic
% % blk1 = getRegion(bim,1,coordStart, coordEnd);
% % toc
% % % ==============================================
% % %%   large
% % % ===============================================
% % 
% % 
% % 
% % % f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% % % i0 = bigimage(f0)
% % 
% % f1='Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif';
% % % f1='Wildlinge fr_h #20.2_000000000001EADF.tif'
% % img = bigimage(f1)
% % 
% % % ==============================================
% % %%   
% % % ===============================================
% % x0=11000
% % coordStart = [1      20000];
% % coordEnd =   [180224  20050 ];%[30000,30000];
% % %Extract the region between the aforementioned coordinates
% % tic
% % blk2 = getRegion(img,1,coordStart, coordEnd);
% % toc
% % %Display the image
% % % bigimageshow(bigimage(blk2))
% % fg,imagesc(blk2(:,:,3))

% ==============================================
%%   LOAD ENTIRE DATA, resolution 10
% ===============================================

% clear
% tic
% f0='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% s=imfinfo(f0);
% % ==============================================
% %  reading: 162sec-->2.7min
% % ===============================================
% cf
% 
% % rows=[s.Height/2-100 s.Height/2+100]-3000
% % cols=[1 s.Width]
% w=imread(f0);%,'PixelRegion',{[1 10977+100],[10977 10977]}) %cell array in the form {rows,cols}
% % w=imread(f0,'PixelRegion',{rows,cols}); %cell array in the form {rows,cols}
% % fg,imagesc(w(:,:,1))
% toc
% 
% 
% 
% % ==============================================
% %%   
% % ===============================================
% ws=mean(w(:,:,1),1);
% wsflt=movmean(ws,[11]);
% ot=otsu(wsflt,2)-1;
% mask   = logical(ot(:).')==0;    %(:).' to force row vector
% starts = strfind([false, mask], [0 1]);
% stops = strfind([mask, false], [1 0]);
% t=[strfind([false, mask], [0 1])' strfind([mask, false], [1 0])']
% numObj=size(t,1)
% 
% fg,
% plot(ws,'k'); hold on
% vline(t(:,1),'color','m');
% vline(t(:,1),'color','r')
% % t([1 end],:)=[];
% 
% 
% % ==============================================
% %%   split , display, save
% % ===============================================
% maxsi=max(t(:,2)-t(:,1));
% maxadd=maxsi.*.1;
% si=round(maxsi+maxadd);
% chan=1:3
% cf
% for i=1:size(t,1)
%     tx=t(i,:);
%     add=si-(tx(2)-tx(1));
%     addhalf=(add/2);
%     if addhalf==round(addhalf)
%         addA=addhalf;
%         addB=addhalf;
%     else
%         addA=floor(addhalf);
%         addB=ceil(addhalf);
%     end
%     u=w(:,tx(1)-addA:tx(2)+addB,chan);
%     disp(sprintf( '%d) %d ',i, size(u,2) ));
%      fg; imagesc(u); title(i);
%      if 1
%          u2=permute(u,[2 1 3]);
%          imwrite(u2, fullfile(pwd,['out_' pnum(i,3) '.tif']), 'tif','Compression','none');
%      end
% end


% ==============================================
%%   
% ===============================================

% ==============================================
%%   'YCbCr'
% ===============================================

% s2=struct();
% s2.Width=size(u,2)
% s2.Height=size(u,1)








% % 
% % % ==============================================
% % %%   small: problem: stripped form not tiled form ...not efficient
% % % ===============================================
% % 
% % 
% %  f1='Wildlinge fr_h #20.2_000000000001EADF_x10_z0.tif';
% % % i0 = bigimage(f0)
% % 
% % % f1='Wildlinge fr_h #20.2_000000000001EADF_x40_z0.tif';
% % % f1='Wildlinge fr_h #20.2_000000000001EADF.tif'
% % img = bigimage(f1)
% % 
% % % ==============================================
% % %%   
% % % ===============================================
% % x0=11000
% % coordStart = [1      20000];
% % coordEnd =   [180224  20050 ];%[30000,30000];
% % %Extract the region between the aforementioned coordinates
% % tic
% % blk2 = getRegion(img,1,coordStart, coordEnd);
% % toc
% % %Display the image
% % % bigimageshow(bigimage(blk2))
% % fg,imagesc(blk2(:,:,3))















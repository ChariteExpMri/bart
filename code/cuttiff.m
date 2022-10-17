
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
x.approach =1;
x.addborderpixel=5;

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

%% ========add border-pixels ====================
if x.addborderpixel>0
    nbb=2; % number of bordering columns/rows to obtain median
    for i=1:size(w,3)
        bov=[w(:,[1: nbb],i) ; w(:,[end-nbb+1:end],i); w([1:nbb],:,i)'; w([end-nbb+1:end],:,i)' ];
        valbord=round(median(bov(:)));
        temp(:,:,i)=padarray(  w(:,:,i)  ,[x.addborderpixel x.addborderpixel],valbord);
    end
    w=temp;
    s.Height =size(w,1);
    s.Width  =size(w,2);
    clear temp;
end


%% ===============================================

approach=x.approach;

if approach==1 || approach==3
    % ==============================================
    %%  other approach
    % ===============================================
    
    %ws=w(:,:,1);
    si=[size(w,1) size(w,2)];
    si2=round([size(w,1) size(w,2)]/10);
    
    c=imresize(w(:,:,1), [si2],'nearest');
    
    try
        notsu=7;
        c1=otsu(medfilt2(c,[15 15]),notsu);
        c2=c1<notsu; %mask
    catch
        notsu=3;
        c1=otsu(medfilt2(c,[15 15]),notsu);
        c2=c1<notsu; %mask
    end
    
    
    c2=imfill(c2,'holes');
    [c3 nc]=bwlabeln(c2);
    uni=unique(c3); uni(uni==0)=[]; %clusterTable
    tv=[uni histc(c3(:),uni) ];
    tv=flipud(sortrows(tv,2));
    
    
    % ==============================================
    %%  remove tiny cluster below threshold
    % ===============================================
    delthresh=round(tv(1,2)*(xp.tr4smallcluster/100)); %treshold for smallest cluster in percent to largest cluster
    %delthresh=1500; %absolute size
    % to tiny cluster
    cl_tiny=tv(find(tv(:,2)<delthresh),1);
    %corner+border-artefacts
    if x.addborderpixel>0
        cl_bord=[];
    else
        cl_bord=unique([c3(:,[1 end]); c3([1 end],:)' ]); cl_bord(cl_bord==0)=[];
    end
    cl_del=unique([cl_tiny; cl_bord]);
    c3=c3(:) ;
    for i=1:length(cl_del)
        c3(c3==cl_del(i))=0;
    end
    [c4 nc]=bwlabeln(reshape(c3,size(c2) ));
    %% -------merging option---if overlap in x-direction by specific percentage than the two
    %% images are one slice parcellated along y-direction
    q = regionprops(c4,c4,'centroid','boundingbox','MeanIntensity');
    cent = cat(1,q.Centroid);
    cl = cat(1,q.MeanIntensity);% --> clusterindex
    bb = cat(1,q.BoundingBox);
    bb(:,3)=bb(:,3)+bb(:,1); %add up
    bb(:,4)=bb(:,4)+bb(:,2);
    
    % get percentage overlap
    ovl=zeros(size(bb,1));
    for i=1:size(bb,1)
        d1=round(bb(i,[1 3]));
        %iother=setdiff(1:size(bb,1),i);
        iother=1:size(bb,1);
        for j=1:length(iother)
            d2=round(bb(iother(j),[1 3]));
            ts=[d1; d2];
            lims=[min(ts(:,1)) max(ts(:,2))];
            vc=zeros(1,lims(2));
            ix1=ts(1,1):ts(1,2);
            vc(ix1)=vc(ix1)+1;%add overlap by adding a 1 for Cl-x1
            ix1=ts(2,1):ts(2,2);
            vc(ix1)=vc(ix1)+1;%add overlap by adding a 1 for Cl-x2
            vc=vc(lims(1):end);
            perc=round(length(find(vc==2))./length(vc)*100);
            ovl(i,j)=perc;
        end
    end
    tri=triu(ovl,1);
    clusteroverlapPercent=75;
    is=[];
    [is(:,1)  is(:,2)]=find(tri>clusteroverlapPercent);
    
    %% ----merge cluster now
    clm=cl(is); %rowwise cluster to merge
    if size(clm,2)==1; clm=clm'; end
    c4=c4(:);
    for i=1:size(clm,1)
        c4(c4==clm(i,1))=clm(i,2);
    end
    c5=reshape(c4,size(c2));
    % ==============================================
    %% free space
    % ===============================================
    clear c1 c2 c3 c4
    
    % ==============================================
    %% approach-3
    % ===============================================
    if approach==3
        %keyboard
        c5=manucut_image(c);
        
    end
    
    
    
    % ==============================================
    %%   cut images
    % ===============================================
    %tic
    uni=unique(c5); uni(uni==0)=[];
    ims={};
    sm=[];
    no=1;
    %c55=imresize(c5,[ si ],'nearest');
    fprintf('cut slices: ');
    for i=1:length(uni)
        %fprintf('%d', i);
        pdisp(i,1);
        if 1
            c6=imresize(c5==uni(i),[ si ],'nearest');
            %c6=c55==uni(i);
            % q2 = regionprops(c6,'boundingbox')
            % bb2 = cat(1,q2.BoundingBox)
            in=find(sum(c6,1)>0);
            bx=[in(1) in(end)];
            ma=c6(:,bx(1):bx(2));
            im=w(:,bx(1):bx(2),:);
            im3=im.*uint8(ma);
            
            im3=padarray(im3,[0 200],0,'both');
            if x.transpose==1
                im3=permute(im3,[2 1 3]);
            end
            ims(end+1,:)={im3};
            sm(:,:,no)=imresize(im3(:,:,1),[300 300]);
            no=no+1;
            %fg,imagesc(im3);
        end
    end
    fprintf('\n');
    %toc
    
    %===================================================================================================
    %% ===============================================
    
 
    
    % ==============================================
    %%    plot result
    % ===============================================
    
    
    numObj=length(uni);
    disp(['number of objects found: ' num2str(numObj)]);
    
    if x.verb==1
        fg;
        subplot(2,1,1);
        imagesc(imresize(c, [1000 1000],'nearest'));
        title({'orig.Tiff ..file: '; [file]},'fontsize',7)
        
        subplot(2,1,2);
        mnt=montageout(permute(padarray(sm,[3 3],255,'both'),[1 2 4 3]));
        imagesc(mnt)
        title(['...and ' num2str(numObj) 'slices found'],'fontsize',8);
    end
    
    
    % ==============================================
    %%  save images
    % ===============================================

    slicefiles={};
    ut2=[]; %all thumbs
    %compression='none';
    compression='LZW';
    for i=1:length(ims)
        %disp(i);
        u2=ims{i,1};
        if x.verb==1
            fg; imagesc(u2); title(['cutted slice-' num2str(i)]);
        end
        
        if 1
            if exist(x.outpath)~=7; mkdir(x.outpath); end
            fiout=fullfile(x.outpath,[x.outstr pnum(i,3) '.tif']);
            disp(['..writing slice-' num2str(i) ': ' fiout]);
            imwrite(u2, fiout, 'tif','Compression',compression);
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
    %%  Logfile
    % ===============================================
%     clc
    if ~isempty(slicefiles)
        logfile=fullfile(x.outpath,'importlog.txt');
        msgline={...
            ['RawSize: ' [num2str([s.Width]) ' x ' num2str(s.Height)]]
            ['cutApproach: ' num2str(approach)]
            ['Nslices: ' num2str(length(slicefiles))]
            ['RawFileSize: ' sprintf('%2.1fMB',s.FileSize/1e6)]
            };
          try;    msgline=[msgline; ['RawCompression: ' s.Compression]];            end
          try;    msgline=[msgline; ['RawColorType: '   s.ColorType]];            end
        
        for i=1:length(slicefiles)
            internfile =slicefiles{i};
            rawfile    =file;
            if i==1
                forceoverwrite=1;
                makelogfile(logfile, rawfile,internfile,msgline,forceoverwrite)
            else
                forceoverwrite=0;
                makelogfile(logfile, rawfile,internfile,msgline,forceoverwrite)
            end
        end
        
    end
%     type(logfile)
    
    % ==============================================
    %%   make montage plot
    % ===============================================
    tif3=imresize(w(:,:,3),[ size(ut2,1)  size(ut2,2) ],'nearest');

    
    ut3=cat(3,tif3,ut2);
    ut3=imresize(ut3,[500 500]);
    ut3=padarray(ut3,[3 3],0,'both');
    ms=['orig' cellstr(num2str([1:size(ut3,3)]'))'];
    for i=1:size(ut3,3)
        tm=text2im(ms{i});
        tm=imresize(tm,2);
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
    v.imgcuts=['approach-' num2str(x.approach)];
    v.x =x;
    v.file=file;
    v.slicefiles=slicefiles;
    
    fioutinfo=fullfile(x.outpath,[x.outstr 'info' '.mat']);
    disp(['..writing info: '  fioutinfo]);
    save(fioutinfo,'v');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % ==============================================
    %%   Approach-2
    % ===============================================
elseif approach==2
    
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
    %%  Logfile
    % ===============================================
    %     clc
    if ~isempty(slicefiles)
        logfile=fullfile(x.outpath,'importlog.txt');
        msgline={...
            ['RawSize: ' [num2str([s.Width]) ' x ' num2str(s.Height)]]
            ['cutApproach: ' num2str(approach)]
            ['Nslices: ' num2str(length(slicefiles))]
            ['RawFileSize: ' sprintf('%2.1fMB',s.FileSize/1e6)]
            };
        try;    msgline=[msgline; ['RawCompression: ' s.Compression]];            end
        try;    msgline=[msgline; ['RawColorType: '   s.ColorType]];            end
        
        for i=1:length(slicefiles)
            internfile =slicefiles{i};
            rawfile    =file;
            if i==1
                forceoverwrite=1;
                makelogfile(logfile, rawfile,internfile,msgline,forceoverwrite)
            else
                forceoverwrite=0;
                makelogfile(logfile, rawfile,internfile,msgline,forceoverwrite)
            end
        end
        
    end
    type(logfile)
    
    
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
    
end

% ==============================================
%%
% ===============================================

disp([ '...Total time for cutting this file: ' sprintf('%2.2f',toc(timeTot)/60) 'min']);





% function makelogfile(logfile, rawfile,internfile,forceoverwrite)
% 
% % ==============================================
% %%  log file
% % ===============================================
% 
% %  logfile=fullfile(fpoutDir,'importlog.txt');
% 
% 
% if exist('forceoverwrite')==1 && forceoverwrite==1
%     lg0=[];
% else
%     if exist(filog)==2
%         lg0=importdata(filog);
%     else
%         lg0=[];
%     end
%     
% end
% 
% 
% lg={[ 'DATE: '  timestr(now) ]};
% lg(end+1,1) ={['#import_TIFF [origin]: '  rawfile]};
% lg(end+1,1) ={['#import_TIFF [BART]  : '  internfile]};
% pwrite2file(logfile, [lg0; lg]);



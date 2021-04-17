

function predictcircles3(pa, pin)

p.meth           ='TwoStage';
p.polarity      ='dark';
p.medfilt       = [2 2];
p.color         ='g';
p.istest        = 0;
p.resizefactor  = 0;
p.sens          =.9;
p.dotplotsize   = 3;
p=catstruct(p,pin);
p.show          = 0;
p.save          = 0;
p.showcounts     = 0;

p.verbose       =1;

% ==============================================
%%
% ===============================================
pold=p;
p=catstruct(p,pin);

% ==============================================
%%   prepare
% ===============================================
trainmat=fullfile(pa,'training.mat');
if exist(trainmat)~=2; error('"training.mat" not found'); return; end

disp(['USING MODEL: CIRCLEDETECTION' ]);

dum=load(trainmat);
if isfield(dum,'currentIndex')==0
    dum.currentIndex=1;
end
clear pr
pr.currentIndex=dum.currentIndex;
pr.tb(:,1)     =dum.training(:,1);
pr.tb(:,2)     =repmat({[]},[size(pr.tb) 1]); %detections preALLOOC
% [files,dirs]=cfg_getfile2('List',pa,'^sec.*.png$')


tim2=tic;

if 0
    % ==============================================
    %%   get fraction of middle slices
    % ===============================================
    % doplot=1
    verbose=1;
    
    % clc;
    
    secfile=fullfile(fileparts(trainmat),'sec.mat');
    s=load(secfile);sec=s.sec;
    
    % ==============================================
    %%
    % ===============================================
    
    sipan=[sec.xd(1,2) sec.yd(1,2)];
    sitot=sec.si([1 2]);
    mx=mean(sec.xd,2);
    my=mean(sec.yd,2);
    le=[length([mx]) length([my])];
    npan=prod(le); %100
    fracuse=0.1;
    npanxy=round(le*sqrt(fracuse));
    
    ixx=round([(length(mx)/2)+[(1:npanxy(1))-npanxy(1)/2]]');
    iyy=round([(length(my)/2)+[(1:npanxy(2))-npanxy(2)/2]]');
    
    fis=pr.tb(:,1);
    fis=strrep(fis, [fileparts(fis{1,1}) filesep],'');
    usepan=[];
    for i=1:length(ixx)
        for j=1:length(iyy)
            usepan=[usepan; find(strcmp(fis,['sec' num2str(ixx(i)) '_' num2str(iyy(j)) '.png']))];
        end
    end
    
    
    
    e=[];
    for ix=1:length(usepan)
        c= imread(pr.tb{usepan(ix),1});
        if size(c,3)==3
            c=rgb2gray(c);
        else
            %c=mat2gray(c);
        end
        %figure(10); imagesc(c); title([num2str(ix) ' of ' num2str(length(usepan))]); drawnow;pause
        e=[e;c(:)];
    end
    
    
    % ==============================================
    %%
    % ===============================================
    e(find(min(e(:))))=[];
    e(find(max(e(:))))=[];
    e=double(e);
    % ==============================================
    %%
    % ===============================================
    
    ot=double(otsu(e,2));
    ME=[mean(e(find(ot==1))) mean(e(find(ot==2)))];
    MED=[median(e(find(ot==1))) median(e(find(ot==2)))];
    SD=[std(e(find(ot==1))) std(e(find(ot==2)))];
    
    tresh=MED(1)+SD(1) ;
    
end

% disp(['MEAN   : ' num2str(ME)]);
% disp(['MEDIAN : ' num2str(MED)]);
% disp(['SD     : ' num2str(SD)]);
% disp(['tresh  : ' num2str(tresh)]);
% ==============================================
%%
% ===============================================
if p.istest==1
    if ~isempty(p.testimage)
        imnum=regexpi2(pr.tb(:,1),p.testimage);
        imvec=imnum;
    end
else
    imvec=1:size(pr.tb,1);
end



% ==============================================
%%
% ===============================================
% for ix=1:size(pr.tb,1)
%  for ix=108

for u=1:length(imvec)
    
    
    ix=imvec(u);
    tim1=tic;
    I = imread(pr.tb{ix,1});
    %     fg,imagesc(I)
    
    
    
    % % ==============================================
    %%
    % ===============================================
    warning off
    if size(I,3)==3
        b = rgb2gray(I);
    else
        b=mat2gray(I) ;
    end
    
%     fg,imagesc(b); colorbar
%     fg,imagesc(b<120)
    
    
    
    % ==============================================
    %%  find circles
    % adapthisteq
    % ===============================================
    if strcmp(p.meth,'PhaseCode') || strcmp(p.meth,'TwoStage')
        if isempty(p.medfilt)
            gm2=(( (mat2gray((b)))));
        else
            gm2=(medfilt2( adapthisteq(mat2gray((b))),[p.medfilt(1) p.medfilt(2)]));
        end
        [ce,ra] = imfindcircles(gm2,p.radius,'Method',p.meth,'ObjectPolarity',p.polarity,...
            'Sensitivity',p.sens);
        
        ra2=ra; %copy for PIE-PLOT 
        if p.doHD==1 
           [ce ra] =doHD(gm2,ce,  p);
        end
        
    elseif    strcmp(p.meth,'frst')
        % ==============================================
        %%
        % ===============================================
        
        % ==============================================
        %%   alpha=0.4222;
        % ===============================================
        d=imcomplement(mat2gray(double(I)));%load example data
        d=d(:,:,3);
        d=adapthisteq(d);
%         d=medfilt2(d,[3 3]);
        min_and_max_of_img1=[min(d(:)) max(d(:))]
%         rmin=10;%estimated celll radius range and area
%         rmax=30;
        
        rmin=p.radius(1);
        rmax=p.radius(2);
        % dFRST
        
        %
        %         t=0.0154;
        %         k=25.5;
        
        % dFRST
        r=rmin:rmax;
        alpha=0.5;
        t=0.0154;% previously used
        %t=0.014;
        k=25;
        d2=mat2gray(d,min_and_max_of_img1);
        try
        res_frst=frst(d2,d2.*0+1,r,t,k,alpha);
        catch
           res_frst= d2.*0;
        end
        
        if 0
            figure;imshow(d2,[]);hold on;
            visboundaries(imdilate(res_frst>0,ones(2)))
            title('dFRST')
        end
        
%         keyboard
        
        [xx yy]=find(res_frst);
        ce=[ yy xx];
        ra=ones(size(ce,1),1)*5;
        
        % ==============================================
        %%
        % ===============================================
        
    end
    
    
    %
    %
    % gm0=(medfilt2(adapthisteq(mat2gray(imgradient(b))),[2 2]));
    % fg,imagesc(imcomplement(imadjust(gm0./gm2)))
    %  gm0=(adapthisteq(mat2gray(imgradient(b))));
    %    fg,imagesc(imcomplement(imadjust(gm0./gm2)))
    %
    %  fg,imagesc(medfilt2(imcomplement(imadjust(gm0./gm2)),[5 5]))
    %
    %
    %    gm3=medfilt2(imcomplement(imadjust(gm0./gm2)),[5 5]) ;
    % %     gm3=imcomplement(double(otsu(gm0,2)==2).*gm2);
    %
    %      [ce,ra] = imfindcircles(b,[8 30],'Method',p.meth,'ObjectPolarity',p.polarity,...
    %         'Sensitivity',.7);
    %
    
    msg_title=[ sprintf('Radius: %d-%d',p.radius(1),p.radius(2)) ';sens: ' num2str(p.sens) ];
    if p.show==1
        
        fg,imagesc(b);colormap gray;
        viscircles(ce, ra*0+1,'Color','m','linewidth',.5); axis square
        title(msg_title,'fontsize',8);
        drawnow;
    end
    if p.showcounts==1
        % ==============================================
        %%  radius-cellcount figure
        % ===============================================
        radvec =[p.radius(1):p.radius(2)]';
        ncounts=histc(ra2,radvec);
        ts=[radvec ncounts   ncounts./sum(ncounts)*100];
        
        
        %         fg,bar(radvec,ncounts)
        ts2=ts(find(ts(:,3)>.5),:);
        
        labels = cellfun(@(a,b) {[sprintf('R%d (%2.1f%%)',a,b) ]}, num2cell(ts2(:,1)) ,num2cell(ts2(:,3)) );
        fg;
        %subplot(2,2,1)
        hp=pie(ts2(:,3),labels);
        ht=findobj(hp,'type','text');
        set(ht,'fontsize',8,'fontweight','bold');
        set(ht,'Rotation',30);
        lg={['successful radii: '  'cell-counts: ' num2str(sum(ts2(:,2)))  sprintf( ' (%2.1f%%)', sum(ts2(:,3)))]
            ['*depicted only radii with counts>5%  ']};
        ti=title(lg);
        set(ti,'HorizontalAlignment','right','BackgroundColor',[0 .8 0],'fontsize',6);
        set(ti,'units','norm');
        %set(ti,'position',[0.25 1.01 0]);
        % ==============================================
        %%
        % ===============================================
        
        
    end
    
    
    cv=round(ce);
    if ~isempty(cv); cv(:,3)=1; end
    % ==============================================
    %%  BREAK if TEST
    % ===============================================

    %%
    % ===============================================
    I2=mat2gray(I);
    if exist('insertShape.m')==1
        im1 = insertShape(I2, 'circle',cv, 'Color',p.color);
    else
        im1 = insertShape3(I2, 'circle',cv, 'Color',p.color,'size',p.dotplotsize);
    end
    
    if p.show==2
        fg,image(im1);
        title(msg_title,'fontsize',8);
    end
    
    if 0
        figure(10),
        subplot(2,2,1);imagesc(b); hold on; viscircles(ce, ra*0+1,'Color','m','linewidth',.5);
        subplot(2,2,2);imagesc(b2); hold on; viscircles(ce, ra*0+1,'Color','m','linewidth',.5);
        subplot(2,2,3);imagesc(im1);
    end
    
    if p.save==1
        savetag='saved';
        % ==============================================
        %  save  celltagged image
        % ===============================================
        outfile=strrep(pr.tb{ix,1},[filesep 'sec'],[filesep 'predfus']);
        imwrite(im1,outfile);
        
        % ==============================================
        %   mask
        % ===============================================
        m=zeros([size(I,1)*size(I,2) 1]);
        if ~isempty(cv)
            ce=round(cv(:,[2 1])); %FLIP XY
            ind = sub2ind([size(I,1),size(I,2)],ce(:,1),ce(:,2));
            m(ind)=1;
        end
        m2=reshape(m,[size(I,1),size(I,2)]);
        
        
        outfile=strrep(pr.tb{ix,1},[filesep 'sec'],[filesep 'predmsk']);
        imwrite(m2,outfile);
    else
        savetag='NOT-saved *';
    end
    
    % figure,image(I);
    if p.verbose==1
        fprintf( ['predict-%d/%d: %2.2fs -->' savetag ' \n'],ix,size(pr.tb,1),toc(tim1) );
    end
end%panels


fprintf( '%s - ELAPSED TIME : %2.2fs\n',pa,toc(tim2) );




function [ce ra] =doHD(b,ce,  p)
ra=ones(size(ce,1),1);


% bw=im2bw(b);
bw=(b>.5);
bw=imcomplement(bw);
% fg,imagesc((bwlabeln(imfill(bw,'holes'))))

[cl num]=bwlabeln(imfill(bw,'holes')); %cluster


uni=[1:num]';
cont=histc(cl(:),uni);
ts=[uni cont];
ts=sortrows(ts,2);

tr=200;           % (Pixel)ClusterSizeTRESHOLD
ts2=ts(ts(:,2)>tr,:);

cl2=zeros(size(cl));
clv=cl(:);
clv2=zeros(size(clv));
for i=1:size(ts2,1)
    clv2(find(clv==ts2(i,1)))=i;
end
cl2=reshape(clv2,size(cl));
uni=unique(cl2); uni(uni==0)=[];
% ==============================================
%%
% ===============================================
 warning off
% p.sens   =.8;%85;
% 
% % p.istest =1
% % p.show   =1;
% % p.save   =0;
% % p.sens   =.9;
% % -----------
% p.dotplotsize=1;
% p.showcounts=0
% p.polarity= 'dark';%'bright';
% p.medfilt=[];%[11 11];
% p.color  ='m';
% p.radius =[1 100]; %[10 30]
% p.testimage='sec5_12.png'
% p.radiusHD=[1 30]
% p.sensHD  =.99
% 
% %%%% p.meth='PhaseCode'
% p.meth='TwoStage'
% 
% [ce1,ra1] = imfindcircles(b,p.radius,'Method',p.meth,'ObjectPolarity',p.polarity,...
%     'Sensitivity',p.sens);

[ce2,ra] = imfindcircles(b,p.radiusHD,'Method',p.meth,'ObjectPolarity',p.polarity,...
    'Sensitivity',p.sensHD);
ce2=round(ce2);
IND = sub2ind(size(b),ce2(:,2),ce2(:,1));
g=zeros(size(b));
g(IND)=1;


ce1=round(ce); % -----------------REFERENCE
if isempty(ce1)
    return;
end
IND = sub2ind(size(b),ce1(:,2),ce1(:,1));
r=zeros(size(b));
r(IND)=1;

% ==============================================
%%
% ===============================================
% cx=[];
% tg2=[];
% tg3=[];
zd=r;
for i=1:length(uni)
    mas=cl2==uni(i);
    g2=g.*(mas);
        
%     if 0
%         ce2=[];
%         [ce2(:,2) ce2(:,1)]=find(g2==1);
%         densimg=sum(r(:))/numel(r)  ; % all cells/numPicels NORMAL
%         incl=r.*mas;
%         denscl=   sum(incl(:))/ sum(mas(:));
%     end
    
     mas2=(boundarymask(mas)+mas)>0;
     mas2=imfill(imclose(mas2,ones(10)),'holes');   
     me=mean(b(mas2));
     sd=std(b(mas2));
    
    if me<.4
        % cx=[cx; ce2];
         disp(['pass: '  num2str(i)]);
        zd= (zd.*~mas)+g2;
    end
     
%     tg3(i,:) = [me sd];
end


% ==============================================
%%
% ===============================================

if 0
%     fg,imagesc(b);colormap gray;
%     viscircles(cx, ones( size(cx,1) ,1),'Color','m','linewidth',.5); axis square
%     title('granular','fontsize',8);


    fg,imagesc(b);colormap gray;
    viscircles(ce1, ones( size(ce1,1) ,1),'Color','m','linewidth',.5); axis square
    title('without HD','fontsize',8);
end

ce3=[];
[ce3(:,2) ce3(:,1)]=find(zd==1);
 
if 0
    % ce3=[cx; ce1]
    ce3=unique(ce3,'rows');
    fg,imagesc(b);colormap gray;
    viscircles(ce3, ones( size(ce3,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
end

%———————————————————————————————————————————————
%%   out
%———————————————————————————————————————————————
ce=ce3;
ra=ones(size(ce,1),1);




function predictcircles3_viathreshold(pa, pin)
warning off;
%% ===============================================

% p.meth           ='TwoStage';
% p.polarity      ='dark';
% p.medfilt       = [2 2];
% p.color         ='g';
% p.istest        = 0;
% p.resizefactor  = 0;
% p.sens          =.9;
% p.dotplotsize   = 3;
p.info1='params';
p=catstruct(p,pin);

p.show          = 0;
p.save          = 0;
p.showcounts     = 0;

% -----intensity threshold
p.doIntensTresh  = 0;
p.IntensTresh   =180;

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

disp(['USING MODEL: CIRCLEDETECTION via threshold' ]);

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
% ==============================================
%%  testMode
% ===============================================
if p.istest==1
    if ~isempty(p.testimage)
        if isnumeric(p.testimage)
            imvec=p.testimage;
        else
            imnum=regexpi2(pr.tb(:,1),p.testimage);
            imvec=imnum;
        end
    end
else
    imvec=1:size(pr.tb,1);
end



% ==============================================
%%  run over images
% ===============================================
% for ix=1:size(pr.tb,1)
%  for ix=108

for u=1:length(imvec)
    
    
    ix=imvec(u);
    tim1=tic;
    I = imread(pr.tb{ix,1});
    %     fg,imagesc(I)
    [px, name]=fileparts(pr.tb{ix,1});
    
    
    
    % % ==============================================
    %%  load image
    % ===============================================
    warning off
    if size(I,3)==3
        if p.RGBchan==0
            b = (double(rgb2gray(I)));
            b=b-min(b(:));
            b=b./max(b(:));
            
%             q1=mat2gray(I(:,:,1));
%             q2=mat2gray(I(:,:,2));
%             b=mat2gray(I(:,:,3));
%             
            
        else
            b=mat2gray(I(:,:,p.RGBchan));
        end
        
    else
        b=mat2gray(I) ;
        mag=I(:,:,1);
    end
    b=double(b);
    
    %     fg,imagesc(b); colorbar
    %     fg,imagesc(b<120)
    b0=b;
    %% ======[medfilt]=========================================
    if ~isempty(p.medfilt)
        medfiltvalue=repmat(p.medfilt(:)',[1 3 ]);
        b=medfilt2(b,[ medfiltvalue(1:2) ]) ;
    end
    
    if strcmp(p.polarity,'dark')
        b=imcomplement(b);
        p.polarity='bright';
    end
    
    %% ======[treshold/otsu]=========================================
    if strcmp(p.method,'otsu')
        %ot=otsu(b,p.otsucluster);
        ot=otsu(b,2);
        b2=ot>p.otsuthreshold;
        fg,imagesc(ot);
    elseif strcmp(p.method,'thresh')
        b2=b>p.threshold;
    elseif strcmp(p.method,'none')
        b2=b;
    end
    
    
    % ==============================================
    %%  find circles
    % adapthisteq
    % ===============================================
    if strcmp(p.meth,'PhaseCode') || strcmp(p.meth,'TwoStage')
        %         if isempty(p.medfilt)
        %             gm2=(( (mat2gray((b)))));
        %         else
        %             gm2=(medfilt2( adapthisteq(mat2gray((b))),[p.medfilt(1) p.medfilt(2)]));
        %         end
        %p.radius=[5  30]
        [ce,ra] = imfindcircles(b2,p.radius,'Method',p.meth,'ObjectPolarity',p.polarity,...
            'Sensitivity',p.sens);
        if 0
            fg,imagesc(b0);%colormap gray;
            viscircles(ce, ra*0+1,'Color','m','linewidth',3); axis square
            title('ww','fontsize',8,'interpreter','none');
            drawnow;
        end
        
        
        
        ra2=ra; %copy for PIE-PLOT
%         if p.doHD==1
%             [ce ra] =doHD(gm2,ce,  p);
%         end
%         
%         if p.doIntensTresh==1
%             [ce ra]=intenstreshAfterDetection(mag,p ,ce,ra);
%         end
%         
        if p.doCellDistanceThresh==1
            [ce ra]=mindist(b2,p,ce,ra);
        end
        
    elseif    strcmp(p.meth,'frst')
        % ==============================================
        %%
        % ===============================================
        
        % ==============================================
        %%   alpha=0.4222;
        % ===============================================
        %         d=imcomplement(mat2gray(double(I)));%load example data
        %         d=d(:,:,3);
        %         d=adapthisteq(d);
        
        d=b;
        min_and_max_of_img1=[min(d(:)) max(d(:))];       
        rmin=p.radius(1);
        rmax=p.radius(2);
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
            %             figure;imshow(d2,[]);hold on;
            figure;imagesc(d2);colormap gray;
            hold on;
            visboundaries(imdilate(res_frst>0,ones(2)))
            %   visboundaries(res_frst);
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
    
    msg_title=[ '#' num2str(imvec(u))  ') "' name '" ' ...
        sprintf('Radius: %d-%d',p.radius(1),p.radius(2)) ';sens: ' num2str(p.sens)...
        '; #cells=' num2str(size(ce,1))];
%     if p.show==1
%         fg,imagesc(b);colormap gray;
%         viscircles(ce, ra*0+1,'Color','m','linewidth',.5); axis square
%         title(msg_title,'fontsize',8,'interpreter','none');
%         drawnow;
%     end
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
    
    if p.show==1
        figure
        %subplot(2,2,1);
        imagesc(b0); hold on; viscircles(ce, ra*0+2,'Color','m','linewidth',2);
        title(msg_title,'fontsize',8,'interpreter','none');
        
        
        if 0
            figure
            imagesc(b2); hold on; viscircles(ce, ra*0+2,'Color','m','linewidth',2);
            title(msg_title,'fontsize',8,'interpreter','none');
        end
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
        %disp(['pass: '  num2str(i)]);
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

% ==============================================
%%
% ===============================================
if 0
    x=ce3(:,1);
    y=ce3(:,2);
    dist2 = pdist2(ce3, ce3);
    
    sm=dist2>10;
    
    dist2 = pdist2(ce3, ce3);
    % Find which points are within 100 of each other
    cp = dist2 < 15;
    
    % ==============================================
    %%
    % ===============================================
    
    
    
    % distx = bsxfun(@minus,x,x');
    % disty = bsxfun(@minus,y,y');
    % dist = sqrt(x.^2+y.^2);
    
    
    ind=sub2ind(size(b),ce3(:,2),ce3(:,1));
    s=zeros(numel(b),1);
    s(ind)=1;
    s=reshape(s,size(b));
    
    fg,imagesc(b);colormap gray;
    viscircles(ce3, ones( size(ce3,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
end
% ==============================================
%%
% ===============================================





%———————————————————————————————————————————————
%%   out
%———————————————————————————————————————————————
ce=ce3;
ra=ones(size(ce,1),1);






function  [ce2 ra2]=intenstreshAfterDetection(mag,p, ce,ra)
ce2=[];
% ==============================================
%%
% ===============================================


% w =medfilt2(mag,[7 7]);
% w=imgaussfilt(mag,3);
w=mag;
si=size(mag);
% s =zeros(size(w));
ce=round(ce);


% iv1=sub2ind(size(w),ce(:,1),ce(:,2));
% w2=w(:);
% s0(iv1)=1;
% s0=reshape(s0,size(w));

% ts=w2(iv1)

%
% s2=imdilate(s0,ones(5));
% sm=s2.*double(w);
%
if 0
    fg,imagesc(mag);colormap gray;
    viscircles(ce, ones(size(ce,1),1)*0+1,'Color','m','linewidth',.5);
    %     axis square
    %     drawnow;
end

%
% s2=s(:);
% iv=find(s2==1)
% [xy(:,1) xy(:,2)]=ind2sub(size(s),iv)

xy=ce;


% % ==============================================
%
% ===============================================

% ke=strel('disk', round(mean(p.radius)) );
ke=strel('disk', round(min(p.radius)) );
% ke=strel('disk', 1);
ke=ke.Neighborhood ;

[xs ys]=meshgrid([-size(ke,1):size(ke,1)]);
ts=[];
for i=1:size(xy,1)
    su=xy(i,[2 1]);
    sw=[xs(:)+su(1) ys(:)+su(2)];
    sw([find(sw(:,1)<=0); find(sw(:,2)<=0)],:)=[];
    sw([find(sw(:,1)>si(1)); find(sw(:,2)>si(1))],:)=[];
    iv2=sub2ind(si,sw(:,1),sw(:,2));
    
    bs=zeros(si);
    bs(iv2)=1;
    bs=reshape(bs,si);
    
    me=mean(w(iv2));
    %     ku=kurtosis(w(iv2));
    ts(i,:)=[me ];
end

% ==============================================
%%
% ===============================================
% cf
% p.IntensTresh=100;
try
    is=find(ts(:,1)<p.IntensTresh);
catch
    [ce2 ra2]=deal([]);
    return
    % keyboard
end
% is=find(ts(:,2)<2);
% is=find(ts(:,1)<180);
ce2=xy(is,:);
ra2=ra(is,:);
% iv3=sub2ind(size(s),xy2(:,1),xy2(:,2));
% bs=zeros(size(s2));
% bs(iv3)=1;
% bs=reshape(bs,size(s));


if 0
    fg,imagesc(mag);colormap gray;
    viscircles(ce, ones(size(ce,1),1)*0+1,'Color','m','linewidth',.2); axis square
    drawnow;
    title('orig')
    
    
    fg,imagesc(mag);colormap gray;
    viscircles(ce2, ones(size(ce2,1),1)*0+1,'Color','m','linewidth',.2); axis square
    title('is');
    
    isnot=setdiff(1:size(ts,1),is);
    ce3=xy(isnot,:);
    fg,imagesc(mag);colormap gray;
    viscircles(ce3, ones(size(ce3,1),1)*0+1,'Color','m','linewidth',.2); axis square
    title('is not');
    
end



% disp('..intensThresh');
% fprintf('..intensThresh..');

%minDilationDistance
function [ce2 ra]=mindist(b,p,ce,ra)

% fprintf('..CellDistCheck..');

% fg,imagesc(b);colormap gray;
% viscircles(ce, ones( size(ce,1) ,1),'Color','m','linewidth',.5); axis square
% title('new','fontsize',8);

% ==============================================
%%
% ===============================================
try
    if isempty(ce)
        [ce2 ra]=deal([]);
        return
    end
    
    ce=round(ce);
    ind=sub2ind(size(b),ce(:,2),ce(:,1));
    
    
    s=zeros(numel(b),1);
    s(ind)=1;
    s=reshape(s,size(b));
catch
    keyboard
end
s2=imdilate(s,ones(p.minCellDistance));
pp=regionprops(s2>0,'centroid');
ce2=round(cell2mat({pp(:).Centroid}'));
ra =ones(size(ce2,1),1);

if 0
    fg,imagesc(b);colormap gray;
    viscircles(ce, ones( size(ce,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
    title('orig')
    
    fg,imagesc(b);colormap gray;
    viscircles(ce2, ones( size(ce2,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
end


% ==============================================
%%
% ===============================================
if 0
    bv=b(:);
    ds = pdist2(ce, ce);
    tr   =triu(ds);
    tr(tr==0)=500;
    
    t=tr<10;
    ce2=[];
    for i=1:size(ce,1)
        ix=find(t(i,:)==1);
        if isempty(ix)
            ce2(end+1,:)=ce(i,:);
        else
            xy=[ce(i,:);ce(ix,:)];
            ind=sub2ind(size(b),xy(:,2), xy(:,1));
            val=bv(ind);
            ce2(end+1,:)=xy(  min( find(val==min(val)) ) ,:);
        end
    end
    ce2=unique(ce2,'rows');
    fg,imagesc(b);colormap gray;
    viscircles(ce2, ones( size(ce2,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
    
end

% ==============================================
%%
% ===============================================

if 0
    x=ce3(:,1);
    y=ce3(:,2);
    dist2 = pdist2(ce3, ce3);
    
    sm=dist2>10;
    
    dist2 = pdist2(ce3, ce3);
    % Find which points are within 100 of each other
    cp = dist2 < 15;
    
    % ==============================================
    %%
    % ===============================================
    
    
    
    % distx = bsxfun(@minus,x,x');
    % disty = bsxfun(@minus,y,y');
    % dist = sqrt(x.^2+y.^2);
    
    
    ind=sub2ind(size(b),ce3(:,2),ce3(:,1));
    s=zeros(numel(b),1);
    s(ind)=1;
    s=reshape(s,size(b));
    
    fg,imagesc(b);colormap gray;
    viscircles(ce3, ones( size(ce3,1) ,1),'Color','m','linewidth',.5); axis square
    title('new','fontsize',8);
end


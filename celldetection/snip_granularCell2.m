

clear;cf

% ==============================================
%%
% ===============================================

load('test.mat')
b=gm2;
fg,imagesc(b)

% ==============================================
%
% ===============================================
b2=mat2gray(b);
bw=im2bw(b2);
bw=imcomplement(bw);
fg; imagesc((bwlabeln(imfill(bw,'holes'))==35).*b)


fg,imagesc((bwlabeln(imfill(bw,'holes'))))

[cl num]=bwlabeln(imfill(bw,'holes'));


uni=[1:num]'
cont=histc(cl(:),uni);
ts=[uni cont];
ts=sortrows(ts,2)

tr=200;
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
p.sens   =.8;%85;

% p.istest =1
% p.show   =1;
% p.save   =0;
% p.sens   =.9;
% -----------
p.dotplotsize=1;
p.showcounts=0
p.polarity= 'dark';%'bright';
p.medfilt=[];%[11 11];
p.color  ='m';
p.radius =[1 100]; %[10 30]
p.testimage='sec5_12.png'
p.radiusHD=[1 30]
p.sensHD  =.99

%%%% p.meth='PhaseCode'
p.meth='TwoStage'

[ce1,ra1] = imfindcircles(b,p.radius,'Method',p.meth,'ObjectPolarity',p.polarity,...
    'Sensitivity',p.sens);

[ce2,ra] = imfindcircles(b,p.radiusHD,'Method',p.meth,'ObjectPolarity',p.polarity,...
    'Sensitivity',p.sensHD);
ce2=round(ce2);
IND = sub2ind(size(b),ce2(:,2),ce2(:,1));
g=zeros(size(b));
g(IND)=1;


ce1=round(ce1); % -----------------REFERENCE
IND = sub2ind(size(b),ce1(:,2),ce1(:,1));
r=zeros(size(b));
r(IND)=1;

% ==============================================
%
% ===============================================
% cx=[];
% tg2=[];
tg3=[];
zd=r;
for i=1:length(uni)
    mas=cl2==uni(i);
    g2=g.*(mas);
    
    
    if 0
        ce2=[];
        [ce2(:,2) ce2(:,1)]=find(g2==1);
        densimg=sum(r(:))/numel(r)  ; % all cells/numPicels NORMAL
        incl=r.*mas;
        denscl=   sum(incl(:))/ sum(mas(:));
    end
    

     mas2=(boundarymask(mas)+mas)>0;
     mas2=imfill(imclose(mas2,ones(10)),'holes');   
     me=mean(b(mas2));
     sd=std(b(mas2));
    
    if me<.4
        % cx=[cx; ce2];
         disp(['pass: '  num2str(i)]);
        zd= (zd.*~mas)+g2;
    end
     
    tg3(i,:) = [me sd];

%      tg3(i,:) = [denscl densimg  denscl./densimg sum(mas(:))./numel(mas) me sd];
     
%      if 0
%          fg,
%          subplot(2,2,1); imagesc(mas2)
%          subplot(2,2,2);   imagesc(mas2.*b); caxis([0 .7]); colormap(jet); colorbar
%          title(i)
%      end
%      if 0
%          mas2=(boundarymask(mas)+mas)>0;
%          mas3=imfill(mas2,'holes');
%          npix=sum(mas3(:))
%          
%          q1=regionprops(mas2,'EulerNumber');
%          %q1=regionprops(imdilate(mas,strel('disk',1)),'EulerNumber');
%          %q2=regionprops(mas,'EulerNumber');
%          disp([[q1.EulerNumber  ]]);
%          %     if q1.EulerNumber
%          fg,imagesc(mas2); title([i q1.EulerNumber npix   q1.EulerNumber.*npix])
%          
%          tg=[q1.EulerNumber q1.EulerNumber./npix  q1.EulerNumber.*npix ];
%          tg2(i,:)=tg;
%      end
end


% ==============================================
%
% ===============================================

if 0
    fg,imagesc(b);colormap gray;
    viscircles(cx, ones( size(cx,1) ,1),'Color','m','linewidth',.5); axis square
    title('granular','fontsize',8);
    
    fg,imagesc(b);colormap gray;
    viscircles(ce1, ones( size(ce1,1) ,1),'Color','m','linewidth',.5); axis square
    title('normal','fontsize',8);
end

ce3=[];
[ce3(:,2) ce3(:,1)]=find(zd==1);
    
% ce3=[cx; ce1]
ce3=unique(ce3,'rows');
fg,imagesc(b);colormap gray;
viscircles(ce3, ones( size(ce3,1) ,1),'Color','m','linewidth',.5); axis square
title('new','fontsize',8);



% ==============================================
%%
% ===============================================



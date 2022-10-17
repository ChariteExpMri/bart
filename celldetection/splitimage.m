

% SPLIT IMAGE IN fixed IMAGE SIZE-SUBPIXS
% val: imageIntensity for padarray values (0-255)
% splitimage(fullfile(pwd,'sample_1.png'),[], [800 800], 255);
% splitimage(fullfile(pwd,'M7 ST3 with AF II.lif_TileScan_004_Merging.tif  '),[], [300 300], 255);


% file : fullpath inputfile
% outpa: outputpath or empty to use path of inputfile
% xysize: xy-size in pixel
% val: 0-255 intensitiy value for padding
function splitimage(file,outpa,xysize, val)
% ==============================================
%%   split IMAGE
% ===============================================

if 0
% clear
% file=fullfile(pwd,'sample_1.png');
% outpa=pwd;
% xy=[200 150];
% val=0;
% splitimage(file,outpa,xysize, val)

splitimage(fullfile(pwd,'sample_1.png'),[], [300 300], 255);

end

 % ==============================================
%%   
% ===============================================

delete(fullfile(pwd,['sec*.png']));
xy=xysize;

if isempty(file)
    path = pwd;
    filter = '*.*';
    [file, imPath, imFilter] = uigetfile(fullfile(path,filter));
else
    
end
if isempty(outpa)
    outpa=fileparts(file);
end

 I = imread(file);
 si=size(I);
 
 %% =============otsu background to white ==================================
 ot=otsu(I(:,:,1),3)==1;
 [e1 con]=bwlabeln(ot);
 
 cl=mode([e1(:,1); e1(:,end); e1(1,:)'; e1(end,:)']);
 e2=e1==cl;
 
%  e3=medfilt2(e2,[11 11]);
I2=I;
for i=1:size(I,3)
    u=I(:,:,i);
    u(e2)=median(u(e2==0));
    I2(:,:,i)=u;
end

I=I2;
 
 %% ===============================================
 
 fc=ceil(si(1:2)./xy);
 si2=xy.*fc;
 
 I2=padarray(I,[si2-si(1:2)],val,'post');

 xd=[1:xy(1):si2(1)+3]';  xd(xd>=si2(1))=[];
 xd(:,2)=xd+xy(1)-1  ;
 yd=[1:xy(2):si2(2)+3]';  yd(yd>=si2(2))=[];
 yd(:,2)=yd+xy(2)-1  ;
 
 tag='sec';
 for i=1:size(xd,1)
     for j=1:size(yd,1)
         sn=I2(xd(i,1):xd(i,2),  yd(j,1):yd(j,2),: );
         
         
         imwrite(sn,fullfile(outpa,[tag num2str(i), '_', num2str(j),'.png']));
     end
 end
 
 
 
% ==============================================
%   splitinfo
% ===============================================

sec.si=si;
sec.si2=si2;
sec.xd=xd;
sec.yd=yd;
sec.file=file;
sec.class=class(I);
sec.tag=tag;
% sec
 save(fullfile(outpa,[tag '.mat']),'sec');

 return

% ==============================================
%%   reverse
% ===============================================
if 0
clc
load(fullfile(outpa,[tag '.mat']));
r=cast(  [zeros([sec.si2 sec.si(3)]) ]  ,sec.class);

no=1;
 tag='sec';
 for i=1:size(sec.xd,1)
     for j=1:size(sec.yd,1)
        [xx v]= imread(fullfile(outpa,[sec.tag num2str(i), '_', num2str(j),'.png']));
%         figure(10); image(xx); drawnow; pause(1);
        
        disp([ no xd(i,1) yd(i,1)]);
        no=no+1;
          r(xd(i,1):xd(i,2),  yd(j,1):yd(j,2),: ) = xx;
        
     end
 end

 r2=r(1:sec.si(1),1:sec.si(2),:);

fg,imagesc([I2 r])
fg,imagesc([I r2])
end

























 
%  
%  rs=[mod(si(1),xy(1)) mod(si(2),xy(2))]
%  
%  sb0=(si(1:2)-rs)./[xy]
%  sb=sb0(find(rs>0))+1
%  
%  
%  
% I2=padarray(I,[rs],nan,'post')
% do=
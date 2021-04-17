% mergeImgae fom pannels

% secfile ('sec.mat') or just the path where sec.mat is located
% outpa: output path or iif empty use path of secfile
% showit: [0,1] 
function mergeimage(secfile,outpa,showit)

if 0

    mergeimage('F:\myProjects\celldetectorTestData\datset4\sec.mat',[],0);
   
end

% ==============================================
%%   deal with inputs
% ===============================================
if exist(secfile)==7
    secfile=fullfile(secfile,'sec.mat');
elseif exist(secfile)==2 
    
else
    secfile=[];
end
    
if isempty(secfile)
    path = pwd;
    filter = 'sec.mat';
    [file, imPath, imFilter] = uigetfile(fullfile(path,filter));
    secfile=fullfile(imPath,file)
end
    
if isempty(outpa)
    outpa=fileparts(secfile);
end

tic;
if 1
    tag='predmsk';
    r2=stitchimage(secfile,tag);
    showimg(secfile,r2,showit);
    imwrite( r2, fullfile(outpa,[tag '.tif']) ,'Compression','LZW' );
end

tag='predfus';
r2=stitchimage(secfile,tag);
showimg(secfile,r2,showit);
imwrite( r2, fullfile(outpa,[tag '.tif']) ,'Compression','LZW' );

fprintf( '%s - ELAPSED TIME : %2.2fmin\n',outpa,toc/60 );


% ==============================================
%%   stitch image
% ===============================================
function r2=stitchimage(secfile,tag)
% ==============================================
%%   
% ===============================================
cf
format compact;
inpa=fileparts(secfile);
a=load(secfile); sec=a.sec;

% get 3rd dim
[xx v]= imread(fullfile(inpa,[tag num2str(1), '_', num2str(1),'.png']));
% fg,image(xx)
% r=cast(  [zeros([sec.si2 size(xx,3)]) ]  ,sec.class);
r=uint8([zeros([sec.si2 3]) ] );
no=1;
for i=1:size(sec.xd,1)
    for j=1:size(sec.yd,1)
        [xx v]= imread(fullfile(inpa,[tag num2str(i), '_', num2str(j),'.png']));
        %         figure(10); image(xx); drawnow; pause(1);
%         fg,image(xx)
        %disp([ no sec.xd(i,1) sec.yd(j,1)]);
       if size(xx,3)==1
        r(sec.xd(i,1):sec.xd(i,2),  sec.yd(j,1):sec.yd(j,2),:) = cat(3,xx,xx,xx);
       else
         r(sec.xd(i,1):sec.xd(i,2),  sec.yd(j,1):sec.yd(j,2),: ) = (xx); 
      end
        no=no+1;
    end
    pdisp(i);
end
r2=r(1:sec.si(1),1:sec.si(2),:);
% r2=cast(r2,sec.class);
disp('done');
% fg; image(r2)
% ==============================================
%%   
% ===============================================


return

function showimg(secfile,r2,showit)
if showit==1
    a=load(secfile); sec=a.sec;
    if size(r2,3)==1;
        r2=repmat(r2,[1 1 3]);
    end
    I2=imread(sec.file);
    figure; imagesc([I2 r2]);
elseif  showit==2
    figure; image([r2]);
end



    
function pdisp(i,varargin)
if nargin==2
  if mod(i,varargin{1})==0
    fprintf(1,'%d ',i);   
  end
    
else
   fprintf(1,'%d ',i); 
end


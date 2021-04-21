
% ==============================================
%%   
% ===============================================
s=load('F:\data3\histo2\josefine\dat\14_000000000001F059\a2_005.mat')
s=s.s

im=s.img;
% ==============================================
%%   
% ===============================================

% Reading an image:
% img = imread('image.jpg');
img=im;

% Requiring the pivots:
f=figure; imshow(img);
p1 = getpoints;
p1=round(p1)
% close(f);
bb=bwboundaries(s.mask);
x0=bb{1}';
x=x0([2 1],1:100:end)

z=x'
px=p1'

del=[];
for i=1:size(px,1)
    dis=round(sqrt(sum((z-repmat(px(i,:),[size(z,1) 1])).^2,2)));
    tres=400;
    del(:,i)=(dis<tres);
end
ikeep=find(sum(del,2)==0);
x2=x(:,ikeep);
% fg;imshow(img); hold on; plotpointsLabels(x,'r.');
% fg;imshow(img); hold on; plotpointsLabels(x2,'r.');
% 

p=[x2 px'];

% ==============================================
%
% ===============================================

% Requiring the new pivots:
f=figure; imshow(img); hold on; plotpointsLabels(p,'r.');
% q1 = getpoints;
sx=repmat(round(mean([px(1:2:end,1) px(2:2:end,1)],2)),[ 1 2 ])';
sy=repmat(round(mean([px(1:2:end,2) px(2:2:end,2)],2)),[ 1 2 ])';
q1=[sx(:) sy(:)]
% f=figure; imshow(img); hold on; plotpointsLabels(q1','r.');
% f=figure; imshow(img); hold on; plotpointsLabels(px','r.');
% q1=round(([p1(:,1:2:end) p1(:,1:2:end)]+[p1(:,2:2:end) p1(:,2:2:end)])./2)
 q=[x2 q1'];
% close(f);
% ==============================================
%  
% ===============================================
imx=img;
for i=1:2
    % Generating the grid:
    step=15;
    [X,Y] = meshgrid(1:step:size(img,2),1:step:size(img,1));
    gv = [X(:)';Y(:)'];
    % Generating the mlsd:
    mlsd = MLSD2DpointsPrecompute(p,gv);
    % The warping can now be computed:
    [imgo pn pw] = MLSD2DWarp(imx,mlsd,q,X,Y);
    % Plotting the result:
    %figure; imshow(imgo); hold on; plotpoints(q,'r.');
    imx=imgo;
end
figure; imshow(imgo); hold on; plotpoints(q,'r.');






% ==============================================
%%   
% ===============================================

cf; clear

pain=fullfile('F:\data5_histo\test_deepslice\warp')
f2=fullfile(pain, 'bum.json');

w=preadfile(f2)
w2=strjoin(w.all,char(10))
v = jsondecode(w2)



f7=fullfile(pain,'histimg.png')
f8=fullfile(pain,'avgt.png')
a=imread(f7);
b=imread(f8);
a=a(:,:,1); %histoimg
b=b(:,:,1);
%===============================================

m=v.slices.markers

cb1=m(:,1:2)
cb2=m(:,3:4)

cb1=fliplr(cb1);
cb2=fliplr(cb2);

% 
% 
% cpselect(a,b,pm, fm)

% ==============================================
%  
% ===============================================


sizeI=[size(a,1) size(a,2)]
% Xmoving=pmov;
% Xstatic=pfix
Xmoving=cb2;
Xstatic=cb1

I1=b;

options.Verbose=true;
[O_trans,Spacing,Xreg]=point_registration(sizeI,Xmoving,Xstatic,options);
% Transform the 2D image  
Ireg=bspline_transform(O_trans,I1,Spacing,3);

fg; imshow(imfuse(a,b))
fg; imshow(imfuse(a,Ireg))
imoverlay(a, Ireg);
%% ===============================================
% tic
% for i=1:100
%     options.Verbose=false;
%     [O_trans,Spacing]=point_registration(sizeI,Xmoving,Xstatic,options);
%     % Transform the 2D image
%     Ireg=bspline_transform(O_trans,I1,Spacing,3);
%     
% end
% 
% toc





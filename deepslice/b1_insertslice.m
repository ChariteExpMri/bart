
% cf;clear; warning off

% ==============================================
%%   paras
% ===============================================

 imagepath     ='C:\paul_projects\python_deepslice\paul_histoIMG'
% imagepath   ='C:\paul_projects\python_deepslice\paul_histoIMG\test3'

% histimage     =fullfile(imagepath,'a1_s005.jpg')
barttemplate  =fullfile('F:\tools\bart_template', 'AVGT.nii')

% ==============================================
%%   get image
% ===============================================

cd(imagepath)


%% ===============================================
%   https://www.nitrc.org/plugins/mwiki/index.php?title=quicknii:Image_coordinates
%                                    [ ux  uy  uz ]
% [ xv  yv  zv ] = [ x/w  y/h  1 ] * [ vx  vy  vz ]
%                                    [ ox  oy  oz ]
% where [xv,yv,zv] are 3D coordinates in the atlas volume, expressed in voxels,
% and [x,y] are 2D coordinates in the (section) image, expressed in pixels (w and h are again the width
% and the height of the image, also expressed in pixels).
% ==============================================
%%   load barttemplate
% ===============================================
%  target-resolution='456 528 320'>
% but we have:      528   320   456
[ha a m mm]=rgetnii(barttemplate);

%% ===============================================
%  get estimation from deepslice
%% ===============================================
f2=fullfile(imagepath, 'est.xml');
g=xml2struct(f2);
eval(regexprep(['&' g.Children(2).Attributes(1).Value],'&',';r.'));
imagename  =g.Children(2).Attributes(2).Value;
histimage  =fullfile(imagepath, imagename);
b=imread(histimage);
fg,image(b)


w= [ r.ux  r.uy  r.uz;
    r.vx  r.vy  r.vz ;
    r.ox  r.oy  r.oz ];

a2=permute(a,[3 1 2 ]);
a2=flipdim(a2,2);
a2=flipdim(a2,3);
size(a2)
% ===============================================
bx=b(:,:,1);
b2=bx(:);
clear co
[co(:,1),co(:,2)] = ind2sub(size(b),[1:length(b2)]);

co=co./1000;
co2=[co  ones(size(co,1),1) ];

% ===============================================

s=co2*w;
s2=round(s);
s2(s<1)=1;
v=zeros(size(co,1),1);
for i=1:size(s2,1)
    try
        v(i,1)=a2(s2(i,1),s2(i,2),s2(i,3));
    end
end

v2=reshape(v, size(bx) );
fg; imagesc(v2')
v3=v2';

% ==============================================
%%   reverse
% ===============================================
c=zeros(size(a2));
for i=1:size(s2,1)
    try
        c(s2(i,1),s2(i,2),s2(i,3))=1;
    end
end
c=c(1:size(a2,1),1:size(a2,2),1:size(a2,3));
%

c=flipdim(c,3);
c=flipdim(c,2);
c=permute(c,[2 3 1 ]);

f3=fullfile(imagepath, 'slice.nii');
rsavenii(f3,ha,c,2);

f4=fullfile(imagepath, 'slice_value.nii');
rsavenii(f4,ha,c.*a,4);

f5=fullfile(imagepath, 'avgt_lowbit.nii');
rsavenii(f5,ha,a,4);


%% ===============================================
% ==============================================
%%   sve as jpg
% ===============================================




paout=fullfile('F:\data5_histo\test_deepslice\warp')

f7=fullfile(paout,'histimg.png')
imwrite(b,f7)
showinfo2('www',f7)


f8=fullfile(paout,'avgt.png')
v4=uint8(mat2gray(v3)*255);
imwrite(v4,f8)
showinfo2('www',f8)

% ==============================================
%%   
% ===============================================



% ==============================================
%%   coordinates to read out
% ===============================================
cf
sx=s;
sx(:,2)=ha.dim(1)-sx(:,2)+1;%+0.0250;
% sx(:,1)=ha.dim(2)-sx(:,1);
sx(:,3)=ha.dim(2)-sx(:,3)+1;%+13.0250;
% sx(:,2)=ha.dim(3)-sx(:,2);
sx(:,1)=sx(:,1);%-0.0250;

 q=spm_sample_vol(ha,sx(:,2)',sx(:,3)',sx(:,1)',0);
q2=reshape(q, size(bx) );
% fg; imagesc(fliplr(flipud(permute(q2,[2 1]))))

% fg; imagesc(q2)
fg; imagesc(permute(q2,[2 1]))
fg; imagesc(v2')







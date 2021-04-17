
% % ==============================================
% %%   defaults
% % ===============================================
% p.doplot=0; %plot image to screen
% p.chan  =3; % blue channel for dapi?
% p.useRot=1; %useRotationInfo

function [fiout s] =p_resizetif(filename,imgsize, p0)
% ==============================================
%%   defaults
% ===============================================
p.doplot=0; %plot image to screen
p.chan  =3; % blue channel for dapi?
p.useRot=1; %useRotationInfo

% ==============================================
%%   
% ===============================================

if 0
    file='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\a1_001.tif'
    pres=struct('doplot' ,0 )
    [fi00 s ] = p_resizetif3(file,[2000 2000],pres);
end



% ==============================================
%%   pass extra paras
% ===============================================

if nargin==3
    warning off;
    p=catstruct(p,p0);
    
end



% addpath('C:\Users\skoch\Desktop\release_2\codes')


if 0
    [pas name ext]=fileparts(f00);
    modfile=strrep(fimod,'.mat','mod.tif')
    if exist(modfile)
        im=imread(modfile);
        [maskfile,brainfile]=clean_data_function2(im);
        s.img=brainfile;
        s.mask=maskfile
    end
    
end


% ==============================================
%%
% ===============================================
disp([' ..resizing img']);

p1=imread(filename);
p1=p1(:,:,p.chan);
p2=imresize(p1, imgsize);
% ms=imcomplement(otsu(p2,4)==4);
% ms=imcomplement(otsu(p2,4)==4);
ms=imcomplement(otsu(p2,7)==7);
ms=imfill(ms,'holes');

ms2=imerode(imopen(ms,strel('disk',7)),strel('disk',5));
ms2=imfill(imdilate(ms2,strel('disk',5)),'holes');
ms3=bwlabeln(ms2);
uni=unique(ms3(:)); uni(uni==0)=[];
tab1=flipud(sortrows([histc(ms3(:),uni) uni],1));
cl=tab1(find(tab1(:,1)==max(tab1(:,1))),2);
ms3=ms3==1;

img=(mat2gray(p2)).*ms3;

% ----------rotate img
if p.useRot==1
    try
        v=load(fullfile(fileparts(filename),'a1_info.mat'));
        v=v.v;
        if isfield(v,'rottab')==1
            
            display('..rotate image');
            [pas fis ext]=fileparts(filename);
            jpgfile=[fis '.jpg'];
            rotangle=v.rottab{regexpi2(v.rottab(:,1),jpgfile ),2};
            img=imrotate(img,rotangle,'crop');
        end
    catch
        disp('..rotation failed');
    end 
end


%------------


% % 
% % % p1=imresize(p1,[2000 2000]);
% % m1=imcomplement(otsu(p1,10)==10);
% % p1=imadjust(mat2gray(p1));
% % p1(m1==0)=0;
% % img=p1;
% ==============================================
%%
% ===============================================

[maskfile,brainfile]=clean_data_function2(img);
fus=imfuse(brainfile,maskfile);

if p.doplot==1
    
    figure;
    subplot(2,2,1); imagesc(p2); title(['orig. resized (size '  regexprep(num2str(size(p2)),'\s+',' ') ')'],'fontsize',7);
    subplot(2,2,2); imagesc(brainfile); title('cleaned (+rotated)','fontsize',7);
    subplot(2,2,3); imagesc(maskfile);  title('mask','fontsize',7);
    subplot(2,2,4);  imagesc(fus);title('fusin','fontsize',7);
end
% ==============================================
%%
% ===============================================
% [maskfile,brainfile]=clean_data_function(filename);
if max(brainfile(:))>200
    brainfile=brainfile./255;
end


s.img =uint8(round(mat2gray(brainfile).*255));
s.mask=uint8(round((maskfile)));
s.source= filename;

% ==============================================
%%   save
% ===============================================
[pa fi ext]=fileparts(filename);
fi2=strrep(fi,'a1_','a2_');
fiout=fullfile(pa, [fi2 '.mat'  ]);
save(fiout,'s');

% ==============================================
%%   tumbnail
% ===============================================
fiout2=fullfile(pa, [fi2 '.jpg'  ]);

q0=round(255*mat2im(mat2gray(p2),gray));
q1=round(255*mat2im(mat2gray(s.img),gray));
q2=round(255*mat2im(mat2gray(s.mask),gray));

bm=[[q0 q1]; [q2 fus]];
% txt=(text2im(fi));
% txt=(text2im(filename));
txt=(text2im([filename filename]));
 txt=imcomplement(txt);
resfac=round((size(bm,2).*.9)./size(txt,2));
txt=round(mat2gray(imresize(txt,[resfac]))*255);
txt3=cat(3,round(txt.*1) ,round(txt.*0.8),round(txt.*0) ); %color Red
txt4=padarray([txt3],[1 size(bm,2)-size(txt3,2) ],'post');
bm=[txt4;bm];
% fg,image(bm)
imwrite((bm),fiout2);






% ==============================================
%%  EOF
% ===============================================
return













clc;close all; clear all;
addpath('C:\Users\skoch\Desktop\Inpaint_nans')
tic
if exist('vl_hog')~=3
    run('vlfeat-0.9.21/toolbox/vl_setup.m')
end

T1=2;
if T1==0
    filename='paul2.tif';
    p1=imread(filename);
elseif T1==1
    %     filename=fullfile('O:\histo_felix\workx\M14 ST3', 'im2_005.jpg') ;
    filename=fullfile('O:\histo_felix\workx\M14 ST3', 'im2_010.jpg') ; %awsome
    filename=fullfile('O:\histo_felix\workx\M14 ST3', 'im2_008.jpg') ; %
    filename=fullfile('O:\histo_felix\workx\M14 ST3', 'im2_003.jpg') ; %
    fg,imagesc(rot90(imread(filename)));
    p1=imread(filename);
    p1=rot90(p1);
elseif T1==2
    filename='C:\Users\skoch\Desktop\histo_\out_001.tif'
    filename='C:\Users\skoch\Desktop\histo_\out_005.tif'
    p1=imread(filename);
    p1=p1(:,:,1);
    p2=imresize(p1, [2000 2000]);
    ms=imcomplement(otsu(p2,4)==4);
    ms2=imerode(imopen(ms,strel('disk',7)),strel('disk',5));
    ms2=imfill(imdilate(ms2,strel('disk',5)),'holes');
    ms3=bwlabeln(ms2);
    uni=unique(ms3(:)); uni(uni==0)=[]
    tab1=flipud(sortrows([histc(ms3(:),uni) uni],1));
    cl=tab1(find(tab1(:,1)==max(tab1(:,1))),2);
    ms3=ms3==1;
    p1=imadjust(mat2gray(p2)).*ms3;
end





% brainname='paul3';
% experimental_thickness=50;
% expresolution=5.1;
% begin_yangle=0;
% atlas_folder='all_masked';
% good_quality_indices=[1]
% thresh = 0.2; % spatial flexibility, don't change if not sure
% ==============================================
%%
% ===============================================


p1=imresize(p1,[2000 2000]);
m1=imcomplement(otsu(p1,10)==10);
p1=imadjust(mat2gray(p1));
p1(m1==0)=0;
img=p1;
% ==============================================
%%
% ===============================================

[maskfile,brainfile]=clean_data_function_paul(img);
fg;
subplot(2,2,1); imagesc(brainfile);
subplot(2,2,2); imagesc(maskfile);
subplot(2,2,3);imagesc(imfuse(brainfile,maskfile));
% ==============================================
%%
% ===============================================

% [maskfile,brainfile]=clean_data_function(filename);
if max(brainfile(:))>200
    brainfile=brainfile./255;
end













% % ==============================================
% %%   defaults
% % ===============================================
% p.doplot=0; %plot image to screen
% p.chan  =3; % blue channel for dapi?
% p.useRot=1; %useRotationInfo

function [fiout s] =resizeTiff(file,p0)
% ==============================================
%%   defaults
% ===============================================
p.doplot=0; %plot image to screen
p.chan  =3; % blue channel for dapi?
p.useRot=1; %useRotationInfo
p.resize=[2000 2000];
p.percentSurviveMaxCluster=1;    %percent clusterSize w.r.t largest cluster to survive
p.imcloseSizeStep=10;   % combine separate clusters using this stepSize
% file='F:\data3\histo2\josefine\dat\Wildlinge_36_000000000001EADD\a1_001.tif'


% ==============================================
%%   
% ===============================================

if 0
   
    file='F:\data3\histo2\josefine\dat\Wildlinge_36_000000000001EADD\a1_001.tif'
    [fiout s] =resizeTiff(file)
end



% ==============================================
%%   pass extra paras
% ===============================================

if nargin>1
    warning off;
    p=catstruct(p,p0);
    
end


% ==============================================
%%
% ===============================================
disp([' ..resizing img']);

p1=imread(file);
p1=p1(:,:,p.chan);
p2=imresize(p1, p.resize);

%———————————————————————————————————————————————
%%  remove vertical stripe in Background
%———————————————————————————————————————————————
ncol=4;
ps=mean(   p2(:,[1:ncol end-ncol+1])   ,2);
imaxbord=find(ps==255);
% p2(imaxbord,:)=mean(ps);

ME_bg=median(ps);
sb=(double(p2)-repmat(ps,[1   size(p2,2) ])) +ME_bg  ; %subtract background
p2=uint8(round(sb));

%———————————————————————————————————————————————
%%   
%———————————————————————————————————————————————
% ms=imcomplement(otsu(p2,4)==4);
% ms=imcomplement(otsu(p2,4)==4);
ms=imcomplement(otsu(p2,7)==7);
ms=imfill(ms,'holes');

ms2=imerode(imopen(ms,strel('disk',7)),strel('disk',5));
ms2=imfill(imdilate(ms2,strel('disk',5)),'holes');
ms3=bwlabeln(ms2);
uni=unique(ms3(:)); uni(uni==0)=[];
tab1=flipud(sortrows([uni histc(ms3(:),uni) ],2));
% numberID NumPixel  percent to largestNumberID
tab1(:,3)=round(tab1(:,2)./tab1(1,2)*100); %percent size w.r.t. largest cluster
tab0=tab1; %Backup
tab1=tab1(tab1(:,3)>=p.percentSurviveMaxCluster,:);
% ==============================================
%%   join clusters
% ===============================================
ms33=ms3(:);
ms4=ms33.*0;
for i=1:size(tab1,1)
    ms4( ms33==tab1(i,1))=1;
end
ms4=reshape(ms4,size(ms3));
% ==============================================
%%   cobine flusters using imclose
% ===============================================
% p.imcloseSizeStep=10;
if size(tab1,1)>1
    
    step   =p.imcloseSizeStep;
    stepadd=step;
    numcl=size(tab1,1);
    it=1;
    
    while numcl~=1
        temp=imclose(ms4, true(step)  );
        [~, numcl]=bwlabeln(temp);
        %disp([it  numcl step]);
        it=it+1;
        step=step+stepadd;
    end  
    ms4=temp;
end
% ==============================================
%%   fill mask
% ===============================================
ms4=imfill(ms4,'holes');
% ==============================================
%%   multiplay by mask
% ===============================================
img=mat2gray(p2).*ms4;


% [mv,bf]=clean_data_function2(img);

% ==============================================
%%   rotation  ---has to be implmented elsewhere!!!!
% ===============================================
if 0
    cl=tab1(find(tab1(:,1)==max(tab1(:,1))),2);
    ms3=ms3==1;
    
    img=(mat2gray(p2)).*ms3;
    
    % ----------rotate img
    if p.useRot==1
        try
            v=load(fullfile(fileparts(file),'a1_info.mat'));
            v=v.v;
            if isfield(v,'rottab')==1
                
                display('..rotate image');
                [pas fis ext]=fileparts(file);
                jpgfile=[fis '.jpg'];
                rotangle=v.rottab{regexpi2(v.rottab(:,1),jpgfile ),2};
                img=imrotate(img,rotangle,'crop');
            end
        catch
            disp('..rotation failed');
        end
    end
    %------------
end

% ==============================================
%%
% ===============================================

[maskfile,brainfile]=clean_data_function2(img);
fus=imfuse(brainfile,maskfile);

if p.doplot==1
    
    figure;
    subplot(2,2,1); imagesc(p2); title(['orig. resized (size '  regexprep(num2str(size(p2)),'\s+',' ') ')'],'fontsize',7);
    subplot(2,2,2); imagesc(brainfile); title('cleaned (+combine cluster)','fontsize',7);
    subplot(2,2,3); imagesc(maskfile);  title('mask','fontsize',7);
    subplot(2,2,4);  imagesc(fus);title('fusin','fontsize',7);
end
% ==============================================
%%
% ===============================================
% [maskfile,brainfile]=clean_data_function(file);
if max(brainfile(:))>200
    brainfile=brainfile./255;
end


s.img =uint8(round(mat2gray(brainfile).*255));
s.mask=uint8(round((maskfile)));
s.source= file;
s.orig=p2;
s.tab0=tab0;
s.tab1=tab1;

% ==============================================
%%   save
% ===============================================
[pa fi ext]=fileparts(file);
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
% txt=(text2im(file));

[~,mouse]=fileparts(pa);
txt=(text2im([fullfile( mouse, [fi ext]) ]));
 txt=imcomplement(txt);
resfac=round((size(bm,2).*.9)./size(txt,2));
txt=round(mat2gray(imresize(txt,[resfac]))*255);
txt3=cat(3,round(txt.*1) ,round(txt.*0.8),round(txt.*0) ); %color Red
txt4=padarray([txt3],[1 size(bm,2)-size(txt3,2) ],'post');
bm=[txt4;bm];
% fg,image(bm)
imwrite((bm),fiout2);


showinfo2('resized-IMG',fiout2);



% ==============================================
%%  EOF
% ===============================================













function warp2histospace(c)


% disp(c)
% ==============================================
%%  path and sliceNR
% ===============================================
file     =c.file;
[pa name ext] = fileparts(file);           %name: "'a1_004'"
numberstr     = regexprep(name,'.*_','_'); % such as '_004'
pafin         = fullfile(pa,'fin'); %output filepath
[~,animal]    = fileparts(pa);
[~,slice,ext] = fileparts(c.file);
sliceName     = [slice,ext];

% ========MESSAGE =======================================
try
    cprintf('*[0 0 1]',[ [  'warp to histo-space: ' animal  ' ' char(8594) ' '  sliceName  ] '\n']);
catch
    disp([  'warp to histo-space: ' animal  ' ' char(8594) ' '  sliceName  ]);
end
%% ===============================================


% return

% keyboard
%% ======[path]=========================================
% file='F:\data5_histo\livia_test\dat\katharina\a1_001.tif' ;
% c.debug     =0;
% c.file=file;

% ==============================================
%%   MANDATORY FILES TO TRANSFORM
% ===============================================
% pa_template=strrep(which('bart.m'),'bart.m','templates');
global ak
pa_template=ak.template;

tb0={...%Name__________INterpol_____saveAFFINE___dtype
    'AVGT.nii'          '1'           1          'uint8'
    'ANO.nii'           '0'           1          'double'
    'HISTOVOL.nii'      'auto'        0          'uint8'
    'AVGThemi.nii'      '0'           1          'logical'
    
   
    };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath


% ==============================================
%%   use mode-file to get histo-mask
% ===============================================
modfile=fullfile(pa,['a2' numberstr '.mat']);
s=load(modfile);
s=s.s;

%% ======[get deepslice cords]=========================================
nametag_dl  =  regexprep(name,'a1_','a3_');
path_dl     = fullfile(pa,[ 'deepsl_' nametag_dl  ]);
file_dlest  = fullfile(path_dl,'');
file_xml    = fullfile(file_dlest,'est.xml');
[c.co c.st] = getestimation_xml(file_xml,'loadhistoimage',1); %get histoImage

%% ========[get manu-warp controlpoints, spacing]================
nametag_manwarp       = regexprep(name,'a1_','a4_');
file_manuwarped       = fullfile(pa,[nametag_manwarp '_warped.txt']);
d                     = preadfile(file_manuwarped);
pos                   = str2num(char(d.all));
Xmoving               = pos(:,3:4);
Xstatic               = pos(:,1:2);
[c.O_trans,c.Spacing] = point_registration(c.st.histo_size,Xmoving,Xstatic);

% ==============================================
%%   paras
% ===============================================
c.pa        = pa;
c.pafin     = pafin;
c.numberstr = numberstr;
c.s         = s;

% ==============================================
%%  [1] trafo images to downsampled version
% ===============================================
tic
g={};
for i=1:size(tb,1)
    [g c]=backtrafo_smallSize(i,tb,g,c );
end

%% ===============================================
%%  [2] trafo images to histo-space
%% ===============================================
% s001_ANO.mat         'v' (double)
% s001_AVGThemi.mat    'v' (double)
% s001_HISTO.mat       'v' 'uint8'
% s001_AVGT.mat       'v' (double)
% s001_REF.mat        'v' 'single'
% s001_AVGT_affine.mat     'v' (double)
% s001_AVGThemi_affine.mat  'v' (double)
% s001_ANO_affine.mat
% #### s001_result.gif
% ===============================================
if 1
    for i=1:size(tb,1)
        [g c]=backtrafo_histospace(i,tb,g,c );
    end
end

%% ===============================================
%%  [3] make summary
%% ===============================================
make_summary(tb,g,c );








% ==============================================
%%   sub: [3] make summary
% ===============================================
function make_summary(tb,g,c )
%% ===[load reffile again]=========================
if isfield(c,'ref_small')
    p1=c.ref_small;
    %disp('.. get ref from struct...');
else
    p1=imread(c.file,'PixelRegion',{[1 5 inf],[1 5 inf]});
end
if size(p1,3)==3;       p1= rgb2gray(p1);     end
%% ===============================================
siz=[500 500]  ;
ref=double(imadjust(mat2gray(imresize(mat2gray(p1),siz) ))) ;
%===============================================
tx_warped=text2im('warped')*0.5;
tx_affine=text2im('affine')*0.5;
t1=[];
t2=[];
for i=1:2
    q1=[]; q2=[];
    for j=1:size(g,1)
        d1=ref;
        if isempty(g{j,i})
            d2=d1;                       fc=0;
        else
            uni=unique(g{j,i});
            if sum(uni==round(uni))==length(uni)  %atlas/masks
                d2=imresize(g{j,i},siz,'nearest');
                d2=pseudocolor2D(d2);
            else
                d2=imresize(mat2gray(g{j,i}),siz);
            end
            fc=1;
        end
        d2=mat2gray(d2);
        if i==1 && j==1;
            d2(1:size(tx_warped,1),1:size(tx_warped,2))=~tx_warped;
            d1(1:size(tx_warped,1),1:size(tx_warped,2))=~tx_warped;
        end
        if i==2 && j==1;
            d2(1:size(tx_affine,1),1:size(tx_affine,2))=~tx_affine;
            d1(1:size(tx_affine,1),1:size(tx_affine,2))=~tx_affine;
        end
        q1 = [q1 d1.*fc ];
        q2 = [q2 d2.*fc ];
    end
    t1=[t1; q1];
    t2=[t2; q2];
end
% fg;imagesc(t2);% axis image
%===============================================
[~,animal]    =fileparts(c.pa);
[~,slice,ext] =fileparts(c.file);
sliceName=[slice,ext];

tx_info=text2im([animal  ': ' sliceName   '  ' sprintf('(%dx%d)', c.size_histo  ) ]);
tx_info=~tx_info;
head=zeros(size(tx_info,1), size(t1,2));
head(1:size(tx_info,1),1:size(tx_info,2))=tx_info*0.5;
t1=[head;t1];
t2=[head;t2];
% fg,imagesc(t1)
% ===============================================
loops=65535;
delay=.4;
% filenameFP=fullfile(outdir,[u.oname_suffix, '.gif']);
nameout=[ 's' regexprep(c.numberstr,'_','') '_result.gif'];
fo1=fullfile(c.pafin,nameout);
c_map=gray;

s1=uint8(round(255*t1));
s2=uint8(round(255*t2));

imwrite(s1,c_map,[fo1],'gif','LoopCount',loops,'DelayTime',delay)
imwrite(s2,c_map,[fo1],'gif','WriteMode','append','DelayTime',delay)
showinfo2('.. summary (anim-gif)',fo1);
%% ===============================================














% ==============================================
%%   sub: backtrafo to histospace
% ===============================================
function [g c]=backtrafo_histospace(i,tb,g,c )

%% =====create outdir path ==========================================
if exist(c.pafin)~=7;
    mkdir(c.pafin);
end
% ==============================================
%%   get info from reference  Image
% ===============================================
% c.file=fullfile(c.pa,['a1' c.numberstr '.tif']);
hi=imfinfo(c.file);

c.size_histo= [hi.Height hi.Width]  ;%[ 16648       11146]
imgNumstr=regexprep(c.numberstr,'_','');

%% ===============================================
if i==1
    % ==============================================
    %%    read referenceImage
    % ===============================================
    if 1
        disp([' ..load histo-file']);
        %     if sum([hi.Width hi.Height]>5000)==2 %above 5000
        %         p1=imread(c.file,'PixelRegion',{[1 2 inf],[1 2 inf]});
        %     else
        p1=imread(c.file);
        %     end
        %     p1=imread(file);
        if size(p1,3)==3
            p1= rgb2gray(p1);
        end
        v=p1;
        %if isa(v,'unit8')==0
            v=uint8(255*imadjust(mat2gray(double(p1))));
        %else
         %   end   
            
     
        outname=[ 's' imgNumstr '_REF' '.mat' ];
        fo1=fullfile(c.pafin,outname);% 's001_REF.mat'
        %save(fo1,'v');
        if c.simulate==0
            save(fo1,'v','-v7.3');
            showinfo2('..saved',fo1);
        end
        
        if c.debug==1
            fg,imagesc(v);
            title([ outname ' ['   num2str(class(v))  ']' ]);
        end
        
        %% =====[save thumbnail]==========================
        vt=imresize(v,[1000 1000],'nearest');
        fo2=regexprep(fo1,'.mat$','.jpg');
        imwrite(vt,fo2);
        c.ref_small=double(mat2gray(vt));  %  --> in struct
        %% ===============================================
    end
    
    
end
%% ===============================================

% ==============================================
%%   resize and save the "warped mage"
% ===============================================
intpol = g{i,3};
w{1}   = g{i,1}; %stack warped and if exist the affine image
if ~isempty(g{i,2})
    w{2}  = g{i,2};
end

for j=1:length(w)  %loop over the warped and corresponding affine image
    in         = w{j};
    unival     = unique(in(:));
    is_integer = (sum((round(unival)==unival)))==length(unival);
    
    if is_integer==1
        if (length(unival)<=2) && (sum(unival)==1)                % BINARY MASK
            b  = logical(in);
            bt = uint8(255*mat2gray(double(b)));       %thumb
        elseif max(unival)<255 && length(unival)<4                % HEMISPHERIC MASK
            b  = uint8(in);
            bt = uint8(255*mat2gray(double(b)));        %thumb
        else                                                      % ATLAS
            b  = single(in);
            bt =uint8(255*(mat2gray(pseudocolor2D(b)))); %thumb
        end
    else                                                          %OTHER IMAGES
        b  = uint8(round(mat2gray(double(in))*255));
        bt = imresize(b,[1000 1000],'nearest');          %thumb
    end
    %% ===============================================
    % in=uint8(round(255*mat2gray(in)));      %--> storage-dependent  about this
    v=imresize(b,[c.size_histo],intpol{1});
    
    [~,inname]= fileparts(tb{i,1});
    outname   = inname;
    if j==2  %affine image
        outname=[outname '_affine' ];
    end
    
    fo1       = fullfile(c.pafin,[ 's' imgNumstr '_' outname '.mat' ]);%  s001_AVGT.mat
    if c.simulate==0
        save(fo1,'v','-v7.3');
        showinfo2('..saved',fo1);
    end
    
    %% =====[save thumbnail]==========================
    fo2=regexprep(fo1,'.mat$','.jpg');
    imwrite(bt,fo2);
    %% ===============================================
    
    
    if c.debug==1
        fg,imagesc(v);
        title([ outname ' ['   num2str(class(v))  ']' ]);
    end
end %j (over warped and i'ts affine image)




%% ===============================================
function [g c]=backtrafo_smallSize(i,tb,g,c )


c.elxout     =fullfile(c.pa,'elx2',['forward' c.numberstr]);

% ==============================================
%%  image and interpType
% ===============================================
fi3=tb{i,1};

c.ipoltable={...
    'nearest'  , 0   ,-1
    'bilinear' , 1    ,1
    };

interpCode=tb{i,2};
if strcmp(interpCode,'0') || strcmp(interpCode,'auto')
    ipol=c.ipoltable(1,:);
elseif strcmp(interpCode,'1')
    ipol=c.ipoltable(2,:);
end

% ==============================================
%%   get slice which is affine
% ===============================================

img1  = getslice_fromcords( fi3,c.co  ,  c.st.histo_size    ,ipol{2});   %get slice

if  strcmp(interpCode,'auto')
    unival=unique(img1(:));
    if (sum(unival==round(unival)))<numel(unival) % --> higher order interpolation
        ipol=c.ipoltable(2,:);
        img1  = getslice_fromcords( fi3,c.co  ,  c.st.histo_size    ,ipol{2});   %get slice
    end
end
aff=img1;

% ==============================================
%%   get manually warped deformation
% ===============================================

img2  = bspline_transform( c.O_trans  ,  img1   ,c.Spacing  ,ipol{3});    %get manually warped image
% ==============================================
%%   get elastix deformation
% ===============================================
c.trafofile2  =  fullfile(c.elxout,'TransformParameters.0.txt');
set_ix(c.trafofile2,'FinalBSplineInterpolationOrder', ipol{2} );
set_ix(c.trafofile2,'ResultImagePixelType','float');
w2 = img2;
pawork =pwd;
cd(fileparts(which('elastix.exe')));
[msg,w3,log]=evalc('transformix(w2,c.elxout)');          % get post-hoc warped image
%imoverlay(w3,fix); title('transformed');
cd(pawork);


% ==============================================
%%   stack  warpedImage and if exist the "affineImage"
% ===============================================

if tb{i,3}==1 % check if affine should be passed
    w={ w3 aff  };
else
    w={w3};
end


s=c.s;
imgout_aff=[];
for j=1:length(w)
    
    %% ========[image]=======================================
    imgIn=double(w{j});
    
    
    %% ===============================================
    % ==============================================
    %%   resize to interim2-scale [2000 x 2000]
    % ===============================================
    
    w4=imresize( imgIn ,size(s.imgmod),ipol{1});
    
    % ==============================================
    %%   [rotation]
    % ===============================================
    u2=w4;
    if isfield(s,'rotationmod')
        %     if p.enableRotation==1
        u2=imrotate(u2,-s.rotationmod  ,ipol{1},'crop');
        %     end
    end
    %% ====[border]==========================================
    R1=corr2(imresize(s.img,[2000 2000]), imresize(u2,[2000 2000]));
    % c.addborder=1;
    if isfield(s,'bordermod')
        border=s.bordermod;
        if border>0
            k=u2;
            k=imresize(k,[size(s.img,1)+2*border  size(s.img,2)+2*border ],ipol{1});
            k(  [ 1:border  end-border+1:end ],:)=[];
            k(:,[ 1:border  end-border+1:end ]  )=[];
            u3=k;
            if any(size(u3)~=size(s.img,1))
                u3=imresize(u3,[size(s.img) ],ipol{1});
            end
            R2=corr2(imresize(s.img,[2000 2000]), imresize(u3,[2000 2000]));
            
            if i==1 && j==1 %decide on first image
                if R2>R1
                    c.addborder=1;
                end
            end
            if c.addborder==1
                u2=u3;
            end
        end
    end
    % ==============================================
    %%  putfile
    % ===============================================
    if j==1
        imgout_warped=u2;
    elseif j==2
        imgout_aff=u2;
    end
    
    
end

% ==============================================
%%   pa
% ===============================================

g(i,:)={imgout_warped imgout_aff  ipol};




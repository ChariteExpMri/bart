
% backrotation added

function [s2]=warpslice(p0)

warning off
timeTot=tic;
addfiles=0;

% ==============================================
%%   MANDATORY FILES TO TRANSFORM
% ===============================================
% pa_template=strrep(which('bart.m'),'bart.m','templates');
global ak
pa_template=ak.template;

tb0={...%Name__________INterpol
    'AVGT.nii'          '1'
    'AVGThemi.nii'      '0'
    'ANO.nii'           '0'
    };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath
% ==============================================
%%   DEFAULT
% ===============================================
p.outDirName                 = 'fin'                           ; %outPutDir
p.saveIMG                    = 1                               ;%do save images
p.refImg                     = fullfile(pa_template,'AVGT.nii'); %reference image for registration
p.filesTP                    =  tb                             ; %mandatory files to transform
p.NumResolutions             = [2 4     ]                      ; %previous: [2 6]
p.MaximumNumberOfIterations  = [250 1000]                      ; %previous: [250 3000]
p.FinalGridSpacingInVoxels   = 50                              ; %control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)
p.file                       =    ''                           ; % files
p.plot                       =   0                             ; %plot results
p.useModFile                 =   1                              ; %use modified files
p.enableRotation             =1                                ; % enable rotation, if manually defined
%-------------------
p=catstruct(p,p0);

% ==============================================
%%   UNPACK SOME STUFF
% ===============================================
file  = p.file;
%  file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_004.tif'
% ==============================================
%%   namings
% ===============================================
[pa name ext]=fileparts(file);           %name: "'a1_004'"
numberstr    =regexprep(name,'.*_','_'); % such as '_004'
try
    cprintf([0 0 1],['  [' mfilename  ']: ']);
    cprintf([1 0 1],['processing "[' name ']" of "'  strrep(pa,[filesep],[filesep filesep])   '"\n']);
catch
    fprintf(['  [' mfilename  ']: ']);
    fprintf(['processing "[' name ']" of "'  strrep(pa,[filesep],[filesep filesep])   '"\n']);
end
% cprintf([0 0 1],['  [' mfilename  ']: "' name '" of "'  strrep(pa,[filesep],[filesep filesep])   '"\n']);
% ==============================================
%%   add paths
% ===============================================
% pa_template=strrep(which('bart.m'),'bart.m','templates');
if isempty(which('@slicedetection.m')) %set paths
    pabart=fileparts(which('bart.m'));
    addpath(pabart);
    addpath(genpath( fullfile(fileparts(which('bart.m')),'slicedetection')  ));
end
% ==============================================
%%   load best slice ...get paramter from [bestslice_###.mat']
% ===============================================
%% ======[path]=========================================
nametag_dl=regexprep(name,'a1_','a3_');
nametag_manwarp=regexprep(name,'a1_','a4_');
% ----
path_dl=fullfile(pa,[ 'deepsl_' nametag_dl  ]);
file_dlest=fullfile(path_dl,'');
file_xml  =fullfile(file_dlest,'est.xml');

use_deepsliceEstimate  =1 ;% PARAMETER
use_manualWarp         =1 ;% PARAMETER


% ==============================================
%%   use slice from deepslice
% ===============================================
disp('use slice from deepslice');
[co st]=getestimation_xml(file_xml,'loadhistoimage',1); %get histoImage
fi1=p.filesTP{1,1}  ;%fullfile(p.templatepath,'AVGT.nii');
% fi1  =fullfile(pa_template,'HISTOVOL.nii');

g.atlas =getslice_fromcords(fi1,co,  st.histo_size,1);
if max(g.atlas(:))<10  % when using the real HISTO-template (this is normed 0-1--> error in elastix)
    g.atlas=g.atlas.*1000;
end
[g.histo]=double(st.image);

% %% ====use modified file =============================
% if  p.useModFile==1
%
%
%     fname=[regexprep(name,'a1_','a2_') '.mat' ];
%     modfile=fullfile(pa,fname);
%
% fname=[regexprep(name,'a1_','a2_') 'mod.tif' ];
%     modfile=fullfile(pa,fname);
%
%
% end
% %% ===============================================


% -------------atlasmask
fi2  =fullfile(pa_template,'AVGTmask.nii');
g.atlasmask =getslice_fromcords(fi2,co,  st.histo_size,0);

if use_manualWarp==1
    file_manuwarped=fullfile(pa,[nametag_manwarp '_warped.txt']);
    if exist(file_manuwarped)==2
        % ========read manu-warp cordinated =======================================
        d=preadfile(file_manuwarped);
        pos=str2num(char(d.all));
        % ========get image =======================================
        Xmoving=pos(:,3:4);
        Xstatic=pos(:,1:2);
        [O_trans,Spacing,Xreg]=point_registration(size(g.atlas),Xmoving,Xstatic);
        g.atlas=bspline_transform(O_trans,g.atlas,Spacing,3);
        
        g.atlasmask=bspline_transform(O_trans,g.atlasmask,Spacing,-1);
        g.atlasmask(g.atlasmask>=.9)=1; g.atlasmask(g.atlasmask<.9)=0;
        %% ===============================================
    end
end

%---rename
g.atlas      =double(g.atlas);
g.atlasmask  =double(g.atlasmask);
g.histo      =double(g.histo);
g.histomask  =ones(size(g.histo));
% ==============================================
%%   use mode-file to get histo-mask
% ===============================================
modfile=fullfile(pa,['a2' numberstr '.mat']);
if exist(modfile)==2
    s=load(modfile); s=s.s;
    size_orig=size(g.atlas);
    g.histo      =double(imresize(double(s.img),size_orig));
    g.histomask  =double(imresize(double(s.mask),size_orig,'nearest'));
    
    if p.useModFile==1
        try
            g.histo      =double(imresize(double(s.imgmod),size_orig));
            g.histomask  =double(imresize(double(s.maskmod),size_orig,'nearest'));
            disp('..use modified histo-file & mask');
        catch
            disp('..use non-modifed histo-file & mask');
            
        end
    end
end


% ==============================================
%%
%%    [2]   ELASTIX-SECTION
%%
% ==============================================
%%   [2.1] elastix -setting
% ===============================================
% % % % --------PARAMETER SETTINGS----------------------------------------------------------------
% ===============================================  ELASTIX PATH
pa_el=strrep(which('bart.m'),'bart.m','elastix2');
addpath(genpath(pa_el));
% ===============================================
p.approach =5 ;  %used before  5

% ===============================================  USE ONE OF THE PARAMETER-files
if p.approach ==1  %5min
    parfile0={...
        %fullfile(patpl, 'par_0034rigid_2D.txt')
        %fullfile(pa_el,'par_affine038CD1_2d.txt')
        fullfile(pa_el,'par_bspline033_Ncorr.txt')};
elseif p.approach ==2
    parfile0={...
        %fullfile(patpl, 'par_0034rigid_2D.txt')
        %fullfile(pa_el,'Par0025affine_h2.txt')
        fullfile(pa_el,'par_bspline033_Ncorr.txt')};
elseif p.approach ==3 %50sec!
    parfile0={...
        %fullfile(pa_el, 'parameters_Affine_default.txt')
        %         fullfile(pa_el, 'parameters_BSpline_default.txt') }; %##default
        %            fullfile(pa_el,'par_bspline033_Ncorr.txt')};
        %         fullfile(pa_el,'par_bspline033CD1_2d.txt')};
        %         fullfile(pa_el, 'parameters_BSpline_default2.txt') }; %####LAST one
        % fullfile(pa_el, 'Par0034bspline.txt')
        fullfile(pa_el, 'Par0063_BSpline.txt')
        };
elseif p.approach ==4 %50sec!
    parfile0={...
        %fullfile(pa_el, 'a1_affine.txt')
        fullfile(pa_el, 'a2_warping.txt')
        };
elseif p.approach ==5
    parfile0=p.parameterFiles;
    % pa_el=fileparts(parfile0{1});
elseif p.approach ==6
    parfile0={...
        %fullfile(pa_el, 'a1_affine.txt')
        %         fullfile(pa_el, 'par_bspline_EM2_2D.txt')
        fullfile(pa_el, 'parameters_BSpline.txt')
        };
end



% ===============================================  	MAKE FOLDERS
elxout     =fullfile(pa,'elx2',['forward' numberstr]);
mkdir(elxout);
path_paramfile=fullfile(elxout,'params');   %make subfolder for parameters (mandatory: no self-copying allowed)
if addfiles==0
    try; rmdir(path_paramfile,'s'); end
    mkdir(path_paramfile);
    % ===============================================  COPY PARAMETER-files
    parfile=strrep(parfile0, fileparts(parfile0{1}) ,path_paramfile);                      %forward
    for i=1:length(parfile)
        copyfile(parfile0{i},parfile{i}    ,'f');
    end
end


% ==============================================
%%   register+warp
% ===============================================
time_warp=tic;
fprintf('..warping...');
%     if 0
%         set_ix(parfile{1},'NumberOfResolutions',p.NumResolutions(1)); %default:2
%         set_ix(parfile{2},'NumberOfResolutions',p.NumResolutions(2)); %default:6
%         set_ix(parfile{1},'MaximumNumberOfIterations',p.MaximumNumberOfIterations(1)); %default:250
%         set_ix(parfile{2},'MaximumNumberOfIterations',p.MaximumNumberOfIterations(2)); %default:1500
%         set_ix(parfile{2},'MaximumStepLength',p.MaximumStepLength(1)); %default:1
%         %set_ix(parfile{2},'FinalGridSpacingInVoxels',p.FinalGridSpacingInVoxels); %control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations) (org default: 70)
%         % rm_ix(parfile{2},'FinalGridSpacingInVoxels');
%     end
% -------------------------
% //(ImagePyramidSchedule 8 8 4 4 2 2 1 1)
% % % % % if 0
% % % % %     rm_ix2(parfile{1},'ImagePyramidSchedule')
% % % % %     set_ix(parfile{1},'NumberOfResolutions',6);
% % % % %     set_ix(parfile{1},'MaximumNumberOfIterations',700);
% % % % % end

% if 0 % (Metric "AdvancedNormalizedCorrelation")
%     %  rm_ix2(parfile{1},'ImagePyramidSchedule')
% %     set_ix(parfile{1},'Metric','AdvancedNormalizedCorrelation');
%     %  set_ix(parfile{1},'NumberOfResolutions',7);
%     %  set_ix(parfile{1},'MaximumNumberOfIterations',[2000 ]);
%
%     %  set_ix(parfile{1},'MaximumStepLength',.5);
% end
% ==============================================
%% set elatix paramter ELATIX call
% ===============================================
if 0 %  for apporach-5
    rm_ix2(parfile{1},'ImagePyramidSchedule')
    set_ix(parfile{1},'NumberOfResolutions',4);
    set_ix(parfile{1},'MaximumNumberOfIterations',[1000 ]);
end



set_ix(parfile{1},'Metric',p.metric);
if ~isempty(p.NumResolutions)
    set_ix(parfile{1},'NumberOfResolutions',p.NumResolutions);
end
if ~isempty(p.MaximumNumberOfIterations)
    set_ix(parfile{1},'MaximumNumberOfIterations',p.MaximumNumberOfIterations);
end


% rm_ix2(parfile{1},'ImagePyramidSchedule')
% old_PyramidSchedule=get_ix(parfile{1},'ImagePyramidSchedule');
% [8     8     4     4     2     2     1     1]

% ==============================================
%%  WARPING
% ===============================================
tic
if 1
    imsizeinterim=1000;
    atlas      =imresize(double(g.atlas)     ,[imsizeinterim imsizeinterim],'bilinear');
    histo      =imresize(double(g.histo)     ,[imsizeinterim imsizeinterim],'bilinear');
    atlasmask  =imresize(double(g.atlasmask ),[imsizeinterim imsizeinterim],'nearest');
    histomask  =imresize(double(g.histomask ),[imsizeinterim imsizeinterim],'nearest');
end

% ===============================================
% mask
% ===============================================
umask=histomask.*atlasmask;
umask=imfill(umask,'holes');
bw=bwlabeln(umask);
bw=bw(:);
uni=unique(bw);uni(uni==0)=[];
uni(:,2)=histc(bw(:),uni(:,1));
uni=flipud(sortrows(uni,2));
thresh=round(max(uni(:,2))*.1);
ix=find(uni(:,2)>thresh);

tmp=zeros([numel(umask) 1]);
for i=1:length(ix)
    tmp(find(bw==uni(ix(i),1)))=1;
end
umask=reshape(tmp,size(histomask));
% [umask]=clean_data_function2(umask);

% ==============================================
%%   ventricle mask
% ===============================================
mov   =atlas.*umask;
fix   =histo.*umask;


if p.ventricle_method>0
    if p.ventricle_method==1
        %  ===============================================
        % [A] PRESERVE VENTRICLE IF PAINTED via prunegui
        fixmask=-1.*(((histomask==0)-1).*umask);
        % ===============================================
        % [B] alternatie to account for ventricle using otsu
        % fixmask=(otsu(fix,5)>1); % ALTERNATIVE FOR DARK VENTRIVLES
    elseif p.ventricle_method==2
        if strcmp(p.otsu_ventriclecolor,'black')                      %DARK-VENTRICLES
            % [B1] dark ventricle (close to zero values)
            fixmask=otsu(fix,p.otsu_nclasses)>1; %dark-ventricle
        elseif strcmp(p.otsu_ventriclecolor,'white')                  %LIGHT-VENTRICLES
            fixmask=otsu(fix,p.otsu_nclasses)<p.otsu_nclasses ;%light ventricle
        end
        
        obj=(1-fixmask).*imerode(umask,ones(5));
        bw=bwlabeln(obj);
        bw=bw(:);
        uni=unique(bw); uni(uni==0)=[];
        tbc=flipud(sortrows([uni histc(bw,uni)],2));
        
        noise_threshPerc_mask=p.otsu_noisethresh ;%0.005;%0.0001%
        noise_threshPix      =round(sum(umask(:)*noise_threshPerc_mask));
        
        ix=find(tbc(:,2)>noise_threshPix);
        nm=zeros(size(bw));
        for i=1:length(ix)
            nm(bw== tbc(ix(i),1) )=1;
        end
        ventr=reshape(nm, size(obj));
        fixmask=~ventr.*umask;
        %   fg,imagesc(fixmask)
    end
    
    fix   =fix.*fixmask;
    
end


%% ===============================================

% ==============================================
% elastix
% ===============================================
delete(fullfile(elxout,'*'));
disp([char(parfile)]);

twarp=tic;
[wa,outs]= elastix2(  (mov), (fix),elxout,parfile(end),pa_el);


wa =imresize(double(wa)     ,[imsizeinterim imsizeinterim],'nearest');


if p.debug==1
    imoverlay(wa,fix);  title('template'); drawnow
end

if 0
    fg,imagesc(wa)
end
fprintf(['Done. (t_registration: '  sprintf('%2.2fs',toc(twarp) ) ')\n']);

%% ===============================================


%     keyboard
fprintf(['Done. (t_registration: '  sprintf('%2.2fs',toc(time_warp) ) ')\n']);
% ==============================================
%%  ANO
% ===============================================
fi3=tb{3,1};
img2 =getslice_fromcords(fi3,co,  st.histo_size,0);
img2=bspline_transform(O_trans,img2,Spacing,-1);
img2    =imresize(double(img2),[imsizeinterim imsizeinterim],'nearest');
trafofile2=fullfile(elxout,'TransformParameters.0.txt');
set_ix(trafofile2,'FinalBSplineInterpolationOrder',0);
set_ix(trafofile2,'ResultImagePixelType','float');

w2=img2;
w2 =imresize(double(w2)     ,[imsizeinterim imsizeinterim],'nearest');
pano_bef= pseudocolor2D(w2);

pawork =pwd;
cd(fileparts(which('elastix.exe')));
[msg,w3,log]=evalc('transformix(w2,elxout)');
%imoverlay(w3,fix); title('transformed');
cd(pawork)
pano=pseudocolor2D(w3).*umask;
if p.debug==1
    imoverlay(fix,pano); title('atlas');
end
%% ===============================================
%% other structural image
%% ===============================================
[pas names exts   ]=fileparts(fi1);
if strcmp(names,'AVGT');   fi4=fullfile(pas,'HISTOVOL.nii');
else                   ;   fi4=fullfile(pas,'AVGT.nii');
end
if ~exist(fi4)
    avgt2=zeros(size(pano));
else
    
    img2 =getslice_fromcords(fi4,co,  st.histo_size,3);
    img2=bspline_transform(O_trans,img2,Spacing,3);
    img2    =imresize(double(img2),[imsizeinterim imsizeinterim],'bilinear');
    trafofile2=fullfile(elxout,'TransformParameters.0.txt');
    set_ix(trafofile2,'FinalBSplineInterpolationOrder',3);
    set_ix(trafofile2,'ResultImagePixelType','float');
    
    
    
    w2=img2;
    w2 =imresize(double(w2)     ,[imsizeinterim imsizeinterim],'nearest');
    avgt2_bef=(w2);
    
    pawork =pwd;
    cd(fileparts(which('elastix.exe')));
    [msg,w4,log]=evalc('transformix(w2,elxout)');
    cd(pawork)
    avgt2=(w4).*umask;
    %imoverlay(fix,avgt2)
    
end

% ==============================================
%%   anim-gif-1
% ===============================================
w.fix  =mat2gray(fix);
w.wa  =mat2gray(wa);
w.avgt2 =mat2gray(avgt2);
w.pano =mat2gray(pano);
w.mov =mat2gray(mov);

smov=w.mov;
tx=~imresize(text2im('before'),1)*.5;
smov(1:size(tx,1),1:size(tx,2))=tx;
swa=w.wa;
tx=~imresize(text2im('post-warping'),1)*.5;
swa(1:size(tx,1),1:size(tx,2))=tx;

t1=[w.fix   w.fix         ];
t2=[smov   swa          ];

%grid
gridpix=50;
valc=.5;
t1(1:gridpix:end,:)=valc;   t1(:,1:gridpix:end)=valc;
t2(1:gridpix:end,:)=valc;   t2(:,1:gridpix:end)=valc;

t1=uint8(round(255*t1));
t2=uint8(round(255*t2));
% imoverlay(t1,t2)
Oname='a5';
%===============================================
loops=65535;
delay=.4;
filenameFP=fullfile(pa,[Oname numberstr  '_warpedQA1.png']);
c_map=gray;
imwrite(t1,c_map,[filenameFP],'gif','LoopCount',loops,'DelayTime',delay);
imwrite(t2,c_map,[filenameFP],'gif','WriteMode','append','DelayTime',delay);
showinfo2('saved warpedImage',filenameFP);



% ==============================================
%%   anim-gif-2
% ===============================================
w.fix  =mat2gray(fix);
w.wa  =mat2gray(wa);
w.avgt2 =mat2gray(avgt2);
w.pano =mat2gray(pano);
w.mov =mat2gray(mov);
w.pano_bef =mat2gray(pano_bef);
w.avgt2_bef =mat2gray(avgt2_bef);

smov=w.mov;
tx=imresize(text2im('before'),2)*.5;
smov(1:size(tx,1),1:size(tx,2))=tx;

swa=w.wa;
tx=imresize(text2im('post-warping'),2)*.5;
swa(1:size(tx,1),1:size(tx,2))=tx;

t1=[ smov   w.fix.*0    w.fix          w.fix   ;...
    smov   w.fix       w.fix          w.fix  ];

t2=[ smov   w.fix*0     w.avgt2_bef    w.pano_bef  ;...
    swa    w.wa        w.avgt2        w.pano       ];





t1(1:gridpix:end,:)=valc;   t1(:,1:gridpix:end)=valc;
t2(1:gridpix:end,:)=valc;   t2(:,1:gridpix:end)=valc;

t1=uint8(round(255*t1));
t2=uint8(round(255*t2));
% imoverlay(t1,t2)

Oname='a5';
%===============================================
loops=65535;
delay=.4;
% filenameFP=fullfile(outdir,[u.oname_suffix, '.gif']);
filenameFP=fullfile(pa,[Oname numberstr  '_warpedQA2.png']);
c_map=gray;

imwrite(t1,c_map,[filenameFP],'gif','LoopCount',loops,'DelayTime',delay)
imwrite(t2,c_map,[filenameFP],'gif','WriteMode','append','DelayTime',delay)
showinfo2('saved warpedImage',filenameFP);

% ==============================================
%% QA-3 static image[side-by Side]
% ===============================================
np=1;
pw=ones(np);
siz=[size(mov,1) size(mov,2)];
check=repmat([ [pw pw-1]; [ pw-1 pw]  ],round(siz./(2*np)+1));
check=check(1:siz(1),1:siz(2));
fus2=check.*double(mat2gray(w.wa))+~check.*double(mat2gray(w.fix));
fus2=round((fus2*255));
%fg,image(fus2)
% ===============================================
fus1=imfuse(w.wa,w.fix ,'falsecolor');
fx=uint8(255*imadjust(mat2gray(double(w.fix))));
mv=uint8(255*imadjust(mat2gray(double(w.wa))));

fus2=check.*double(mv)+~check.*double(fx);
%fg,image(fus2)
fus1=imfuse(mv,fx ,'falsecolor');
t1=[ind2rgb(fx,gray)*255  ind2rgb(mv,gray)*255 ;  fus1 ind2rgb(fus2,jet)*255 ];
t1(1:gridpix:end,:)=200;   t1(:,1:gridpix:end)=200;
%fg,image(t1)
% =======[write template-slice]========================================
filenameFP=fullfile(pa,[Oname numberstr  '_warpedQA3.jpg']);

imwrite(t1,filenameFP);
showinfo2('saved QA-3',filenameFP);



% ==============================================
%%   msg
% ===============================================
try
    cprintf([0 .5 0],['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
catch
    fprintf(['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
end






return






% backrotation added

function [s2]=warp2histo(p0)


timeTot=tic;
% ==============================================
%%
% ===============================================

warning off


% ==============================================
%%   MANDATORY FILES TO TRANSFORM
% ===============================================
pa_template=strrep(which('bart.m'),'bart.m','templates');
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
p.refImg                     = fullfile(pa_template,'AVGT.nii'); %reference image for registration
p.filesTP                    =  tb                             ; %mandatory files to transform
p.NumResolutions             = [2 2     ]                      ; %previous: [2 6]
p.MaximumNumberOfIterations  = [250 1000]                      ; %previous: [250 3000]
p.FinalGridSpacingInVoxels   = 40                              ; %control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)
p.file                       =    ''                           ; % files
p.plot                       =    0                            ; %plot results

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

cprintf([0 0 1],['  [' mfilename  ']: ']);
cprintf([1 0 1],['processing "[' name ']" of "'  strrep(pa,[filesep],[filesep filesep])   '"\n']);

% cprintf([0 0 1],['  [' mfilename  ']: "' name '" of "'  strrep(pa,[filesep],[filesep filesep])   '"\n']);
% ==============================================
%%   add paths
% ===============================================

pa_template=strrep(which('bart.m'),'bart.m','templates');
if isempty(which('@slicedetection.m')) %set paths
    pabart=fileparts(which('bart.m'));
    addpath(pabart);
    addpath(genpath( fullfile(fileparts(which('bart.m')),'slicedetection')  ));
end


% ==============================================
%%   load best slice ...get paramter from [bestslice_###.mat']
% ===============================================

fib=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.mat'});
if exist(fib)~=2
    disp(['missing file: ' fib ]);
    return
end
s2       =load(fib);
s2       =s2.s2;
parameter=s2.param;
% ==============================================
%%   get reference image(CV)
% ===============================================
if exist('cv')~=1
  
    % if 0
    %     [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
    % end
    if 1
        fprintf('..get reference Image...');
        [ cv    ]=p_getHIstvol(p.refImg,0) ;
        
        [refPa, refName]=fileparts(p.refImg);
        if 1
            if strcmp(refName, 'AVGT')==1
                file_mask=fullfile(refPa, ['AVGTmask.nii' ]);
                [ cvmask]=p_getfromHistvolspace(file_mask) ;
                cv=cv.*uint8(cvmask);
            end
        end
        % [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
        % [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
        % cv=cv.*uint8(cvmask);
        
        fprintf('Done.\n');
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
% % % paelastix=fullfile(fileparts(which('ah.m')),'matlab_elastix');
% % % addpath(genpath(paelastix));

% ===============================================  ELASTIX PATH
pa_el=strrep(which('bart.m'),'bart.m','elastix2');
addpath(genpath(pa_el));
% ===============================================
p.approach =3 ;

% ===============================================  USE ONE OF THE PARAMETER-files
if p.approach ==1  %5min
    parfile0={...
        %fullfile(patpl, 'par_0034rigid_2D.txt')
        fullfile(pa_el,'par_affine038CD1_2d.txt')
        fullfile(pa_el,'par_bspline033_Ncorr.txt')};
elseif p.approach ==2
    parfile0={...
        %fullfile(patpl, 'par_0034rigid_2D.txt')
        fullfile(pa_el,'Par0025affine_h2.txt')
        fullfile(pa_el,'par_bspline033_Ncorr.txt')};
elseif p.approach ==3 %50sec!
    parfile0={...
        fullfile(pa_el, 'parameters_Affine_default.txt')
        %         fullfile(pa_el, 'parameters_BSpline_default.txt') }; %##default
        %            fullfile(pa_el,'par_bspline033_Ncorr.txt')};
%         fullfile(pa_el,'par_bspline033CD1_2d.txt')};
%         fullfile(pa_el, 'parameters_BSpline_default2.txt') }; %####LAST one
        fullfile(pa_el, 'Par0034bspline.txt') };
    
end

% ===============================================  	MAKE FOLDERS
elxout     =fullfile(pa,'elx2',['forward' numberstr]);
mkdir(elxout);

path_paramfile=fullfile(elxout,'params');   %make subfolder for parameters (mandatory: no self-copying allowed)
mkdir(path_paramfile);
% ===============================================  COPY PARAMETER-files
parfile=strrep(parfile0,pa_el,path_paramfile);                      %forward
%parfileinv=stradd(strrep(parfile0,pa_el,savepath),'inv',1);   %backward
for i=1:length(parfile)
    copyfile(parfile0{i},parfile{i}    ,'f');
    %copyfile(parfile0{i},parfileinv{i} ,'f')
end



% ==============================================
%% %%   [2.2]   get slice
% ===============================================
xx        =parameter;
slicenum  =xx(1);
X          =xx(2);
Y          =xx(3);
cent       =[size(cv,2)/2 size(cv,1)/2];
vol_center =[cent slicenum];
tatlas     =uint8(obliqueslice(cv, vol_center, [Y -X 90]));



% ==============================================
%%  [2.3]   get orig resized image [a2_##.mat]
% ===============================================
% fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
fir=fullfile(pa,['a2' numberstr '.mat']);
if exist(fir)~=2
    disp(['missing file: ' fir ]);
    return
end
s=load(fir); s=s.s;
% ==============================================
%%   2.3.1 load infomat
% rotate back
% ===============================================
fi_info=fullfile(pa,['a1_info.mat']);
info=load(fi_info); 
info=info.v;
% ==============================================
%%   2.3.2 check for manual rotations saved in ['a1_info.mat']!!!!
% rotate back
% ===============================================

if isfield(info,'rottab')==1
    ix=find(strcmp(info.rottab(:,1), [ 'a1' numberstr '.jpg' ]));
    if ~isempty(ix)
        rotangle=info.rottab{ix,2};
        s.img  =imrotate(s.img,-rotangle,'crop','nearest');
        s.mask =imrotate(s.mask,-rotangle,'crop','nearest');
        disp([' ..rotating slice back: '  num2str(rotangle) '°']);
    end
end


% ==============================================
%%   register+warp
% ===============================================
time_warp=tic;
fprintf('..warping...');

% numresolutions            =[2 6]; %default [2 6]
% MaximumNumberOfIterations =[250 3000]; %default[250 1500]
% set_ix(parfile{1},'NumberOfResolutions',numresolutions(1)); %default:2
% set_ix(parfile{2},'NumberOfResolutions',numresolutions(2)); %default:6
% set_ix(parfile{1},'MaximumNumberOfIterations',MaximumNumberOfIterations(1)); %default:250
% set_ix(parfile{2},'MaximumNumberOfIterations',MaximumNumberOfIterations(2)); %default:1500
% -------------------------
if 0
    set_ix(parfile{1},'NumberOfResolutions',p.NumResolutions(1)); %default:2
    set_ix(parfile{2},'NumberOfResolutions',p.NumResolutions(2)); %default:6
    set_ix(parfile{1},'MaximumNumberOfIterations',p.MaximumNumberOfIterations(1)); %default:250
    set_ix(parfile{2},'MaximumNumberOfIterations',p.MaximumNumberOfIterations(2)); %default:1500
    
    set_ix(parfile{2},'FinalGridSpacingInVoxels',p.FinalGridSpacingInVoxels); %control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations) (org default: 70)
end
% -------------------------
if 1
    % ### image to atlas-Size (320x456) before warping  (t=70s) -->ok!!!
    mov =tatlas;
    fix =imresize(s.img,[size(tatlas)]);
    %disp(['size [mov;fix]: ' num2str(size(mov))  '-'  num2str(size(fix))]);
end
if 0
    % ### image to atlas-Size (320x456) before warping  (t=70s) -->ok!!!
    mov =imresize(tatlas,[1000 1000]);
    fix =imresize(s.img ,[size(mov)]);
end
% -------------------------
% ### atlas to image size (2000x2000) before warping  (t=90s) --> not that good!
% if 0
%     mov =imresize(tatlas,[size(s.img)]);
%     fix =s.img;
% end
% -------------------------
% ==============================================
%%   
% ===============================================

[wa,outs]= elastix2(mov,fix,elxout,parfile(1:end),pa_el);
fprintf(['Done. (t_registration: '  sprintf('%2.2fs',toc(time_warp) ) ')\n']);
% cprintf([0 .5 0],['  ..t_registEstimation: ' sprintf('%2.2f',toc(time_warp) )  ' s\n']);

if 0
    imoverlay(wa,fix);
end

% ==============================================
%%   
% ===============================================

% ==============================================
%%   transformix test
% ===============================================
%  outs.TransformParametersFname'
%      {'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\elx2\forward_004\TransformParameters.0.txt'}
%     {'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\elx2\forward_004\TransformParameters.1.txt'}
% if 0
%     pawork=pwd
%     cd(fileparts(which('elastix.exe')))
%     [wa2,log] = transformix(mov,elxout) ;
%     cd(pawork)
%
% end
% ==============================================
%   load tif
% ===============================================
if 0
    ftif=fullfile(pa,['a1' numberstr '.tif']);
    info=imfinfo(ftif);
    % t=imread(ftif);
    t2=imresize(t,[3000 3000]);
    v =imresize(wa,[size(t2,1) size(t2,2)]);
    imoverlay(t2(:,:,3),v);
end

% ==============================================
%%
%%    [3]   TRANSFORMIX-SECTION
%%
% ==============================================

% ==============================================
%%  [3.1] PREPARE OTHER IMAGES (TABLE)
% ===============================================
% tb0={...%Name__________INterpol
%     'AVGT.nii'          1
%     'AVGThemi.nii'      0
%     'ANO.nii'           0
% %     '_b1grey.nii'       0
%    };
% tb=tb0;
% tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath

isOtherImage=0;
tb=p.filesTP;
if ~isempty(char(tb))
    isOtherImage=1;
    if size(tb,2)==1
        tb(:,2)=repmat({1},[size(tb,1) 1]);
    end
    tb(:,2)=cellfun(@(a){[ str2num(num2str(a)) ]},tb(:,2)); %inperpol Value as numeric
end

% ==============================================
%%  [3.2A] NONLINEAR TRANSFORM IMAGES     [o]-cell
% ===============================================
% [ msk]=p_getVol(fullfile(pa_template, 'AVGTmask.nii' )) ;
time_transform = tic;
o={};
global bigtemplate
fprintf('transforming non-linear:');
for i=1:size(tb,1)
    [~,fiName]=fileparts(tb{i,1});
    fprintf([ '(' num2str(i) ') "' fiName '.nii"; ']);
    % ------------------------------------------------------ get volume
    %     [ w    ]=p_getVol(tb{i,1}) ;
    
    if 1 % FASTER when jusing other histoSlices.. BUT RESSOURCEFULL
        if isfield(bigtemplate,fiName)~=1
            [ w    ]=p_getVol(tb{i,1}) ;
            bigtemplate=setfield(bigtemplate,fiName,w);
        else
            w=getfield(bigtemplate,fiName);
        end
        
    end
    % ------------------------------------------------------ get slice
    slicenum=parameter(1);
    X       =parameter(2);
    Y       =parameter(3);
    cent    =[size(cv,2)/2 size(cv,1)/2];
    vol_center=[cent slicenum];
    if tb{i,2}==0
        interpx                        ='nearest';
        FinalBSplineInterpolationOrder=0;
    else
        interpx                       ='linear';
        FinalBSplineInterpolationOrder=3;
    end
    w2=obliqueslice(w, vol_center, [Y -X 90],'Method',interpx);
    % ------------------------------------------------------ transformix
    trafofile2=fullfile(elxout,'TransformParameters.1.txt');
    set_ix(trafofile2,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500
    
    pawork =pwd;
    cd(fileparts(which('elastix.exe')));
    %[w3,log] = transformix(w2,elxout) ;
    [msg,w3,log]=evalc('transformix(w2,elxout)');
    cd(pawork);
    % ------------------------------------------------------ put to [o]-cell
    o(i,:)={fiName w3};
    % ------------------------------------------------------ transformix
    if p.plot==1
        if strcmp(fiName,'ANO')
            imoverlay(fix,pseudocolorize(w3));gridder(20,'color','w');
        else
            imoverlay(fix,w3);gridder(20,'color','w');
        end
        title(fiName);
    end
end %over images
% fprintf('Done.\n');
fprintf(['Done. (t_transformImages: '  sprintf('%2.2fs',toc(time_transform) ) ')\n']);
% cprintf([0 .5 0],['  ..t_transformImages: ' sprintf('%2.2f',toc(time_transform) )  ' s\n']);



% ==============================================
%%  [3.2B] AFFINE TRANSFORM IMAGES     [a]-cell
%% this is needed to estimate the volume of the atlas-region
% ===============================================
% [ msk]=p_getVol(fullfile(pa_template, 'AVGTmask.nii' )) ;
time_transform = tic;
a={};
global bigtemplate
fprintf('transforming affine:');
for i=1:size(tb,1)
    [~,fiName]=fileparts(tb{i,1});
    fprintf([ '(' num2str(i) ') "' fiName '.nii"; ']);
    % ------------------------------------------------------ get volume
    %     [ w    ]=p_getVol(tb{i,1}) ;
    
    if 1 % FASTER when jusing other histoSlices.. BUT RESSOURCEFULL
        if isfield(bigtemplate,fiName)~=1
            [ w    ]=p_getVol(tb{i,1}) ;
            bigtemplate=setfield(bigtemplate,fiName,w);
        else
            w=getfield(bigtemplate,fiName);
        end
        
    end
    % ------------------------------------------------------ get slice
    slicenum=parameter(1);
    X       =parameter(2);
    Y       =parameter(3);
    cent    =[size(cv,2)/2 size(cv,1)/2];
    vol_center=[cent slicenum];
    if tb{i,2}==0
        interpx                        ='nearest';
        FinalBSplineInterpolationOrder=0;
    else
        interpx                       ='linear';
        FinalBSplineInterpolationOrder=3;
    end
    w2=obliqueslice(w, vol_center, [Y -X 90],'Method',interpx);
    % ------------------------------------------------------ transformix
    trafofile2          = fullfile(elxout,'TransformParameters.0.txt');
    orig_interpolator   = get_ix(trafofile2,'FinalBSplineInterpolationOrder');
    set_ix(trafofile2,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500
    
    pawork =pwd;
    cd(fileparts(which('elastix.exe')));
    %[w3,log] = transformix(w2,elxout) ;
    [msg,w3,log]=evalc('transformix(w2,elxout)');
    cd(pawork);
    % ------------------------------------------------------ put to [o]-cell
    a(i,:)={fiName w3};
    % ------------------------------------------------------ transformix
    if p.plot==1
        if strcmp(fiName,'ANO')
            imoverlay(fix,pseudocolorize(w3));gridder(20,'color','w');
        else
            imoverlay(fix,w3);gridder(20,'color','w');
        end
        title([fiName '-affine']);
    end
    
     set_ix(trafofile2,'FinalBSplineInterpolationOrder',orig_interpolator);
end %over images
% fprintf('Done.\n');
fprintf(['Done. (t_transformImages: '  sprintf('%2.2fs',toc(time_transform) ) ')\n']);
% cprintf([0 .5 0],['  ..t_transformImages: ' sprintf('%2.2f',toc(time_transform) )  ' s\n']);


% ==============================================
%%
%%    [4]  RESIZE-TO-ORIG-HISTO--SECTION
%%
% ==============================================
% ==============================================
%%   [4.1] output dir  
% ===============================================
 outdir=fullfile(pa,p.outDirName);
 mkdir(outdir);
 outtag=[strrep(numberstr,'_', 's') '_'];  %PREFIX-outTage ('s001_','s002_', etc)
 % ==============================================
%%   [4.2] load original tif  
% ===============================================
fprintf('...load orig. tiff.. ');
 tifname=fullfile(pa,['a1' numberstr '.tif']);
 info=imfinfo(tifname);
 size_img=[info.Height info.Width ];
 t=imread(tifname);
 if size(t,3)==3              %---USING BLUE-RGB-DIM
     t=t(:,:,3);
 end
 fprintf('Done.\n');
% ==============================================
%%   [4.3A] resize images +save as mat  NON-LINEAR-IMAGES
% ===============================================
time_save=tic;
fprintf('saving(nonlinear): ');
for i=1:size(o,1)
    %%%%nameout=[ o{i,1}  numberstr '.mat' ];
    nameout=[outtag o{i,1} '.mat' ];
    fprintf([ '(' num2str(i) ') "' nameout '"; ']);
    if 1
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        v=imresize(o{i,2},[size_img],interpy);
        if (length(unique(o{i,2})))/(numel(o{i,2})) >.4  % convert to uint8 ---file to large for intensbased images
            v=round((mat2gray(v).*255));
            %disp('..intensIMG..conv-to uin8');
        end
        % ------------------------------------------------------ save  [imageName_###.mat]
        
        fi_out=fullfile(outdir, nameout);
        save(fi_out, 'v');
    end
end
% ==============================================
%%   [4.3B] resize images +save as mat  AFFINE-IMAGES
% ===============================================
time_save=tic;
fprintf('saving(noaffine): ');
for i=1:size(a,1)
    nameout=[outtag a{i,1} '_affine' '.mat' ];
    fprintf([ '(' num2str(i) ') "' nameout '"; ']);
    if 1
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        v=imresize(a{i,2},[size_img],interpy);
        if (length(unique(a{i,2})))/(numel(a{i,2})) >.4  % convert to uint8 ---file to large for intensbased images
            v=round((mat2gray(v).*255));
           % disp('..intensIMG..conv-to uin8');
        end
        % ------------------------------------------------------ save  [imageName_###.mat]
        fi_out=fullfile(outdir, nameout);
        save(fi_out, 'v');
    end
end





% ==============================================
%   [4.4] save BLUE-DIM of original tif
% ===============================================
nameout=[outtag 'HISTO' '.mat' ] ;
fi_out=fullfile(outdir, nameout);
v=t;
fprintf([ '(' num2str(i+1) ') "' nameout '"; ']);
save(fi_out, 'v');

fprintf('Done.\n');
cprintf([0 .5 0],['  ..t_savingIMGs: ' sprintf('%2.2f',toc(time_save) )  ' s\n']);

% ==============================================
%%   [4.5] make plot (all necessary steps are done now!)
% ===============================================
fprintf(['...create image ' [ '"res'  numberstr '.gif"...' ] ]);
sizp=[500 500];
v2=uint8(zeros([ sizp length(o) ]));
for i=1:size(o,1)
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        
        v=imresize(o{i,2},[sizp],interpy);
        if strcmp(o{i,1},'ANO')
            v=pseudocolorize(v);
        end
        v=imadjust(mat2gray(v));
        v=uint8(round(v*255));
        v2(:,:,i)=v;
end

vh=imresize(t,[sizp],'nearest');
vh=uint8(round(255*imadjust(mat2gray(vh))));
v2=cat(3,vh,v2);
v3=repmat(vh,[1 1 size(v2,3)]);
% ==============================================
%   add unwarped image
% ===============================================
% fixr=uint8(round(255*imadjust(mat2gray(imresize(fix,[sizp])))));
movr=uint8(round(255*imadjust(mat2gray(imresize(mov,[sizp])))));
warp =uint8(round(255*imadjust(mat2gray(imresize(wa,[sizp])))));


% tx_fix=uint8(round(imcomplement(text2im([ 'Histo-resized' ]))*255));
tx_mov=uint8(round(imcomplement(text2im([ 'refImg_unregistered' ]))*255));
tx_war=uint8(round(imcomplement(text2im([ 'refImg_warped' ]))*255));


% fixr(1:size(tx_fix,1),1:size(tx_fix,2))=tx_fix;
movr(1:size(tx_mov,1),1:size(tx_mov,2))=tx_mov;
warp(1:size(tx_war,1),1:size(tx_war,2))=tx_war;
% ==============================================
%  
% ===============================================

% v2=cat(3,fixr,movr,v2);
% v3=cat(3,fixr,movr,v3);
% v2=cat(3,movr,fixr,v2);
% v3=cat(3,movr,fixr,v3);
v2=cat(3,movr,warp,v2);
v3=cat(3,movr,vh,v3);

r1=montageout(permute(v2,[1 2 4 3]));
r2=montageout(permute(v3,[1 2 4 3]));
% fg,imagesc(r1)
% fg,imagesc(r2)
% ==============================================
%   write GIF
% ===============================================
% r1=montageout(permute(v2,[1 2 4 3]));
% r2=montageout(permute(v3,[1 2 4 3]));

step=round(sizp(1)/10);
val=90;
r1(1:step:end,:)         =90;
r1(:         ,1:step:end)=90;
r2(1:step:end,:)         =90;
r2(:         ,1:step:end)=90;


tx=text2im([ 'SLICE'  numberstr '.mat'  ' (' sprintf('SL=%2.1f; a1=%2.1f; a2=%2.1f',parameter) ')' ]);
tx=imcomplement(tx);
tx2=uint8(  zeros([size(tx,1)  size(r1,2) 1])   )  ;
tx2(:, 1:size(tx,2),1 )=round(tx.*255);

r1=[tx2; r1 ];
r2=[tx2; r2 ];


nameout=[outtag 'result' '.gif' ];
fileout2=fullfile(outdir, nameout);
dollop=1;
while dollop==1
    try
        imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
        imwrite(r2  ,fileout2,'gif','WriteMode','append');
        disp('image written.');
        dollop=0;
    catch ME
        uiwait(msgbox({ME.message '---> CLOSE IMAGE-VIEWER to proceed!!'},'ERROR','modal'));
        %     try
        %         imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
        %         imwrite(r2  ,fileout2,'gif','WriteMode','append');
        %         disp('image written.');
        %     catch
        %         disp('..could not write gif-image.')
        %     end
    end
end
fprintf('Done.\n');
showinfo2('final image',fileout2);



% ==============================================
%%   
% ===============================================
cprintf([0 .5 0],['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);



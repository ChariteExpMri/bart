
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

fib=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.mat'});
if exist(fib)~=2
    disp(['missing file: ' fib ]);
    return
end
s2       =load(fib);
s2       =s2.s2;
parameter=s2.param;


% ==============================================
%%  [0.3]   get orig resized image [a2_##.mat]
% ===============================================
% fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
fir=fullfile(pa,['a2' numberstr '.mat']);
if exist(fir)~=2
    disp(['missing file: ' fir ]);
    return
end
s=load(fir); s=s.s;



% ==============================================
%%   0.3.1 load infomat
% rotate back
% ===============================================
try
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
end
% ==============================================
%%   0.3.2 use mod_image
% ===============================================
histo     =s.img;
histo_orig=s.img;
so=s;

% useModFile=1;

if p.useModFile==1
    disp('...using mod-file..');
    fmodif=fullfile(pa,[strrep(name,'a1_','a2_') 'mod.tif']);
    if exist(fmodif)==2
        s3=(mat2gray(imread(fmodif)).*255);
        paint=s3==255;
        brain=single(s3>0)-single(paint);
        val=median(s3(brain(:)==1));
        s3(paint)=val;
        histo=uint8(s3);
    end
end





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

if isfield(s,'hemi')==1
    [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGThemi.nii' )) ;
    if strcmp(lower(s.hemi),'r') || strcmp(lower(s.hemi),'right') || strcmp(lower(s.hemi),'R')
        cvmask=single(cvmask==2);
        cv=cv.*uint8(cvmask);
        disp('---using right hemisphere template only');
    elseif strcmp(lower(s.hemi),'l') || strcmp(lower(s.hemi),'left') || strcmp(lower(s.hemi),'L')
        cvmask=single(cvmask==1);
        cv=cv.*uint8(cvmask);
         disp('---using left hemisphere template only');
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
p.approach =5 ;

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
        % fullfile(pa_el, 'Par0034bspline.txt') 
        fullfile(pa_el, 'Par0063_BSpline.txt') 
        };
elseif p.approach ==4 %50sec!
    parfile0={...
        fullfile(pa_el, 'a1_affine.txt')
        fullfile(pa_el, 'a2_warping.txt')
        };
 elseif p.approach ==5 
     parfile0=p.parameterFiles;
    % pa_el=fileparts(parfile0{1});
    
end

% ===============================================  	MAKE FOLDERS
elxout     =fullfile(pa,'elx2',['forward' numberstr]);
mkdir(elxout);

path_paramfile=fullfile(elxout,'params');   %make subfolder for parameters (mandatory: no self-copying allowed)
try; rmdir(path_paramfile,'s'); end
mkdir(path_paramfile);
% ===============================================  COPY PARAMETER-files
parfile=strrep(parfile0, fileparts(parfile0{1}) ,path_paramfile);                      %forward
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



% % ==============================================
% %%  [2.3]   get orig resized image [a2_##.mat]
% % ===============================================
% % fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
% fir=fullfile(pa,['a2' numberstr '.mat']);
% if exist(fir)~=2
%     disp(['missing file: ' fir ]);
%     return
% end
% s=load(fir); s=s.s;
% 
% 
% 
% % ==============================================
% %%   2.3.1 load infomat
% % rotate back
% % ===============================================
% try
%     fi_info=fullfile(pa,['a1_info.mat']);
%     info=load(fi_info);
%     info=info.v;
%     % ==============================================
%     %%   2.3.2 check for manual rotations saved in ['a1_info.mat']!!!!
%     % rotate back
%     % ===============================================
%     
%     if isfield(info,'rottab')==1
%         ix=find(strcmp(info.rottab(:,1), [ 'a1' numberstr '.jpg' ]));
%         if ~isempty(ix)
%             rotangle=info.rottab{ix,2};
%             s.img  =imrotate(s.img,-rotangle,'crop','nearest');
%             s.mask =imrotate(s.mask,-rotangle,'crop','nearest');
%             disp([' ..rotating slice back: '  num2str(rotangle) '°']);
%         end
%     end
% end
% % ==============================================
% %%   2.3.2 use mod_image
% % ===============================================
% histo     =s.img;
% histo_orig=s.img;
% so=s;
% 
% % useModFile=1;
% 
% if p.useModFile==1
%     disp('...using mod-file..');
%     fmodif=fullfile(pa,[strrep(name,'a1_','a2_') 'mod.tif']);
%     if exist(fmodif)==2
%         s3=(mat2gray(imread(fmodif)).*255);
%         paint=s3==255;
%         brain=single(s3>0)-single(paint);
%         val=median(s3(brain(:)==1));
%         s3(paint)=val;
%         histo=uint8(s3);
%     end
% end



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
    
    set_ix(parfile{2},'MaximumStepLength',p.MaximumStepLength(1)); %default:1
    
    %set_ix(parfile{2},'FinalGridSpacingInVoxels',p.FinalGridSpacingInVoxels); %control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations) (org default: 70)
    % rm_ix(parfile{2},'FinalGridSpacingInVoxels');
end
% -------------------------
if 0
    % ### image to atlas-Size (320x456) before warping  (t=70s) -->ok!!!
    mov =tatlas;
    fix =imresize(histo,[size(tatlas)]);
    %disp(['size [mov;fix]: ' num2str(size(mov))  '-'  num2str(size(fix))]);
end
if 1
    % ### image to atlas-Size (320x456) before warping  (t=70s) -->ok!!!
    if 0
        mov =imresize(double(tatlas),[1000 1000],'bilinear');
        fix =imresize(double(histo) ,[size(mov)],'bilinear');
    end
    
    imsizeinterim=2000;
    mov =imresize(double(tatlas),[imsizeinterim imsizeinterim],'bilinear');
    fix =imresize(double(histo) ,[size(mov)],'bilinear');
    
end
% -------------------------
% ### atlas to image size (2000x2000) before warping  (t=90s) --> not that good!
% if 0
%     mov =imresize(tatlas,[size(s.img)]);
%     fix =s.img;
% end
% -------------------------
% ==============================================
%% ELATIX call
% ===============================================
% % % % % if 0  % change original paramfiles and reload!!!!!
% % % % %     parfile=strrep(parfile0,pa_el,path_paramfile);                      %forward
% % % % %     %parfileinv=stradd(strrep(parfile0,pa_el,savepath),'inv',1);   %backward
% % % % %     for i=1:length(parfile)
% % % % %         copyfile(parfile0{i},parfile{i}    ,'f');
% % % % %         %copyfile(parfile0{i},parfileinv{i} ,'f')
% % % % %     end
% % % % % end


warning off;
%% ================ testbed ===============================

if 0
    delete(fullfile(elxout,'*'));
    [wa,outs]= elastix2(  (mov), (fix),elxout,parfile(1),pa_el);
    fprintf(['Done. (t_registration: '  sprintf('%2.2fs',toc(time_warp) ) ')\n']);
    
end
%% ===============================================


delete(fullfile(elxout,'*'));
[wa,outs]= elastix2(  (mov), (fix),elxout,parfile(1:end),pa_el);
fprintf(['Done. (t_registration: '  sprintf('%2.2fs',toc(time_warp) ) ')\n']);
% cprintf([0 .5 0],['  ..t_registEstimation: ' sprintf('%2.2f',toc(time_warp) )  ' s\n']);

if 0
    imoverlay(wa,fix);
end

if 0
  fg,imagesc(wa)  
end
% ==============================================
%%   
% ===============================================


if 0
    % ==============================================
    %%  inverse transform from spline to affine
    %% this is necessary for area-correction using the modif-image
    %% this snip is implemented in the cell2region-code
    % REASON: bring "modified image" to affine space to remove tissue which
    % does not exist from regions before regional area calculation
    % ===============================================
    
    if 0
        % ======== get paramter =======================================
        if 0
            [pa name ext]=fileparts(file);           %name: "'a1_004'"
            numberstr    =regexprep(name,'.*_','_'); % such as '_004'
            elxout     =fullfile(pa,'elx2',['forward' numberstr]);
            
            
            dum=spm_select('FPList',elxout,'^TransformParameters.*.txt')
        end
        %
        %      % ===============================================
        %———————————————————————————————————————————————
        %%
        %———————————————————————————————————————————————
        elxoutinverse     =strrep(elxout,[filesep 'forward_'],[filesep 'backward_']);
        elxoutinverseParams=fullfile(elxoutinverse,'params');
        warning off;
        mkdir(elxoutinverse);
        delete(fullfile(elxoutinverse,'*'));
        mkdir(elxoutinverseParams);
        delete(fullfile(elxoutinverseParams,'*'));
        
        
        parafiles    =parfile%(end); %use only b-spline
        parafilesinv =stradd(parafiles,'inv',1);
        parafilesinv =replacefilepath(parafilesinv, elxoutinverseParams);
        
        for i=1:length(parafilesinv)
            copyfile(parafiles{i},parafilesinv{i},'f');
            pause(.01)
            rm_ix(parafilesinv{i},'Metric'); pause(.1) ;
            set_ix3(parafilesinv{i},'Metric','DisplacementMagnitudePenalty'); %SET DisplacementMagnitudePenalty
        end
        
        
        %-----TRAFOFILE------------
        trafofile=outs.TransformParametersFname';
        trafofileinv=replacefilepath(trafofile, elxoutinverseParams);
        for i=1:length(trafofileinv)
            %trafofile=trafofile(end); %Bspline only
            
            copyfile(trafofile{i},trafofileinv{i},'f');
            if i==1
                set_ix(trafofileinv{1},'InitialTransformParametersFileName','NoInitialTransform'); % no affine-Reg-LINKAGE
            end
        end
        
        % [im3,trfile3] =      run_elastix(z.movimg,z.movimg,    z.outbackw  ,parafilesinv,[], []       ,   trafofile   ,[],[]);
        % [~,im3,trfile3]=evalc('run_elastix(z.movimg,z.movimg,    z.outbackw  ,parafilesinv,[], []       ,   trafofile   ,[],[])');
        
        %affimgx=outs.transformedImages{2}; % here we use the affine image
        affimgx=wa;
        [wainv,outsinv]= elastix2( (affimgx),(affimgx),elxoutinverse,parafilesinv,pa_el,'t0',trafofileinv);
        
        
        trfileInv=outsinv.TransformParametersFname;
        set_ix(trfileInv{1},'InitialTransformParametersFileName','NoInitialTransform');%% orig
        
        
        [wa2aff,log] = transformix(wa,trfileInv{2}) ;
        %[wa2aff,log] = transformix(wa,elxoutinverse) ;
        fg,imagesc(wa2aff)
        
        
        % ==============================================
        %   transformix inverse test
        % ===============================================
        
        % forwImg=wa;
        r1 = mhd_read(fullfile(elxout,'result.0.mhd'));
        r2 = mhd_read(fullfile(elxout,'result.1.mhd'));
        
        pawork =pwd;
        cd(fileparts(which('elastix.exe')));
        [wa2aff,log] = transformix(wa,trfileInv) ;
        cd(pawork)
        
        cf
        fg,imagesc(r1)   ;title('aff-saved')
        %     fg,imagesc(wainv);title('aff-created_elastix')
        fg,imagesc(wa2aff);title('aff-created_transformix')
        %     fg,imagesc(wa);title('bspline')
        %
        %     cf
        %     fg,imagesc(r2)   ;title('bspline-saved')
        %     fg,imagesc(wa);title('bspline-created')
    end
    %———————————————————————————————————————————————
    %%   back from histo to affine registration
    %———————————————————————————————————————————————
    
    warning off
    cd(fileparts(which('elastix.exe')));
    % pa_invert=fullfile
    elxoutinverse     =strrep(elxout,[filesep 'forward_'],[filesep 'backward_']);
    % elxoutinverseParams=fullfile(elxoutinverse,'params');
    mkdir(elxoutinverse);
    delete(fullfile(elxoutinverse,'*'));
    %———————————————————————————————————————————————
    %%   THIS WORKS
    %———————————————————————————————————————————————
    affix  = outs.transformedImages{1};
    wamov  = wa;
    
    tic
    % [wa,outs]= elastix2( (mov),(fix),elxoutinverse,parfile(1:end),pa_el);
    [wa2aff,out2aff]= elastix2( (wamov),(affix),elxoutinverse,parfile(2),pa_el);
    toc
    
    % ----TEST
    
    [wa2aff2,log] = transformix(wa,elxoutinverse) ;
    fg,imagesc(wa2aff2)   ;title('aff-transformed')
    
    r1 = mhd_read(fullfile(elxout,'result.0.mhd'));
    fg,imagesc(r1)   ;title('aff-saved')
    %———————————————————————————————————————————————
    %%
    %———————————————————————————————————————————————
    
    
    
    
    %———————————————————————————————————————————————
    %%
    %———————————————————————————————————————————————
    
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
  
    %%%w=w.*cast(cvmask,'like','w'); %%
    %w=w.*double(cvmask);
    %fg,imagesc(w(:,:,200))
    
    
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
    
    if 0
        %CRITICAL !! mask here
        msk=imfill(imerode(tatlas>0,strel(ones(7))),'holes');
        w2=w2.*msk;
    end
    %---------------RESIZE---
    if any(size(w2)-size(fix))
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        w2=imresize(w2,[size(fix)],interpy);
        
    end
    
    %% ===============================================
    
    % ------------------------------------------------------ transformix
    trafofile1=fullfile(elxout,'TransformParameters.0.txt');
    set_ix(trafofile1,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder);
    set_ix(trafofile1,'ResultImagePixelType','float');
    
    trafofile2=fullfile(elxout,'TransformParameters.1.txt');
    set_ix(trafofile2,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500
    set_ix(trafofile2,'ResultImagePixelType','float');
    
    
    
    pawork =pwd;
    cd(fileparts(which('elastix.exe')));
    %[w3,log] = transformix(w2,elxout) ;
    [msg,w3,log]=evalc('transformix(w2,elxout)');

    %% ===============================================
    
    cd(pawork);
    % ------------------------------------------------------ put to [o]-cell
    o(i,:)={fiName w3};
    % ------------------------------------------------------ transformix
    if p.plot==1
        if strcmp(fiName,'ANO')
            imoverlay(fix,pseudocolorize(w3));gridder(100,'color','w');
        else
            imoverlay(fix,w3);gridder(100,'color','w');
        end
        title(fiName);
    end
end %over images
% fprintf('Done.\n');
fprintf(['Done. (t_transformImages: '  sprintf('%2.2fs',toc(time_transform) ) ')\n']);
% cprintf([0 .5 0],['  ..t_transformImages: ' sprintf('%2.2f',toc(time_transform) )  ' s\n']);


% ==============================================
%%   interim mask image
% ===============================================
[refPa, refName]=fileparts(p.refImg);
file_mask=fullfile(refPa, ['AVGTmask.nii' ]);
[ cvmask]=p_getfromHistvolspace(file_mask) ;
 w2=obliqueslice(cvmask, vol_center, [Y -X 90],'Method','nearest');
%  w2=imerode(imclose(w2,strel(ones(15))),ones(11));
wm2=imresize(w2,[size(fix)],'nearest');

trafofile2=fullfile(elxout,'TransformParameters.1.txt');
set_ix(trafofile2,'FinalBSplineInterpolationOrder',0); %default:1500

% wm2=double(mov>0);

pawork =pwd;
cd(fileparts(which('elastix.exe')));
%[w3,log] = transformix(w2,elxout) ;
[msg,wm3,log]=evalc('transformix(wm2,elxout)');
cd(pawork);
%% ===============================================
% [mf1,bf]=clean_data_function2(wm3);
[mf,bf]=clean_data_function2(imerode(imfill(wm3,'holes'),ones(5)));
% [mf,bf]=clean_data_function2(wm3-imbothat(wm3,ones(15)));
% mf=imdilate(mf,ones(5));
%  fg,imagesc(w3)
% fg,imagesc(mf.*w3)
ob=o;
for i=1:size(ob,1)
    ob{i,2}=double(ob{i,2}).*double(mf);
    %fg, imagesc([ o{i,2} ob{i,2} ; 0.*[ o{i,2} ob{i,2} ]])
end
o=ob;

% ==============================================
%%  [3.2B] AFFINE TRANSFORM IMAGES     [a]-cell
%% this is needed to estimate the volume of the atlas-region
% ===============================================
% [ msk]=p_getVol(fullfile(pa_template, 'AVGTmask.nii' )) ;
time_transform = tic;
a={};
global bigtemplate
fprintf('transforming affine:');

elxout_aff=fullfile([elxout],'affine');
mkdir(elxout_aff); %extra-affine FOLDER
trafofile_affie0=fullfile(fullfile(elxout    ,'TransformParameters.0.txt'));
trafofile_affie =fullfile(fullfile(elxout_aff,'TransformParameters_affine.0.txt'));
copyfile(trafofile_affie0 , trafofile_affie ,'f')


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
    %---------------RESIZE---
    if any(size(w2)-size(fix))
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        w2=imresize(w2,[size(fix)],interpy);
        
    end
    
    
    
    % ------------------------------------------------------ transformix
    
    orig_interpolator   = get_ix(trafofile_affie,'FinalBSplineInterpolationOrder');
    set_ix(trafofile_affie,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500
    
    set_ix(trafofile_affie,'ResultImagePixelType','float'); %default:1500
    
    
    
    pawork =pwd;
    cd(fileparts(which('elastix.exe')));
    %[w3,log] = transformix(w2,elxout) ;
    [msg,w3,log]=evalc('transformix(w2,elxout_aff)');
    %     disp(['max of: w2/w3: '  num2str(max(w2(:)))  '/' num2str(max(w3(:)))]);
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
    
    set_ix(trafofile_affie,'FinalBSplineInterpolationOrder',orig_interpolator);
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

tifname=fullfile(pa,['a1' numberstr '.tif']);
info=imfinfo(tifname);
info=info(1);
size_img=[info.Height info.Width ];

if p.useModFile==1
    disp('...using mod-file..');
    if exist(fmodif)==2
        disp('..warp onto modified Histo-image');
        err_modif=0;
        t=imresize(uint8(s3),[size_img]); %replace image
    else
        err_modif=1;
    end
end

if p.useModFile==0 || err_modif==1
     %fprintf('...load orig. tiff.. ');
     disp('..warp onto original Histo-image');
    t=imread(tifname);
    if size(t,3)==3              %---USING BLUE-RGB-DIM
        %t=t(:,:,3);
        t=sum(t,3);
        t=uint8(round((mat2gray(imadjust(mat2gray(t))))*255));
    end
end

fprintf('Done.\n');
% ==============================================
%%   [4.3A] resize images +save as mat  NON-LINEAR-IMAGES
% ===============================================
time_save=tic;
fprintf('saving(nonlinear): ');
thumb={};
o(4,:)={'REF'  single(wa) };
addborder=0;
for i=1:size(o,1)
    %%%%nameout=[ o{i,1}  numberstr '.mat' ];
    nameout=[outtag o{i,1} '.mat' ];
    fprintf([ '(' num2str(i) ') "' nameout '"; ']);
    if 1
        try
        if tb{i,2}==0
            interpy                        ='nearest';
        else
            interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
        end
        catch
           interpy                        ='nearest'; 
        end
        % ============================================================================================
        % ---unsing border and rotation--info ------------------------------------------
        % ============================================================================================
        %cf
        %fg,imagesc(s.img); title('orig')
   
        u2=imresize(o{i,2},[size(so.img)],interpy);
        if isfield(so,'rotationmod')
            if p.enableRotation==1
                u2=imrotate(u2,-so.rotationmod  ,'nearest','crop');
            end
        end
        
        R1=corr2(imresize(s.img,[2000 2000]), imresize(u2,[2000 2000]));
        if isfield(so,'bordermod')
            border=so.bordermod;
            k=u2;
            k=imresize(k,[size(so.img,1)+2*border  size(so.img,2)+2*border ],interpy);
            k(  [ 1:border  end-border+1:end ],:)=[];
            k(:,[ 1:border  end-border+1:end ]  )=[];
            u3=k;
            if any(size(u3)~=size(so.img,1))
                u3=imresize(u3,[size(so.img) ],interpy);
            end
             R2=corr2(imresize(s.img,[2000 2000]), imresize(u3,[2000 2000]));
             
             if i==1%decide on first image
                 if R2>R1
                     addborder=1;
                 end
             end 
             if addborder==1
                u2=u3; 
             end
        end
        
        
        
        thumb{i,1}=u2;
        %fg; imagesc(u2); title('crap')
        
        % -----------------------------------------------------------------------------
        
        
        v=imresize(   u2      ,[size_img],interpy);
%         if (length(unique(o{i,2})))/(numel(o{i,2})) >.4  % convert to uint8 ---file to large for intensbased images
%             v=round((mat2gray(v).*255));
%             %disp('..intensIMG..conv-to uin8');
%         end
        % ------------------------------------------------------ save  [imageName_###.mat]
        
        fi_out=fullfile(outdir, nameout);
        if p.saveIMG==1
            save(fi_out, 'v','-v7.3');
        end
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
    
    if tb{i,2}==0
        interpy                        ='nearest';
    else
        interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
    end
    v=imresize(a{i,2},[size_img],interpy);
    if (length(unique(a{i,2})))/(numel(a{i,2})) >.4  % convert to uint8 ---file to large for intensbased images
        v=round((mat2gray(v).*255));
        v=uint8(v);
        % disp('..intensIMG..conv-to uin8');
    end
    % ------------------------------------------------------ save  [imageName_###.mat]
    fi_out=fullfile(outdir, nameout);
    if p.saveIMG==1
        save(fi_out, 'v','-v7.3');
    end
    
end





% ==============================================
%   [4.4] save BLUE-DIM of original tif
% ===============================================
nameout=[outtag 'HISTO' '.mat' ] ;
fi_out=fullfile(outdir, nameout);
v=t;
fprintf([ '(' num2str(i+1) ') "' nameout '"; ']);
if p.saveIMG==1
    save(fi_out, 'v','-v7.3');
end

fprintf('Done.\n');
try
    cprintf([0 .5 0],['  ..t_savingIMGs: ' sprintf('%2.2f',toc(time_save) )  ' s\n']);
catch
    fprintf(['  ..t_savingIMGs: ' sprintf('%2.2f',toc(time_save) )  ' s\n']);
end

% ==============================================
%%   [4.5] make summary plot 
% ===============================================
fprintf(['...create image ' [ '"res'  numberstr '.gif"...' ] ]);
sizp=[500 500];

% ==============================================
%   layout images
% ===============================================
% ========== IMAGES-B1 =====================================
B=uint8([]);
%----REF
n=4;
q=uint8(round(255*(imadjust(mat2gray(imresize(thumb{ [n ] ,1},sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im(o{n,1})));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,1)=q;
%----AVGT
n=1;
q=uint8(round(255*(imadjust(mat2gray(imresize(thumb{ [n ] ,1},sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im(o{n,1})));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,n+1)=q;
%----HEMI
n=2;
q=uint8(round(255*(imadjust(mat2gray(imresize(thumb{ [n ] ,1},sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im(o{n,1})));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,n+1)=q;
%----ANO
n=3;
q=uint8(round((pseudocolorize(((imresize(thumb{ [n ] ,1},sizp,'nearest')))))));
q2=uint8(255*imcomplement(text2im(o{n,1})));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,n+1)=q;

% ========= BACKGROUND-B2 ======================================
q=uint8(round(255*(imadjust(mat2gray(imresize(s.img,sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im('HISTO-orig')));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B2=q;
B2=repmat(B2,[1 1 4]);

% ========fix&warped image=======================================
%----movIMG
q=uint8(round(255*(imadjust(mat2gray(imresize(mov,sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im('movedIMG (source)'   )));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,5)=q;
%----fixIMG
q=uint8(round(255*(imadjust(mat2gray(imresize(fix,sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im('fixedIMG (target)'   )));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
B(:,:,6)=q;
% ======== moved image=======================================

% warped
q=uint8(round(255*(imadjust(mat2gray(imresize(wa,sizp,'nearest'))))));
q2=uint8(255*imcomplement(text2im('warpedIMG'   )));
q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);

B2(:,:,5)=B(:,:,5); %same moved-image appear static
B2(:,:,6)=q;
% ===============================================
% make2d+RGBconvert
r1=montageout(permute(B ,[1 2 4 3]));
r2=montageout(permute(B2,[1 2 4 3]));
% r1=mat2im(montageout(permute(B ,[1 2 4 3])),gray);
% r2=mat2im(montageout(permute(B2,[1 2 4 3])),gray);





% ==============================================
%   ADD INFO
% ===============================================
bi=[];
sih=round(size(r1,2)/2);
q=imcomplement(text2im(['IMG: ' name ])); %IMG
q(:,size(q,2)+1:sih) = 0;
bi=[bi;q];

[~,mdir,~]=fileparts(pa);
q=imcomplement(text2im(['DIR: ' mdir ]));   %MDIR
q(:,size(q,2)+1:sih) = 0;
bi=[bi;q];


try
    flog=fullfile(pa,'importlog.txt');               %log-file
    lg=importdata(flog);
    %ix=find(~cellfun('isempty',strfind(lg,'[origin]')));
    ix=find(~cellfun('isempty',regexpi(lg, [ name ext '$' ]))); % search for numericName
    if length(ix)==1
        rawfile=regexprep(lg{ix-1}, '.*\[origin]: ','' );
        [~,nameRaw,extRaw]=fileparts(rawfile);
        q=imcomplement(text2im(['RAW: ' [nameRaw,extRaw] ]));   
        q(:,size(q,2)+1:sih) = 0;
        bi=[bi;q];
    end
end


[~,mdir,~]=fileparts(pa);                  % PARAMETER
q=imcomplement(text2im(['PAR (S,p,y): ' sprintf('%2.1f , %2.2f , %2.2f', parameter(1),parameter(2),parameter(3)) ]));   %PARAMETER
q(:,size(q,2)+1:sih) = 0;
bi=[bi;q];

if p.useModFile==1; usemodfileSTR='yes'; else usemodfileSTR='no'; end
q=imcomplement(text2im(['use modfile: ' usemodfileSTR ]));   %use mod-file
q(:,size(q,2)+1:sih) = 0;
bi=[bi;q];
if p.useModFile==1
    try
        q=imcomplement(text2im(['rotation   : ' num2str(so.rotationmod) ]));   %rotation
        q(:,size(q,2)+1:sih) = 0;
        bi=[bi;q];
    end
    
    try
        q=imcomplement(text2im(['border     : ' num2str(so.bordermod) ]));   %add border
        q(:,size(q,2)+1:sih) = 0;
        bi=[bi;q];
    end
    
end

q=imcomplement(text2im(['TIME       : ' datestr(now) ]));   %time
q(:,size(q,2)+1:sih) = 0;
bi=[bi;q];



% ================PARAMETER-FILE INFO ===============================
bi2=[];
% ---------------- NUMBER OF REOLUTIONS ---------------- 
dum=[nan nan];
try;dum(1)=get_ix2(parfile{1},'NumberOfResolutions');end
try;dum(2)=get_ix2(parfile{2},'NumberOfResolutions');end
dum=regexprep(num2str(dum),'\s+','/');
q=imcomplement(text2im(['numRESOLUTIONS(af/w): ' dum ]));   
q(:,size(q,2)+1:sih) = 0;
bi2=[bi2;q];
% ---------------- NUMBER OF ITERATIONS ---------------- 
dum=[nan nan];
try;dum(1)=get_ix2(parfile{1},'MaximumNumberOfIterations');end
try;dum(2)=get_ix2(parfile{2},'MaximumNumberOfIterations');end
dum=regexprep(num2str(dum),'\s+','/');
q=imcomplement(text2im(['numITERARIONS(af/w): ' dum ]));   
q(:,size(q,2)+1:sih) = 0;
bi2=[bi2;q];
% ---------------- MaximumStepLength ----------------
dum=[nan nan];
try;dum(1)=get_ix2(parfile{1},'MaximumStepLength');end
try;dum(2)=get_ix2(parfile{2},'MaximumStepLength');end
dum=regexprep(num2str(dum),'\s+','/');
q=imcomplement(text2im(['maxStepLength(af/w): ' dum ]));  
q(:,size(q,2)+1:sih) = 0;
bi2=[bi2;q];
% same-sizes of bi/bi2
bis=[size(bi,1) size(bi2,1)];
imin=find(bis==min(bis));
if imin==1
    bi=[bi; zeros(size(bi2,1)-size(bi,1), size(bi,2)  )];
else
    bi2=[bi2; zeros(size(bi,1)-size(bi2,1), size(bi,2)  )];
end


q2=uint8(round(255.*[bi bi2]));
r1=[r1;q2];
r2=[r2;q2];

if 0
    % fg,imagesc([r1])
    % fg,imagesc([r2])
    fg, image(repmat(r1,[1 1 3]))
    fg, image(repmat(r2,[1 1 3]))
end

% ==============================================
%%   write IMAGE
% ===============================================

nameout=[outtag 'result' '.gif' ];
fileout2=fullfile(outdir, nameout);
if exist(fileout2)==2
    delete(fileout2);
end
    
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
%%   msg
% ===============================================
try
    cprintf([0 .5 0],['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
catch
    fprintf(['  [' mfilename '] DONE.  (dT: ' sprintf('%2.2f',toc(timeTot)/60 )  'min)\n']);
end

% % % fprintf(['...create image ' [ '"res'  numberstr '.gif"...' ] ]);
% % % sizp=[500 500];
% % % 
% % % o2=o;
% % % v2=uint8(zeros([ sizp size(o2,1)-1 ]));
% % % o2(:,2)=thumb;
% % % for i=1:3%size(o2,1)
% % % %     if tb{i,2}==0
% % %         interpy                        ='nearest';
% % % %     else
% % % %         interpy                       ='bilinear';%'bicubic' ;  % 'bilinear';
% % % %     end
% % %     
% % %     v=imresize(o2{i,2},[sizp],interpy);
% % %     if strcmp(o2{i,1},'ANO')
% % %         v=pseudocolorize(v);
% % %     end
% % %     v=imadjust(mat2gray(v));
% % %     v=uint8(round(v*255));
% % %     v2(:,:,i)=v;
% % % end
% % % 
% % % % vh=imresize(o2{end,2},[sizp],'nearest')  ; %imresize(t,[sizp],'nearest');
% % % vh=imresize(so.img,[sizp],'nearest')  ; %imresize(t,[sizp],'nearest');
% % % 
% % % vh=uint8(round(255*imadjust(mat2gray(vh))));
% % % v2=cat(3,vh,v2);
% % % % 
% % % 
% % % 
% % % v3=repmat(vh,[1 1 size(v2,3)]);
% % % 
% % % v3(:,:,1)=imresize(o2{end,2},[sizp],interpy);
% % % 
% % % % ==============================================
% % % %   add unwarped image
% % % % ===============================================
% % % % fixr=uint8(round(255*imadjust(mat2gray(imresize(fix,[sizp])))));
% % % movr=uint8(round(255*imadjust(mat2gray(imresize(fix,[sizp])))));
% % % warp =uint8(round(255*imadjust(mat2gray(imresize(wa,[sizp])))));
% % % 
% % % % imresize(o2{end,2},[sizp],interpy);
% % % movr=uint8(round(255*imadjust(mat2gray(imresize(o2{end,2},[sizp])))));
% % % warp=uint8(round(255*imadjust(mat2gray(imresize(o2{end,2},[sizp])))));
% % % 
% % % % tx_fix=uint8(round(imcomplement(text2im([ 'Histo-resized' ]))*255));
% % % tx_mov=uint8(round(imcomplement(text2im([ 'refImg_unregistered' ]))*255));
% % % tx_war=uint8(round(imcomplement(text2im([ 'refImg_warped' ]))*255));
% % % 
% % % 
% % % % fixr(1:size(tx_fix,1),1:size(tx_fix,2))=tx_fix;
% % % movr(1:size(tx_mov,1),1:size(tx_mov,2))=tx_mov;
% % % warp(1:size(tx_war,1),1:size(tx_war,2))=tx_war;
% % % % ==============================================
% % % %
% % % % ===============================================
% % % 
% % % % v2=cat(3,fixr,movr,v2);
% % % % v3=cat(3,fixr,movr,v3);
% % % % v2=cat(3,movr,fixr,v2);
% % % % v3=cat(3,movr,fixr,v3);
% % % v2=cat(3,movr,warp,v2);
% % % v3=cat(3,movr,vh,v3);
% % % 
% % % r1=montageout(permute(v2,[1 2 4 3]));
% % % r2=montageout(permute(v3,[1 2 4 3]));
% % % % fg,imagesc(r1)
% % % % fg,imagesc(r2)
% % % % ==============================================
% % % %   write GIF
% % % % ===============================================
% % % % r1=montageout(permute(v2,[1 2 4 3]));
% % % % r2=montageout(permute(v3,[1 2 4 3]));
% % % 
% % % step=round(sizp(1)/10);
% % % val=90;
% % % r1(1:step:end,:)         =90;
% % % r1(:         ,1:step:end)=90;
% % % r2(1:step:end,:)         =90;
% % % r2(:         ,1:step:end)=90;
% % % 
% % % 
% % % tx=text2im([ 'SLICE'  numberstr '.mat'  ' (' sprintf('SL=%2.1f; a1=%2.1f; a2=%2.1f',parameter) ')' ]);
% % % tx=imcomplement(tx);
% % % tx2=uint8(  zeros([size(tx,1)  size(r1,2) 1])   )  ;
% % % tx2(:, 1:size(tx,2),1 )=round(tx.*255);
% % % 
% % % r1=[tx2; r1 ];
% % % r2=[tx2; r2 ];
% % % 
% % % 
% % % nameout=[outtag 'result' '.gif' ];
% % % fileout2=fullfile(outdir, nameout);
% % % dollop=1;
% % % while dollop==1
% % %     try
% % %         imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
% % %         imwrite(r2  ,fileout2,'gif','WriteMode','append');
% % %         disp('image written.');
% % %         dollop=0;
% % %     catch ME
% % %         uiwait(msgbox({ME.message '---> CLOSE IMAGE-VIEWER to proceed!!'},'ERROR','modal'));
% % %         %     try
% % %         %         imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
% % %         %         imwrite(r2  ,fileout2,'gif','WriteMode','append');
% % %         %         disp('image written.');
% % %         %     catch
% % %         %         disp('..could not write gif-image.')
% % %         %     end
% % %     end
% % % end
% % % fprintf('Done.\n');
% % % showinfo2('final image',fileout2);






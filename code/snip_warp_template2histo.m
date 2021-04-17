
function [s2]=warp_template2histo()

if 0
    
    file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_004.tif'

end
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
%%   namings
% ===============================================

[pa name ext]=fileparts(file);           %name: "'a1_004'"
numberstr    =regexprep(name,'.*_','_'); % such as '_004'

% ==============================================
%%   load best slice ...get paramter
% ===============================================

fib=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.mat'});
if exist(fib)~=2
    disp(['missing file: ' fib ]);
    return
end
s2=load(fib); s2=s2.s2;
parameter=s2.param;
% ==============================================
%%   get CV
% ===============================================
if exist('cv')~=1
    disp('...getting template');
    if 0
        [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
    end
    if 1
        [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
        [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
        cv=cv.*uint8(cvmask);
    end
end

% ==============================================
%%   
% ===============================================

% ==============================================
%%   elastix -setting
% ===============================================
% % % % --------PARAMETER SETTINGS----------------------------------------------------------------
% % % paelastix=fullfile(fileparts(which('ah.m')),'matlab_elastix');
% % % addpath(genpath(paelastix));

% ----------------------
pa_el=strrep(which('bart.m'),'bart.m','elastix2');
addpath(genpath(pa_el));

% ===============================================
p.approach =3 ;
savepath=fullfile(fileparts(file),'elx2' );
elxout=fullfile(savepath,['forward' numberstr]);
% ===============================================
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
        fullfile(pa_el, 'parameters_BSpline_default.txt') };
end


% copy files forward/backward
mkdir(elxout);
path_paramfile=fullfile(elxout,'params');
mkdir(path_paramfile)
% mkdir(elxout);
parfile=strrep(parfile0,pa_el,path_paramfile);                      %forward
% parfileinv=stradd(strrep(parfile0,pa_el,savepath),'inv',1);   %backward
for i=1:length(parfile)
    copyfile(parfile0{i},parfile{i}    ,'f');
%     copyfile(parfile0{i},parfileinv{i} ,'f')
end



% ==============================================
%%   get slice
% ===============================================

xx=parameter;
slicenum=xx(1);
X       =xx(2);
Y       =xx(3);
cent    =[size(cv,2)/2 size(cv,1)/2];
vol_center=[cent slicenum];
tatlas=uint8(obliqueslice(cv, vol_center, [Y -X 90]));



% ==============================================
%%   get histo
% ===============================================
fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
if exist(fir)~=2
    disp(['missing file: ' fir ]);
    return
end
s=load(fir); s=s.s;

% ==============================================
%%   register+warp
% ===============================================
tic
numresolutions            =[2 6]; %default [2 6]
MaximumNumberOfIterations =[250 3000]; %default[250 1500]
set_ix(parfile{1},'NumberOfResolutions',numresolutions(1)); %default:2
set_ix(parfile{2},'NumberOfResolutions',numresolutions(2)); %default:6

set_ix(parfile{1},'MaximumNumberOfIterations',MaximumNumberOfIterations(1)); %default:250
set_ix(parfile{2},'MaximumNumberOfIterations',MaximumNumberOfIterations(2)); %default:1500
disp('..warping...');




if 1
    % image to atlas-Size (320x456) before warping  (t=70s) -->ok!!!
    mov =tatlas;
    fix =imresize(s.img,[size(tatlas)]);
end
% atlas to image size (2000x2000) before warping  (t=90s) --> not that good!
if 0
    mov =imresize(tatlas,[size(s.img)]);
    fix =s.img;
end

[wa,outs]= elastix2(mov,fix,elxout,parfile(1:end),pa_el);
toc


% ==============================================
%   transformix
% ===============================================
%  outs.TransformParametersFname'
%      {'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\elx2\forward_004\TransformParameters.0.txt'}
%     {'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\elx2\forward_004\TransformParameters.1.txt'}
if 0
    pawork=pwd
    cd(fileparts(which('elastix.exe')))
    [wa2,log] = transformix(mov,elxout) ;
    cd(pawork)
    
end
% ==============================================
%   load tif
% ===============================================
ftif=fullfile(pa,['a1' numberstr '.tif']);
info=imfinfo(ftif);
% t=imread(ftif);
t2=imresize(t,[3000 3000]);
v =imresize(wa,[size(t2,1) size(t2,2)]);
imoverlay(t2(:,:,3),v);

% ==============================================
%%   other images
% ===============================================
tb0={...%Name__________INterpol
    'AVGT.nii'          1
    'AVGThemi.nii'      0
    'ANO.nii'           0
%     '_b1grey.nii'       0
   };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath

% ==============================================
%%   
% ===============================================
% [ msk]=p_getVol(fullfile(pa_template, 'AVGTmask.nii' )) ;


i=1
% ---------------------- get volume
[ w    ]=p_getVol(tb{i,1}) ;
% w=.*msk;
% ---------------------------- get slice
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
% w2=obliqueslice(w, vol_center, [Y -X 90],'Method','nearest');
% w3=obliqueslice(w, vol_center, [Y -X 90],'Method','linear' );

% ------------------------------ transformix
trafofile2=fullfile(elxout,'TransformParameters.1.txt')
set_ix(trafofile2,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500

pawork=pwd
cd(fileparts(which('elastix.exe')))
[w3,log] = transformix(w2,elxout) ;
cd(pawork)


if i==3
    imoverlay(fix,pseudocolorize(w3));gridder(20,'color','w');
else
    imoverlay(fix,w3);gridder(20,'color','w');
end


% ==============================================
%%   
% ===============================================

keyboard

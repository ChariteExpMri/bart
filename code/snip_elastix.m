


clear; cf
warning off;

timex0=tic;

% ==============================================
%%  default parameter 
% ===============================================
fiopt='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\optim_002.mat';
p.doplot   =1         ; % plot result
p.nbest    =50        ; %best n-results
p.cellsize =16        ; % HOG-cellSize (larger is more detailed)'
p.size     =[330 450] ; %resize image (current-atlas-size: 320x456)
p.nresolutions =[1 1 ]; %number of resolutions (val1): affine registration (val2) B-spline registration (values>1 takes longer but might be more precise)
% -------------------


% ==============================================
%%   
% ===============================================
pa_template=strrep(which('bart.m'),'bart.m','templates');
if isempty(which('@slicedetection.m')) %set paths
    pabart=fileparts(which('bart.m'));
    addpath(pabart);
    addpath(genpath( fullfile(fileparts(which('bart.m')),'slicedetection')  ));
end
% ==============================================
%% get optim-mat
% ===============================================
ss=load(fiopt);
ss=ss.ss;

% ==============================================
%%   get ATLAS and mask by Atlasmask
% ===============================================
%  [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
[ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
[ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
cv=cv.*uint8(cvmask); 

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
savepath=fullfile(fileparts(fiopt),'elx' );
elxout=fullfile(savepath,'forward');
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
mkdir(savepath);
% mkdir(elxout);
parfile=strrep(parfile0,pa_el,savepath);                      %forward
parfileinv=stradd(strrep(parfile0,pa_el,savepath),'inv',1);   %backward
for i=1:length(parfile)
    copyfile(parfile0{i},parfile{i}    ,'f');
    copyfile(parfile0{i},parfileinv{i} ,'f')
end
% ==============================================
%%   remove contents of elxout
% ===============================================
%% 
% which_dir = elxout;
% dinfo = dir(which_dir);
% dinfo([dinfo.isdir]) = [];   %skip directories
% filenames = fullfile(which_dir, {dinfo.name});
% try; delete( filenames{:} ); end
% [~,dum2]=fileparts(which_dir);
% % if length(dir(which_dir))-2 ==  0; % disp([dum2 '-DIR is empty']);
% % else;                               disp([dum2 '-DIR is NOT empty']);
% % end




cprintf([0 .5 0],['  ..dT-prereq: ' sprintf('%2.2f',toc(timex0)/60)  ' min\n']);

% ==============================================
%%  [2] REGISTER NOW+warp
% tic
% [wa,outs]= elastix(mov,fix,elxout,parfile(1:end));
% toc
% imoverlay(wa,fix); %title([  ' warped AVGT to Histo'],'fontsize',8,'interpreter','none');
% 
% ==============================================
%  parfor  slice wise
% siz=[200 200];
%n=20; parfor:  undefined threats ('all') :  2.8333min for 20 slices, 2.6667min, threds undefined
%n=20; parfor:             with 1 threat  :97.162214 seconds. !!!! [4.85s per IMG]
% ===============================================
%   paramteter
% ===============================================
% p.nbest    =20        ; %best n-results
% p.cellsize =16        ; % HOG-cellSize (larger is more detailed)'
% p.size     =[330 450] ; %resize image (current-atlas-size: 320x456)
% p.nresolutions =[1 1 ]; %number of resolutions (val1): affine registration (val2) B-spline registration (values>1 takes longer but might be more precise)
% -------------------
n        = p.nbest;
cellsize = p.cellsize;
siz      = p.size;
numresolutions=p.nresolutions;


if 0
    n=20;
    cellsize=16;
    siz=[330 450];
    numresolutions=[1 1];
end

n=min(size(ss.s,1),n); %check if less lokal optima exists than expected
% ===============================================

% --------------
set_ix(parfile{1},'NumberOfResolutions',numresolutions(1)); %default:4
set_ix(parfile{2},'NumberOfResolutions',numresolutions(2)); %default:6
disp('..warping...')
% -------------- make outputPATHS for parfor 
% pawork=pwd;
% cd(pa_el);
elsPathList={};
for i=1:n
    elsPathList{i,1} = [elxout '_' pnum(i,3) ];
    mkdir(elsPathList{i});
end
% --------------PRE-ALLOCATE
q=zeros([siz n]);  
[met1 met2]=deal(nan(n,1));
% --------------finalize fixed-image     
fix    =imresize(double(ss.img),[siz]);
hog_hi = vl_hog(single(fix),cellsize);
fix=uint8(fix);

poolobj = gcp;
 addAttachedFiles(poolobj,{'readWholeTextFile.m' ,'elastix2.m'});%,'elastix.m'
timexWarp=tic;
parfor i=1:n%10
    
    xx=ss.s(i,:)
    slicenum=xx(1);   X=xx(2);  Y=xx(3);
    cent    =[size(cv,2)/2 size(cv,1)/2];
    vol_center=[cent slicenum];
    d=uint8(obliqueslice(cv, vol_center, [Y -X 90]));
    
%     mov=double(d);%.*double((d>30));
    mov=double(d).*double((d>30));
    mov=imresize(mov,[siz]);
        
      mov=uint8(mov);
%       fix=uint8(fix);
    
    % ----------------------------
    elxout3=elsPathList{i};
    [wa,outs]= elastix2(mov,fix,elxout3,parfile(1:end),pa_el ,struct('threads',1));
    %[wa,outs]=  elastix(mov,fix,elxout3,parfile(1:end),struct('threads',1));
    %     [wa outs] = snip_parfor(mov,fix,elxout3,parfile)
    q(:,:,i)=wa;
    

    
    %----HOG
    hog_at= vl_hog(single(wa ),cellsize);
    hog_diff=hog_hi-hog_at;
    met1(i,:)=norm(reshape(hog_diff,1,numel(hog_diff)));
    
    %---MI-------
    lg=outs.log;
    ix=max(regexpi2(lg,'Time spent in resolution 0 (ITK initialisation'));
    row=str2num(char(lg(ix-1)));
    val=row(2);
    met2(i,:)=val ;%row;
    
end

cprintf([0 .5 0],['  ..dT-warping: ' sprintf('%2.2f',toc(timexWarp)/60)  ' min\n']);
cprintf([0 .5 0],['  ..dt-total  : ' sprintf('%2.2f',toc(timex0)/60)  ' min\n']);
% ==============================================
%%   remove warping dirs
% ===============================================
for i=1:length(elsPathList)
    if exist(elsPathList{i})==7
        rmdir(elsPathList{i},'s');
    end
end


% ==============================================
%%   plot result
% ===============================================
min1=min(find(met1==min(met1))); % HOG
min2=min(find(met2==min(met2))); % MI
if p.doplot==1
    % norm
    norma=[normalize01(met1) normalize01(met2)];
    met3=sqrt(sum([norma(:,1).^2 norma(:,2).^2],2));
    min3=min(find(met3==min(met3)));
     
    
    fg;
    msg1=['HOG (ix:' num2str(min1) ')'  sprintf('%2.2f ',ss.s(min1,:)) ];
    msg2=['MI  (ix:' num2str(min2) ')' sprintf('%2.2f ',ss.s(min2,:))];
    msg3=['RMS(MI,HOG  (ix:' num2str(min3) ')' sprintf('%2.2f ',ss.s(min3,:))];
    subplot(2,2,1); plot(met1,'-r.'); title(msg1,'fontsize',8);
    subplot(2,2,2); plot(met2,'-b.'); title(msg2,'fontsize',8);
    subplot(2,2,3);plot(met3,'-b.'); title(msg3,'fontsize',8);
    
    disp(['metric-solution-Idx' fprintf('%d ',[min1 min2 min3])]);
    imoverlay(q(:,:,min1),imadjust(mat2gray(fix))); title(msg1,'fontsize',8);
    imoverlay(q(:,:,min2),imadjust(mat2gray(fix))); title(msg2,'fontsize',8);
    imoverlay(q(:,:,min3),imadjust(mat2gray(fix))); title(msg3,'fontsize',8);
end


% ==============================================
%%   save result
% ===============================================
disp( 'saving results: ["warp.mat"]');
ss.sep1 ='-----warping';
ss.q    =single(q);
ss.hog  =met1;
ss.mi   =met2;
ss.hi   =single(fix);

[pas name ext]=fileparts(fiopt)
nameshort=[strrep(name,'optim_', 'warp_') '.mat'];
fiout=fullpath(pas,nameshort);

disp(['..storing warped-solution(s) ["'  nameshort '"]']);
save(fiout,'ss');







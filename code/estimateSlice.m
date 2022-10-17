
function estimateStlice(p0)
% cf; 
warning off
% ==============================================
%%   struct-parameter
% ===============================================


p.file         ='';
% p.channel           = 3;
p.usemanualrotation = 1;
p.method         = 2   ;   %[1]multistart [2] surrogate
p.numIterations  = 500 ;  %surrogate-only
p.numStartpoints = 100 ;    % number of starting points (recom: 100)


p.parallel       = 1   ;    % use parallell-comp
p.cellsize       = 4   ;    % HOG-cellSize (larger is rougher/smoother)
p.useSSIM        = 1   ;   % use Multiscale structural similarity' 
p.doflt          = 1   ;    % gaus filt altas slice after extraction from 3dvol
% -------------------
p.plot           = 1   ;    % plot update for each iteration (slow)
p.plotresult     = 1   ;    % plot result best "solution" (image)
%-----------
% p.plan1_x0= [200   0   0  ];  % PLAN1: best guess (slice, pitch, yaw)
p.plan1_LB= [80    0   0  ];  % PLAN1: lower boundaries (slice, pitch, yaw)
p.plan1_UB= [400   0   0  ];  % PLAN1: upper boundaries (slice, pitch, yaw)
%-----------
% p.plan2_tol=40;               % PLAN2 +/- slice-tolerance
p.plan2_x0= [nan    0    0   ];  % PLAN2: best guess (slice, pitch, yaw)
p.plan2_LB= [nan  -25   -5  ];  % PLAN2: lower boundaries (slice, pitch, yaw)
p.plan2_UB= [nan  +25   +5  ];  % PLAN2: upper boundaries (slice, pitch, yaw)


p=catstruct(p,p0);


% ==============================================
%%   parameter
% ===============================================

% file='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\a1_001.tif'
% file='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\a1_002.tif'

file       =  p.file;
% pa_template=  strrep(which('bart.m'),'bart.m','templates');
global ak
pa_template=ak.template;

totTime=tic; %TIMER

numberstr    =regexprep(file,{'.*_' '.tif'},{'_' ''})  ;  % such as '_001'
% ==============================================
%%   set up vlfeat-TBX
% ===============================================
if exist('vl_hog')~=3
    %run('vlfeat-0.9.21/toolbox/vl_setup.m')
    run(fullfile(strrep(which('bart.m'),'bart.m', 'vlfeat-0.9.21'),'toolbox/vl_setup.m' ))
end
if isempty(which('@slicedetection.m')) %set paths
    pabart=fileparts(which('bart.m'))
    addpath(pabart);
    addpath(genpath( fullfile(fileparts(which('bart.m')),'slicedetection')  ));
end





if 0
    % ==============================================
    %%   get resampled image &  mask of histoslice
    % ===============================================
    %     pres=struct( );
    %     pres.doplot=0; %plot image to screen
    %     pres.chan  =3; % blue channel for dapi?
    %     pres.useRot=1; %useRotationInfo
    [pas,name ext]=fileparts(file);
    
    fib=fullfile(pas,['a2' numberstr '.mat']);
    if exist(fib)~=2
        return
    end
    s=load(fib);
    s=s.s;
    if isa(s.img,'double')==0
        s.img=double(s.img);
    end
    
%     keyboard
%     
%     pres.doplot  = 0; %plot image to screen
%     pres.chan    = p.channel;
%     pres.useRot  = p.usemanualrotation;
%     [f00 s] = p_resizetif3(file,[2000 2000],pres);
end
% ==============================================
%%      change image rotation
% ===============================================
if 0
    [pas,name ext]=fileparts(file);
    modfile=fullfile(pas, [strrep(name,'a1_','a2_') 'mod.tif']);
    if exist(modfile)==2
        disp(['...modififaction found: ' modfile] );
        im=imread(modfile);
        [maskfile,brainfile]=clean_data_function2(im);
        s.img=brainfile;
        s.mask=maskfile;
        s.ismodified=1;
        save(f00,'s');
        [~,matname,ext]=fileparts(f00);
        disp(['..saved modififaction in: ' [matname,ext] ]);
    end
end


% ==============================================
%%   get subject-histoslice
% ===============================================
[pat name ext]=fileparts(file);
filename2=fullfile(pat,[ strrep(name,'a1_','a2_') '.mat']);
s=load(filename2); s=s.s;

% ==============================================
%%   modified version (pruning)
% ===============================================
modfile=fullfile(pat,[ strrep(name,'a1_','a2_') 'mod.tif']);
if exist(modfile)==2
   d=imread(modfile) ;
    
   [maskfile,brainfile]=clean_data_function2(d);
   s.img=brainfile;
   s.mask=maskfile;
   %s.mask=uint8(s.img>0);
end

% ==============================================
%%   get histoVolume
% ===============================================
% p.useHistVol=0;
if p.useHistVol==1
    [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
    disp(['Template: HISTOVOL']);
else
    if 1
        [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
        [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
        cv=cv.*uint8(cvmask);
        disp(['Template: AVGT']);
    end
end

if isfield(s,'hemi')==1
    [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGThemi.nii' )) ;
    if strcmp(lower(s.hemi),'r') || strcmp(lower(s.hemi),'right') || strcmp(lower(s.hemi),'R')
        cvmask=single(cvmask==2);
        %cv=cv.*uint8(cvmask);
    elseif strcmp(lower(s.hemi),'l') || strcmp(lower(s.hemi),'left') || strcmp(lower(s.hemi),'L')
        cvmask=single(cvmask==1);
        %cv=cv.*uint8(cvmask);
    end
end

%———————————————————————————————————————————————
%%  using  FIB
%———————————————————————————————————————————————
if 0
    fb     =p_getfromHistvolspace(fullfile(pa_template, 'FIBT.nii' )) ;
    cvmask =p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
    fb=(fb./max(fb(:)))*100;
    fb=fb+cvmask;
    p2.fb=single(fb);
end

if exist('cvmask')==0
    cvmask =p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
    cvmask=single(cvmask>0);
end
cv=uint8(cvmask).*cv; %IMPORTANT TO MASK HISTOVOLUME!



% ==============================================
%%   filter HISTO-SLICE
% ===============================================
if p.filterHisto==1
    isrounded=any((s.img(:))==round(s.img(:)));
    maxval=max(s.img(:));
    s.img=imadjust(mat2gray(s.img));
    
    
    
    if  regexpi(p.filterHistoParam,'^m')==1
        wid=str2num(regexprep(p.filterHistoParam,'m',''));
        s.img=medfilt2(s.img,[wid wid]);
    elseif  regexpi(p.filterHistoParam,'^g')==1
        wid=str2num(regexprep(p.filterHistoParam,'g',''));
        s.img=imgaussfilt(s.img,[wid]);
    end
    if isrounded==1
        s.img=round(s.img.*double(maxval));
    end
    
end



% ==============================================
%%  1) METHOD: MULTISTART
% ===============================================
if p.method==1 || p.method==3
% ============================================================================================
%%   PLAN-1 : find slice
% =============================================================================================

timeplan1=tic;

p2.method          =p.method           ;%used method
p2.parallel       = p.parallel         ;% use parallell-comp
p2.cellsize       = p.cellsize         ;% HOG histogram (larger is finer scaled  )
p2.useSSIM        = p.useSSIM;
p2.numStartpoints = p.numStartpoints   ;% number of starting points (recom: 100)
p2.doflt          = p.doflt            ;% gauss-filt altas slice after extraction from 3dvol
p2.plot           = p.plot             ;% plot update for each iteration (slow)
p2.plotresult     = 0;%p.plotresult       ;% plot result best "solution" (image)

if p.method==1
    x0=mean([p.plan1_LB; p.plan1_UB],1);
    LB=p.plan1_LB;
    UB=p.plan1_UB;
    
    plan1=[x0; LB; UB];
    p2.planno=1;
    [xx1,fvel1,flag1,outp1,solx1,imgout]=func_call_angles5(s, cv,plan1,  p2 );
    best1=[xx1 fvel1] ;%-198.4362
    sol1=[cell2mat({solx1.X}') [solx1.Fval]'];
    
    if p.plotresult==1
        %plotslice(xx1,fvel1,cv, s.img,{p.file ['PLAN-1']});
        %plotslice(xx1,fvel1,cv, s.img,{p.file ['PLAN-1']},sol1);
    end
else
    % ==============================================
    %%   METHOD-3
    % ===============================================
    %---SLICE---------------------
    LB=[p.plan1_LB(1) 0 0];     UB=[p.plan1_UB(1) 0 0];  x0=mean([LB;UB],1); plan1=[x0; LB; UB];
    p2.planno=1;
    p2.method=1;
    [xx1,fvel1,flag1,outp1,solx1,imgout]=func_call_angles5(s, cv,plan1,  p2 );
    %---ANGLE-pitch-----------------
    slice=round(xx1(1));
    LB=[slice -15 0];     UB=[slice 15 0];  x0=mean([LB;UB],1); plan1=[x0; LB; UB];
    [xx1,fvel1,flag1,outp1,solx1,imgout]=func_call_angles5(s, cv,plan1,  p2 );
    %---ANGLE-yaw-----------------
    pitch=round(xx1(2));
    LB=[slice pitch-10 -15];     UB=[slice pitch+10 15];  x0=mean([LB;UB],1); plan1=[x0; LB; UB];
    [xx1,fvel1,flag1,outp1,solx1,imgout]=func_call_angles5(s, cv,plan1,  p2 );
    %--------------------
    %---AGGREGATE PARAMETER-----------------
    pitch2=round(xx1(2));
    yaw   =round(xx1(3));
    
    LB=[slice-20 pitch-10 yaw-10];   
    UB=[slice+20 pitch+10 yaw+10];  
    x0=mean([LB;UB],1); 
    plan1=[x0; LB; UB];
    [xx1,fvel1,flag1,outp1,solx1,imgout]=func_call_angles5(s, cv,plan1,  p2 );
    
    best1=[xx1 fvel1] ;%-198.4362
    sol1=[cell2mat({solx1.X}') [solx1.Fval]'];
    
    if p.plotresult==1
        %plotslice(xx1,fvel1,cv, s.img,{p.file ['PLAN-1']});
        %plotslice(xx1,fvel1,cv, s.img,{p.file ['PLAN-1']},sol1);
    end
    
end




% one run only
xx   =xx1;
best2=xx1;
xx2  =xx1;
fvel =fvel1;
outp=outp1;
sol2=[cell2mat({solx1.X}') [solx1.Fval]'];
plan2=plan1;
% histview(cv,sol2(1,:))
cprintf([0 1 1],[' TIME_PLAN-1 (min): [' num2str(toc(timeplan1)/60) ']  '  '\n']);
% ============================================================================================
%%   plan2
% =============================================================================================
if 0
    timeplan2=tic;
    if 0
        tol=40;
        x0=[best1(1)        5   0  ];
        LB=[best1(1)-tol  -25  -6  ];
        UB=[best1(1)+tol  +25  +6  ];
        plan2=[x0; LB; UB];
    end
    
    x0=p.plan2_x0;
    LB=p.plan2_LB;
    UB=p.plan2_UB;
    plan2=[x0; LB; UB];
    plan2(:,1)=[best1(1) best1(1)-p.plan2_tol  best1(1)+p.plan2_tol]';
    
    if 0
        [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
        [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
        cv2=cv.*uint8(cvmask);
        disp(['Template: AVGT']);
    end
    
    %  cv2=uint8(smooth3(cv,'box',3));
    %cv2=cv;
    %  cv2=uint8(imgaussfilt3(cv,1));
    % s2.img=imadjust(imgaussfilt(imadjust(s.img),3));
    % [xx sol]=func_call_angles4(s2, cv,plan2,struct('parallel',1,'cellsize',16) );%!!!!
    % [xx,fvel,flag,outp,sol]=func_call_angles4(s, cv2,plan2,struct('parallel',1,'cellsize',25) );%!!!!
    p2.planno=1;
    [xx,fvel,flag,outp,sol]=func_call_angles5(s, cv,plan2,p2);%!!!!
    
    
    best2=xx;
    xx2  =xx;
    sol2=[cell2mat({sol.X}') [sol.Fval]'];
    % histview(cv,sol2(1,:))
    cprintf([0 1 1],[' TIME_PLAN-2 (min): [' num2str(toc(timeplan2)/60) ']  '  '\n']);
end

elseif p.method==2
    % ==============================================
    %% surrogate
    % ===============================================
    timeplan1=tic;
    
    p2.method          =p.method           ;%used method
    p2.numIterations   =p.numIterations;

    p2.parallel       = p.parallel         ;% use parallell-comp
    p2.cellsize       = p.cellsize         ;% HOG histogram (larger is finer scaled  )
    p2.useSSIM        = p.useSSIM;
    p2.numStartpoints = p.numStartpoints   ;% number of starting points (recom: 100)
    p2.doflt          = p.doflt            ;% gauss-filt altas slice after extraction from 3dvol
    p2.plot           = p.plot             ;% plot update for each iteration (slow)
    p2.plotresult     = 0;%p.plotresult       ;% plot result best "solution" (image)
    
    
    %x0=p.plan1_x0;
    LB=p.plan1_LB;
    UB=p.plan1_UB;
    x0=mean([LB;UB],1);
    
    plan1=[x0; LB; UB];
    p2.planno=1;
    
    [xx,fvel,flag,outp,sol]=func_call_angles5(s, cv,plan1,  p2 );
    best2=xx;
    xx2  =xx;
    sol2=sortrows([cell2mat({sol.X}') [sol.Fval(:)]],4);
    sol3=sol2;
    sol4=sortrows([cell2mat({sol.X}') [sol.Fval(:)]],1);
    
    if size(sol4,1)>100
        %% ===============================================
        sor=round(sol4(:,1:3));
        uni=unique(sor(:,1));
        sol5=[];
        for i=1:length(uni)
            is=find(sor(:,1)==uni(i));
            is2=min(find(sol4(is,4)==min(sol4(is,4))));
            sol5(end+1,:)=sol4(is(is2),:);
        end
        ip=peakfinder(sol5(:,4),(max(sol5(:,4))-min(sol5(:,4)))/6 ,mean(sol5(:,4)),-1);
        sol4=sortrows(sol5(ip,:),4);
        % length(ip)
        %% ===============================================
    end
    sol2=sol4;
    
%     ix=peakseek(-sol4(:,4),5);
%     sol2=sortrows(sol4(ix,:),4);
%     if size(sol2,1)>100  %reduce table to most likely
%         sol2=sol2(1:100,:);
%     end
    
    plan2=plan1;
    
end

% ==============================================
%%   plot result
% ===============================================


if p.plotresult==1
    if exist('sol3')==1
        plotslice(xx2,fvel,cv, s.img,{p.file ['PLAN-2']},sol3);
    else
        plotslice(xx2,fvel,cv, s.img,{p.file ['PLAN-2']},sol2);
    end
end

cprintf([0 1 1],[' TIME_PLAN-total (min): [' num2str(toc(timeplan1)/60) ']  '  '\n']);

% ============================================================================================
%%   save result
% =============================================================================================
if 1
    [pas name ext]=fileparts(file);
    ss.file=file;
    ss.outp =outp;
    ss.s    =sol2;
    ss.sb   =[xx fvel];
    ss.plan2=plan2;
    ss.p    =p;
    ss.img  =s.img;
    ss.mask =s.mask;
    
    %     ss.xx1  =xx1;
    %     ss.s=sortrows([ss.s;best1],4);
    
    ss.info={...
        'ss.outp: optimizer output';
        'ss.s:    all solutions, ordered';
        'ss.sb:   best solution';
        'ss.plan2: last plan'
        'ss.p:   paramter;'
        'ss.img:  slice(s.img)'
        'ss.mask: mask(s.img)'
        'ss.xx1:  planA solution'
        };
    
    nameshort=[strrep(name,'a1_','optim_') '.mat'];
    fiout=fullpath(pas,nameshort);
    disp(['..storing solution(s) ["'  nameshort '"]']);
    save(fiout,'ss');
    
end

cprintf([0 0 1],[' TIME_total (min): [' num2str(toc(totTime)/60) ']  '  '\n']);
cprintf([0 .5 0],[' DONE'  '\n']);

% ==============================================
%%   EOF
% ===============================================

return




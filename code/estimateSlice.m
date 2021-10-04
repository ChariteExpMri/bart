
function estimateStlice(p0)
% cf; 
warning off
% ==============================================
%%   struct-parameter
% ===============================================


p.file         ='';
% p.channel           = 3;
p.usemanualrotation = 1;

p.parallel       = 1   ;    % use parallell-comp
p.cellsize       = 4   ;    % HOG-cellSize (larger is rougher/smoother)
p.useSSIM        = 1   ;   % use Multiscale structural similarity' 
p.numStartpoints = 100 ;    % number of starting points (recom: 100)
p.doflt          = 1   ;    % gaus filt altas slice after extraction from 3dvol
% -------------------
p.plot           = 1   ;    % plot update for each iteration (slow)
p.plotresult     = 1   ;    % plot result best "solution" (image)
%-----------
p.plan1_x0= [200   0   0  ];  % PLAN1: best guess (slice, pitch, yaw)
p.plan1_LB= [80    0   0  ];  % PLAN1: lower boundaries (slice, pitch, yaw)
p.plan1_UB= [400   0   0  ];  % PLAN1: upper boundaries (slice, pitch, yaw)
%-----------
p.plan2_tol=40;               % PLAN2 +/- slice-tolerance
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

%———————————————————————————————————————————————
%%  using  FIB
%———————————————————————————————————————————————
fb     =p_getfromHistvolspace(fullfile(pa_template, 'FIBT.nii' )) ;
cvmask =p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
fb=(fb./max(fb(:)))*100;
fb=fb+cvmask;     
p2.fb=single(fb);


cv=uint8(cvmask).*cv; %IMPORTANT TO MASK HISTOVOLUME!

% ==============================================
%%   optimize test
% ===============================================
[pat name ext]=fileparts(file);
filename2=fullfile(pat,[ strrep(name,'a1_','a2_') '.mat']);
s=load(filename2); s=s.s;

% ==============================================
%%   modified version (pruning)
% ===============================================
modfile=fullfile(pat,[ strrep(name,'a1_','a2_') 'mod.tif'])
if exist(modfile)==2
   d=imread(modfile) ;
    
   [maskfile,brainfile]=clean_data_function2(d);
   s.img=brainfile;
   s.mask=maskfile;
   %s.mask=uint8(s.img>0);
   
    
end




if 0
    % ==============================================
    %%   PARAMS
    % ===============================================
    p.parallel       = 1   ;    % use parallell-comp
    p.cellsize       = 16  ;    % HOG histogram (larger is finer scaled  )
    p.numStartpoints = 100 ;    % number of starting points (recom: 100)
    p.doflt          = 1   ;    % gauss-filt altas slice after extraction from 3dvol
    % -------------------
    p.plot           = 1   ;    % plot update for each iteration (slow)
    p.plotresult     = 1   ;    % plot result best "solution" (image)
    
    x0=[200   0   0  ];
    LB=[80    0   0  ];
    UB=[400   0   0  ];
    plan1=[x0; LB; UB];
end

% ============================================================================================
%%   PLAN-1 : find slice
% =============================================================================================

timeplan1=tic;


p2.parallel       = p.parallel         ;% use parallell-comp
p2.cellsize       = p.cellsize         ;% HOG histogram (larger is finer scaled  )
p2.useSSIM        = p.useSSIM;
p2.numStartpoints = p.numStartpoints   ;% number of starting points (recom: 100)
p2.doflt          = p.doflt            ;% gauss-filt altas slice after extraction from 3dvol
p2.plot           = p.plot             ;% plot update for each iteration (slow)
p2.plotresult     = 0;%p.plotresult       ;% plot result best "solution" (image)


x0=p.plan1_x0;
LB=p.plan1_LB;
UB=p.plan1_UB;

plan1=[x0; LB; UB];
p2.planno=1;
% xx=func_call_angles5(s, cv,plan1,  struct('parallel',0,'cellsize',16) );
[xx1,fvel1,flag1,outp1,solx1]=func_call_angles5(s, cv,plan1,  p2 );
best1=[xx1 fvel1] ;%-198.4362
sol1=[cell2mat({solx1.X}') [solx1.Fval]'];
%     outp1


if p.plotresult==1
    plotslice(xx1,fvel1,cv, s.img,{p.file ['PLAN-1']});
end


cprintf([0 1 1],[' TIME_PLAN-1 (min): [' num2str(toc(timeplan1)/60) ']  '  '\n']);

% ============================================================================================
%%   plan2
% =============================================================================================
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

if p.plotresult==1
    plotslice(xx2,fvel,cv, s.img,{p.file ['PLAN-2']});
end

cprintf([0 1 1],[' TIME_PLAN-2 (min): [' num2str(toc(timeplan2)/60) ']  '  '\n']);

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




% p_pipelnine
clear; cf
% cd('C:\Users\skoch\Desktop\release_2')
% addpath('C:\Users\skoch\Desktop\release_2\codes')
% ==============================================
%%   parameter
% ===============================================

% filename='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\a1_001.tif'
filename='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB\a1_002.tif'

pa_template=strrep(which('bart.m'),'bart.m','templates')

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



% filename='C:\Users\skoch\Desktop\histo_\out_005.tif'


if 1
    % ==============================================
    %%   resample+make mask of histoslice
    % ===============================================
    pres=struct( );
    pres.doplot=0; %plot image to screen
    pres.chan  =3; % blue channel for dapi?
    pres.useRot=1; %useRotationInfo
    [f00 s] = p_resizetif3(filename,[2000 2000],pres);
end
    % ==============================================
    %% change imgae
    % ===============================================
if 1    
    [pas,name ext]=fileparts(filename);
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
    [ cv]=p_getHIstvol(fullfile(pa_template, 'HISTOVOL.nii' ),1) ;
      
     if 0
      [ cv    ]=p_getHIstvol(fullfile(pa_template, 'AVGT.nii' ),0) ;
      [ cvmask]=p_getfromHistvolspace(fullfile(pa_template, 'AVGTmask.nii' )) ;
      cv=cv.*uint8(cvmask);
     end
      
      

totTime=tic;

% ==============================================
%%   optimize test
% ===============================================
[pat name ext]=fileparts(filename);
filename2=fullfile(pat,[ strrep(name,'a1_','a2_') '.mat']);
s=load(filename2); s=s.s;



% ==============================================
%%   PARAMS
% ===============================================
p.parallel       = 1   ;    % use parallell-comp
p.cellsize       = 16  ;    % HOG histogram (larger is finer scaled  )
p.numStartpoints = 100 ;    % number of starting points (recom: 100) 
p.doflt          = 1   ;    % gaus filt altas slice after extraction from 3dvol
% -------------------
p.plot           = 1   ;    % plot update for each iteration (slow)
p.plotresult     = 1   ;    % plot result best "solution" (image)

% ==============================================
%%   PARAMS-2
% ===============================================

if 1
    % ==============================================
    %%   plan1: find slice
    % ===============================================
    x0=[200   0   0  ];
    LB=[80    0   0  ];
    UB=[400   0   0  ];
    plan1=[x0; LB; UB];
    % xx=func_call_angles5(s, cv,plan1,  struct('parallel',0,'cellsize',16) );
    [xx1,fvel1,flag1,outp1,solx1]=func_call_angles5(s, cv,plan1,  p );
    best1=[xx1 fvel1] ;%-198.4362
    sol1=[cell2mat({solx1.X}') [solx1.Fval]'];
    outp1
end
% best1=[362   -18    -1 20]

% return
% ==============================================
%%   plan2                                       BEST-f: 11.3867-198.4362      2.620244      
% ===============================================
tol=40;
% tol=20;
%  tol=12;
x0=[best1(1)        5   0  ];
LB=[best1(1)-tol  -25  -6  ];
UB=[best1(1)+tol  +25  +6  ];
plan2=[x0; LB; UB];

 cv2=uint8(smooth3(cv,'box',3)); 
%  cv2=uint8(imgaussfilt3(cv,1));
% s2.img=imadjust(imgaussfilt(imadjust(s.img),3));
% [xx sol]=func_call_angles4(s2, cv,plan2,struct('parallel',1,'cellsize',16) );%!!!!
% [xx,fvel,flag,outp,sol]=func_call_angles4(s, cv2,plan2,struct('parallel',1,'cellsize',25) );%!!!!

[xx,fvel,flag,outp,sol]=func_call_angles5(s, cv2,plan2,p);%!!!!


best2=xx
xx2=xx;
sol2=[cell2mat({sol.X}') [sol.Fval]'];
% histview(cv,sol2(1,:))


% cprintf([0 0 1],[' TOTALTIME (min): [' num2str(toc(totTime)/60) ']  '  '\n']);

% ==============================================
%%   save result
% ===============================================
if 1
    [pas name ext]=fileparts(filename);
    ss.filename=filename;
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

% ==============================================
%%   EOF
% ===============================================

return




















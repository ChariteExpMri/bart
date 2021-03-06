

function [xx,fvel,exitflag,output,solutions,imgout]=func_call_angles5(s, cv,plan,p0)


% ==============================================
%%   PARAMS
% ===============================================
p.method         = 2   ; %used method [1]multistart [2] surrogate
p.parallel       = 0   ;    % use parallell-comp
p.cellsize       = 16  ;    % HOG histogram (larger is finer scaled  )
p.numStartpoints = 5   ;    % number of starting points (recom: 100)
p.doflt          = 0   ;    % gaus filt altas slice after extraction from 3dvol
% -------------------
p.plot           = 1   ;    % plot update for each iteration (slow)
p.plotresult     = 1   ;    % plot result best "solution" (image)

% ==============================================
%%
% ===============================================

if exist('p0')==1
    warning off;
    p = catstruct(p,p0);
end
if exist('plan')==0
    plan=[];
end
% ==============================================
%%
% ===============================================
res.tb=[];
res.best=[];

% counts=1;
imgout={};
% ==============================================
%%
% ===============================================
% previous version : func_call_angles3/func_call_angles4
%


if exist('vl_hog')~=3
    %run('vlfeat-0.9.21/toolbox/vl_setup.m')
    run(fullfile(fileparts(which('bart.m')), 'vlfeat-0.9.21/toolbox/vl_setup.m' ));
    
end


%% ===fill params================================================================================================
experimental_file =s.img;
maskfile          =s.mask;
% cellsize          =p.cellsize;
% useSSIM           =p.useSSIM;

%% ===================================================================================================
p3=p;
try; p3=rmfield(p3,{'fb'}); end



%% ===================================================================================================

if 1    %RESIZE SLICE TO ATLAS  (320   456   528)
    %sim=[320   456]; %original:16min
    sim=[size(cv,1) size(cv,2)];
    %         %--------ROTATE
    %         if 0
    %             experimental_file =imrotate(experimental_file,2);
    %             maskfile          =imrotate(maskfile,2);
    %         end
    
    maskfile           =imresize(maskfile,[sim],'nearest');
    experimental_file  =imresize(experimental_file,[sim],'bilinear');
    
    %cv=imresize(cv,[sim],'bilinear');
end



timeTot=tic;

% ==============================================
%%   only slice: 173.3321
% ===============================================
% x0=[200   0   0  ];
% LB=[80    0   0  ];
% UB=[400   0   0  ];

if exist('plan')==1 && ~isempty(plan)
    cprintf([0 0 1], '*** using plan: \n');
    disp(plan);
    x0=plan(1,:);
    LB=plan(2,:);
    UB=plan(3,:);
else
    disp('expected plan:  [3x3 matrix]; for searching problem (start-value+boundary)  ');
    disp(' column-1 : slices  ');
    disp(' column-2 : up-down angle (PITCH) ');
    disp(' column-3 : left-right angle (YAW) ');
    disp(' row-1  : starting value (between LB and UB)  ');
    disp(' row-2 : min-value (lower boundary; LB)');
    disp(' row-3 : max-value (upper boundary; UB)');
    error('PLAN is MISSING');
end

% if 0
%     opts=psoptimset('maxiter',1000,'Display','final','UseParallel',0)
%     %         );%,'Display' ,'iter');
%     % % 'CompletePoll', 'on','SearchMethod', 'GSSPositiveBasisNp1'
%     % [xx ]= fminsearchbnd(@func_y_opim,x0,LB,UB,opts)%,options,varargin)
%     % [xx ]= fminbnd(@func_y_opim,LB,UB,opts)%,options,varargin)
%     xx = patternsearch(@func_y_opim,x0,[],[],[],[],LB,UB,[],opts)
% end
% opts=optimoptions('maxiter',1000,'Display','final','UseParallel',0,...
%         'Algorithm','interior-point' )

% opts = optimoptions(@fmincon,'Algorithm','interior-point');
% optimizer='active-set';
 %optimizer='active-set';
 %optimizer='interior-point';
optimizer='sqp';
opts = optimoptions(@fmincon,'Algorithm',optimizer);



opts.MaxIterations=10050;
% opts.Display='iter'
opts.OptimalityTolerance= 1e-14;
% opts.ConstraintTolerance=1e-9;
% opts.FiniteDifferenceStepSize=1e-9
if 1
    %opts.FiniteDifferenceStepSize=1e-9
    opts.OptimalityTolerance=.1;
    opts.StepTolerance=.1;
    % opts.ConstraintTolerance=.1;
end
if 0
   opts.ConstraintTolerance=1e-9; 
   opts.FinDiffRelStep=1
   opts.FiniteDifferenceStepSize=1;
end


if 0
    optimizer='sqp';
    %   opts = optimoptions(@fmincon,'Algorithm',optimizer,'Display','iter', 'FiniteDifferenceStepSize', 5,...
    %             'OptimalityTolerance', 1e-10, 'UseParallel',true);
    opts = optimoptions(@fmincon,'Algorithm',optimizer,'OptimalityTolerance', 1e-10);
end
% cprintf([1 0 1],['  optimizer  : ' optimizer '\n']);


problem = createOptimProblem('fmincon','x0',x0,...
    'objective',@func_y_opim,'lb',LB,'ub',UB,'options',opts);%,...

% problem = createOptimProblem('fmincon','x0',x0,...
%     'objective',@func_y_opim,'lb',LB,'ub',UB);%,...
%     'options',opts);
%% ==============================================
%%   surrogatopt
% ===============================================
if p.method==2
    cprintf([0 .5 1],[' Method: surrogate'  '\n']);
    
    % ==============================================
    %%
    % ===============================================
    
    %     tic
    % %     opts = optimoptions('surrogateopt');
    %     opts = optimoptions('surrogateopt','PlotFcn','surrogateoptplot');
    %     problem = createOptimProblem('fmincon','x0',x0,...
    %     'objective',@func_y_opim,'lb',LB,'ub',UB,'options',opts);%,...
    
    doPlot=0;
    p0.planno=-1;
    nIter=p0.numIterations;
    %tic
    LB(2:3)=[-35 -5];
    UB(2:3)=[ 35  5];
    opts = optimoptions('surrogateopt','Display','final','PlotFcn',[],...%''surrogateoptplot',...);
        'UseParallel',false,'PlotFcn','surrogateoptplot','MaxFunctionEvaluations',nIter)
    initialslicegap=10000;
    if (UB(1)-LB(1))>initialslicegap
        startpoints=[[LB(1):initialslicegap:UB(1)]' ];
        startpoints=[startpoints zeros(length(startpoints),2)];
        opts= optimoptions(opts,'InitialPoints',startpoints);
    end
    %p3.cellsize       = 6
   
    
%     LB(2:3)=[-1  -3];
%     UB(2:3)=[ 40  3];
    [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,LB,UB,[1 2 3],opts);
    
    
 %    [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,LB,UB,[1 2 3],opts);
    %inipoints=[ 120]
    %[xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[40 0 0],[400 0 0],[1 2 3],opts);
    
    
    
     % [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,LB,UB,[1 2 3],opts);
    
    
    %toc
    xx        =xsur;
    fvel      =fsur;
    exitflag  =flgsur;
    output    =osur;
    solutions =trials;
    
    if 0
        
        %tic
        [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[40 -20 -5],[400 20 5],[1 2 3],opts)
        toc
        
        keyboard
        
        %run-2______
        tic
        [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[xsur(1)-20 -20 -5],[xsur(1)+20 20 5],[1 2 3],opts)
        toc
        %---------------
        if 0
            [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[80 0 0],[80 00],[1 2 3],opts)
        end
        
        
        
        opts = optimoptions('surrogateopt',...%''surrogateoptplot',...);
            'UseParallel',false,'MaxFunctionEvaluations',500);
        tic
        doPlot=0;
        %[xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[65 -20 -5],[90 20 5],[1 2 3],opts)
        [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[40 -20 -5],[400 20 5],[1 2 3],opts)
        xsur
        toc
       
        
        
        
        plotter(23,xsur);
        fg,imagesc(experimental_file)
        btab=sortrows([trials.Fval trials.X],1);
    end
    % ==============================================
    %%
    % ===============================================
    
    
    
    if 0
        % ==============================================
        %%
        % ===============================================
        
        %     tic
        % %     opts = optimoptions('surrogateopt');
        %     opts = optimoptions('surrogateopt','PlotFcn','surrogateoptplot');
        %     problem = createOptimProblem('fmincon','x0',x0,...
        %     'objective',@func_y_opim,'lb',LB,'ub',UB,'options',opts);%,...
        opts = optimoptions('surrogateopt','Display','final','PlotFcn',[],...%''surrogateoptplot',...);
            'UseParallel',true,'PlotFcn','surrogateoptplot','MaxFunctionEvaluations',100);
        tic
        doPlot=0;
        [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[80 -20 -5],[400 20 5],[1 2 3],opts)
        %  [xsur,fsur,flgsur,osur,trials] = surrogateopt(@func_y_opim,[80 -1 -1],[400 1 1],[1 2 3],opts)
        xsur
        toc
        % ==============================================
        %%
        % ===============================================
        
    end
    
    
    
    
elseif p.method==1
    % ==============================================
    %%   method-1: multistart
    % ===============================================
    cprintf([0 .5 1],[' Method: multistart'  '\n']);
    
    % delete(gcp('nocreate'));
    poolobj = gcp;
    % addAttachedFiles(poolobj,{'vl_hog.mexw64',which('vl_hog'), [mfilename '.m']});%,'elastix.m'
    
    addAttachedFiles(poolobj,{fileparts(which('vl_hog')), 'compute_hog_single_v4.m'  });
    updateAttachedFiles(poolobj);
    % ==============================================
    %%   start
    % ===============================================
    if p.plot==1; doPlot=1; end
    
    if p.parallel==0
        ms=MultiStart('UseParallel',0);
    else
        p.plot=0;    doPlot=0;
        ms=MultiStart('UseParallel',1);
    end
    % [xx fvel]=run(ms, problem,20); %20
    % [xx,fvel,exitflag,output,solutions]=run(ms, problem,100); %20
    
    
    % p.numStartpoints=1 %###TEST
    
    
    [xx,fvel,exitflag,output,solutions]=run(ms, problem,p.numStartpoints); %20
    
end

% ==============================================
%%
% ===============================================

cprintf([0 0 1],['BEST: [' num2str(fvel) '] ' regexprep(num2str(xx),'\s+',' ') '\n']);
cprintf([0 .5 0],['  ..dT: ' sprintf('%2.2f',toc(timeTot)/60)  ' min\n']);
% disp(['xx_afterfminsearch: '  num2str(xx)]);
% ==============================================
%%   result-PLOT
% ===============================================
if p.plotresult==1
    plotter(fvel,xx);
end

% poolobj = gcp;
%  addAttachedFiles(poolobj,{'readWholeTextFile.m' ,'elastix2.m', [mfilename '.m'],'mhd_read.m'});%,'elastix.m'
%

%===================================================================================================
%===================================================================================================
% ==============================================
%%   nested FCN
% ===============================================


    function hogval=func_y_opim(xx)
        %   load('testbed4_josephine5.mat')
        timex1a=tic;
        % ==============================================
        %%   get slice
        % ===============================================
        slicenum=xx(1);
        X=xx(2);
        Y=xx(3);
        
        
        %         [xd,yd,zd,corners ]=deal([]);
        %         [tx,ty,tz,moveNorm,]=deal(0);
        cent    =[size(cv,2)/2 size(cv,1)/2];
        vol_center=[cent slicenum];
        %         rx=X ;%up-down
        %         ry=Y; % tb(2);  %LEFT RIGHT
        %         rz=0;
        %         clear s
        % fig=figure(10000,'visible','off');
        %   set(fig,)
        % tic;
        % if 0
        %     [s xd yd zd next_corners vol_center ] = getslice4(cv,corners,[], [], [],[vol_center],...
        %         tx,ty,tz,rx,ry,rz,moveNorm,0);
        %     % toc
        %     dat=(s.CData);
        % end
        
        
        tatlas=uint8(obliqueslice(cv, vol_center, [Y -X 90]));
        if doPlot==1 && p.parallel==0
            figure(1000);
            try
                %imagesc([tatlas experimental_file])
                imagesc([tatlas round(imadjust(mat2gray(experimental_file)).*255)])
            catch
                imagesc(tatlas); colormap gray;
            end
            title('M1'); drawnow
        end
        
        if p.doflt==1
            tatlas=imgaussfilt(tatlas,1);
        end
        
        %% ===============================================
        
        if 0
            fib=uint8(obliqueslice(p0.fb, vol_center, [Y -X 90]));
        end
        
        %tatlas=imadjust(uint8(dat),[0 .25],[0 1]);
        % ==============================================
        %%   hog diff
        % ===============================================
        if p0.planno==1
            [hogval ]=compute_hog_single_v3(experimental_file,maskfile,tatlas,p3);
            %[hogval im]=compute_hog_single_v3(experimental_file,maskfile,tatlas,p3);
            %imgout(end+1,:)={ [xx hogval] im};
        elseif p0.planno==0
            [hogval ]=compute_hog_single_v3(experimental_file,maskfile,tatlas,p3);
            %[hogval ]=compute_hog_single_v4(experimental_file,maskfile,tatlas,fib,p3);
        elseif p0.planno==-1
            [hogval ]=compute_siftflow(experimental_file,maskfile,tatlas,p3);
        end
        
        %         hogval=compute_hog_single(cellsize,experimental_file,tatlas,experimental_thickness,...
        %             thick_thresh,maskfile,expresolution);
        hogval=double(hogval);
        % ==============================================
        %%
        % ===============================================
        try
            cprintf([1 0 1],['HOG:' num2str(hogval) ' ...'  ...
                num2str(xx(1)) ','   num2str(xx(2))  ','  num2str(xx(3)) ,...
                ' T(s): ' num2str(toc(timex1a)) '\n']);
        end
        
        try
            res.tb=[res.tb; [ xx hogval ] ];

            if isempty(res.best)
                res.best=res.tb(end,:);
            elseif hogval<res.best(4)
                res.best=res.tb(end,:);
            end
           xlabel([ ['best: [' num2str(res.best(4)) '] ' num2str(res.best(1)) ','   num2str(res.best(2))  ','  num2str(res.best(3))]    ]); drawnow;
        end
        
    end% nested



    function plotter(fvel,xx)
        timex1a=tic;
        % ==============================================
        %%   get slice
        % ===============================================
        % xx=[166   13.1462   -2.39]
        
        slicenum=xx(1);
        X=xx(2);
        Y=xx(3);
        
        [xd,yd,zd,corners ]=deal([]);
        [tx,ty,tz,moveNorm,]=deal(0);
        cent    =[size(cv,2)/2 size(cv,1)/2];
        vol_center=[cent slicenum];
        rx=X ;%up-down
        ry=Y; % tb(2);  %LEFT RIGHT
        rz=0;
        clear s
        % fig=figure(10000,'visible','off');
        %   set(fig,)
        % tic;
        if 0
            [s xd yd zd next_corners vol_center ] = getslice4(cv,corners,[], [], [],[vol_center],...
                tx,ty,tz,rx,ry,rz,moveNorm,0);
            % toc
            dat=(s.CData);
        end
        
        
        
        tatlas=obliqueslice(cv, vol_center, [Y -X 90]);
        [hogval sr]=compute_hog_single_v3(experimental_file,maskfile,tatlas,p3);
        %         figure;
        %         imagesc(imadjust(dat)); colormap gray
        imoverlay(sr.tatlas,sr.ef);
        title(['[' num2str(fvel) ']' regexprep(num2str(xx),'\s+',' ' ) ],'fontsize',7); drawnow
    end
end %function










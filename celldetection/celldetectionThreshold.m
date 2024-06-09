% using threshold
function celldetectionThreshold(p0)


% disp('---ok...')
% return


if 0
    p.file         ='F:\data3\histo2\josefine\dat\14_000000000001F059\a1_004.tif';
    celldetection(p)
    
end

p=p0;

% keyboard
% return

% % ==============================================
% %%   paramter
% % ===============================================
% p.task         =3;%[1:4];
% p.file         ='';
% p.splitsize    =[600 600] ;%
% p.paddingValue =255; % intensity value for padding
% p.polarity     ='dark' ; %
% % ---------------------------------------
% p.istest  =0;
% p.sens   =.85;
% 
% % p.istest =1
% % p.show   =1;
% % p.save   =0;
% % p.sens   =.9;
% % -----------
% p.dotplotsize =1;
% p.showcounts  =0;
% % p.polarity    = 'dark';%'bright';
% p.medfilt     =[];%[11 11];
% p.color       ='m';
% p.radius      =[3 7];%[3 7]; %[10 30]
% p.testimage   =[1:10];%'sec2_9.png'
% % p.testimage='sec4_7.png'
% % -----------------------------------
% %%%% p.meth='PhaseCode'
% p.meth='TwoStage'  ;
% %p.meth='frst'
% % -----fdo 2nd sensitivyty
% p.doHD     =0          ;
% p.radiusHD=[3 7]       ;
% p.sensHD  =.99         ;
% % -----intensity threshold
% p.doIntensTresh  = 0   ;
% p.IntensTresh   =100;  ;
% %------min cellDistance
% p.doCellDistanceThresh =1;
% p.minCellDistance=7;



% ==============================================
%%
% ===============================================

% p=catstruct(p,p0);

% ==============================================
%%   prereq
% ===============================================
try
    cprintf([0 0 1],['proc: '  strrep(p.file,filesep,[filesep filesep]) '\n']);
catch
    fprintf(['proc: '  strrep(p.file,filesep,[filesep filesep]) '\n']);
end



[px name ext]=fileparts(p.file);
detectdir=fullfile(px,[ 'cellcounts_'  name]);

%% ________________________________________________________________________________________________
% ==============================================
%%   TASK-1: make DIR/SPLIT IMAGE
% ===============================================

if ~isempty(find(p.task==1))
    
    % ==============================================
    %%   make dir and copy file
    % ===============================================
    
    
    if exist(detectdir)==7
        rmdir(detectdir,'s');
    end
    mkdir(detectdir);
    showinfo2('..cell-folder',detectdir);
    
    
    fprintf(['[1]..creating cellDetection-folder.. ']);
    
    % slicename1=fullfile(detectdir,[ 'input.tif' ]);
    slice=p.file;
    
    
    % copyfile(p.file,slicename1, 'f');
    % ==============================================
    %%   split  image
    % ===============================================
    fprintf(['..split images.. ']);
    splitimage(slice,detectdir, p.splitsize, p.paddingValue);
    % splitimage(slicename1,[], [600 600], 255);
    pcreateDB(detectdir,slice);
    fprintf(['Done.']);
    
end
%% ________________________________________________________________________________________________


%% ________________________________________________________________________________________________
% ==============================================
%%   TASK-2:cell-detection
% ===============================================
if ~isempty(find(p.task==2))
    %% ==============================================
    % ===============================================
    %p.istest=0;
    if p.istest==1
        p.show   = 1;
        p.save   = 0;
    elseif p.istest==0
        p.show   = 0;
        p.save   = 1;
    end 
    %--------------------------------------------------
    disp(['[2]..detecting cells.. ']);
    %predictcircles3(detectdir,p);
    predictcircles3_viathreshold(detectdir,p);
    disp(['..Done']);
    %     showinfo2('..cutting..Infoimage',fioutMon);
end

%% ________________________________________________________________________________________________
% ==============================================
%%   TASK-3:merge image
% ===============================================
if ~isempty(find(p.task==3))
    disp(['[3]..merging image.. ']);
    mergeimage(detectdir,[],0);
    disp(['..Done']);
    showinfo2('..show Result',fullfile(detectdir,'predfus.tif'));
end


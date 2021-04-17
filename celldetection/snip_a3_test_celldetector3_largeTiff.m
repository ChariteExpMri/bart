
clear

% ==============================================
%%   
% ===============================================



file='F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_001.tif'

% ==============================================
%%
% ===============================================
polarity='dark'
slicename0=file

detectdir=fullfile(pwd,['test' ]);
mkdir(detectdir);

slicename1=fullfile(detectdir,[ 'input.tif' ]);
copyfile(slicename0,slicename1, 'f');


splitimage(slicename1,[], [600 600], 255);
pcreateDB(detectdir);

% ==============================================
%%   
% ===============================================
if 0
    path1='f:\data3\neher_histo\cell_detection_test1'
    cd('C:\Users\skoch\Desktop\Cell-segmentation-methods-comparison-master')
    addpath('detection','evaluation','foreground_segmentation','final_segmentation','example_data')
    addpath(genpath('util'));
    cd(path1);
end
% predictcircles_estimate(detectdir,polarity,'m','sec5_12.png');
% radius: 10:30
% ==============================================
%%   
% ===============================================

istest=0

if istest==1
    p.istest = 1
    p.show   = 1;
    p.save   = 0;
elseif istest==0
    p.istest = 0
    p.show   = 0;
    p.save   = 1; 
end
p.sens   =.85;

% p.istest =1
% p.show   =1;
% p.save   =0;
% p.sens   =.9;
% -----------
p.dotplotsize=1;
p.showcounts=0
p.polarity= 'dark';%'bright';
p.medfilt=[];%[11 11];
p.color  ='m';
p.radius =[3 7]; %[10 30]
p.testimage='sec5_12.png'
% p.testimage='sec2_10.png'
%%%% p.meth='PhaseCode'
 p.meth='TwoStage'
%  p.meth='frst'
p.doHD     =0
p.radiusHD=[2 7]
p.sensHD  =.99

 predictcircles3(detectdir,p);
% ==============================================
%%   
% ===============================================
mergeimage(detectdir,[],0);
    

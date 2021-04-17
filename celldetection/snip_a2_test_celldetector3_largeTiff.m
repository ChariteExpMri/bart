
clear

% ==============================================
%%   
% ===============================================


files={
    'F:\data3\neher_histo\cell_detection_test1\neher_hist2\20210215_NeuN_IHC_JW-Scene-2-ScanRegion1.czi - 20210215_NeuN_IHC_JW-Scene-2-ScanRegion1.czi #1 - C=2.tif'
    }

% ==============================================
%%
% ===============================================
i=1
imgno=i
if imgno==2
    polarity='dark'
else
    polarity='dark'
end
slicename0=files{imgno}
% [a ha]=imread(file);

detectdir=fullfile(pwd,['x_frst2' num2str(imgno)]);
mkdir(detectdir);

slicename1=fullfile(detectdir,[ 'input.tif' ]);
copyfile(slicename0,slicename1, 'f');


splitimage(slicename1,[], [600 600], 255);
pcreateDB(detectdir);

% ==============================================
%%   
% ===============================================
path1='f:\data3\neher_histo\cell_detection_test1'
cd('C:\Users\skoch\Desktop\Cell-segmentation-methods-comparison-master')
addpath('detection','evaluation','foreground_segmentation','final_segmentation','example_data')
addpath(genpath('util'));
cd(path1);
% predictcircles_estimate(detectdir,polarity,'m','sec5_12.png');
% radius: 10:30
% ==============================================
%%   
% ===============================================
p.istest =0
p.show   =0;
p.save   =1;
p.sens   =.8;
% -----------
p.polarity='dark'
p.medfilt=[];%[11 11];
p.color  ='m';
p.radius =[9 30]; %[10 30]
p.testimage='sec5_12.png'
% p.testimage='sec2_2.png'
% p.meth='PhaseCode'
% p.meth='TwoStage'
p.meth='frst'

 predictcircles3(detectdir,p);

% ==============================================
%%   
% ===============================================




mergeimage(detectdir,[],0);
    

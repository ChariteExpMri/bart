
clear

% ==============================================
%%   paramter
% ===============================================
p.file         ='F:\data3\histo2\josefine\dat\14_000000000001F059\a1_004.tif';
p.splitsize    =[600 600] ;%
p.paddingValue =255; % intensity value for padding
p.polarity     ='dark' ; %

% ==============================================
%%   make dir and copy file
% ===============================================

[px name ext]=fileparts(p.file);
detectdir=fullfile(px,[ 'cellcounts_'  name]);
mkdir(detectdir);

% slicename1=fullfile(detectdir,[ 'input.tif' ]);
slice=p.file;


% copyfile(p.file,slicename1, 'f');
% ==============================================
%%   split  image
% ===============================================

splitimage(slice,detectdir, p.splitsize, p.paddingValue);
% splitimage(slicename1,[], [600 600], 255);
pcreateDB(detectdir,slice);

% ==============================================
%%   
% ===============================================
% if 0
%     path1='f:\data3\neher_histo\cell_detection_test1'
%     cd('C:\Users\skoch\Desktop\Cell-segmentation-methods-comparison-master')
%     addpath('detection','evaluation','foreground_segmentation','final_segmentation','example_data')
%     addpath(genpath('util'));
%     cd(path1);
% end
% % predictcircles_estimate(detectdir,polarity,'m','sec5_12.png');
% % radius: 10:30
% ==============================================
%%   
% ===============================================
% cf
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
p.showcounts=0;
p.polarity= 'dark';%'bright';
p.medfilt=[];%[11 11];
p.color  ='m';
p.radius =[3 7];%[3 7]; %[10 30]
p.testimage=[13];%'sec2_9.png'

% p.testimage='sec4_7.png'
%%%% p.meth='PhaseCode'
p.meth='TwoStage'
  %p.meth='frst'
% -----fdo 2nd sensitivyty
p.doHD     =0
p.radiusHD=[2 7]
p.sensHD  =.99
% -----intensity threshold
p.doIntensTresh  = 0
p.IntensTresh   =100;
%------min cellDistance
p.doCellDistanceThresh =1;
p.minCellDistance=7;


 predictcircles3(detectdir,p);
% ==============================================
%
% ===============================================
mergeimage(detectdir,[],0);
    

function makelogfile(logfile, rawfile,internfile,msgline,forceoverwrite)

% ==============================================
%%  log file
% ===============================================

%  logfile=fullfile(fpoutDir,'importlog.txt');


if exist('forceoverwrite')==1 && forceoverwrite==1
    lg0=[];
else
    if exist(logfile)==2
        lg0=importdata(logfile,'\n');
        %=pread
    else
        lg0=[];
    end
    
end
if exist('msgline')==0
    msgline='';
else
    if iscell(msgline)
       msgline= strjoin(msgline,'; ');
    end
end


lg={[ 'DATE: '  timestr(now) ]};
if ~isempty(msgline)
 lg(end+1,1) ={['[#info]: '  msgline]};   
end
lg(end+1,1) ={['#import_TIFF [origin]: '  rawfile]};
lg(end+1,1) ={['#import_TIFF [BART]  : '  internfile]};

% [lg0; lg]
% lg0
% lg

pwrite2file(logfile, [lg0; lg]);

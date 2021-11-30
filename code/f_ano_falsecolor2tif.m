

% #ok convert ANO-atlas in histoSpace to pseudoatlas-TIF (pseudo-color or Allen-color)
% % =====================================================
% #lk EXAMPLE
% % =====================================================
% z=[];
% z.mode           = [3];                                          % % type of output: [1]pseudocolor,[2]Allen-color, [3] both(1+2) 
% z.inresize       = [1000];                                       % % internally resize image for faster calculation, output image is in original HistoSpace-size
% z.compression    = 'LZW';                                        % % compression of the resulting TIF-image {LZW|none}
% z.atlasExcelFile = 'F:\data3\histo2\bart_template\ANO.xlsx';     % % ExcelFile of the Atlas (DO NOT MODIFY)
% z.isparallel     = [0];                                          % % use parallel computing (0,1)
% f_ano_falsecolor2tif(1,z);      



function f_ano_falsecolor2tif(showgui,x )

% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end


% ==============================================
%%   GUI
% ===============================================


if exist('x')~=1;        x=[]; end

global ak
% templateDir=fullfile(fileparts(which('bart.m')),'templates');
atlasExcelfile=fullfile(ak.template,'ANO.xlsx');
%% -------------------------------------------------------------
para={...
    'inf98'      '*** convert ANO.mat (HistoSpace) to pseudocolor tif  '    '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    %     'inf100'     '==================================='                          '' ''
    %     'template'   template   'template to used for registration (do not modify)' ''
    %     'interp'    'auto'      'interpolation type for slicing/resizing/warping: {"auto":determine interpolation;[0]NN;[1];linear} '   {'auto' 0 1}
    %     '' '' '' ''
    'mode'        [3]      'type of output: [1]pseudocolor,[2]Allen-color, [3] both(1+2) ' {1 2 3}
    'inresize'    [1000]  'internally resize image for faster calculation, output image is in original HistoSpace-size' {nan 1000}
    'compression' 'LZW'   'compression of the resulting TIF-image {LZW|none}'   {'LZW','none'}
    'atlasExcelFile' atlasExcelfile  'ExcelFile of the Atlas (DO NOT MODIFY)'  'f'
    %     'check_DIRassign'     0  'check folder-assignment only [0/1]: [1] check assignment only..do nothing else; [0] warp images '  'b'
    'isparallel'          0               'use parallel computing (0,1)'  'b'
    };

p=paramadd(para,x);%add/replace parameter
%     [m z]=paramgui(p,'uiwait',0,'close',0,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .7 .5 ],'title','PARAMETERS: LABELING');

% %% show GUI
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end


timeTot=tic;


cprintf('*[0 0 1]', [ '*** converting ANO.mat-to-pseudoColorANO.Tif (' mfilename '.m) ***' '\n'] );
% cprintf([0 0 1],[' ANO.mat to pseudoANO.tif ... '  '\n']);
xmakebatch(z,p, mfilename); % ## BATCH


% ==============================================
%%   assign folders
% ===============================================
% -------------- BART selected folders
fidi=bartcb('getsel');
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);


% ==============================================
%%   read atlas for faster readout
% ===============================================
% global ak
F1xls=z.atlasExcelFile;
if exist(F1xls)~=2
    msgbox({'proc: RGB-colorizing ANO','missing ANO.xls-file:' F1xls})
end

%   read excel-file
[~,~,a0]=xlsread(F1xls);

del=regexpi2(cellfun(@(a){[ num2str(a)  ]}, a0(:,1) ), 'NaN');
a0(del,:)=[];
hat=a0(1,1:5);
at=a0(2:end,1:5);
z.at  =at;
z.hat =hat;

% ==============================================
%%   check and assign files
% ===============================================
fi=w.files;
[pas slice ext]=fileparts2(fi);
anoNames=cellfun(@(a){[ regexprep(a,{'a1_'},{'s'}) '_ANO.mat'   ]}, slice );
files0=cellfun(@(a,b){[a filesep 'fin' filesep  b]},pas,anoNames);

err={};
errix=[];
for i=1:length(files0)
    if exist(files0{i})~=2
        err(end+1,:)={(i) 'missing file:  '  files0{i}    fi{i}};
        errix(end+1,1)=i;
    else
        k=dir(files0{i});
        if k.bytes<1000
            err(end+1,:)={(i) 'file to small:  '  files0{i} fi{i}};
            errix(end+1,1)=i;
        end
    end
end


if ~isempty(err)
    cprintf('-[1 0 1]', ['WARNING-->following files will be not processed:' '\n']);
    errmsg=plog([],[err],0, [  ' [' mfilename '.m] : ERRORS' ],'s=2;al=1;');
    disp(char(errmsg));
    assignin('base','barterror',err);
end



files=files0(setdiff(1:length(files0),errix));
% ==============================================
%%   PROCEED
% ===============================================
% return
disp(['isparalel: ' num2str(z.isparallel)]);

if z.isparallel==0
    for i=1:length(files)
        ano_falsecolor2tif(files{i}, z);
    end
else
    parfor i=1:length(files)
        ano_falsecolor2tif(files{i}, z);
    end
end

% ==============================================
%%   display
% ===============================================
cprintf('*[0 0 1]', ['DONE (T=' sprintf('%2.1f min',toc(timeTot)/60   ) ...
    '). converting ANO.mat-to-pseudoColorANO.Tif     \n' ]);

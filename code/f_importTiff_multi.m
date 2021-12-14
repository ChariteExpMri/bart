

%% #b import tiffs multi-slices per animal/folder
%% #b      



function f_importTiff_multi(showgui,x )

% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-gui
% ===============================================

if exist('x')~=1;        x=[]; end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
%% import 4ddata
para={...
    'inf98'      '*** import multiple tifs      '    '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'inf100'     '==================================='                          '' ''
    'files'                  ''              'select TIFF-file(s); '  'mf'
    'frameNumber'            1               'select the frame number (default is 1) if TIFF contains more than 1 image' {1 2 3 4 5}
    'SliceInOwnDir'          1               'import each slice in its own folder (use filename of slice as new Dir-name) '   'b'     

    'useFolderName'          0               'resulting animal name: [0]: from folder or [1] from Tiff-file ' 'b'
    'copyfoldercontent'      0               'copy the folder content (all files) from original tif-folder'  'b'
    'isparallel'             0               'use parallel computing (0,1)'  'b'
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




cprintf([0 0 1],[' import Tiffs... '  '\n']);
xmakebatch(z,p, mfilename); % ## BATCH




% ==============================================
%%   split folderwise
% ===============================================
[px name ext]=fileparts2(z.files);
unimdirs=unique(px);
for i=1:length(unimdirs)
    is=find(strcmp(px,unimdirs{i}));
    tifgrp{i}=cellfun(@(a,b,c){[a filesep [b c]]}, px(is),name(is),ext(is) );
end



% ==============================================
%%   PROCEED
% ===============================================

global ak
s=catstruct(z,ak);
disp(['isparalel: ' num2str(s.isparallel)]);
if s.isparallel==0
    for i=1:length(tifgrp)
        importTiff_multi(tifgrp{i},s);
    end
else
    parfor i=1:length(tifgrp)
        importTiff_multi(tifgrp{i},s);
    end
end

% ==============================================
%%   
% ===============================================


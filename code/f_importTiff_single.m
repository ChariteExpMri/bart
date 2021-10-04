

%% #b import tiffs
%% #b      



function f_importTiff_single(showgui,x )

if 0
    
    z=[];
    z.files  = { 'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF.ndpi'             % % select tiff files
        'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF_macro.tif' };
    z.format = 'ndpi';                                                                                  % % select tiff files
    f_importTiff(0,z);
    
end
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
    'inf98'      '*** import single tifs      '                         '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'inf100'     '==================================='                          '' ''
    'files'                  ''              'select TIFF-file(s); '  'mf'
    'frameNumber'            1               'select the frame number (default is 1) if TIFF contains more than 1 image' {1 2 3 4 5}
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
%%   proceed
% ===============================================
zfiles=cellstr(z.files);
global ak
s=catstruct(z,ak);
disp(['isparalel: ' num2str(s.isparallel)]);
if s.isparallel==0
    for i=1:length(z.files)
        importTiff_single(z.files{i},s);
    end
else
    parfor i=1:length(z.files)
        importTiff_single(z.files{i},s);
    end
end

% ==============================================
%%   
% ===============================================


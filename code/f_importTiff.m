

%% #b import tiffs
%% #b  
% 
% #wo COMANDLINE
% z=[];
% z.files              = { 'F:\data4\Lina_HISTO_gadolinium\raw_large\39. 2021-1_M4a_0000000000021839.ndpi' };     % % select "tiff" or "ndpi"-files
% z.ndpi_magnification = [10];                                                                                   % % ndpi only: select magnification (use 10!) 
% z.isparallel         = [0];                                                                                     % % use parallel computing (0,1)
% f_importTiff(1,z);



function f_importTiff(showgui,x )

if 0
    
    z=[];
    z.files  = { 'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF.ndpi'             % % select tiff files
        'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF_macro.tif' };
%     z.format = 'ndpi';                                                                                  % % select tiff files
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
    'inf98'      '*** import tifs                '                         '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'inf100'     '==================================='                          '' ''
    'files'                  ''     'select "tiff"- or "ndpi"-files'  'mf'
    'ndpi_magnification'     10     'ndpi only: select magnification (use 10!), "all": create all magnifications ' { 0.625 0.15625 2.5    10 40 'all'}
    %
    
    %    'format'                'ndpi'            'select tiff files'  {'ndpi','tiff' }
    'isparallel'             0                'use parallel computing (0,1)'  'b'
    %     'deleteFiles'           '_x40;.ndpi'      'delete files '   {'none' ,'_x40' '_x40;.ndpi'}
    %     'template'             templateDir       'select main template folder <required to fill>'  'd'
    %     'keepSubdirStructure'   1          '[0,1]: [0] flattened hierarchy (no subdirs), [1] the destination path contains the subfolders  '    'b'
    %     'animalsubdirs'         1          '[0,1]: [1] preserve SUBFOLDERS WITHIN ANIMAL FOLDERS in either output name or folder hierarchy or [0] do not preserve' 'b'
    %     'prefixDirName'         0          'adds mouse Dir/folder name as prefix to the new filename'      'b'
    %     'renameString'         ''          'replace file name with new file name (no file extention), !NOTE: files might be overwritten (same output name)'  {'mask' 'raw' 'test'}
    %     'addString'            ''          'add string as suffix to the output file name'                                                            ''
    %     'reorient'             ''          ' <9 lement vector> reorient volume, default: []: do nothing; (nb: use [0 0 0 0 0 0 1 -1 1] if data came from DSIstudio)'  {'0 0 0 0 0 0 -1 1 1';'0 0 0 0 0 0 1 -1 1'; '0 0 0 0 0 0 -1 -1 1'}
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
cprintf([0 0 1],['Import Tiffs' '\n']);
timx=tic;
if s.isparallel==0
    for i=1:length(z.files)
        importTiff(z.files{i},s);
    end
else
    parfor i=1:length(z.files)
        importTiff(z.files{i},s);
    end
end
cprintf([0 0 1],['Done. (t=' sprintf('%2.2f min',toc(timx)/60)  ')' '\n']);

% ==============================================
%%   
% ===============================================


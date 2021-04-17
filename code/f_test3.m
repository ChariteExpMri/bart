
function varargout=f_test(showgui,x )
% paramlist=[];
if 0
    
    z=[];
    z.files  = { 'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF.ndpi'             % % select tiff files
        'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF_macro.tif' };
    z.format = 'ndpi';                                                                                  % % select tiff files
    f_importTiff(0,z);
    
end

%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-gui
% ===============================================

if exist('x')~=1;        x=[]; end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
%% import 4ddata
para={...
%     'inf98'      '*** cut tif to slices      '                                  '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
%     'inf100'     '==================================='                          '' ''
    'files'                  ''                'select tiff files'                   'mf'
    'fileswcard'             '_x10'                'alternative select wildcard string'   {'_x10' ''}
    'transpose'               1                'transpose image {0,1}'               'b'
    'verbose'                 1                  'passes extra info  {0,1}'          'b'
    'outdir'                'up1'      'out-put directory: {explicit path, same" "up1"}'  {'up1' 'same'}
    'verb'                   1                  'verbose,passes extra info  {0,1}'               'b'
    'thumbnail'              1                'save thumbnail image (jpg) {0,1}'          'b'
    'isparallel'             0                'use parallel computing (0,1)'  'b'
    ...
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
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end

xmakebatch(z,p, mfilename); % ## BATCH


if showgui==1
    varargout{1}=z;
    if ischar(parse)==1 && strcmp(parse,'parse')
        showgui=-1;
    end
end
% ==============================================
%%   Parse parameter without runnning rest
% ===============================================
if showgui==-1
    p2=struct2param(p,z);
    p2=[{['@' mfilename] 0 'FunctionName' ''}; p2]; % add functionName
    varargout{1}=p2;
    return
end

cprintf([0 0 1],[' import Tiffs... '  '\n']);

'weiter'






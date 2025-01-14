
function varargout=f_warp2histospace(showgui,x )

%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end
if exist('x')~=1;        x=[]; end


% ==============================================
%%   predefined images
% ===============================================
global ak
pa_template=ak.template;
% pa_template=strrep(which('bart.m'),'bart.m','templates');
tb0={...%Name__________INterpol
    'AVGT.nii'          '0'
    'AVGThemi.nii'      '0'
    'ANO.nii'           '0'
    };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath



% refimage=tb{1,1} ;
% ==============================================
%%   struct
% ===============================================
para={...
    
% 'inf1'    'TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
% '' '' '' ''
% 'image'  1       '[1] use original input image, [0]use  lowresscreenshot(jpg) from original  {0|1} '  'b'

'finalsize'    1  'determine final image-size:  [1] from input-image, [2] from logfile '  {1 2 3}   
'' '' '' ''
'save_tif'   1  'save also as tif-file'  'b'
% 'savemat' 0  'debug-mode, {0|1}, if [1] create plots'  'b'
'debug'   0     'debug-mode, {0|1}, if [1] create plots'  'b'
'simulate'  1   'simulation-mode: {0|1} , if [1] do not save mat-file (create only thumbnails)'  'b'
% 'useModFile'     1              'use modFile "a2_XXXmod.tif" if exist'               'b'
% 'defaultsfile'  defaultsfile   'fullfile name to "deepslice_defaults.m"'  'f'
% 'pythonscript' 'runDeepslice_single.py'       'deepslice script' {'runDeepslice_single.py'}

% '' '' '' ''
% 'saveIMG'        1  'save output images {0|1}; [0]is for testing only [1]yes save images'      'b'

};


% ==============================================
%% show GUI
% ===============================================
p=paramadd(para,x);%add/replace parameter
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.1 .2 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end
xmakebatch(z,p, mfilename); % ## BATCH
%% ===============================================
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
% ==============================================
%%   files
% ===============================================
if isfield(x,'files') && ~isempty(char(x.files))
    z.files=x.files;
else
    fidi=bartcb('getsel')  ;
    z.files=fidi(strcmp(fidi(:,2),'file'),1);
end

% ==============================================
%%   PROCEED
% ===============================================
cprintf([0 0 1],[' warp to histo-space. '  '\n']);
z.files=cellstr(z.files);
if isempty( char(z.files)); return; end
timex=tic;
for i=1:length(z.files)
    z2=z;
    z2=rmfield(z2,'files');
    z2.file=z.files{i};
    warp2histospace(z2);
end
cprintf([0 0 1],[' done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);


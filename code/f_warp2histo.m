
function varargout=f_warp2histo(showgui,x )


if 0
    
   
    
end

%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-FILES
% ===============================================

if exist('x')~=1;        x=[]; end
if ~isempty(x) && ~isempty(x.files)
%     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
%     x.files =regexprep(x.files,{ [filesep filesep 'a1_'] '.tif'},{[filesep filesep 'optim_'],'.mat' });
end


% ==============================================
%%   predefined images
% ===============================================
global ak
pa_template=ak.template;
% pa_template=strrep(which('bart.m'),'bart.m','templates');
tb0={...%Name__________INterpol
    'AVGT.nii'          '1'
    'AVGThemi.nii'      '0'
    'ANO.nii'           '0'
%     '_b1grey.nii'       0
   };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath
% templateDir=fullfile(fileparts(which('bart.m')),'templates');
% ==============================================
%%   struct
% ===============================================
para={...
 
'inf1'    'TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
'' '' '' ''
'outDirName'   'fin'   'Name of the output Directory: ("fin": folder with output images)'      ''
'' '' '' ''
'inf2'    '_____ REFERENCE IMAGE _________________________'  ''  ''
'refImg'     tb{1,1}                'Reference image for registration'                   'f'
'' '' '' ''
'inf3'    '_____ FILES TO TRANSFORM FROM TEMPLATE-FOLDER _________________________'  ''  ''
'filesTP'    tb 'Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) ' {@fileselection }
'' '' '' ''
'inf4'     '_____ ELASTIX PARAMETER _________________________' '' ''
'NumResolutions'             [2 2     ]  'number of resolutions for affine(arg1) & B-spline(arg2) transformation'   ''
'MaximumNumberOfIterations'  [250 1000]  'number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation' ''
'FinalGridSpacingInVoxels'   40          'control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)' ''


'' '' '' ''
'inf5'     '_____ DO THIS FOR THE FOLLOWING FILES _________________________' '' ''
'files'    {}          'histo-files'  'mf'
};
% ==============================================
%%   
% ===============================================
p=paramadd(para,x);%add/replace parameter
%     [m z]=paramgui(p,'uiwait',0,'close',0,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .7 .5 ],'title','PARAMETERS: LABELING');

% %% show GUI
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.1 .2 .6 .5 ],...
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


cprintf([0 0 1],[' warp estimated slices... '  '\n']);



% ==============================================
%%   PROCEED
% ===============================================
z.files=cellstr(z.files);
if isempty(z.files{1}); return; end

for i=1:length(z.files)
    z2=z;
    z2=rmfield(z2,'files');
    z2.file=z.files{i};
    warp2histo(z2);
end




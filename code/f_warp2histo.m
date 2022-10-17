
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
% if ~isempty(x) && ~isempty(x.files)
% %     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
% %     x.files =regexprep(x.files,{ [filesep filesep 'a1_'] '.tif'},{[filesep filesep 'optim_'],'.mat' });
% end


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
%     '_b1grey.nii'       0
   };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath
% templateDir=fullfile(fileparts(which('bart.m')),'templates');

% 
% refimage=fullfile(pa_template,'HISTOVOL.nii');
refimage=fullfile(pa_template,'AVGT.nii');
%% =============================================== elastix-paramter
pa_el=strrep(which('bart.m'),'bart.m','elastix2');
parfile0={...
        fullfile(pa_el, 'a1_affine.txt')
        fullfile(pa_el, 'a2_warping.txt')
        };

% refimage=tb{1,1} ;
% ==============================================
%%   struct
% ===============================================
para={...
 
'inf1'    'TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
'' '' '' ''
% 'outDirName'   'fin'   'Name of the output Directory: ("fin": folder with output images)'      ''
'useModFile'                 1               'use modFile "a2_XXXmod.tif" if exist'  'b'
'enableRotation' 1       'enable rotation if manally defined' 'b'
'saveIMG'        1  'save output images {0|1}; [0]is for testing only [1]yes save images'      'b'

'' '' '' ''
'inf2'    '_____ REFERENCE IMAGE _________________________'  ''  ''
'refImg'     refimage               'Reference image for registration'                   'f'

'' '' '' ''
'inf3'    '_____ FILES TO TRANSFORM FROM TEMPLATE-FOLDER _________________________'  ''  ''
'filesTP'    tb 'Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) ' {@fileselection }

'' '' '' ''
'inf4'     '_____ ELASTIX PARAMETER _________________________' '' ''
'parameterFiles'    parfile0      'Elastix paramter files (affine&Bspline)'    {@getElestixfiles}
'changeParameter'  'HIT BUTTON'              'change elastix Parameter using a local copy of parameterfiles'       {@changeElastixparameter}
};
% 
% 'NumResolutions'             [2     6     ]  'number of resolutions for affine(arg1) & B-spline(arg2) transformation'   ''
% 'MaximumNumberOfIterations'  [1250 1000]     'number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation' ''
% 'MaximumStepLength'          1               'maximum voxel displacement step between two iterations. The larger this parameter, the more aggressive the optimization. ' ''

% 'inf5'    '_____ MISC _________________________'  ''  ''
% 'isparallel'           0   'parallel processing {0,1}' 'b'

% '' '' '' ''
% 'inf6'     '_____ DO THIS FOR THE FOLLOWING FILES _________________________' '' ''
% 'filesAlternative'    {}          'histo-files'  'mf'

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
cprintf([0 0 1],[' warping to histoSpace... '  '\n']);
z.files=cellstr(z.files);
if isempty(z.files{1}); return; end
timex=tic;
% if z.isparallel==0
    for i=1:length(z.files)
        z2=z;
        z2=rmfield(z2,'files');
        z2.file=z.files{i};
        warp2histo(z2);
    end
% else
%     n=length(z.files);
%    parfor i=1:n
%        disp('hui')
%         z2=z;
%         z2=rmfield(z2,'files');
%         z2.file=z.files{i};
%         warp2histo(z2);
%     end 
% end
cprintf([0 0 1],[' done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);

function getElestixfiles(e,e2)
he=[];
pa_el=strrep(which('bart.m'),'bart.m','elastix2');
msg='select 1x affine and 1x bspline parameterFile (in that order!)';
[t,sts] = spm_select(inf,'any',msg,'',pa_el,'.*.txt','');
if isempty(t);
    [r1 r2]=paramgui('getdata');
    t=r2.parameterFiles;
else
    t=cellstr(t);
end
paramgui('setdata','x.parameterFiles',t);
return


function changeElastixparameter(e,e2)

he=[];
[r1 r2]=paramgui('getdata');
paramfiles0=r2.parameterFiles;
%% make local dir ---------------
warning off
global ak
elparamDirLocal=fullfile(fileparts(ak.dat),'Elastixparameter');
mkdir(elparamDirLocal);

paramfiles1=replacefilepath(paramfiles0,elparamDirLocal);
try
    copyfilem(paramfiles0,paramfiles1);
end

edit(paramfiles1{1});
edit(paramfiles1{2});



hm=msgbox({...
    '(1)local copies of selected ParamterFiles created in "yourstudy"/Elastixparameter-folder'
    ''
    '(2) modify these ParamterFiles in the EDITOR now! '
    '(3) don''t forget to hit the "save"-button'
    '(4) if possible..close parameter-files in editor'
    },'IMPORTANT');
uiwait(hm);


paramgui('setdata','x.parameterFiles', paramfiles1); %update paramterFiles


%% ===============================================




return













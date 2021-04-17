function here

% ==============================================
%%   
% ===============================================
% ==============================================
%%   get images
% ===============================================
pa_template=strrep(which('bart.m'),'bart.m','templates')
tb0={...%Name__________INterpol
    'AVGT.nii'          '1'
    'AVGThemi.nii'      '0'
    'ANO.nii'           '0'
%     '_b1grey.nii'       0
   };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath

% ==============================================
%%   
% ===============================================

showgui=1
x=struct()
% ==============================================
%  struct
% ===============================================
para={...
 
'inf1'    '% TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
'' '' '' ''
'outDirName'   'fin'   'Name of the output Directory: ("fin": folder with output images)'      ''

'inf2'    '% === REFERENCE IMAGE =========================='  ''  ''
'refImg'     tb{1,1}                'Reference image for registration'                   'f'
'' '' '' ''
'inf3'    '_____FILES TO TRANSFORM FROM TEMPLATE-FOLDER _________________________'  ''  ''
'filesTP'    tb 'Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) ' {@fileselection }
'' '' '' ''
'inf4'     '___ELASTIX PARAMETER _________________________' '' ''
'NumResolutions'             [2 6]  'number of resolutions for affine(arg1) & B-spline(arg2) transformation'   ''
'MaximumNumberOfIterations' [250 3000]  'number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation' ''

% '' '' '' ''
% '' '' '' ''
%  'inf100'     '===RESIZE IMAGE=========================='                          '' ''
% 'channel'               3   'which RGB-channel to use {1,2,3}'                    ''
% 'usemanualrotation'     1   'do include manual rotation info, if exist {0,1}' 'b'
% 
% 'inf101'     '===FIND SLICE PLAN-1&2=========================='                          '' ''
% 'parallel'              1       'use parallell-computation' 'b'
% 'cellsize'              16      'cellsize of HOG-histogram (larger is finer scaled  )' ''
% 'numStartpoints'       100      'number of starting points (recom: 100) of Multistart-optimization' ''
% 'doflt'                  1      'Gauss filt altas slice after extraction from 3dvol {0,1}'  'b'
% % -------------------
% 'plot'                   1       'plot update for each iteration (slow)' 'b'
% 'plotresult'             1       'plot result best "solution" (image)'   'b'
% % ----------
% 'plan1_x0'              [200   0   0  ]  'PLAN1: best guess (slice, pitch, yaw)'        ''
% 'plan1_LB'              [80    0   0  ]  'PLAN1: lower boundaries (slice, pitch, yaw)' ''''
% 'plan1_UB'              [400   0   0  ]  'PLAN1: upper boundaries (slice, pitch, yaw)'  ''
% %-----------
% 'plan2_tol'             40                  'PLAN2 +/-slice-tolerance'                    ''
% 'plan2_x0'               [nan    0    0   ] 'PLAN2: best guess (slice, pitch, yaw)'      ''
% 'plan2_LB'               [nan  -25   -5  ]  'PLAN2: lower boundaries (slice, pitch, yaw)' ''
% 'plan2_UB'               [nan  +25   +5  ]  'PLAN2: upper boundaries (slice, pitch, yaw)'  ''
}; 

% ==============================================
%  
% ===============================================

p=paramadd(para,x);%add/replace parameter
%     [m z]=paramgui(p,'uiwait',0,'close',0,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .7 .5 ],'title','PARAMETERS: LABELING');

% %% show GUI
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .2 .5 .5 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end

% ==============================================
%%   
% ===============================================


function he=fileselection(e,e2)

% return

% function he=getparmfiles(li,lih)
%     'warpParamfile'  fullfile(fileparts(fileparts(which('ant.m'))),'elastix','paramfiles' ,'p33_bspline.txt')      'parameterfile used for warping'  @getparmfiles
pat=strrep(which('bart.m'),'bart.m','templates');
he=[];
pap=fileparts(which('trafoeuler2.txt'));
msg='select one/more files from template folder to transform"';
[t,sts] = spm_select(inf,'any',msg,'',pat,'.*.nii','');
t=cellstr(t);
if isempty(t{1}); return; end
% t=cellstr(t);
% [s ss]=paramgui('getdata')
% paramgui('setdata','x.wa.orientelxParamfile',[t ' % rem'])
% ==============================================
%%   interpolation
% ===============================================
tb  =[ repmat({true},[length(t) 1]) t];
tbh ={'Interpolation [x]linear;[ ]NN'  'file' };

tooltip={'<html><pre>''<b><font color=red> image interpolation </b> <font color=black>'
    '[x] linear interpolation ...for intensity-based images'
    '[ ] next-neighbour interpolation ...for masks/atlases (preserve values)'
    };
tooltip=  strjoin(tooltip,'<br>');

out=uitable_checklist(tb,tbh,...
    'title','Image Interpolation (see tooltip)','tooltip', tooltip ,...
    'pos', [.2 .2 .5 .3],'postab', [0 0  1 .2],'autoresize',1);
if isempty(out)
    he={};
else
    he=[out(:,2) out(:,1)];
end

return

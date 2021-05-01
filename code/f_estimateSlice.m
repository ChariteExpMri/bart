
function varargout=f_estimateSlice(showgui,x )



%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-FILES
% ===============================================

if exist('x')~=1;        x=[]; end
if isstruct(x) && ~isempty(x.files)  
%     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
    x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a1','.tif' });
end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
% ==============================================
%%   struct
% ===============================================
para={...
    'files'                  ''                'select files'                   'mf'
    
    'inf100'     '===RESIZE IMAGE=========================='                          '' ''
    'channel'               3   'which RGB-channel to use {1,2,3}'                    ''
    'usemanualrotation'     1   'do include manual rotation info, if exist {0,1}' 'b'
    
    'inf101'     '===FIND SLICE PLAN-1&2=========================='                          '' ''
    'parallel'              1       'use parallell-computation' 'b'
    'cellsize'              8      'cellsize of HOG-histogram (larger is rougher )' ''
    'useSSIM'               1       'use Multiscale structural similarity after HOG, otherwise use NORM' 'b'
    'numStartpoints'       100      'number of starting points (recom: 100) of Multistart-optimization' ''
    'doflt'                  0      'Gauss filt altas slice after extraction from 3dvol {0,1}'  'b'
    % -------------------
    '' '' '' ''
    'useHistVol'            1     'TEMPLATE to use: (0) AVGT or (1) HISTOVOL'  'b'
    % -------------------
    'plot'                   1       'plot update for each iteration (slow)' 'b'
    'plotresult'             1       'plot result best "solution" (image)'   'b'
    % ----------
    'plan1_x0'              [200   0   0  ]  'PLAN1: best guess (slice, pitch, yaw)'        ''
    'plan1_LB'              [80    0   0  ]  'PLAN1: lower boundaries (slice, pitch, yaw)' ''''
    'plan1_UB'              [450   0   0  ]  'PLAN1: upper boundaries (slice, pitch, yaw)'  ''
    %-----------
    'plan2_tol'             40                  'PLAN2 +/-slice-tolerance'                    ''
    'plan2_x0'               [nan    0    0   ] 'PLAN2: best guess (slice, pitch, yaw)'      ''
    'plan2_LB'               [nan  -25   -5  ]  'PLAN2: lower boundaries (slice, pitch, yaw)' ''
    'plan2_UB'               [nan  +25   +5  ]  'PLAN2: upper boundaries (slice, pitch, yaw)'  ''
    };
% ==============================================
%%   GUI
% ===============================================
p=paramadd(para,x);


if showgui==1 || showgui==2
    if     showgui==1; pb1string='OK'    ; pb1color='w';
    elseif showgui==2; pb1string='PASS' ;  pb1color=[0.9294    0.6941    0.1255];
    end
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .2 .5 .5 ],...
        'title',[mfilename '.m'],...
        'pb1string',pb1string,'pb1color',pb1color,'info',hlp);
    if isempty(m); 
        varargout{1}=[];
        varargout{2}=[];
        return;
    end
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
elseif showgui==2
     showgui=-1;   %just parse data
end
% ==============================================
%%   Parse parameter without runnning rest
% ===============================================
if showgui==-1
    p2=struct2param(p,z);
    p2=[{['@' mfilename] 0 'FunctionName' ''}; p2]; % add functionName
    varargout{1}=p2;
    varargout{2}= z;
    return
end




% ==============================================
%%   PROCEED
% ===============================================
cprintf([0 0 1],[' estimate slice orientation... '  '\n']);

z.files=cellstr(z.files);
if isempty(z.files{1}); return; end

for i=1:length(z.files)
    z2=z;
    z2=rmfield(z2,'files');
    z2.file=z.files{i};
    estimateSlice(z2);
end




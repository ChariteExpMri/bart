
% resizing tiff for registration

function varargout=f_resizeTiff(showgui,x )

%———————————————————————————————————————————————
%%    PARAMS
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
if ~isfield(x,'files') || isempty(x.files)
    fidi=bartcb('getsel');
    fidi=fidi(strcmp(fidi(:,2),'file'),1);
    x.files=fidi;
end

if ~isfield(x,'isparallel') ; x.isparallel=0; end

% ==============================================
%%   struct
% ===============================================
para={...
 
'inf1'    'RESIZE TIFF-IMAGE FOR ATLAS-REGISTRATION'  ''  ''
'' '' '' ''
'method'                  4     'mask method: [1]DAPI-otsu; [2]WSL-otsu; [3]Threshold,[4]local entropy'                      {1,2,3,4}
'chan'                    3       'RGB-chanel to use (DAPI: 3; WSL: 2)'                                   ''
'' '' '' ''
'' '' '' ''
'removestripes'         0 'remove stripes in background'         'b'



'inf22'    '__METHOD-2___WSL-ots_____________'  ''  ''

'm2_flt'               [11 11] 'method-2 (WSL) ONLY: median filter order'         ''
'm2_otsuclass'         [20]    'method-2 (WSL) ONLY: number of otsu-classes (higher..more sensitive)'         ''

'inf33'    '__METHOD-3___THRESHOLD_____________'  ''  ''
'm3_TR'               'pct50'      'threshold: range 0-255, 0 is background; other thresholds: "pct75":75th percentile, "mean"/"median" ' {'pct75','mean','median' [1],[50]}


'inf44'    '__METHOD-4___LOCAL ENTROPY_____________'  ''  ''
'm4_entropy_fltsize'     3    'disk-size to compute local entropy (default:3) ' {3:7}
'm4_entropy_threshmax'   0.3  'keep values above threshold relativ to max entropy in image  ([1] is pixel with max entropy in image)' {.1:.1:.9}
     
'' '' '' ''


'inf3'       '___OTHER INPUT_____________'  ''  ''

'mask_curvature'   30    'curvature/detail of mask; default:30, larger value is more detailed',{30:20:200}
'imadjust'  1   'adjust Adjust image intensity values {0,1}'   'b'
'fastload'  1  'force tiff-fast-reading (if image size is >5000pix in width&high, read only each 2nd pixel)' 'b'



'percentSurviveMaxCluster' 1    'percent clusterSize w.r.t largest cluster to survive'  ''
'imcloseSizeStep'          10    'stepSize to iterative combine separate clusters'      ''
'resize'             [2000 2000]  'size of the resized image'                           ''
'doplot'                  0       'plot image to screen'                                'b'
'isparallel'      x.isparallel    'use parallel processing {0,1}'              'b'
};
% 'files'    {}          'histo-files'  'mf'

% ==============================================
%%   GUI
% ===============================================
p=paramadd(para,x);


if showgui==1 || showgui==2
    if     showgui==1; pb1string='OK'    ; pb1color='w';
    elseif showgui==2; pb1string='PASS' ;  pb1color=[0.9294    0.6941    0.1255];
    end
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.1 .2 .6 .5 ],...
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

% ==============================================
%%   
% ===============================================
xmakebatch(z,p, mfilename); % ## BATCH

% ==============================================
%%   
% ===============================================

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
cprintf([0 0 1],[' resize Histo-slices... '  '\n']);

z.files=cellstr(z.files);
if isempty(char(z.files)); return; end

if z.isparallel==0
    for i=1:length(z.files)
        z2=z;
        z2=rmfield(z2,'files');
        resizeTiff(z.files{i},z2);
    end
else
    parfor i=1:length(z.files)
        z2=z;
        z2=rmfield(z2,'files');
        resizeTiff(z.files{i},z2);
    end
end




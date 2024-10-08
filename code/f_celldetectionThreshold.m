
function varargout=f_celldetection(showgui,x )

%source: snip_a4_test_celldetector3_largeTiff.m

% ==============================================
%%     PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-FILES
% ===============================================

if exist('x')~=1;        x=[]; end
% if isstruct(x) && ~isempty(x.files)  
% %     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
%     x.files =regexprep(x.files,{ [filesep filesep 'a1_'] '.tif'},{[filesep filesep 'optim_'],'.mat' });
% end

templateDir=fullfile(fileparts(which('bart.m')),'templates');

% if ~isfield(x,'approach')
%     x.approach=1;
% end

% ==============================================
%%   paramter
% ===============================================
para={...
'task'         [1:4]   'task: [1]image splitting [2]cell detection [3]image stitching; combination possible such as [1 2 3]' {1 2 3 4}
'inf1' '___IMG-SPLITTING________' '' ''
'splitsize'    [600 600] 'image split size' ''
'paddingValue' 255       'intensity value for padding' ''
'' '' '' ''
'inf2' '___DETECTION________' '' ''
'RGBchan'        2        'RGB-channel for cell-detection'  {1,2,3}
'polarity'     'dark'    'cell-polarity' {'bright','dark'}
'method'        'otsu'    'image threshold method {"otsu"|"thresh"}'        {'otsu' 'thresh'}
'otsucluster'    7        'if "method" is "otsu"  : number of Otsu-clusters'  {3:8}
'otsuthreshold'  1        'if "method" is "otsu"  : values below/equal this Otsu-class are considered as background'  {1 2 3}
'threshold'     0.1       'if "method" is "thresh": values below/equal this value are considered as background'  {linspace(.1,.3,5)}
'medfilt'      []        'median filter image [two values] or empty'  ''
'radius'      [5 15]     'detection radius of cells [3 7] IMPORTANT!!!'  '' %[3 7]; %[10 30]
'sens'        0.85       'sensitivity (0-1) ...larger is more sensitive' ''
'' '' '' ''
'inf3' '___DISTANCE________' '' ''
'doCellDistanceThresh' 1  'remove nearby markers (if cell detected markers are to close to each other)' 'b'
'minCellDistance'      20  'cell distance threshold, cell marker with lower distance to next marker will be removed' {1 5 10 15 20 25 30}
'' '' '' ''
'inf4' '__TEST________' '' ''
'istest'      0       'testmode: {0}NO, run and save all,  {1}YES, TEST ONLY'  'b'
'testimage'   [1:10]  'ONLY OF istest is 1, plot this test-image numbers ' ''
'' '' '' ''
'meth' 'TwoStage'  'method to use'  {'TwoStage'}
'' '' '' ''
% % -----fdo 2nd sensitivyty
% 'inf25' '___SENSITIVITY2 ("TwoStage" only)________' '___________________________________' ''
% 'doHD'     0         'for "TwoStage" only, apply 2nd sensitivity for hippocampus.' 'b'
% 'radiusHD' [3 7]     ' doHD only:  cell detection radius'  ''
% 'sensHD'   .99       ' doHD only: sensitivity  (0-1) ...larger is more sensitive' '' 
% % -----intensity threshold
% 'inf26' '___INTENSITY-THRESHOLD ("TwoStage" only)________' '___________________________________' ''
% 'doIntensTresh'   0  'do intensitiy threshold, values above that values cannot be cells ' ''
% 'IntensTresh'   100   'suggested cell must have mean value BELOW this value to be valid '  ''
% %------min cellDistance
% 'inf27' '___CELL-DISTANCE-THRESHOLD ("TwoStage" only)________' '___________________________________' ''
% 'doCellDistanceThresh'  1  'cells to close to each other will be "merged"'   'b'
% 'minCellDistance'   7    'distance between cells (morph-operation value)...larger more merging/fewer cells'  ''
% '' '' '' ''
'inf30' '___MISC________' '' ''
'dotplotsize' 1  'show  cell-plot size/histogram (pye)' 'b'
'showcounts'  0   'show counts ??'  'b'
'color'       'm' 'cell-detection color'  ''
'isparallel'   0 'PARALLEL COMPUTIATION...might be faster'  'b'
};



% ==============================================
%   GUI
% ===============================================
p=paramadd(para,x);


if showgui==1 || showgui==2
    if     showgui==1; pb1string='OK'    ; pb1color='w';
    elseif showgui==2; pb1string='PASS' ;  pb1color=[0.9294    0.6941    0.1255];
    end
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .2 .5 .6 ],...
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
%%   batch
% ===============================================

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
%%   files
% ===============================================
if isfield(x,'files') && ~isempty(char(x.files))
    z.files=x.files;
else
  fidi=bartcb('getsel')  ;
    z.files=fidi(strcmp(fidi(:,2),'file'),1);
end
% return
% ==============================================
%%   PROCEED
% ===============================================
cprintf([0 0 1],[' CELL-DETECTION via Threshold... '  '\n']);

z.files=cellstr(z.files);
if isempty(z.files{1}); return; end

if z.isparallel==1
    parfor i=1:length(z.files)
        z2=z;
        z2=rmfield(z2,'files');
        z2.file=z.files{i};
        celldetectionThreshold(z2);
    end
else
    for i=1:length(z.files)
        z2=z;
        z2=rmfield(z2,'files');
        z2.file=z.files{i};
        celldetectionThreshold(z2);
    end
end

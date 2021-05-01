
function varargout=f_warpestSlices(showgui,x )



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
    x.files =regexprep(x.files,{ [filesep filesep 'a1_'] '.tif'},{[filesep filesep 'optim_'],'.mat' });
end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
% ==============================================
%%   struct
% ===============================================
para={...
'files'           ''                'select "optim-mat"-file(s)'                   'mf'
  'doplot'          1          'plot result {0,1}'  'b'
  'nbest'           inf        'warp nbest-slices (i.e. the n-best canditates), "inf": warp all available slices (defined by "f_estimateSlice.m" ) '  {inf,100}
  'cellsize'        8           'HOG-cellSize (larger is rougher)' ''
  'useSSIM'         1          'use Multiscale structural similarity' 'b'
  'size'           [330 450]   'image-size to calculate HOG..do not change!'  ''
  'nresolutions'   [1 1 ]     'number of pyramids for affine/nonlinear registration: resolutions (val1): affine registration (val2) B-spline registration (values>1 takes longer but might be more precise)' ''
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
cprintf([0 0 1],[' warp estimated slices... '  '\n']);

z.files=cellstr(z.files);
if isempty(z.files{1}); return; end

for i=1:length(z.files)
    z2=z;
    z2=rmfield(z2,'files');
    z2.file=z.files{i};
    try
        warpestSlices(z2);
    catch
        warpestSlices(z2);
    end
    
end




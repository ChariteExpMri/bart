
% batch_example
% % =====================================================
% % #g FUNCTION:        [f_cell2atlasaggregate.m]
% % #b info :            f_cell2atlasaggregate is a function.
% % =====================================================
% z=[];
% z.atlas         = 'F:\tools\bart_template\ANO.xlsx';                               % % reference atlas (excel-file)
% z.evalable      = 'G:\data1\josefine\result\bart_evaluationTable_filled.xlsx';     % % load evaluation table (excelfile)
% z.isparallel    = [0];                                                             % % do parallel processing {0,1}
% z.removeNANrows = [1];                                                             % % remove Nan-rows (regions with no cells detected will be removed)
% z.showTable     = [0];                                                             % % show output table {0,1}
% z.save          = [1];                                                             % % save result as excelfile {0,1}
% z.save_dir      = 'G:\data1\josefine\result\regdensity';                           % % saving output-directory
% z.save_prefix   = 'atc_';                                                          % % add Prefix to output-filename
% z.debug         = [0];                                                             % % just for debugging..show more plots
% f_cell2atlasaggregate(0,z);



function varargout=f_cell2atlasaggregate(showgui,x )

disp(['executing: ' mfilename '.m']);


% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-FILES
% ===============================================

if exist('x')~=1;        x=[]; end
% if isstruct(x) && ~isempty(x.files)  
% %     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
%     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a1','.tif' });
% end
% ==============================================
%%   atlas
% ===============================================
global ak
refatlas=fullfile(ak.template,'ANO.xlsx');
% templateDir=fullfile(fileparts(which('bart.m')),'templates');

outputpath=fullfile(fileparts(ak.dat),'result', 'regdensity');
% mkdir(outputpath);
% ==============================================
%%   struct
% ===============================================
para={...
   
    'atlas'              refatlas  'reference atlas (excel-file)'    'f' 
    'evalable'          ''     'load evaluation table (excelfile)'         'f'
    'isparallel'         0   'do parallel processing {0,1}'        'b'
    'removeNANrows'      1 'remove Nan-rows (regions with no cells detected will be removed)'  'b'   
    'showTable'          0   'show output table {0,1}'                    'b'
    'save'               1   'save result as excelfile {0,1}'       'b'
    'save_dir'           outputpath    'saving output-directory'         'd'
    'save_prefix'       'atc_'    'add Prefix to output-filename'     ''
    '' '' '' ''
    'debug'       0   'just for debugging..show more plots'  'b'
    };
%     '' '' '' ''
%     '' '____OPTIONAL USED FILES_______' '' ''
%      'files'                  ''                'select files'                   'mf'

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
        'title',['aggregate atlas-based cellcounts over slices (' mfilename '.m)'],...
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
% return
mkdir(z.save_dir);
fist  =bartcb('getselstacked');

%% ===========read evaluation table ===============
if exist(z.evalable)==2
    [~,~, a0]=xlsread(z.evalable);
    cprintf([.4 .7 .2],['..using evaluationTable: "'  strrep(z.evalable,filesep,[filesep filesep]) ' "\n']);
    
     ha=a0(1,:);
     a=a0(2:end,:); 
     a(find(strcmp(cellfun(@(a){[num2str(a)  ]}, a(:,1)),'NaN')),:)=[];
     
     z.info_evaluationTable={'evaluationTable: "het", "et"'};
     z.het=ha;
     z.et =a;
end


%% ===============================================




cprintf([0 0 1],[' aggregate atlas-based cellcounts over slices [' mfilename '.m]... '  '\n']);
timex=tic;
if isempty(max(cellfun(@length,fist))); return; end

if z.isparallel==0
    for i=1:length(fist)
        z2=z;
        z2.files=fist{i};
        cell2atlasaggregate(z2);
    end
else
   disp('...using parallel computing...');
   parfor i=1:length(fist);
        z2=z;
        z2.files=fist{i};
        cell2atlasaggregate(z2);
    end 
end
cprintf([0 0 1],[' Done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);







function varargout=f_makeDatabase(showgui,x )

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
% if isstruct(x)  
%     if ~isfield(x,'files') || ~isempty(x.files) 
% %     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
%     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a1','.tif' });
% end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
% ==============================================
%%   struct
% ===============================================
para={...
   
    'files'  ''   'load all excelfiles containing regionwise cellcounting  '        'mf'
    'saveBigTable' 1  'save big table with all animals '            'b'
    'showTable'   0   'show output table {0,1}'                    'b'
    };
%     '' '' '' ''
%     '' '____USED FILES_______' '' ''
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
        'title',['assignCells to atlas (' mfilename '.m)'],...
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
%%   get all xlsfile-files
% ===============================================




% ==============================================
%%   make big table
% ===============================================
cprintf([0 .7 0],'make BIG table...');
b=[];
for i=1:length(z.files)
    
    [~,~,a0]=xlsread(z.files{i});
    a0(:,strcmp(cellfun(@(a){[num2str(a)  ]}, a0(1,:) ),'NaN'))=[];
    a0(strcmp(cellfun(@(a){[num2str(a)    ]}, a0(:,1)),'NaN'),:)=[];
    
    if i==1
        hb=a0(1,:);
    end
    a=a0(2:end,:);
    b=[b;a];
end
cprintf([0 .7 0],'..Done!\n');
% ==============================================
%%   save table
% ===============================================
if z.saveBigTable==1
    cprintf([0 .7 0],'..saving BIGtable...');
    [paout animal ext]=fileparts(z.files{1});
    paout2=fullfile(paout,'BigTable');
    warning off;
    mkdir(paout2)
    try; delete(f1); end
    f1=fullfile(paout2,'bigtable.xlsx');
    pwrite2excel(f1,{1 'celldensALL'},hb,[],b);
    showinfo2('..BIGtable',f1);
    cprintf([0 .7 0],'..Done!\n');
end
























%% #b make project
%% #b         



function f_makeProject(showgui,x )



%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end
% if exist('pa')==0      || isempty(pa)      ;    pa=antcb('getallsubjects')  ;end
% 
% if ischar(pa);                      pa=cellstr(pa);   end
% if isempty(x) || ~isstruct(x)  ;  %if no params spezified open gui anyway
%     showgui  =1   ;
%     x=[]          ;
% end
% 
% ==============================================
%% PARAMETER-gui
% ===============================================

if exist('x')~=1;        x=[]; end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
%% import 4ddata
para={...
    'inf98'      '*** Make Project                 '                         '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'inf100'     '==================================='                          '' ''
    'main'                  ''               'select main folder for data analysis to <required to fill> '  'd'
    'template'             templateDir       'select main template folder <required to fill>'  'd'
%     'keepSubdirStructure'   1          '[0,1]: [0] flattened hierarchy (no subdirs), [1] the destination path contains the subfolders  '    'b'
%     'animalsubdirs'         1          '[0,1]: [1] preserve SUBFOLDERS WITHIN ANIMAL FOLDERS in either output name or folder hierarchy or [0] do not preserve' 'b'
%     'prefixDirName'         0          'adds mouse Dir/folder name as prefix to the new filename'      'b'
%     'renameString'         ''          'replace file name with new file name (no file extention), !NOTE: files might be overwritten (same output name)'  {'mask' 'raw' 'test'}
%     'addString'            ''          'add string as suffix to the output file name'                                                            ''
%     'reorient'             ''          ' <9 lement vector> reorient volume, default: []: do nothing; (nb: use [0 0 0 0 0 0 1 -1 1] if data came from DSIstudio)'  {'0 0 0 0 0 0 -1 1 1';'0 0 0 0 0 0 1 -1 1'; '0 0 0 0 0 0 -1 -1 1'}
     };

p=paramadd(para,x);%add/replace parameter
%     [m z]=paramgui(p,'uiwait',0,'close',0,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .7 .5 ],'title','PARAMETERS: LABELING');

% %% show GUI
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end

% add dat-folder
z.dat=fullfile(z.main,'dat');
is=find(strcmp(p(:,1),'main'));
p=[p(1:is,:); {'dat' '' ,'data-folder' 'x'}; p(is+1:end,:) ];

m2=strsplit(m,char(10))';
is=regexpi2(m2,'x.main');
m2=[m2(1:is,:); {['x.dat     =  ''' z.dat '''; % data-folder' ]}; m2(is+1:end,:) ];


disp('..save project..');
xmakebatch(z,p, mfilename); % ## BATCH


% ==============================================
%%   proceed
% ===============================================

warning on;
mkdir(z.dat);


[fi pa]=uiputfile(fullfile(z.main,'proj.m'),'name of the project-file ');
fiout=fullfile(pa,fi);
fiout=regexprep(fiout,'\.m$' ,'.m');


pwrite2file(fiout,m2);

disp(['project generated: ' fiout ]);












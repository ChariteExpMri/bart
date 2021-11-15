function varargout=bartcb(varargin)

if 0
    bartcb('update')
%     [s1 s2]=bartcb('getallsubjects');
    bartcb('close')
    bartcb('load')
    bartcb('load','F:\data3\histo2\data_Josephine\proj.m')
    bartcb('getsel')
    bartcb('updateListboxinfo');
end

if nargin==0; return; end

if strcmp(varargin{1},'update')
    update(varargin);
elseif strcmp(varargin{1},'getallsubjects')
    [varargout{1} varargout{2}]=getallsubjects(varargin);
elseif strcmp(varargin{1},'close')
    closebart()
elseif strcmp(varargin{1},'load')  
    loadproject(varargin)
elseif strcmp(varargin{1},'getsel')
    [varargout{1} varargout{2}]=getsel(varargin);
elseif strcmp(varargin{1}, 'updateListboxinfo')
   updateListboxinfo();
elseif strcmp(varargin{1}, 'version')
   varargout{1} =version(varargin);
end


function out=version(varargin)
vstring=strsplit(help('bartver'),char(10))';
idate=max(regexpi2(vstring,' \w\w\w 20\d\d (\d\d'));
dateLU=['BART vers. ' char(regexprep(vstring(idate), {' (.*'  '  #\w\w ' },{''}))];
out=dateLU;



function [ fpdirs dirs] =getsel(arg)
hf=findobj(0,'tag','bart');
hb=findobj(hf,'tag','lb1');
global ak
 fpdirs=ak.list1(hb.Value,:);
 dirs=[];

 
 
 
%  currstr=hb.String(hb.Value);
%  dirs=regexprep(currstr,{'#.*' '<html>' '\s+' '&nbsp;'},'') ;
% if ~isempty(dirs)
%     fpdirs=stradd(dirs,[ak.dat filesep],1);
% else
%    fpdirs=[]; 
%    dirs  =[];
% end



function loadproject(arg)
usegui=1;
if length(arg)==1
    usegui=1;
else
    usegui=0;
    if exist(arg{2})~=2
       usegui=1;  
    end
end

if usegui==1
    [fi pa ]=uigetfile(pwd,'select project to load');
    if isnumeric(fi); return; end
    projfile=fullfile(pa,fi);
else
    projfile=arg{2};
    [pa fi ext]=fileparts(projfile);
    fi=[fi ext];
end
    

hf=findobj(0,'tag','bart');
if isempty(hf)
    bart();
end



lastpath=pwd;
cd(pa);
run(regexprep(fi,'\.m',''));
cd(lastpath);

global ak;
ak=x;
disp(['loaded project: '  projfile  ' ; global: "ak"']);
set(findobj(0,'tag','bart'),'name',['BART: ' projfile]);
ak.configfile = projfile;
%listbox2 ------------------
if 0
    fcn=bart_fcn();
    hb=findobj(hf,'tag','lb2');
    val=get(hb,'value');
    set(hb,'string',cellfun(@(a,b){[b ' [' a ']']},fcn(:,1),fcn(:,2)));
    try
        set(hb,'value',val);
    catch
        set(hb,'value',[]);
    end
end
% ------------------


bartcb('update');
% ==============================================
%%  history
% ===============================================
barthistory('update');
% ==============================================
%%   
% ===============================================

function closebart()
hf=findobj(0,'tag','bart');
if ~isempty(hf)
    set(hf,'CloseRequestFcn', 'closereq');
    close(hf);
end
clear global ak;


function updateListboxinfo()
try
    hf=findobj(0,'tag','bart');
    hb=findobj(hf,'tag','lb1');
    global ak;
    ndirs   =sum(strcmp(ak.list1(:,2),'dir'));
    nfiles =sum(strcmp(ak.list1(:,2),'file'));
    
    
    [sel]=bartcb('getsel');
    if isempty(sel);
        ndirsSel  =0;
        nfilesSel =0;
    else
        ndirsSel  =sum(strcmp(sel(:,2),'dir'));
        nfilesSel =sum(strcmp(sel(:,2),'file'));
    end
    
    hl=findobj(hf,'tag','listboxinfo');
    m=[ num2str(ndirsSel) '/' num2str(ndirs) ' dirs; ' num2str(nfilesSel)  '/' num2str(nfiles) ' files'];
    set(hl,'string',m);
end


function update(var)
warning off
drawnow;
%% ===============================================
hf=findobj(0,'tag','bart');
hb=findobj(hf,'tag','lb1');
global ak;
try
    %  [s1 s2]=bartcb('getallsubjects');
    %update function-LB
    lb2=findobj(hf,'tag','lb2');
    ival=get(lb2,'value');
    fcn=bart_fcn();
    set(lb2,'string',cellfun(@(a,b){[b ' [' a ']']},fcn(:,1),fcn(:,2)))
    set(lb2,'value',ival);
    
%     -----------------
    %     'a'
    if isfield(ak,'list1')
        selectedStrings=ak.list1(hb.Value,1);
    else
        selectedStrings=[];
    end
        
    
    [dirs fpdirs ms ms2]=getdirs();
    
%     [slices fpslices]=getslices(fpdirs);

   set(hb,'string',ms,'fontname','courier');%,'fontsize',6);
  %    set(hb,'string',fpslices,'fontname','courier','fontsize',6);
    set(hb,'value',[]);
    ak.list1Html=ms;
    ak.list1    =ms2;
    if ~isempty(selectedStrings)
    set(hb,'value',find(ismember( ak.list1(:,1), selectedStrings))); % previous selecition
    end
    
catch
    set(hb,'value',[]);
end

tooltip=html_dirs();
us.tooltip=tooltip;
set(hb,'userdata',us);
set(hb,'tooltipstring',['<html>' strjoin(tooltip,'<br>') ]);
updateListboxinfo;
drawnow;



jScrollPane = findjobj(hb);
jListbox = jScrollPane.getViewport.getComponent(0);
set(jListbox, 'MouseMovedCallback', {@mouseMovedCallback,hb});

function mouseMovedCallback(jListbox, jEventData, hListbox)
try
    
    % Get the currently-hovered list-item
    mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
    hoverIndex = jListbox.locationToIndex(mousePos) + 1;
    listValues = get(hListbox,'string');
    hoverValue = listValues{hoverIndex};
    % Modify the tooltip based on the hovered item
    msgStr = sprintf('<html>item #%d: <b>%s</b></html>', hoverIndex, hoverValue);
    us=get(hListbox,'userdata');
    %    img={'<img src="file:/F:\data5_histo\MRE_anna1\dat\DAPI_Naive2\a1_001.jpg" alt="Girl in a jacket"><br>'}
    t1=[hoverValue;{'<font size="5" face="arial" color="red">'} ;us.tooltip];
    t1=strjoin(t1,'<br>');
    set(hListbox, 'Tooltip',t1);
    
    
    %    s=get(hListbox,'string')
    global ak
    f1= ak.list1{hoverIndex};
    [pa name ext]=fileparts(f1);
    f2=fullfile(pa,[name '.jpg']);
    if exist(f2)==2
        hr=findobj(findobj(0,'tag','bart'),'tag','currentImage');
        if isempty(hr)
            hr=uicontrol('style','pushbutton','units','norm','tag','currentImage') ;
            set(hr,'position',[  0.501 0  .2 .2],'backgroundcolor','w');
        end
        set(hr,'tooltipstring',[strrep(msgStr,'<html>','<html>image under cursor<br>') ]);
        set(hr,'visible','on');
        set(hr,'units','pixels');
        pos=get(hr,'position');
        img=imread(f2);
        mn=min([pos(3) pos(4)]);
        img=imresize(img,[mn mn]);
        set(hr,'Cdata',img);
    else
        hr=findobj(gcf,'tag','currentImage');
        set(hr,'visible','off');
        
        
    end
end
      
  

%    filePath='F:\data5_histo\MRE_anna1\dat\DAPI_Naive2\a1_001.jpg';
%    filePath = strrep(['file://' filePath],'\','\');
%    t2 = ['<html><center><img src="' filePath '"><br />' ...
%        '<b><font color="blue">' filePath];
%  t2=['<html>  <img src="file://F:/data5_histo/MRE_anna1/dat/DAPI_Naive2/a1_001.jpg" alt="img" style="width:50px;height:50px;"><br></html>' ];
%   t2=['<html>  <img src="F:\\data5_histo\\MRE_anna1\\dat\\DAPI_Naive2\\a1_001.jpg" alt="Girl" style="width:250px;height:250px;"/><br></html>' ];



% TT = "<html>" + "This is the "  + "<img src=\"file:cut.gif\">" + " tool tip text." + "</html>";

%   filePath = '"F:\data5_histo\MRE_anna1\table.png"';
%   filePath = strrep(['file:/' filePath],'\','/');
%   t2 = ['<html><img src=\' filePath '><br /></html>']
% %   t2=['<html><img src\="https://www.w3schools.com/images/picture.jpg" alt="Mountain" style="width:250px;height:250px;>']
%  jListbox.setToolTipText(t2)
%  <img src="C:\\wamp\\www\\site\\img\\mypicture.jpg"/>
%   set(hListbox, 'Tooltip',t2);

%% ===============================================
function [slices fpslices]=getslices(dirs)

slices={};
fpslices={};
for i=1:length(dirs)
    dx=dirs{i};
    [files,~] = spm_select('List',dx,[ 'a1_\d\d\d.tif' ]);
    slices=[slices; cellstr(files)];
    [~, pa]=fileparts(dx)
     fpslices=[fpslices ;   stradd(cellstr(files), [pa filesep ],1) ];
end






function [dirs fpdirs ms ms2]=getdirs()
% ==============================================
%%
% ===============================================
global ak
pa=ak.dat;
kk=dir(pa);
dirs={kk(find(cellfun('isempty',regexpi({kk.name}','^\.$|^\..$')))).name}';
isdirx=[];
for i=1:length(dirs)
    fpdirs{i,1}=fullfile(pa,dirs{i} );
    isdirx(i)=isdir(fpdirs{i,1});
end
dirs=dirs(isdirx==1);
fpdirs=fpdirs(isdirx==1);


list={...
    'raw\*.tif'      'raw'
    '*.tif'          'SL'
    %     'o_struct.mat'  'Ostruct'
    %     'bestslice.mat' 'bslice'
    %     'par_*.txt'     'warped'
    };
list2={};

fpdirs={};
for i=1:length(dirs)
    fpdirs{i,1}=fullfile(pa,dirs{i} );
    
    tg={};
    
    for j=1:size(list,1)
        k=dir(fullfile(fpdirs{i,1},list{j,1}));
        if isempty(k)
            v=0;
            date='-';
        else
            v=1;
            date=k(1).date;
        end
        tg=[tg; {list{j,2} v  date}];
        
    end
    list2{i}=tg;
end

% %  set(lb,'string',{'<html>234 HS<font color =#008000> &#9632'})
% % set(lb,'string',{'<html>234 HS<font color =#e6e6e6> &#9632'})
% status
lenMax=size(char(dirs),2);

% make max dirs-length
dirs2=cellfun(@(a){[ a repmat(' ', [1 lenMax-length(a)]) ]},dirs);
dirs2=strrep(dirs2,' ','&nbsp;');

ms={};
ms2={};
for i=1:length(list2);
    m=['<html><b><u>' dirs2{i}  '</b></u> # '];
    r=fpdirs{i};
    for j=1:size(list2{i},1)
        if  list2{i}{j,2} ==1 %exist
            m=[m    '<font color =#008000> &#9632' ] ;
        else
            m=[m    '<font color =#e6e6e6> &#9632' ];
        end
        
        m=[m '<font color =#000000>'  list2{i}{j,1}  ];
    end
    [files,~] = spm_select('List',fpdirs{i},[ 'a1_\d\d\d.tif' ]);
    if isempty(files)
       ms= [ms; {m}]; 
       ms2=[ms2; {r 'dir'}];
    else
        slic=cellstr(files);
%           slicHtml=cellfun(@(a){['<html><b><font color =blue>'  a ]},slic);
          
          %% colorcode slice---------------------------
%           pv=fullfile(r,)
        slicHTML= html_dirs(r, slic);
          
          
          %% --------------------------- 
         ms =[ms; {m}; slicHTML];
         tx=[cellfun(@(a){[ r filesep a ]},slic) ];
         tx(:,2)=repmat({'file'},[size(tx,1) 1]);
         ms2=[ms2;{r 'dir'}; tx]; %DIRECT PATH;
    end
end
% set(hb,'string',ms,'fontname','courier');


function v3=html_dirs(r, slic)
% ==============================================
%%   
% ===============================================
colblank=[repmat(.1,[1 3])];
t={...
    'a2_#.mat'             [0 0 1]                         'Tif resized'
    'a2_#mod.tif'          [0.0588    1.0000    1.0000]    'modified Tif-image exists'     
    'optim_#.mat'          [0.9294    0.6941    0.1255]    'slice-finder executed' 
    'warp_#.mat'           [1 0 0 ]                        'suggested slices warped'
    'bestslice_#.mat'      [ 0.4667    0.6745    0.1882]   'best slice selected'
    ['fin' filesep 's#_result.gif']      [1 0 1]   'backtransformed images to histo-space'
    ['cellcounts_a1_#' filesep 'predfus.tif'] [0 0 0] 'cell-detection'
    ['fin' filesep 's#_cellcountsRegion.mat']      [.5 .5 .5]   'regionwise cellcounts/area calc'
    };
if exist('r')~=1
    % ==============================================
    %%
    % ===============================================
%     <html><pre>
    v3={};
    for j=1:size(t,1)
        if isnumeric(t{j,2})
        colhex=sprintf('%02X',round([t{j,2}]*255));
        else
            colhex=t{j,2};
        end
       v3{j,1}= [    '<font color =#' colhex '>&#9632' ...
            '<font color =black><b> ' t{j,3} '</b>' ' [' t{j,1} ']' ];
    end
    return
%     uhelp([ {''}; v3])
    %set(hb,'tooltipstring',['<html>' strjoin(v3,'<br>') ])
    % ==============================================
    %%
    % ===============================================
    
    
end


%----check status-mat and load if exists
  fi_status=fullfile(r,'status.mat');
  st=[];
  if exist(fi_status)==2
     load(fi_status) 
  end

% ------

% clc;
v3={};
for i=1:length(slic)
    ps=fullfile(r,slic{i});
    [~, name, ext]=fileparts(slic{i});
    name2=strrep(name,'a1_','');
    v=' ';
    for j=1:size(t,1)
        fil=fullfile(r, [strrep(t{j,1},'#',name2)]);
        if exist(fil)==2
            %disp('is');
            colhex=sprintf('%02X',round([t{j,2}]*255));
            v=[v    '<font color =#' colhex '>&#9632' ];
        else
            %disp('is not');
            colhex=sprintf('%02X',round([colblank]*255));
            v=[v    '<font color =#' colhex '>&#9633' ];
        end
    end
    v2=['<html><b><font color =blue>'   [ slic{i} ] v];
    %disp(v2);
    
    if ~isempty(st)
        ix=find(strcmp(st.fis(:,1), regexprep( slic{i} ,'.tif','')));
        if st.fis{ix,2}==1              %ok
          v2=[v2  '<font color=green>  &#9819'  ];
        elseif st.fis{ix,2}==-1         %problematic
          v2=[v2    '<font color=red>  &#9876'   ];
        elseif st.fis{ix,2}==2         %work
          v2=[v2    '<font color=#ff8c00>  &#9873'  ];
        end
    end
    
    
 v3{i,1}=v2;
end

% uhelp([ {''}; v3])


% ==============================================
%%   
% ===============================================

function [dirs fpdirs]=getallsubjects(var)
%% ===============================================
global ak

k=dir(ak.dat);
name={k.name}';
dirs=name(find([k(:).isdir]));
%  [files,dirs] = spm_select('FPList',ak.dat,'')
dirs(regexpi2(dirs,'^.$|^..$'))=[];
if ~isempty(dirs)
    fpdirs=stradd(dirs,[ak.dat filesep],1);
else
   fpdirs=[]; 
   dirs  =[];
end

% varargout{1}=dirs;
% varargout{2}=fpdirs;




%% ===============================================
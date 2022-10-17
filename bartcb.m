
%% get selected files and folders
% fidi=bartcb('getsel'); %get selected files/dirs
% fidi=bartcb('getall'); %get all files/dirs
% fi  =bartcb('getselstacked') ;%get files, stacked animalwise
% v=bartcb('getanimals'); % get struct with animal-names, No slices, and FPdirs of selected animals 
% w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
% w.files =fidi(strcmp(fidi(:,2),'file'),1);
%% select files/dirs in listbox
% ---------select via grouping tag-----
% bartcb('sel','group',[1]);
% bartcb('sel','group',[1 3]);
% ---------select via  ratng tag-----
% bartcb('sel','tag','ok');
% bartcb('sel','tag','issue|ok');
% ---------select based on string in fullpathFileName-----
% bartcb('sel','filename',v);
% bartcb('sel','filename','test_2figs\a1_001');
% ---------select string in FILEs-----
% bartcb('sel','file','Nai|half');
% bartcb('sel','file','Nai|half|a1');
% bartcb('sel','file','a1_001');
% bartcb('sel','file','all');  %select all files
% ---------select string in DIRs-----
% bartcb('sel','dir','Nai|half');
% bartcb('sel','dir','fside');
% bartcb('sel','dir','all'); %select all dirs
% =============================================
% bartcb('reload') ;% reload BART

function varargout=bartcb(varargin)

if 0
    bartcb('update')
%     [s1 s2]=bartcb('getallsubjects');
    bartcb('close')
    bartcb('load')
    bartcb('load','F:\data3\histo2\data_Josephine\proj.m')
    bartcb('getsel')
    bartcb('getall')
    bartcb('sel')
    bartcb('updateListboxinfo');
end

if nargin==0; return; end

if strcmp(varargin{1},'update')
    update(varargin);
elseif strcmp(varargin{1},'reload')
    bart_reload(varargin);
elseif strcmp(varargin{1},'getallsubjects')
    [varargout{1} varargout{2}]=getallsubjects(varargin);
elseif strcmp(varargin{1},'close')
    closebart()
elseif strcmp(varargin{1},'load')  
    loadproject(varargin)
elseif strcmp(varargin{1},'getsel')
    [varargout{1} varargout{2}]=getsel(varargin);
elseif strcmp(varargin{1},'getall')
    [varargout{1} varargout{2}]=getall(varargin);
elseif strcmp(varargin{1},'getselstacked')
    [varargout{1} varargout{2}]=getselstacked(varargin);  
elseif strcmp(varargin{1},'getanimals')
    [varargout{1} varargout{2}]=getanimals(varargin); 
    
elseif strcmp(varargin{1},'sel')
    [varargout{1} varargout{2}]=sel(varargin);    
    
elseif strcmp(varargin{1}, 'updateListboxinfo')
   updateListboxinfo();
elseif strcmp(varargin{1}, 'version')
   varargout{1} =version(varargin);
elseif strcmp(varargin{1}, 'versionupdate')
  versionupdate(varargin);
end

function bart_reload(varargin)
global ak;
cfile=ak.configfile;
bart;
loadproject({1,cfile});

function versionupdate(varargin)
hc=findobj(findobj(0,'tag','bart'),'tag','txtversion');
if isempty(hc); return; end
version=bartcb('version');
set(hc,'string',version);
return



function out=version(varargin)
vstring=strsplit(help('bartver'),char(10))';
idate=max(regexpi2(vstring,' \w\w\w 20\d\d (\d\d'));
dateLU=['BART vers. ' char(regexprep(vstring(idate), {' (.*'  '  #\w\w ' },{''}))];
out=dateLU;

function [ fpdirs dirs] =getall(arg)
hf=findobj(0,'tag','bart');
hb=findobj(hf,'tag','lb1');
global ak
 fpdirs=ak.list1;
 dirs=[];
 
function [ v dirs] =getanimals(arg)
[ v dirs] =deal([]);


%% ===============================================

fi  =bartcb('getselstacked');
t={};
for i=1:length(fi)
   [pax slice]=fileparts(fi{i});
   [px animal]=fileparts(pax{1});
   dx={animal  size(slice,1) fullfile(px,animal)};
   t(i,:)=dx;
end

v.dirs =t(:,3);
v.names=t(:,1);
v.ht={'animal' 'Nslices' 'dir'};
v.t=t;
v.N=size(v.dirs,1);


  %% ===============================================
  

function [ fpdirs dirs] =getselstacked(arg)
[ fpdirs dirs] =deal([]);
%% ===============================================

 fidi=bartcb('getsel');
 
 % if dir is selected
 files2='';
 dirs=fidi(strcmp(fidi(:,2),'dir'),1);
 for i=1:length(dirs)
     [fidum] = spm_select('FPList',dirs{i},'^a1_.*.tif$');
     fidum=cellstr(fidum);
     if ~isempty(fidum)
     files2=[files2; fidum];
     end
 end
 files1=fidi(strcmp(fidi(:,2),'file'),1);
 if isempty(files1)
     files=files2;
 else
     files=files1;
 end
 
 files=unique([files;files2]);
 %% ===============================================
 
[px ]=fileparts2(files);
animal=unique(px);
stack={};
for i=1:length(animal)
    ix=~cellfun(@isempty,strfind(files,animal{i}));
    stack{i,1}=files(ix);
end
fpdirs=stack;
%% ===============================================



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
delete(findobj(hf,'type','axes')); %delete axis from other window
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


try
    jScrollPane = findjobj(hb);
    jListbox = jScrollPane.getViewport.getComponent(0);
    set(jListbox, 'MouseMovedCallback', {@mouseMovedCallback,hb});
end

function mouseMovedCallback(jListbox, jEventData, hListbox)
warning off;
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
        if size(img,3)==1; img=repmat(img,[1 1 3]);end
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
    ['fin' filesep 's#_result.gif']      [1 0 1]   'backtransformed result (gif-plot) to histo-space'
    ['fin' filesep 's#_AVGT.mat'  ]      [ 0.7176    0.2745    1.0000]   'backtransformed images to histo-space'
    ['fin' filesep 's#_other*.gif'  ]    [0.6353    0.0784    0.1843]   'warped other images to histo-space'
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
            
            if ~isempty(strfind(t{j,1},'*'))
                k=dir(fil);
                if ~isempty(k)
                    colhex=sprintf('%02X',round([t{j,2}]*255));
                    v=[v    '<font color =#' colhex '>&#9632' ];
                else
                    colhex=sprintf('%02X',round([colblank]*255));
                    v=[v    '<font color =#' colhex '>&#9633' ];
                end
            else
                %disp('is not');
                colhex=sprintf('%02X',round([colblank]*255));
                v=[v    '<font color =#' colhex '>&#9633' ];
                
            end
            
        end
    end
    v2=['<html><b><font color =blue>'   [ slic{i} ] v];
    %disp(v2);
    
    if ~isempty(st)
        ix=find(strcmp(st.fis(:,1), regexprep( slic{i} ,'.tif','')));
        if st.fis{ix,2}==1              %ok
          v2=[v2  '<font color=#22E80E>  &#9819'  ];
        elseif st.fis{ix,2}==2         %work
            v2=[v2    '<font color=#ff8c00>  &#9873'  ]; %work
        elseif st.fis{ix,2}==-2         %issue
            v2=[v2    '<font color=red>  &#9876'   ]; %clud:  &#9729
        elseif st.fis{ix,2}==-1         %problematic
            v2=[v2    '<font color=#A40D5A>  &#9762'   ];
        
          
          %elseif st.fis{ix,2}>=11 && st.fis{ix,2}<=20         %number    
        end
        %% add GROUP numer NUMBER_________ (HTML "1" is "g&#49;" we start with st.group==1 as '1')
        if 1
            %if isfield(st,'group')
                if size(st.fis,2)>3
                    if isempty(st.fis{ix,4}) || st.fis{ix,4}==0
                        v2= [[regexprep(v2,'<font color=#ff00ff>  g&#\d\d;','')]];
                    else
                        v2= [[regexprep(v2,'<font color=#ff00ff>  g&#\d\d;','')]];
                        v2=[v2    '<font color=#ff00ff>  g&#' num2str(48+st.fis{ix,4}) ';'  ];
                        %v2=[v2    '<font color=#ff00ff>  g&#49;'  ];
                    end
                end
                
            %end
        end
        
        
    end
    
    
 v3{i,1}=v2;
end

% ---------select via grouping tag-----
% bartcb('sel','group',[1]);
% bartcb('sel','group',[1 3]);
% ---------select via  ratng tag-----
% bartcb('sel','tag','ok');
% bartcb('sel','tag','issue|ok');
% ---------select string in FILEs-----
% bartcb('sel','file','Nai|half');
% bartcb('sel','file','Nai|half|a1');
% bartcb('sel','file','a1_001');
% bartcb('sel','file','all');  %select all files
% ---------select string in DIRs-----
% bartcb('sel','dir','Nai|half');
% bartcb('sel','dir','fside');
% bartcb('sel','dir','all'); %select all dirs


function [ fpdirs dirs] =sel(arg)

hf=findobj(0,'tag','bart');
hb=findobj(hf,'tag','lb1');


fpdirs=[];
dirs  =[];
if length(arg)==1; return; end
global ak
if strcmp(arg{2},'group')   %---------group
    ix=[];
    grpnum=arg{3};
    if ischar(grpnum)
        grpnum=str2num(grpnum);
    end
    for i=1:length(grpnum)
        is=regexpi2(ak.list1Html, ['<font color=#ff00ff>  g&#' num2str(grpnum(i)+48) ';']);
        ix=[ix;is(:)];
    end
    set(hb,'value',ix);
elseif strcmp(arg{2},'tag') %---------tag
    ts={'ok' '&#9819'
        'remind me'  '&#9873'
        'issue' '&#9876'
        'problem' '&#9762'
        };
    tag=arg{3};
    %     tag='crown'
    %     tag='crown|problem'
    iv=ts(regexpi2(ts(:,1),tag),2);
    if length(iv)==1; sp=char(iv)      ;
    else            ; sp=strjoin(iv,'|');
    end
    ix=find(~cellfun(@isempty,regexpi(ak.list1Html, sp)));
    set(hb,'value',ix);
    
 elseif strcmp(arg{2},'filename') %---------fullpath files 
     %% ===============================================
     sname=ak.list1(:,1);
    tag=cellstr(arg{3});
    padat=ak.dat;
     [files] = spm_select('FPListRec',padat,'.*a1_\d\d\d.tif');
     files=cellstr(files);
     sel=[];
    for i=1:length(tag)
        thistag=tag{i};
        %[pa name ext]=fileparts(thistag)
        ix=regexpi2(sname,strrep(thistag,filesep,[filesep filesep]));
        sel=[sel; ix(:)];
    end
     set(hb,'value',sel); 
     
    %% ===============================================
    
elseif strcmp(arg{2},'file') || strcmp(arg{2},'dir') %---------file/string search
    tag=arg{3};
    sname=ak.list1(:,1);
    %     idir=find(strcmp(ak.list1(:,2),'dir'));
    %     sname(idir)=cellfun(@(a){[a filesep '@@@@@@@@' ]}, sname(idir) )
    %     [n1 n2 n3]=fileparts2(sname)
    [n1 n2 n3]=fileparts2(sname);
    sname=cellfun(@(a,b){[a  b]}, n2 ,n3 );
    
    ix=find(~cellfun(@isempty,regexpi(sname, tag)));
    type=ak.list1(ix,2);
    ixfiles=ix(strcmp(type,'file'));
    ixdirs=ix(strcmp(type,'dir'));
    if strcmp(arg{2},'dir')
        if strcmp(arg{3},'all')
            ixdirs=find((strcmp(ak.list1(:,2),'dir')));
        end
        set(hb,'value',ixdirs);
        return
    end
    
    if isempty(ixfiles)
        fis=[];
    else
        fis=ak.list1(ixfiles,1);
    end
    for i=1:length(ixdirs)
        tdir=ak.list1{ixdirs(i),1};
        [files] = spm_select('FPList',tdir,'^a1_001.tif');
        if ~isempty(files)
            fis=[fis; cellstr(files)];
        end
    end
    ifis=[];
    for i=1:length(fis)
        ix=find(strcmp(ak.list1(:,1),fis{i}));
        ifis=[ifis; ix(:)];
    end
    
     if strcmp(arg{3},'all')
            ifis=find((strcmp(ak.list1(:,2),'file')));
        end
    set(hb,'value',ifis);
    
end







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
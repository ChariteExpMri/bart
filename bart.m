

function bart()

if isempty(which('@dummy.m')) %set paths
    pabart=fileparts(which('bart.m'));
    addpath(pabart);
    addpath(genpath(fullfile(pabart,'code')));
    addpath(genpath(fullfile(pabart,'slicedetection')));
end

if 0
    
    pathCell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive
        onPath = any(strcmpi(Folder, pathCell));
    else
        onPath = any(strcmp(Folder, pathCell));
    end
    
end



% addpath(genpath(fileparts(which('bart.m'))))
% ==============================================
%%  fg,  slice-LB, fcn-lb
% ===============================================

delete(findobj(0,'tag','bart'))
fg
set(gcf,'menubar','figure','tag','bart','name','Bart','NumberTitle','off',...
    'units','norm','CloseRequestFcn',[],'menubar','none');


hb=uicontrol('style','listbox','units','norm','tag','lb1','tooltipstring','slices');
set(hb,'position',[0 0 .5 .8],'max',1000,'fontsize',7,'fontname','courier');
% set(hb,'string',{'1' '2' '3' '4'})
lb1_defineContext(hb)

hb=uicontrol('style','listbox','units','norm','tag','lb2','tooltipstring','functions');
set(hb,'position',[0.5 .3 .5 .5],'max',1000);
fcn=bart_fcn();
set(hb,'string',cellfun(@(a,b){[b ' [' a ']']},fcn(:,1),fcn(:,2)))
% ==============================================
%%   run
% ===============================================
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'string','RUN','tag','run','tooltipstring','run selected function for selected cases');
set(hb,'position',[ 0.5054    0.2488    0.0804    0.0464],'callback',@runfcn);

% ==============================================
%%   load project
% ===============================================
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'string','load project','tag','run','tooltipstring','run selected function for selected cases');
set(hb,'position',[ 0.0179    0.8845    0.1214    0.0583],'callback',@loadproject);
% ==============================================
%%   update
% ===============================================
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'string','update','tag','update','tooltipstring','update cases');
set(hb,'position',[ 0.0125    0.8012    0.0804    0.0464],'callback',@update);

% ==============================================
%%   useparallel
% ===============================================
hb=uicontrol('style','radio','units','norm');
set(hb,'string','parallel','tag','isparallel','tooltipstring','use parallel computation');
set(hb,'position',[ 0.2054    0.9202    0.1204    0.0464],'backgroundcolor','w');%,'callback',@update,'');

% ==============================================
%%   
% ===============================================

m = uimenu('Text','File');
m2 = uimenu(m,'Text','new Project','callback', @newProject);
m2 = uimenu(m,'Text','import Tiffs','callback', @importTiffs);


m2 = uimenu(m,'Text','close','callback', @closebart);

m  = uimenu('Text','Extras');
m2 = uimenu(m,'Text','check updates','callback', {@check_updates,1});
m2 = uimenu(m,'Text','force updates','callback', {@check_updates,2});


% ==============================================
%%   MENU
% ===============================================

function newProject(e,e2)
f_newproject();

function importTiffs(e,e2)
f_importTiff();
bartcb('update');

function closebart(e,e2)
% delete(findobj(0,'tag','bart'));
bartcb('close');

function check_updates(e,e2,task)

if strcmp(which('bart.m'), 'F:\data3\histo2\bart\bart.m')
   msgbox('This is the original version...can''t be updated');
else
    %just update
    cd(fileparts(which('bart.m')));
    % ==============================================
    %%   update without deleting new folder
    % ===============================================
    if task==1
        git reset --hard HEAD;git pull;
    elseif task==2
        
    end
end




% ==============================================
%%   update Listbox
% ===============================================
function update(e,e2)
bartcb('update');

function loadproject(e,e2)

bartcb('load');
% [fi pa ]=uigetfile(pwd,'select project to load');
% if isnumeric(fi); return; end
% 
% projfile=fullfile(pa,fi);
% lastpath=pwd;
% cd(pa);
% run(regexprep(fi,'\.m',''));
% cd(lastpath);
% 
% global ak;
% ak=x;
% disp(['loaded project: '  projfile  'global: "ak"']);
% set(findobj(0,'tag','bart'),'name',['BART: ' projfile]);
% bartcb('update');

function lb1_defineContext(hb)

cmenu = uicontextmenu;
set(hb, 'UIContextMenu', cmenu);
uimenu(cmenu, 'Label', '<html><b><font color =green> opden DIR', 'Callback', {@lb1_context, 'opdenDIR'});
uimenu(cmenu, 'Label', '<html><b><font color =blue> show resized Tif', 'Callback', {@lb1_context, 'showresizedTif'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =blue> show Tif and Mask', 'Callback', {@lb1_context, 'showTifandMask'});
uimenu(cmenu, 'Label', '<html><b><font color =blue> show warped BestSlice', 'Callback', {@lb1_context, 'showWarpedBestSlice'});
uimenu(cmenu, 'Label', '<html><b><font color =blue> show final result', 'Callback', {@lb1_context, 'show_finalResult'});

% item2 = uimenu(cmenu, 'Label', 'dotted', 'Callback', cb2);
% item3 = uimenu(cmenu, 'Label', 'solid', 'Callback', cb3);




function lb1_context(e,e2,task)
   
[sel]=bartcb('getsel');  
files =sel(strcmp(sel(:,2),'file'),1);
dirs  =sel(strcmp(sel(:,2),'dir'),1);   
   
if strcmp(task,'opdenDIR')
    for i=1:length(files)
       explorer(fileparts(files{i})) ;
    end 
elseif strcmp(task,'showresizedTif')
    for i=1:length(files)
       fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a1_'],'.jpg'});
       if exist(fi)==2
            web(fi,'-new');
       else
           disp(['could not open: ' fi]);
       end
    end 
 elseif strcmp(task,'showTifandMask')
    for i=1:length(files)
       fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.jpg'});
       if exist(fi)==2
            web(fi,'-new');
       else
           disp(['could not open: ' fi]);
       end
    end    
elseif strcmp(task,'showWarpedBestSlice')
    for i=1:length(files)
       fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.gif'});
       if exist(fi)==2
            web(fi,'-new');
       else
           disp(['could not open: ' fi]);
       end
    end
    
elseif strcmp(task,'show_finalResult')
    for i=1:length(files)
       fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},...
           {[filesep filesep 'fin'  filesep filesep 's'],'_result.gif'});
       if exist(fi)==2
            web(fi,'-new');
       else
           disp(['could not open: ' fi]);
       end
    end
    
end

% web('F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\bestslice_001.gif','-new')

function runfcn(e,e2)
addpath(genpath(fullfile(fileparts(which('bart.m')),'code'))); % override antx2-paramgui version
% 'ak'
hf=findobj(0,'tag','bart');
hb=findobj(hf,'tag','lb2');
hp=findobj(hf,'tag','isparallel');
isparallelSet=get(hp,'value');
% str=hb.String(hb.Value);


fm=bart_fcn();
idxfun=hb.Value;
funs=fm(idxfun,1);
funs=regexprep(funs,'\.m$','');


inofun=find(cellfun(@isempty,funs)); %DELETE NON-FUNCTIONAL SELECTIONS
funs(inofun)=[];
idxfun(inofun)=[];


% funs=regexprep(str,{'.*[' '].*' '\s+' '\.m'},'');
fidi=bartcb('getsel');
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);


timeTot=tic;
if length(funs)==1
    % SINGLE FUNCTION CALL
    cprintf([0 0 1],['executing: [' funs{1} ']  '  '\n']);
    if fm{idxfun(1),3}==1 && isparallelSet==1
        isparallel=1;
    else
        isparallel=0;
    end
    w2=catstruct(w,struct('isparallel',isparallel));
    
    if strcmp(funs{1},'f_importTiff')
        w2= rmfield(w2,'files');
    end
    
    feval(funs{1},1,w2);
else
   % MULTI FUNCTION CALL
   % [1] first call GUIS
   cw={};
   for i=1:length(funs)
       cprintf([0 0 1],['executing: [' funs{i} ']  '  '\n']);
       
       if fm{idxfun(i),3}==1 && isparallelSet==1
           isparallel=1;
       else
           isparallel=0;
       end
       w2=catstruct(w,struct('isparallel',isparallel));
       
       if strcmp(funs{i},'f_importTiff')
           w2= rmfield(w2,'files');
       end
       
      [w1 w2]= feval(funs{i},2,w2);
      cw(i,:)={w1 w2};
   end
   % [2] execute functions using parameters (from GUIS) WITHOUT GUIS
   for i=1:length(funs)
       feval(funs{i},0,cw{i,2});
   end
end



% ==============================================
%%   old
% ===============================================


if 0
    for i=1:length(funs)
        cprintf([0 0 1],['executing: [' funs{i} ']  '  '\n']);
        
        if fm{idxfun(i),3}==1 && isparallelSet==1
            isparallel=1;
        else
            isparallel=0;
        end
        w2=catstruct(w,struct('isparallel',isparallel));
        
        if strcmp(funs{i},'f_importTiff')
            w2= rmfield(w2,'files');
        end
        
        feval(funs{i},1,w2);
    end
end
% ==============================================
%%   done
% ===============================================



cprintf([0 .5 0],['total time (over cases): ' num2str(toc(timeTot)/60) 'min\n']);
bartcb('update');











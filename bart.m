

function bart()
pabart=fileparts(which('bart.m'));
addpath(pabart);
addpath(genpath(fullfile(pabart,'code')));
    
if isempty(which('@dummy.m')) %set paths
   
    addpath(genpath(fullfile(pabart,'slicedetection')));
    addpath(genpath(fullfile(pabart,'vlfeat-0.9.21\mex')));
    addpath(genpath(fullfile(pabart,'celldetection')));
	addpath(genpath(fullfile(pabart,'elastix2')));

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
set(gcf,'WindowKeyPressFcn',@keys);



hb=uicontrol('style','listbox','units','norm','tag','lb1','tooltipstring','slices');
set(hb,'position',[0 0 .5 .8],'max',1000,'fontsize',7,'fontname','courier');
set(hb,'callback',@lb1_cb)
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
%%   listbox-info
% ===============================================
hb=uicontrol('style','text','units','norm');
set(hb,'string','0/0 dirs; 0/0 files','tag','listboxinfo');
set(hb,'position',[0.18 0.80119 0.25 0.03],'fontsize',8);
set(hb,'backgroundcolor','w');
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
% ---------------------
m = uimenu('Text','Tools');
m2 = uimenu(m,'Text','flip up-down original tiff','callback', @cb_flipTiffUD);
m2 = uimenu(m,'Text','prune tiffs','callback', @cb_pruneTiff);
% ---------------------
m = uimenu('Text','CellDetection');
m2 = uimenu(m,'Text','cellDetection','callback', @cellDetecetion);
m2 = uimenu(m,'Text','assign cells to region','callback', @cell2regionAssign);
% ---------------------
m = uimenu('Text','SNIPS');
m2 = uimenu(m,'Text','make HTMLfile to select bad slices','callback', @selectBadImages_HTML);


m  = uimenu('Text','updates');
m2 = uimenu(m,'Text','check updates','callback', {@check_updates,1});
m2 = uimenu(m,'Text','force updates','callback', {@check_updates,2});


% ==============================================
%%   MENU
% ===============================================
function lb1_cb(e,e2)
bartcb('updateListboxinfo');

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
    bartcb('close');
    cd(fileparts(which('bart.m')));
    % ==============================================
    %%   update without deleting new folder
    % ===============================================
    if task==1
        git reset --hard HEAD;git pull;
        bart();
    elseif task==2
        disp('not implemented jet!')
    end
end


function cb_flipTiffUD(e,e2)
% ==============================================
%%   
% ===============================================
[fis]=bartcb('getsel');
fis=fis(strcmp(fis(:,2),'file'),:);
fislist=strjoin(strrep(fis(:,1),{[filesep]},{[filesep filesep]}) ,char(10));
fislist=strrep(fislist,'_','\_');

options.Resize='on';
options.WindowStyle='modal';'normal';
options.Interpreter='tex';
prompt={['\color{red}\bf Flip up-down original tiff-image.' char(10) ...
    'It is assumed that images were pre-select in the left Listbox' char(10)...
    '\color{black}\rm  \bf SELECTED FILES: \rm' char(10)...
    fislist  char(10) ...
    '\color{red} ..THESE IMAGE(S) WILL BE FLIPPED!' char(10)  char(10) ... ...
    '\color{blue}\bf Type "1" to CONFIRM and FLIP THESE IMAGES!' ]};
name='Flip up-down original tiff-image. ';
numlines=1;
defaultanswer={'0','hsv'};

answer=inputdlg(prompt,name,[1 70],defaultanswer,options);
if isempty(answer) | strcmp(answer{1},'1')~=1
    disp('..canceled') ;
    return
end
% ==============================================
%%   
% ===============================================
 % suffix='_test';
 suffix='';%overwrite
for i=1:size(fis,1)
   fi=fis{i,1};
   
   %info=imfinfo(fi);
   disp(['fllip up-down: ' fi]);
   a=imread(fi);
   a=flipdim(a,1);
    
  
   fi2=stradd(fi,suffix,2);
   imwrite(a,fi2, 'tif','Compression','none');
   
   %---------
   f2=strrep(fi,'.tif','.jpg');
   a=imread(f2);
   a=flipdim(a,1);
   f22=stradd(f2,suffix,2);
   imwrite(a,f22, 'jpg','quality',100);
   
   % check
   %a2=imread(f22);
   %fg,imagesc(a2-a)
   
end
disp(['Done.' ]);






function cb_pruneTiff(e,e2)


[sel]=bartcb('getsel');
if isempty(sel); return; end
fis=sel((strcmp(sel(:,2),'file')),1);
[pa fi ext]=fileparts2(fis);
fi2=cellfun(@(a,b) {[a filesep b  '.mat']},  pa ,regexprep(fi, { 'a1_'},{'a2_'}));
fi2=fi2(existn(fi2)==2); %check existence
prunegui(fi2);

bartcb('update');

% convert to 'a2_001.mat''

% ==============================================
%%
% ===============================================
function cellDetecetion(e,e2)

[sel]=bartcb('getsel');
if isempty(sel); return; end
fis=sel((strcmp(sel(:,2),'file')),1);
fis=fis(existn(fis)==2); %check existence
% disp(fis);
x.files=fis;
f_celldetection(1,x);
bartcb('update');


function cell2regionAssign(e,e2)
[sel]=bartcb('getsel');
if isempty(sel); return; end
fis=sel((strcmp(sel(:,2),'file')),1);
fis=fis(existn(fis)==2); %check existence
% disp(fis);
x.files=fis;
f_cell2region(1,x);
bartcb('update');

function selectBadImages_HTML(e,e2)
  makeSelection_HTML();



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
uimenu(cmenu, 'Label', '<html><b><font color =green> DIR: open DIRECTORY', 'Callback', {@lb1_context, 'opdenDIR'});
uimenu(cmenu, 'Label', '<html><b><font color =green> DIR: show cutting Image', 'Callback', {@lb1_context, 'showCuttingImage'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =blue> show (cutted) Tif', 'Callback', {@lb1_context, 'showresizedTif'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =blue> show resized Tif and Mask', 'Callback', {@lb1_context, 'showTifandMask'});
uimenu(cmenu, 'Label', '<html><b><font color =blue> show warped BestSlice', 'Callback', {@lb1_context, 'showWarpedBestSlice'});
uimenu(cmenu, 'Label', '<html><b><font color =blue> show final result', 'Callback', {@lb1_context, 'show_finalResult'});

uimenu(cmenu, 'Label', '<html><b><font color =black> show cell-counts', 'Callback', {@lb1_context, 'show_cellCounts'},'separator','on');



uimenu(cmenu, 'Label', '<html><b><font color =red> remove CONTENT of this directory (keep raw-dir)', 'Callback', {@lb1_context, 'removeContentDir'},'separator','on');
% ---ok-registration
uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "ok"',          'Callback', {@lb1_context, 'tag_ok'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "remind me"',          'Callback', {@lb1_context, 'tag_remindme'},'separator','off');

uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "problematic"', 'Callback', {@lb1_context, 'tag_problem'},'separator','off');
uimenu(cmenu, 'Label', '<html><b><font color =gray> untag ',               'Callback', {@lb1_context, 'tag_untag'},'separator','off');


% item2 = uimenu(cmenu, 'Label', 'dotted', 'Callback', cb2);
% item3 = uimenu(cmenu, 'Label', 'solid', 'Callback', cb3);




function lb1_context(e,e2,task)

[sel]=bartcb('getsel');
files =sel(strcmp(sel(:,2),'file'),1);
dirs  =sel(strcmp(sel(:,2),'dir'),1);

if strcmp(task,'opdenDIR')
    mix=[dirs; files]
    for i=1:length(mix)
        if isdir(mix{i})
            explorer((mix{i})) ;
        else
            explorer(fileparts(mix{i})) ;
        end
        
    end
elseif strcmp(task,'showCuttingImage')
    for i=1:length(dirs)
        fi=fullfile(dirs{i},'a0_cut.jpg');
        if exist(fi)==2
            web(fi,'-new');
        else
            disp(['could not open: ' fi]);
        end
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
    
elseif strcmp(task,'show_cellCounts')
    for i=1:length(files)
        [px name ext]=fileparts(files{i});
        fi=fullfile(px,['cellcounts_' name],['predfus.tif']);
        if exist(fi)==2
            system(fi);
        else
            disp(['could not open: ' fi]);
        end
    end
elseif strcmp(task,'tag_ok') || strcmp(task,'tag_remindme') ...
        || strcmp(task,'tag_problem') || strcmp(task,'tag_untag')
    for i=1:length(files)
        [px name ext]=fileparts(files{i});
        fi=fullfile(px,['status.mat']);
        if exist(fi)~=2
            [fis] = spm_select('List',px,'^a1_\d\d\d.tif$');   fis=cellstr(fis);
            fis=regexprep(fis,'.tif$','');
            fis(:,2)={0};
            fis(:,3)={''};
            st.fis  =fis;
            st.hfis ={'name' 'tag','message'};
            save(fi,'st');
        else
            load(fi);
        end
        %--------------------------------
        if strcmp(task,'tag_ok')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =1   ; % set "OK"-tag
        elseif strcmp(task,'tag_remindme')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =2   ; % set "work"-tag
        elseif strcmp(task,'tag_problem')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =-1   ; % set "problematic"-tag
        elseif strcmp(task,'tag_untag')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =0   ; % set "untag"
        end
        save(fi,'st');
        
        %disp(st.fis);
    end
    bartcb('update');
    
elseif strcmp(task,'removeContentDir')
    mix=unique([dirs; fileparts2(files)]);
    % ==============================================
    %% delete content
    % ===============================================
    if ~isempty(char(mix))
        opts.Interpreter = 'none';
        % Include the desired Default answer
        opts.Default = 'Yes';
        % Use the TeX interpreter to format the question
        quest = ['PROCEED???  ..DELETING FOLDER CONTENT:' ...
            char(10) 'YES) DELETE. ' ...
            char(10) ' NO) CANCEL. '];
        answer = questdlg(quest,'PROCEED',...
            'Yes','No ...cancel',opts);
        if ~isempty(strfind(answer,'No'))
            disp('canceled...')
            return
        end
        
    
        
    end
    % ==============================================
    %%   check
    % ===============================================
    
    dlgtitle = 'Delete Folder Content';
    prompt = {['Just to be shure!'  char(10) 'Type "del" to remove the content of the selected folder(s).' char(10) ...
        'This operation is IRREVERSIBLE!']};
    dims = [1 60];
    definput = {''};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    chk=char(answer{1});
    if strcmp(chk,'del')~=1
        disp('canceled');
        return
    end
    
    disp('removing folder content');
    % return
    % ==============================================
    %%
    % ===============================================
    for i=1:length(mix)
        pa=mix{i};
        k=dir(pa);
        names={k(:).name}';
        names(strcmp(names,'.')) =[];
        names(strcmp(names,'..')) =[];
        names(strcmp(names,'raw'))=[];
        %names
        for j=1:length(names)
            delobj=fullfile(pa,names{j});
            if isdir(delobj)==1
                rmdir(delobj,'s');
            else
                delete(  delobj  );
            end
            
        end
    end
    disp('...done');
    bartcb('update');
    
    
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


function keys(e,e2)
% e2
if strcmp(e2.Character,'+')
    hl=findobj(gcf,'tag','lb1');
    fs=get(hl,'fontsize');
    set(hl,'fontsize',fs+1);
elseif strcmp(e2.Character,'-')
    hl=findobj(gcf,'tag','lb1');
    fs=get(hl,'fontsize');
    if fs<2; return; end
    set(hl,'fontsize',fs-1);
end








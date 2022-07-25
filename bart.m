
%% main gui
% right-side functions: bart_fcn.m

function bart()
if isempty(which('ant.m'))
    msgbox({'ANTx2-TBX not found in path-list.' 'BART needs ANTx2..'},'warning');
    return
end

pabart=fileparts(which('bart.m'));
addpath(pabart);
addpath(genpath(fullfile(pabart,'code')));

% if isempty(which('@dummy.m')) %set paths
addpath(genpath(fullfile(pabart,'slicedetection')));
addpath(genpath(fullfile(pabart,'vlfeat-0.9.21\mex')));
addpath(genpath(fullfile(pabart,'celldetection')));
addpath(genpath(fullfile(pabart,'elastix2')));

% end

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
%%   select
% ===============================================
hb=uicontrol('style','pushbutton','units','norm');
set(hb,'string','sel','tag','select','tooltipstring','select');
set(hb,'position',[ 0.1    0.8012    0.0404    0.0364],'callback',@select);
set(hb,'tooltipstring','select specific files/folders');
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
set(hb,'visible','off');
% ==============================================
%%  version
% ===============================================
%====INDICATE LAST UPDATE-DATE ========================
% vstring=strsplit(help('antver'),char(10))';
% idate=max(regexpi2(vstring,' \w\w\w 20\d\d (\d\d'));
% dateLU=['ANTx2  vers.' char(regexprep(vstring(idate), {' (.*'  '  #\w\w ' },{''}))];
dateLU=bartcb('version');
% dateLU=['v'  datestr(now)];
h = uicontrol('style','pushbutton','units','normalized','position',[.94 .65 .08 .05],'tag','txtversion',...
    'string',dateLU,'fontsize',5,'fontweight','normal',...
    'tooltip',['date of last update' char(10) '..click to see last updates [bartver.m]']);
% set(h,'position',[.2 .65 .08 .02],'fontsize',6,'backgroundcolor','w','foregroundcolor',[.7 .7 .7])
set(h,'position',[0.44107 0.96548 0.25 0.027],'fontsize',7,'backgroundcolor','w','foregroundcolor',[0.9294    0.6941    0.1255],...
    'horizontalalignment','left','callback',{@callbartver});


%% ===============================================
% update-pushbutton :get update ...no questions ask
%% ===============================================
h = uicontrol('style','pushbutton','units','normalized','position',[.94 .65 .04 .05],...
    'tag','update_btn',...
    'string','','fontsize',13,  'callback',{@updateTBXnow},...
    'tooltip', ['<html><b>download latest updates from Github</b><br>forced updated, no user-input<br>'...
    '<font color="green"> see contextmenu for more options'],...
    'backgroundcolor','w');
set(h,'position',[0.69286 0.96071 0.025 0.033333]);
set(h,'units','pixels');
posi=get(h,'position');
set(h,'position',[posi(1:2) 14 14]);
set(h,'units','norm');
icon=fullfile(antpath,'icons','Download_16.png');
[e map]=imread(icon)  ;
set(h,'cdata',e);

cmm=uicontextmenu;
uimenu('Parent',cmm, 'Label','check update-status',             'callback', {@updateTBX_context,'info' });
uimenu('Parent',cmm, 'Label','force update',                    'callback', {@updateTBX_context,'forceUpdate' } ,'ForegroundColor',[1 0 1],'separator','on');
uimenu('Parent',cmm, 'Label','show last local changes (files)', 'callback', {@updateTBX_context,'filechanges_local' } ,'ForegroundColor',[.5 .5 .5],'separator','on');
uimenu('Parent',cmm, 'Label','help: update from GitHUB-repo' ,  'callback', {@updateTBX_context,'help' } ,'ForegroundColor',[0 .5 0],'separator','on');
set(h,'UIContextMenu',cmm);



% ==============================================
%%
% ===============================================


m = uimenu('label','File');

m2 = uimenu(m,'label','new Project','callback', @newProject);
m2 = uimenu(m,'label','import Tiffs','callback', @importTiffs);
m2 = uimenu(m,'label','import single Tiff from several animals','callback', @importTiffs_single);
m2 = uimenu(m,'label','import multiple Tiff (several tiffs per folder)','callback', @importTiffs_multi);

m2 = uimenu(m,'label','close','callback', @closebart);
% ---------------------
m = uimenu('label','Tools');
m2 = uimenu(m,'label','flip up-down original tiff','callback', @cb_flipTiffUD);
m2 = uimenu(m,'label','prune tiffs','callback', @cb_pruneTiff);
% ---------------------
m = uimenu('label','CellDetection');
m2 = uimenu(m,'label','cellDetection','callback', @cellDetecetion);
m2 = uimenu(m,'label','assign cells to region','callback', @cell2regionAssign);
% ---------------------
m = uimenu('label','HTML');
m2 = uimenu(m,'label','make HTMLfile to select bad slices [makeSelection_HTML.m]','callback', @selectBadImages_HTML);
m2 = uimenu(m,'label','make HTMLfile Report:  finalResult [HTMLreport.m]'        ,'callback', @HTMLreport_call);
m2 = uimenu(m,'label','make HTMLfile Report:  other images to histoSpace [HTMLreportotherimages.m]'        ,'callback', @HTMLreportotherimages_call);

% ---------------------
m = uimenu('label','Conversion');
m2 = uimenu(m,'label','convert Histo-ATLAS(ANO)-slice(mat) to pseudocolor-TIF [f_ano_falsecolor2tif]','callback', @convetANO2pseudoTiff);



m  = uimenu('label','updates');
m2 = uimenu(m,'label','      update','callback', {@check_updates,2});
m2 = uimenu(m,'label','<html><font color =blue>force update','callback', {@check_updates,3});
m2 = uimenu(m,'label','check update','callback', {@check_updates,1});
m2 = uimenu(m,'label','<html><font color =gray>help  bart-update','callback', {@check_updates,-1});


%% BArthistory
h = uicontrol('style','pushbutton','units','normalized','position',[0.14107 0.88452 0.034 0.058],...
    'tag','ant_study_history',...
    'string','','fontsize',13,   'callback',@openStudyHistory,'tooltip', 'open STUDY-HISTORY',...
    'backgroundcolor','w');
% icon=which('profiler.gif');
icon=fullfile(matlabroot,'toolbox','matlab', 'icons','book_link.gif');
% icon=fullfile(matlabroot,'toolbox','matlab', 'icons','HDF_grid.gif');

[e map]=imread(icon)  ;
e=ind2rgb(e,map);
% e(e<=0.01)=nan;
set(h,'cdata',e);

% ==============================================
%%   
% ===============================================
% ==============================================
%%   CFM -all
% ===============================================
%% SETTINGS
h = uicontrol('style','pushbutton','units','normalized','position',[0.21071 0.88929 0.04 0.05],...
    'tag','ant_cfm',...
    'string','','fontsize',13,   'callback',{@openCFM,'all'},'tooltip', 'open Case-FileMatrix (all animals)',...
    'backgroundcolor','w');
% icon=which('profiler.gif');
icon=fullfile(matlabroot,'toolbox','matlab', 'icons','HDF_grid.gif');
[e map]=imread(icon)  ;
inoLila=find(map(:,1)==1 & map(:,2)==0 & map(:,3)==1 );
map(inoLila,:)=repmat([0 .5 0],[length(inoLila) 1]);
e=ind2rgb(e,map);
% e(e<=0.01)=nan;
set(h,'cdata',e);
% ==============================================
%%   CFM -selected
% ===============================================
%% SETTINGS
h = uicontrol('style','pushbutton','units','normalized','position',[0.25 0.88929 0.04 0.05],...
    'tag','ant_cfm',...
    'string','','fontsize',13,   'callback',{@openCFM,'sel'},'tooltip', 'open Case-FileMatrix (selected animals)',...
    'backgroundcolor','w');
% icon=which('profiler.gif');
% icon=fullfile(matlabroot,'toolbox','matlab', 'icons','HDF_grid.gif');
% [e map]=imread(icon)  ;
e2=e(:,[3:8 end-1:end],:);
% e(:,[ end-7:end])=1;

% e=ind2rgb(e,map);
% e(e<=0.01)=nan;
set(h,'cdata',e2);



% h = uicontrol('style','pushbutton','units','normalized','position',[0.17679 0.88452 0.034 0.058],...
%     'tag','ant_study_history',...
%     'string','','fontsize',13,   'callback',@call_CFM,'tooltip', 'open case-file-matrix(cfm)',...
%     'backgroundcolor','w');
% % icon=which('profiler.gif');
% % icon=fullfile(matlabroot,'toolbox','matlab', 'icons','book_link.gif');
% icon=fullfile(matlabroot,'toolbox','matlab', 'icons','HDF_grid.gif');
% [e map]=imread(icon)  ;
% e=ind2rgb(e,map);
% % e(e<=0.01)=nan;
% set(h,'cdata',e);


% ==============================================
%%   update tbx via button, no user-questions
% ===============================================
function updateTBX_context(e,e2,task)
cname=getenv('COMPUTERNAME');
msg_myMachine='The source machine can''t be updated from Github';
if strcmp(task,'help')
    help updatebart
elseif strcmp(task,'info')
    if strcmp(cname,'STEFANKOCH06C0')==1
        disp(msg_myMachine);  %my computer---not allowed
    else
        updatebart('info');
    end
elseif strcmp(task,'forceUpdate')
    if strcmp(cname,'STEFANKOCH06C0')==1
        disp(msg_myMachine);  %my computer---not allowed
    else
        updatebart(3);
    end
elseif strcmp(task,'filechanges_local')
    if strcmp(cname,'STEFANKOCH06C0')==1
        disp(msg_myMachine);  %my computer---not allowed
    else
        updatebart('changes');
    end
end
% ==============================================
%%   update-btn
% ===============================================

function updateTBXnow(e,e2)
cname=getenv('COMPUTERNAME');
if strcmp(cname,'STEFANKOCH06C0')==1
    disp('The source machine can''t be updated from Github');  %my computer---not allowed
else
    thispa=pwd;
    go2pa =fileparts(which('bartver.m'));
    cd(go2pa);
    try
        w=git('log -p -1');                    % obtain DATE OF local repo
        w=strsplit(w,char(10))';
        date1=w(min(regexpi2(w,'Date: ')));
    catch
        cd(thispa);
    end
    
    updatebart(2);                              % UPDAETE
    bartcb('versionupdate');
    
    try
        w=git('log -p -1');                  % obtain DATE OF local repo
        w=strsplit(w,char(10))';
        date2=w(min(regexpi2(w,'Date: ')));
    catch
        cd(thispa);
    end
    
    cd(thispa);
    if strcmp(date1,date2)~=1   %COMPARE date1 & date2 ...if changes--->reload tbx
        q=updatebart('changes');
        if ~isempty(find(strcmp(q,'bart.m')));
            disp(' BART-main gui was modified: reloading GUI');
            %antcb('reload');
            bart;
        end
    end
end

% ==============================================
%%   MENU
% ===============================================



function openCFM(e,e2,dirmode)
if strcmp(dirmode,'all')
    cfm(1,'','all');
else
    cfm(1,'','sel');
end

% function call_CFM(e,e2)
% 
% bartcfm()


function openStudyHistory(e,e2)
barthistory('select');

function callbartver(e,e2)
bartver;


function lb1_cb(e,e2)
bartcb('updateListboxinfo');

function newProject(e,e2)
f_newproject();

function importTiffs(e,e2)
f_importTiff();
bartcb('update');

function importTiffs_single(e,e2)
f_importTiff_single();
bartcb('update');

function importTiffs_multi(e,e2)
f_importTiff_multi();
bartcb('update');

function closebart(e,e2)
% delete(findobj(0,'tag','bart'));
bartcb('close');

function check_updates(e,e2,task)

if strcmp(which('bart.m'), 'F:\data3\histo2\bart\bart.m')
    msgbox('This is the original version...can''t be updated');
else
    %just update
    %     bartcb('close');
    %     cd(fileparts(which('bart.m')));
    % ==============================================
    %%   update without deleting new folder
    % ===============================================
    %     if task==1
    %         git reset --hard HEAD;git pull;
    %         bart();
    %     elseif task==2
    %         disp('not implemented jet!')
    %     end
    
    if  task==-1
        help updatebart;
    elseif task==2
        updatebart(2);
    elseif task==3
        updatebart(3);
    elseif task==1
        updatebart('info');
        %updatebart('changes')
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

function HTMLreport_call(e,e2)
HTMLreport();

function HTMLreportotherimages_call(e,e2)
HTMLreportotherimages();

function convetANO2pseudoTiff(e,e2)
f_ano_falsecolor2tif();

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
% --------
uimenu(cmenu, 'Label', '<html><b><font color =blue> show resized Tif and Mask', 'Callback', {@lb1_context, 'showTifandMask'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =#0AAED6> show Parameter of a2_###.mat (mod-paramter)', 'Callback', {@lb1_context, 'showParamModfile'});
% --------
uimenu(cmenu, 'Label', '<html><b><font color =blue> show warped BestSlice', 'Callback', {@lb1_context, 'showWarpedBestSlice'},'separator','on');
% --------
uimenu(cmenu, 'Label', '<html><b><font color =blue> show final result', 'Callback', {@lb1_context, 'show_finalResult'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =#0AAED6> show final parameter (Slice/pitch/yaw)', 'Callback', {@lb1_context, 'show_finalParameter'},'separator','off');
% --------

uimenu(cmenu, 'Label', '<html><b><font color =black> show cell-counts', 'Callback', {@lb1_context, 'show_cellCounts'},'separator','on');



uimenu(cmenu, 'Label', '<html><b><font color =red> remove CONTENT of this directory (keep raw-dir)', 'Callback', {@lb1_context, 'removeContentDir'},'separator','on');
% ---ok-registration
uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "ok"  (crown icon)',          'Callback', {@lb1_context, 'tag_ok'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "remind me" (flag icon)',          'Callback', {@lb1_context, 'tag_remindme'},'separator','off');

uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "issue" (sword icon)',       'Callback', {@lb1_context, 'tag_issue'},'separator','off');
uimenu(cmenu, 'Label', '<html><b><font color =gray> tag as "problematic" (biohazzard icon)', 'Callback', {@lb1_context, 'tag_problem'},'separator','off');
uimenu(cmenu, 'Label', '<html><b><font color =gray> untag rating',         'Callback', {@lb1_context, 'tag_untag'},'separator','off');


uimenu(cmenu, 'Label', '<html><b><font color =gray> tag group assignment',   'Callback', {@lb1_context, 'tag_group'},'separator','on');
uimenu(cmenu, 'Label', '<html><b><font color =gray> untag group assignment', 'Callback', {@lb1_context, 'tag_untaggroup'},'separator','off');


%          v2=[v2  '<font color=#22E80E>  &#9819'  ];
%         elseif st.fis{ix,2}==2         %work
%             v2=[v2    '<font color=#ff8c00>  &#9873'  ]; %work
%         elseif st.fis{ix,2}==-2         %issue
%             v2=[v2    '<font color=red>  &#9876'   ]; %clud:  &#9729
%         elseif st.fis{ix,2}==-1         %problematic
%             v2=[v2    '<font color=#A40D5A>  &#9762'   ];
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
elseif strcmp(task,'showParamModfile')
    for i=1:length(files)
        fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
        if exist(fi)==2
            s=load(fi);s=s.s;
            cprintf([0 .1 1],[repmat('_',[1 length(fi)]) '\n']);
            cprintf([0 .1 1],[strrep(fi,filesep,[filesep filesep]) '\n']);
            disp(s);
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
elseif strcmp(task,'show_finalParameter')
    cprintf('*[0 .1 1]',['*** FINAL_PARAMETER (slice,pitch,yaw)***' '\n']);
    tb={};
    for i=1:length(files)
        fi=regexprep(files{i},{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.mat'});
        %if exist(fi)==2
        
        cprintf([0 .1 1],[repmat('_',[1 length(fi)]) '\n']);
        cprintf([0 .1 1],[strrep(fi,filesep,[filesep filesep]) '\n']);
        rawfile='unknown';
        try
            s=load(fi);s=s.s2;
            
            try
                f2=fullfile(fileparts(fi),'importlog.txt');
                l=importdata(f2);
                ix=find(~cellfun('isempty',strfind(l,files{i})));
                rawfile=l{ix-1};
                rawfile=regexprep(rawfile,'.*\[origin]: ','');
                %rawfile=regexprep(rawfile,{']'},{''});
            catch
                %rawfile='unknown';
            end
            g  =sprintf('[%6.3f\t%6.3f\t%6.3f]\t %s', s.param(1),s.param(2),s.param(3),rawfile);
            g2 =[num2cell(s.param) rawfile];
        catch
            g=sprintf('[%6.3f\t%6.3f\t%6.3f\t %s] --> presumably not processed', nan,nan,nan,'unknown');
            g2 =[num2cell([nan,nan,nan]) rawfile] ;
        end
        disp(g);
        
        
        
        dx=[fi,  (g2) ];
        tb=[tb;dx];
        
        %         else
        %             disp(['could not open: ' fi]);
        %         end
    end
    
    htb={'File' 'Slice' ,'Pitch' 'Yaw' ,'Raw'};
    % uhelp(plog([],[htb;tb],0, '#ko Paramter Estimations','s=4;al=2;'),1);
    spara.info=['*** REGISTRATION PARAMETER ***'];
    spara.htb=htb;
    spara. tb= tb;
   
    
    %% ===============================================
    msg='Parameter table  ';
    msg2='slice/pitch/yaw';
    name='parameter';
    cprintf('*[1 0 1]',msg);
    
    %% --save xlsfile-option
    global ak
    xlscode=[...
        ['spara.outdir=''' fullfile(fileparts(ak.dat),'results') ''';']...
        ['warning off; mkdir(spara.outdir);']...
        '[ spara.fi spara.pa]=uiputfile(fullfile(spara.outdir,''*.xlsx''),''enter filename to save paramter [excel]'');'....
        'if isnumeric(spara.fi); return;end;'....
        'spara.fout=fullfile(spara.pa,spara.fi);'...;
        'pwrite2excel(spara.fout,{1 ''params''},spara.htb,[],spara.tb);'...
        'showinfo2(''ParameterFile [Excel]'',spara.fout);'
        ];   
    
    spara.xlscode=xlscode;
    %       eval(xlscode);
    %% --
     assignin('base','spara', spara);
    
    disp([  ' [' msg2 ']: <a href="matlab: uhelp(plog([],[ spara.htb;spara.tb],0, ''#ko Paramter Estimations'',''s=4;al=2;''),1,''name'',''' name ''');">' 'show it' '</a>' ...
        ' or <a href="matlab: ' 'eval(spara.xlscode)' ';">' 'save as ExcelFile' '</a>'  ' '  ...
        ] );
    
    
    %% ===============================================
    
    
    
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
    % elseif strcmp(task,'tag_ok') || strcmp(task,'tag_remindme') ...
    %         || strcmp(task,'tag_problem') || strcmp(task,'tag_untag') ||...
    %         ...
    %         strcmp(task,'tag_group') || strcmp(task,'tag_untaggroup')  %groupwise un/tagging
    
    
elseif ~isempty(regexpi('tag_ok','^tag_'));
    
    if strcmp(task,'tag_group')==1
        prompt = {['Enter group number [single value between 1-to-9].'...
            'The selected images will be tagged with this number:']};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {'1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        groupnumber=str2num(answer{1});
        if ~isnumeric(groupnumber) || isempty(groupnumber)
            return
        end
        
    end
    
    
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
            st.group=0;
            save(fi,'st');
        else
            load(fi);
        end
        %--------------------------------
        if strcmp(task,'tag_ok')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =1   ; % set "OK"-tag
        elseif strcmp(task,'tag_remindme')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =2   ; % set "work"-tag
        elseif strcmp(task,'tag_issue')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =-2   ; % set "issue"-tag
        elseif strcmp(task,'tag_problem')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =-1   ; % set "problematic"-tag
        elseif strcmp(task,'tag_untag')==1
            st.fis{find(strcmp(st.fis(:,1),name)) ,2}  =0   ; % set "untag"
            
            
        elseif strcmp(task,'tag_group')==1
            %st.group=groupnumber;
            st.fis{find(strcmp(st.fis(:,1),name)) , [4]} = groupnumber; %GROUPNUMBER
        elseif strcmp(task,'tag_untaggroup')==1
            st.fis{find(strcmp(st.fis(:,1),name)) , [4]} = 0 ;%untag group
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
if ~isempty(find(strcmp(funs,'f_cuttiffs')))
    w.files={};
end


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



function select(e,e2)


delete(findobj(0,'tag','sel_pan'));
hp = uipanel('Title','select files/folders','FontSize',8,...
    'BackgroundColor','white','units','norm','tag','sel_pan');
set(hp,'position',[0.4 .5   .5 .15]);
set(hp,'BackgroundColor',[ 1.0000    0.7333    0.1608]);


list1={'dir','file' ,'tag','group'};
hb=uicontrol(hp,'style','popupmenu','units','norm','tag','sel_poptype');
set(hb,'position',[0  .5 .2 .4],'string',list1);
set(hb,'tooltipstring','selected the search-type (dir,file,tag,group)');

hb=uicontrol(hp,'style','edit','units','norm','tag','sel_edit');
set(hb,'position',[.205  .5 .6 .4],'string','');
set(hb,'tooltipstring','type string/pattern to search for');

list2={...
    '<html><font color=red>clear-edit-field ' ...  %------FILE/DIR
    '<html><font color=blue>---FILE/DIR-PATTERN: ' ...  %------FILE/DIR
    'all' ...
    '<html><font color=blue>---TAG-PATTERN: ' ...  %------TAG
    'ok' 'remind me' 'issue' 'problem' ...
    'issue|problem'...
    '<html><font color=blue>---GROUP-PATTERN examples: ' ...   %------Group
    '1' '1 3' '1:3'...
    };

hb=uicontrol(hp,'style','popupmenu','units','norm','tag','sel_popinsert');
set(hb,'position',[.805  .5 .2 .4],'string',list2);
set(hb,'tooltipstring','this can be inserted into the edit-field ');
set(hb,'callback',{@sel_task,'insert'});

%----------ok/cancel-------
hb=uicontrol(hp,'style','pushbutton','units','norm','tag','sel_find');
set(hb,'position',[0.1    0  .22 .4],'string','find&select','backgroundcolor','w');
set(hb,'tooltipstring','find and select found files');
set(hb,'callback',{@sel_task,'find'});

hb=uicontrol(hp,'style','pushbutton','units','norm','tag','sel_close');
set(hb,'position',[0.33    0  .15 .4],'string','close','backgroundcolor','w');
set(hb,'tooltipstring','close this panel');
set(hb,'callback',{@sel_task,'close'});

function sel_task(e,e2,task)
hp=findobj(gcf,'tag','sel_pan');
htype=findobj(hp,'tag','sel_poptype');
hins =findobj(hp,'tag','sel_popinsert');
he =findobj(hp,'tag','sel_edit');



if strcmp(task,'close')
    delete(hp);
elseif strcmp(task,'insert')
    s=hins.String{hins.Value};
    if ~isempty(strfind(s,'html'));
        if ~isempty(strfind(s,'clear'));
            set(he,'string', '');
        end
        return;
    else
        set(he,'string', s);
    end
    
    
elseif strcmp(task,'find')
    
    str=['bartcb(''sel'',''' htype.String{htype.Value} ''',''' he.String ''');'];
    %disp(str);
    eval(str);
end






function varargout=bartconfig(showgui, p0)
varargout{1}=[];
varargout{2}=[];


if exist('showgui')~=1
    showgui=1;
end

if exist('p0')~=1
    p0=struct();
end

% ==============================================
%%   
% ===============================================
p={...
    'inf99'      '*** CONFIGURATION PARAMETERS   ***              '                         '' ''
    'inf100'     '==================================='                          '' ''
    '' '' '' ''
    'dat'         fullfile(pwd,'dat')      'studie''s datapath, MUST BE be specified, and named "dat", such as "c:\b\study1\dat" '  'd'
    'template'    'UNDEFINED'             'select the template path ("bart_template")'  {@gettemplate}
    %'vv.c'        'UNDEFINED'             'select the template path'  'd'
    '' '' '' ''
    'inf101'     '==================================='                          '' ''
    'deepsliceconfig' 'UNDEFINED'             'select the deepslice-config (optional) '  {@getdeepsliceconfig}
    
    
    };
% p2=p;

p2=paramadd(p,p0);%add/replace parameter

% x.main     =  'F:\data3\histo2\josefine';	% select main folder for data analysis to <required to fill>
% x.dat     =  'F:\data3\histo2\josefine\dat'; % data-folder
% x.template =  'F:\data3\histo2\bart\templates';	% select main template folder <required to fill>

% ==============================================
%%   
% ===============================================
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    %figpos=[0.1688    0.3000    0.8073    0.6111];
    figpos=[0.1729    0.4333    0.5052    0.2533];
    [m z ]=paramgui(p2,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',figpos,...
        'title',['SETTINGS [' mfilename '.m]'],'pb1string','OK','info',hlp);%,'cb1string',cb1string);
end

% ==============================================
%%   save
% ===============================================

try
    varargout{1}=m;
end

try
    varargout{2}=z;
end

function getdeepsliceconfig(e,e2)
%% ===============================================
cmd4ui_path='<select own deepslice-configuration>';
dontuse='none';
dlpath={...  
    dontuse
    which('deepslice_defaults_home.m')
    which('deepslice_defaults_win10server.m');
    

    
    cmd4ui_path};
[idx,tf] = listdlg('PromptString',{ 'Select deepslice-configuration (file)',''},...
    'SelectionMode','single','ListString',dlpath,'ListSize',[450,100]);
if isempty(idx); return; end
cpath=dlpath{idx};
if strcmp(cpath,cmd4ui_path)
       [fi, pa] = uigetfile('*.m', 'Select deepslice-configuration (file)');
       if isnumeric(dn); return; end
       cpath=fullfile(pa,fi);
end
paramgui('setdata','x.deepsliceconfig',cpath);
return
%% ===============================================


function gettemplate(e,e2)
%% ===============================================
cmd4ui_path='<select own template>';
templatepaths={...
    'F:\tools\bart_template'
    'D:\MATLAB\bart_templates'
    cmd4ui_path};
[idx,tf] = listdlg('PromptString',{ 'Select template (path of template) to use',''},...
    'SelectionMode','single','ListString',templatepaths,'ListSize',[250,100]);
if isempty(idx); return; end
tpath=templatepaths{idx};
if strcmp(tpath,cmd4ui_path)
       dn = uigetdir(pwd, 'Select template (path of template) to use');
       if isnumeric(dn); return; end
       tpath=dn;
end
paramgui('setdata','x.template',tpath);
return
%% ===============================================
% 
% [ofi opa]=uiputfile(fullfile(pwd,'.xlsx'),'this');
% if isnumeric(ofi); return; end
% [~,fi,ext]=fileparts(ofi);
% if isempty(fi); fi='dummy';end
% ext='.xlsx';
% fiout=fullfile(opa,[fi ext]);
% 
% %% ===============================================
% 
% paramgui('setdata','x.template',fiout);





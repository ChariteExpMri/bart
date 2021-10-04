
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
    'template'    'UNDEFINED'             'select the template path ("bart_template")'  'd'
    %'vv.c'        'UNDEFINED'             'select the template path'  'd'
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










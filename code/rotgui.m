% #yk ROTATE images such that the slice-midline is vertically oriented (tol ~1-2°)

% function rottab=rotgui(pa,wildcart, p0)
function rottab=rotgui(files,rottab, p0)

warning off;

% ==============================================
%%   input
% ===============================================

if 0
    pa='F:\data3\histo2\josefine\dat\Phagoptose_79c_000000000001EADB';
    filesShort={'a1_001.jpg' 'a1_002.jpg'}';
    file=stradd(filesShort,[pa filesep],1);
    rottab=[filesShort {3 -5}' ];
    
    rottab=rotgui(file,rottab)
    
    rottab=rotgui(file)
    
    rottab=rotgui(file,[],struct('step',10))
    
end
% ==============================================
%%   defaults
% ===============================================

p.step=1;
p.wait=1;
p.isOK=0;


if nargin==3
    p=catstruct(p,p0);
end


% ==============================================
%%
% ===============================================
filesLong=files;
files2=filesLong;
files={};
for i=1:length(files2)
    [px name ext]=fileparts(files2{i});
    files{i,1}=[name ext];
end
pa=px;
% 
% 
% [files,~] = spm_select('List',pa,[ wildcart ]);
% files=cellstr(files);
% files2=stradd(files,[ pa filesep] ,1);
% 
% % v=load(fullfile(pa,'a1_info.mat'));
% % v=v.v;
if exist('rottab')  && isempty(rottab); 
    clear rottab
end
    
if exist('rottab')~=1
    rottab=[files repmat({0},[length(files) 1])] ;
end
% ==============================================
%%   test
% ===============================================
% if 1
%     rottab{1,2}=30;
% end

%% ===============================================
im={};
for i=1:length(files2)
    im{i,1}=imread(files2{i});
    
end
%% ===============================================
delete(findobj(gcf,'tag','rotfig'));
makefigure();

% ------------- predefinition
hr=findobj(0,'tag','rotfig');
lb=findobj(hr,'tag','lb1');                  %set listbox images
set(lb,'string',files);
set(findobj(hr,'tag','dir'),    'string',pa);    %set path
set(findobj(hr,'tag','stepsize'),'string',num2str(p.step));    %set path
% -----------set userdata--
u.pa    =pa;
% u.v     =v;
u.files =files;
u.files2=files2;
u.step=p.step;
u.im=im;
u.rottab=rottab;
u=catstruct(u,p);
set(hr,'userdata',u);



% -----------
loadimg(1);
%===================================================================================================
rottab=[];
if p.wait==1
    uiwait(gcf);
    try
    
    hr=findobj(0,'tag','rotfig');
    u=get(hr,'userdata');
    if u.isOK==1
        rottab=u.rottab;
    else
        rottab=[];
    end
    
   close(hr); 
    catch
      rottab=[];  
    end
end





function isOK(e,e2,arg)
% arg
hr=findobj(0,'tag','rotfig');
u=get(hr,'userdata');
u.isOK=arg;
set(hr,'userdata',u);
uiresume(gcf);




function loadimg(imgnum)
hr=findobj(0,'tag','rotfig');
u=get(hr,'userdata');


% lb=findobj(hr,'tag','lb1');
rotval=u.rottab{imgnum,2};
b=imrotate(u.im{imgnum}, rotval,'crop');
ax1=findobj(hr,'tag','ax1');
axes(ax1);
him=findobj(ax1,'type','image');
set(him,'cdata',b);
xlim([1 size(b,2)]);
ylim([1 size(b,1)]);
% imagesc(b);
set(findobj(hr,'tag','rotvalue'),'string', [num2str(rotval) '°']  );

function selectimg(e,e2)
hr=findobj(0,'tag','rotfig');
u=get(hr,'userdata');
lb=findobj(hr,'tag','lb1');
% rotval=str2num(regexprep(get(findobj(hr,'tag','rotvalue'),'string'),'°',''))
imgno=lb.Value;
loadimg(imgno);


function rotroll(e,e2,arg)
hr=findobj(0,'tag','rotfig');
u=get(hr,'userdata');

lb=findobj(hr,'tag','lb1');
imgno=lb.Value;

step=str2num(get(findobj(hr,'tag','stepsize'),'string'));
u.rottab{imgno,2} =u.rottab{imgno,2}+(arg.*step);
set(hr,'userdata',u);
loadimg(imgno);


function helpfun(e,e2)
uhelp(mfilename);


function makefigure()

fg;
hr=gcf;
set(gcf,'units','norm','tag','rotfig','name',['rotfig [' mfilename ']']);
set(hr,'menubar','none');
imagesc(rand(100));
ax1=gca;
% axis off
grid on;
set(ax1,'linewidth',2,'tag','ax1');
set(ax1,'position',[ .19 .15 .8 .8 ]);


hb=uicontrol(hr,'style','listbox','units','norm', 'string', 'empty');
set(hb,'position',[ 0.001 0.3 .18 .5],'tag','lb1','callback',@selectimg);
%===rotate btn============================================
hb=uicontrol(hr,'style','pushbutton','units','norm', 'string', '<html>&#10226;');
set(hb,'position',[ 0.5 0.01 .1 .08],'tag','rotforw','fontsize',20,'callback',{@rotroll,1});
hb=uicontrol(hr,'style','pushbutton','units','norm', 'string', '<html>&#10227;');
set(hb,'position',[ 0.6 0.01 .1 .08],'tag','rotback','fontsize',20,'callback',{@rotroll,-1});
%===rotate step size ============================================
ht=uicontrol(hr,'style','text','units','norm', 'string', '°step size');
set(ht,'position',[ 0.4 0.05 .1 .04],'backgroundcolor','w');
hb=uicontrol(hr,'style','edit','units','norm', 'string', '0');
set(hb,'position',[ 0.4 0.01 .1 .05],'tag','stepsize');
%===current value ============================================
ht=uicontrol(hr,'style','text','units','norm', 'string', '20.53');
set(ht,'position',[ 0.7 0.01 .1 .08],'tag','rotvalue','fontsize',15);
set(ht,'backgroundcolor','k','foregroundcolor',[0.4667    0.6745    0.1882]);
%===dir ============================================
ht=uicontrol(hr,'style','text','units','norm', 'string', 'path');
set(ht,'position',[ 0.0 0.96 1 .04],'tag','dir','fontsize',10);
set(ht,'backgroundcolor','k','foregroundcolor',[0.4667    0.6745    0.1882]);
%===OK/cancel ============================================
hb=uicontrol(hr,'style','pushbutton','units','norm', 'string', 'OK');
set(hb,'position',[ 0.001 0.01 .1 .05],'tag','Cancel','fontweight','bold');
set(hb,'callback',{@isOK,1});
hb=uicontrol(hr,'style','pushbutton','units','norm', 'string', 'Cancel');
set(hb,'position',[ 0.1 0.01 .1 .05],'tag','OK','fontweight','bold');
set(hb,'callback',{@isOK,0});

%===help ============================================
hb=uicontrol(hr,'style','pushbutton','units','norm', 'string', '?');
set(hb,'position',[ 0.01 0.1 .05 .05],'tag','Cancel','fontweight','bold');
set(hb,'callback',@helpfun);





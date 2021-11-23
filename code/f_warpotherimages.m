

%% #b warp other images to histospace
%% #b      



function f_warpotherimages(showgui,x )

% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-gui
% ===============================================
% p.file      =w.files{1};
% p.file2warp ={'aux_AVGT.nii','aux_ANO.nii' 'aux_AVGThemi.nii'};
% p.interp    ='auto';
% p.outDirName='fin';
% p.saveIMG   =1;
% p.template  ='F:\data3\histo2\bart_template\HISTOVOL.nii';

global ak
template=fullfile(ak.template,'HISTOVOL.nii');

% ==============================================
%%   
% ===============================================


if exist('x')~=1;        x=[]; end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
%% -------------------------------------------------------------
para={...
    'inf98'      '*** warp other images to histospace      '    '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'inf100'     '==================================='                          '' ''
    'niftis2warp'                  ''         'select TIFF-file(s); '  'mf'
    
    'template'   template   'template to used for registration (do not modify)' ''
    'interp'    'auto'      'interpolation type for slicing/resizing/warping: {"auto":determine interpolation;[0]NN;[1];linear} '   {'auto' 0 1}
    '' '' '' ''
    'check_DIRassign'     0  'check folder-assignment only [0/1]: [1] check assignment only..do nothing else; [0] warp images '  'b'
    'isparallel'          0               'use parallel computing (0,1)'  'b'
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




cprintf([0 0 1],[' warp other images... '  '\n']);
xmakebatch(z,p, mfilename); % ## BATCH


% ==============================================
%%   assign folders
% ===============================================
if isempty(z.niftis2warp{1}); 
    disp('no files to warp to histo-space selected');
    return; 
end

% -------------- selected images --> split to obtain dir-names
[px nifti ext]=fileparts2(z.niftis2warp);
[mdir_other_main mdir_other ]=fileparts2(px);
niftifilesShort=cellfun(@(a,b){[a  b]}, nifti,ext );

% -------------- BART selected folders
fidi=bartcb('getsel');
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);

[py dum ]=fileparts2(w.files);
[mdir_bart_main mdir_bart ]=fileparts2(py);

% -------------- assign other-files to selected bart-dir
bartfile  ={};
otherfile ={};
for i=1:length(mdir_bart)
    ix=find(strcmp(mdir_other,mdir_bart{i} ));
    if ~isempty(ix)
        bartfile{end+1,1}=[ w.files{i}  ];
        otherfile{end+1,1}=[ z.niftis2warp(ix)  ];
        
    end
end

if isempty(bartfile) || isempty(otherfile)
    if     isempty(bartfile) ;     disp('no files in BART-GUI selected');
    elseif isempty(otherfile);     disp('no files assigned..check folder-names:folder other images to be warp must correspond to the folder-name in bart/dat (identical folder-names)');
    end
    return;
end




% ==============================================
%%   summary
% ===============================================
tb={};
for i=1:length(bartfile)
    bf=bartfile(i);
    of=otherfile{i};
    
    [pz]=fileparts(bf{1});
    [~,thisMdir]=fileparts(pz); %bart-dir-name
    
    bf2=[bf; repmat({' '},[ length(of)-1 1]) ];
    dx={[' #k [' num2str(i) '] DIR: #r ' thisMdir ]  ''};
    dx=[dx;  bf2 of ];
    tb=[tb; dx];
end
uhelp(plog([],[{' #b Mdir'  'otherFiles'};tb],0, '#ko other files to warp','s=4;al=1;'),1,'name','warpOtherImages');
drawnow

if z.check_DIRassign==1
    return
end

% ==============================================
%%   PROCEED
% ===============================================
z2=z;
z2=rmfield(z2,'niftis2warp');
disp(['isparalel: ' num2str(z2.isparallel)]);

if z.isparallel==0
    for i=1:length(bartfile)
        warpotherimages(bartfile{i}, otherfile{i},z2);
    end
else
    parfor k=1:length(bartfile)
        warpotherimages(bartfile{i}, otherfile{i},z2);
    end
end

% ==============================================
%%   
% ===============================================


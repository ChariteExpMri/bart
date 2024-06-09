
function varargout=f_manwarp(showgui,x )



%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end
if exist('x')~=1;        x=[]; end


% ==============================================
%%   predefined images
% ===============================================
global ak
pa_template=ak.template;
% pa_template=strrep(which('bart.m'),'bart.m','templates');
tb0={...%Name__________INterpol
    'AVGT.nii'          '0'
    'AVGThemi.nii'      '0'
    'ANO.nii'           '0'
    };
tb=tb0;
tb(:,1)=stradd(tb0(:,1),[pa_template filesep],1); %fullpath


%% ============[defaultsfile]===================================

defaultsfile=which('deepslice_defaults.m');
if exist(defaultsfile)==0
    defaultsfile= fullfile(fileparts(ak.dat),'deepslice_defaults.m');
end
if exist(defaultsfile)~=2
    msg='deepslice-file "deepslice_defaults.m" not found..abort';
    %msgbox(msg) ;
    disp(msg);
    return
end

% refimage=tb{1,1} ;
% ==============================================
%%   struct
% ===============================================
para={...
    
% 'inf1'    'TRANSFORM IMAGES BACK TO HISTO-SPACE'  ''  ''
% '' '' '' ''
% 'image'  1       '[1] use original input image, [0]use  lowresscreenshot(jpg) from original  {0|1} '  'b'
% 'dummy'   'dummy'  'dummyvariable'  'w'
'useModFile'     1              'use modFile "a2_XXXmod.tif" if exist'               'b'
'defaultsfile'  defaultsfile   'fullfile name to "deepslice_defaults.m"'  'f'
% 'pythonscript' 'runDeepslice_single.py'       'deepslice script' {'runDeepslice_single.py'}

% '' '' '' ''
% 'saveIMG'        1  'save output images {0|1}; [0]is for testing only [1]yes save images'      'b'

};


% ==============================================
%%
% ===============================================
p=paramadd(para,x);%add/replace parameter
%     [m z]=paramgui(p,'uiwait',0,'close',0,'editorpos',[.03 0 1 1],'figpos',[.2 .3 .7 .5 ],'title','PARAMETERS: LABELING');

% %% show GUI
if showgui==1
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],'figpos',[.1 .2 .5 .3 ],...
        'title',[mfilename '.m'],'pb1string','OK','info',hlp);
    if isempty(m); return; end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end

xmakebatch(z,p, mfilename); % ## BATCH

%% =======[other paras]========================================

z.templatepath=pa_template;

z.defaultsfile=char(z.defaultsfile);
wd=pwd;
[padef, namedef, extdef]=fileparts(z.defaultsfile);
cd(padef);
q=feval(namedef);
z=catstruct(z,q);
cd(wd);

%% ===============================================

if showgui==1
    varargout{1}=z;
    if ischar(parse)==1 && strcmp(parse,'parse')
        showgui=-1;
    end
end
% ==============================================
%%   Parse parameter without runnning rest
% ===============================================
if showgui==-1
    p2=struct2param(p,z);
    p2=[{['@' mfilename] 0 'FunctionName' ''}; p2]; % add functionName
    varargout{1}=p2;
    return
end


cprintf([0 0 1],[' running deepslice... '  '\n']);

% ==============================================
%%   files
% ===============================================
if isfield(x,'files') && ~isempty(char(x.files))
    z.files=x.files;
else
    fidi=bartcb('getsel')  ;
    z.files=fidi(strcmp(fidi(:,2),'file'),1);
end


% ==============================================
%%   PROCEED
% ===============================================
% cprintf([0 0 1],[' warping to histoSpace... '  '\n']);
z.files=cellstr(z.files);
z.files=regexprep(z.files,'.tif$','.jpg'); %use JPG
if isempty( char(z.files)); return; end
timex=tic;
% if z.isparallel==0
for i=1:length(z.files)
    z2=z;
    z2=rmfield(z2,'files');
    z2.file=z.files{i};
    manwarp(z2);
end
% else
%     n=length(z.files);
%    parfor i=1:n
%        disp('hui')
%         z2=z;
%         z2=rmfield(z2,'files');
%         z2.file=z.files{i};
%         warp2histo(z2);
%     end
% end
cprintf([0 0 1],[' done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);


% ==============================================
%%   run deepslice
% ===============================================
function manwarp(p)

%% ===============================================

%% ======[path]=========================================
[mdir name ext]=fileparts(p.file);
nametagDS=regexprep(name,'a1_','a3_')
imagepath=fullfile(mdir,[ 'deepsl_' nametagDS  ]);


outtag=regexprep(name,'a1_','a4_')

% strrep(name,'_deepsliceIN','');


%% ===============================================
outdir   =mdir;
f1      =fullfile(p.templatepath,'AVGT.nii');
f2      =fullfile(p.templatepath,'ANO.nii' );
f3     =fullfile(imagepath,'est.xml');
outname=[outtag   '_warped']
f4    =fullfile(outdir,[ outname '.txt']);
if exist(f4)~=2
    f4=[];
end


if p.useModFile==1
    %% ===============================================
    fname=[regexprep(name,'a1_','a2_') 'mod.tif' ];
    modfile=fullfile(mdir,fname);
    manwarp2d('fixfile',modfile, 'warpfile',f1,'warpfile2',f2,'xmlfile',f3,'outdir',outdir,'pnt_out' ,outname ,'pntfile',f4);
    disp('use modfile');
    %% ===============================================
    
    
else
    
    manwarp2d('warpfile',f1,'warpfile2',f2,'xmlfile',f3,'outdir',outdir,'pnt_out' ,outname ,'pntfile',f4);
    
end
%% ===============================================









return
clean_dir=1;
run_cmd  =1;
%% ======[path]=========================================

[pa0 name ext]=fileparts(p.file);

imagepath=fullfile(pa0,[ 'deepsl_' name  ]);
if clean_dir==1
    try; rmdir(imagepath, 's'); end
end
if exist(imagepath)==0; mkdir(imagepath); end

%% ======[file]=========================================

if p.image==1  %read tiff
    file00=fullfile(pa0 ,[name '.tif']);
    a=imread(file00);
    b=imresize(a,[1000 1000]);
    %fg,imagesc(b)
    b=uint8((imadjust(mat2gray(b))*255));
    if size(b,3)==3; b=rgb2gray(b); end
    file0=fullfile(pa0, [ name '_deepsliceIn' ext]  );
    imwrite(b,file0);
    
else
    a=imread(p.file);
    a2=imresize(a,[1000 1000]);
    file0=fullfile(pa0, [ name '_deepsliceIn' ext]  );
    imwrite(a2,file0);
end

file=fullfile(imagepath, [ name '_deepsliceIn' ext]  );
copyfile(file0,file,'f');

%% =====[python script]==========================================
pythonscript=which(p.pythonscript);
%% ===============================================
% clear; cf; warning off
% imagepath   ='C:\paul_projects\python_deepslice\paul_histoIMG'
% imagepath   ='C:\paul_projects\python_deepslice\paul_histoIMG\test3'
% pythonscript='C:\paul_projects\python_deepslice\runDeepslice.py'
% pythonscript=which('runDeepslice_single.py')

% conda_path  ='C:\Users\skoch\miniconda3';
% % conda_path  ='C:\Users\skoch\anaconda3'
% conda_env   ='C:\Users\skoch\anaconda3\envs\deepslice';










%% ===============================================
pythonscript_pyt =strrep(pythonscript,filesep,'/');
imagepath_pyt    =strrep(imagepath,filesep,'/');

% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate "C:\Users\skoch\anaconda3\envs\deepslice";cd "C:\paul_projects\python_deepslice"; python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
%===================================================================================================
%windir%\System32\cmd.exe "/K" C:\Users\skoch\anaconda3\Scripts\activate.bat C:\Users\skoch\anaconda3

%% =====[get powershell]==========================================
[r1 m]=system('where powershell.exe');
pshellpath=regexprep([char(m)],char(10),'');

%% ==========[run]=====================================

c={
    % ['%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit ']
    [pshellpath ' -ExecutionPolicy ByPass -NoExit ']
    ['-Command "& "' p.conda_path  '\shell\condabin\conda-hook.ps1"; ']
    ['conda activate "' p.conda_env '"; ']
    ['python '  '"' pythonscript_pyt  '"  "' imagepath_pyt  '";']
    ['exit']
    };
cm=strjoin(c,' ');
if run_cmd==1
    system(cm);
end

%% =======[postanal]========================================
file_xml=fullfile(imagepath, 'est.xml');
if exist(file_xml)==2
    disp('..deepslice SUCCESSSFUL...');
    showinfo2('..',file_xml);
else
    disp('..deepslice FAILED...');
end


% ==============================================
%%   extract slice
% ===============================================
% file_out =    'F:\data5_histo\livia_test\dat\5ht\deepsl_a1_001\est.xml'

[co st]=getestimation_xml(file_xml,'loadhistoimage',1); %get histoImage
fi1=fullfile(p.templatepath,'AVGT.nii');
mov =getslice_fromcords(fi1,co,  st.histo_size,1);
[fix]=imread(file);
% ==============================================
%%   QA-1 [animated-gif]
% ===============================================

fx=uint8(255*imadjust(mat2gray(double(fix))));
mv=uint8(255*imadjust(mat2gray(double(mov))));
% fx=ind2rgb(fx,jet);
% mv=ind2rgb(mv,jet);

loops=65535;
delay=.4;
cmap=gray;

fo1=fullfile(pa0, [ name '_deepsliceQA1' '.gif']);

imwrite(fx,cmap,[fo1],'gif','LoopCount',loops,'DelayTime',delay)
imwrite(mv,cmap,[fo1],'gif','WriteMode','append','DelayTime',delay)
showinfo2('saved QA-1',fo1);

%% ===============================================
% ==============================================
%%   QA-2 [side-by Side]
% ===============================================
np=1;
p=ones(np);
siz=[size(mv,1) size(mv,2)];
check=repmat([ [p p-1]; [ p-1 p]  ],round(siz./(2*np)+1));
check=check(1:siz(1),1:siz(2));
fus2=check.*double(mv)+~check.*double(fx);
% fg,image(fus2)
% ===============================================
fus1=imfuse(mv,fx ,'falsecolor');
t1=[ind2rgb(fx,gray)*255  ind2rgb(mv,gray)*255 ;  fus1 ind2rgb(fus2,jet)*255 ];

% fg,image(t1)
fo3=fullfile(pa0, [ name '_deepsliceQA2' '.jpg']);
imwrite(t1,fo3);
showinfo2('saved QA-1',fo3);


%% =======[write template-slice]========================================
fo2=fullfile(pa0, [ name '_deepsliceOut' '.jpg']);
imwrite(mv,fo2);
showinfo2('saved template-slice',fo2);
%% ===============================================

return
%
%  t1=[fx              mv   fx];
%  t2=[imfuse(fx,mv )  mv   mv];
%
%
% q=ind2rgb(rgb2gray(imfuse(fx,mv )),jet);
%
% %% ===============================================
% loops=65535;
% delay=.4;
%
% fx2=ind2rgb(fx,jet);
%
% fo1=f'bla.png'
%
% imwrite(t1,jet,[fo1],'gif','LoopCount',loops,'DelayTime',delay)
% imwrite(img2,c_map,[filenameFP],'gif','WriteMode','append','DelayTime',delay)
% showinfo2('saved warpedImage',filenameFP);




%% ===============================================


return
%% ===============================================
% clc
%
% c={
% ['%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit ']
% ['-Command "& ''C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1'' ; ']
% ['conda activate "C:\Users\skoch\anaconda3\envs\deepslice"; ']
% ['cd "C:\paul_projects\python_deepslice"; ']
% ['python' ' '  'test2.py'  ' ' '"C:/paul_projects/python_deepslice/paul_histoIMG";']
% ['exit']
% };
% cm=strjoin(c,' ');
% system(cm);

%
% % ==============================================
% %%
% % ===============================================
%
% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate 'C:\Users\skoch\miniconda3' "
%
%
% sleep 10
%
% conda activate C:\Users\skoch\anaconda3\envs\deepslice
% cd "C:\paul_projects\python_deepslice"
%
% python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
%
% exit
%
%
% % system('%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& ''C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1'' ; conda activate ''C:\Users\skoch\miniconda3'' "')
% % system('conda activate C:\Users\skoch\anaconda3\envs\deepslice')
% % system('cd "C:\paul_projects\python_deepslice"')
%
%
% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate "C:\Users\skoch\anaconda3\envs\deepslice";cd "C:\paul_projects\python_deepslice"; python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
%
%
% conda activate 'C:\Users\skoch\miniconda3' "
% && conda activate "C:\Users\skoch\anaconda3\envs\deepslice"
%
%
% && cd "C:\paul_projects\python_deepslice" && python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
%
% python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'















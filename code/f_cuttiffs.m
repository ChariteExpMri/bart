






%% #b cut tiffs     
%% cut large tiff into slices
% x.transpose =1;         transpose image {0,1}
% x.outstr    ='a1_';     output-string of the slice ...followed by numeric number
% x.verbose   =0;         give extra info  {0,1}
% x.outdir    ='up1';     out-put directory: {explicit path,'same' 'up1'}
%                           explicit path: explicit output-directory
%                           'same': same directory as input-image
%                           'up1' 1st. upper directory of input-image
% x.thumbnail =1;         save thumbnail image (jpg) {0,1}
%% EXAMPLE:
% file='F:\data3\histo2\data_Josephine\Wildlinge_fr_h_20_2_000000000001EADF\raw\Wildlinge_fr_h_20_2_000000000001EADF_x10_z0.tif'
% cuttiff(file,struct('transpose',1,'verbose',0));
%% EXAMPLE GUI
% z=[];
% z.files      = '';         % % select tiff files
% z.fileswcard = '_x10';     % % alternative select wildcard string --> use 10x -images from selected listbox
% z.transpose  = [1];        % % transpose image {0,1}
% z.verbose    = [1];        % % passes extra info  {0,1}
% z.outdir     = 'up1';      % % out-put directory: {explicit path, same" "up1"}
% z.verb       = [1];        % % verbose,passes extra info  {0,1}
% z.thumbnail  = [1];        % % save thumbnail image (jpg) {0,1}
% z.isparallel = [1];        % % use parallel computing (0,1)
% f_cuttiffs(1,z);




function f_cuttiffs(showgui,x )

if 0
    
    z=[];
    z.files  = { 'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF.ndpi'             % % select tiff files
        'C:\Users\skoch\Desktop\histo_\Wildlinge fr_h #20.2_000000000001EADF_macro.tif' };
    z.format = 'ndpi';                                                                                  % % select tiff files
    f_importTiff(0,z);
    
end

%———————————————————————————————————————————————
%%   PARAMS
%———————————————————————————————————————————————
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-gui
% ===============================================

if exist('x')~=1;        x=[]; end

templateDir=fullfile(fileparts(which('bart.m')),'templates');
%% import 4ddata
para={...
%     'inf98'      '*** cut tif to slices      '                                  '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
%     'inf100'     '==================================='                          '' ''
    'files'                  ''                'select tiff files'                   'mf'
    'fileswcard'             '_x10'                'alternative select wildcard string'   {'_x10' ''}
    'transpose'              1                'transpose image {0,1}'               'b'
    'outdir'                'up1'      'out-put directory: {explicit path, same" "up1"}'  {'up1' 'same'}
    'verb'                   0                  'verbose,passes extra info  {0,1}'               'b'
    'thumbnail'              1                'save thumbnail image (jpg) {0,1}'          'b'
    'isparallel'             0                'use parallel computing (0,1)'  'b'
    ...
%     'template'             templateDir       'select main template folder <required to fill>'  'd'
%     'keepSubdirStructure'   1          '[0,1]: [0] flattened hierarchy (no subdirs), [1] the destination path contains the subfolders  '    'b'
%     'animalsubdirs'         1          '[0,1]: [1] preserve SUBFOLDERS WITHIN ANIMAL FOLDERS in either output name or folder hierarchy or [0] do not preserve' 'b'
%     'prefixDirName'         0          'adds mouse Dir/folder name as prefix to the new filename'      'b'
%     'renameString'         ''          'replace file name with new file name (no file extention), !NOTE: files might be overwritten (same output name)'  {'mask' 'raw' 'test'}
%     'addString'            ''          'add string as suffix to the output file name'                                                            ''
%     'reorient'             ''          ' <9 lement vector> reorient volume, default: []: do nothing; (nb: use [0 0 0 0 0 0 1 -1 1] if data came from DSIstudio)'  {'0 0 0 0 0 0 -1 1 1';'0 0 0 0 0 0 1 -1 1'; '0 0 0 0 0 0 -1 -1 1'}
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

cprintf([0 0 1],[' import Tiffs... '  '\n']);
xmakebatch(z,p, mfilename); % ## BATCH

% ==============================================
%%   get files if wildcard used
% ===============================================
if ~isempty(regexprep(char(z.fileswcard),'\s+',''))
    [files  ]=bartcb('getsel');
    dirs=files(strcmp(files(:,2),'dir'),1); %dir-folder only
    if isempty(char(dirs))
        msgbox('no animal folder(s) selected');
        return
        
    end
        
    dirs=stradd(dirs,[filesep 'raw'],2);
    
    files2={};
    for i=1:length(dirs)
        [files,~] = spm_select('List',dirs{i},[ '' z.fileswcard ]);
        if ~isempty(files)
            files=cellstr(files);
            files=stradd(files,[ dirs{i} filesep] ,1);
            files2=[files2; files];
        end
    end
    if ~isempty(files2)
        files1=char(z.files);
        if isempty(files1)
            z.files=files2;
        else
            z.files=unique([z.files; files2]);
        end
    end
    
end


% ==============================================
%%   proceed
% ===============================================

% ==============================================
%%   proceed
% ===============================================
z.zfiles=cellstr(z.files);
global ak
s=catstruct(z,ak);
disp(['isparalel: ' num2str(s.isparallel)]);
lgerr={[' #ok CUT-TIFFS (' mfilename  ')']};
lgerr=[lgerr; {[' #wb ERRONEOUS File #w'  repmat(' ',[1 size(char(z.files),2)-12])  '#wr Message']} ];
lgerr=[lgerr; { repmat('=',[1 length(lgerr{2})])} ];
if s.isparallel==0
    
    for i=1:length(z.files)
        try
        cuttiff(z.files{i},s);
        catch
            lgerr=[lgerr;  {[z.files{i}  ' #r ' regexprep(lasterr,char(10),'--')]} ];
        end
    end
    
else
    poolobj = gcp;
    addAttachedFiles(poolobj,{which('f_cuttiffs.m'),which('cuttiff.m')});
    updateAttachedFiles(poolobj);
    parfor i=1:length(z.files)
        try
            cuttiff(z.files{i},s);
        catch
            %  dum={[z.files{i}  ' #r ' regexprep(lasterr,char(10),'--')]};
            % dum={'www'} ;
            lgerr=[lgerr;  {[z.files{i}  ' #r ' regexprep(lasterr,char(10),'--')]} ];
        end
    end
end

uhelp(lgerr)







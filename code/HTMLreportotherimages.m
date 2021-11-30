

% make HTMLreport: other images warped to histospace

function HTMLreportotherimages(showgui,x )


global ak
tx=[...
    %     {'finalResult' ['fin' filesep 's#_result.gif']  }
    {'otherImages' ['fin' filesep 's#_other_.gif']            '.mat' 'Other Images Warped  To Histospace'}
    {'pseudoANOtiff'         ['fin' filesep 's#_ANO_.jpg']    '.tif' 'ANOatlas in Histospace in pseudoColors (Slice-size)'}
    ];
outdir=fullfile(fileparts(ak.dat),'checks') ;
% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-gui
% ===============================================

if exist('x')~=1;        x=[]; end

%% import 4ddata
para={...
    'inf98'      '*** HTMLreport      '    '' ''   %    'inf1'      '% PARAMETER         '                                    ''  ''
    'task'                 tx{1,1}           'Task to perform. Display putput of task in HTML)'  tx(:,1)
    'outdir'              outdir             'output directory'  'd'
    'HTMLfileName'          ''               'filename-suffix of HTML-file (optional)'  ''
    'imageSize'             300              'image size (width) in pixels'    {50 100 200 400 500 1000}
    'istest'                 0               'testMOde: perform report for 1st slice only (0,1)'  'b'
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

cprintf([0 0 1],[' HTMLreport... '  '\n']);
xmakebatch(z,p, mfilename); % ## BATCH


p=z;

% p.istest  =0;  %[0]all animals;  [1]: test of 5 animals
% p.task    =tx{1,1};
% p.outdir  =fullfile(fileparts(ak.dat),'checks');
% p.HTMLfileName = 'test1'


% ==============================================
%%
% ===============================================


%% readout insentity image
% cf;clear; warning off

fidi=bartcb('getsel');
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);



% ==============================================
%%   parameter
% ===============================================


% global ak
%
%
% tx=[...
%     {'finalResult' ['fin' filesep 's#_result.gif']  }
%
%     ]
% p.addimage=1;  %add image in matfile
% p.istest  =0;  %[0]all animals;  [1]: test of 5 animals
% p.task    ='finalResult';
% p.outdir  =fullfile(fileparts(ak.dat),'checks');
% p.HTMLfileName = 'test1'

% ==============================================
%%   get selected  files and mdirs
% ===============================================


fidi=bartcb('getsel');
w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
w.files =fidi(strcmp(fidi(:,2),'file'),1);

files=w.files ;
[pas name ext]=fileparts2(files );
[pas2 name2 ext2]=fileparts2(pas );
% mname=name2 ;%  mouseName
mname=cellfun(@(a,b){[a filesep b]}, name2,name );%  mouseName



% ==============================================
%%   get selected  files and mdirs
% ===============================================
N=length(files);
if p.istest==1
    N=5;
    cprintf([0 0 1],[' TEST of  N='  num2str(N) '  animals \n']);
else
    cprintf([0 0 1],[' ANIMALS  N='  num2str(N) '  animals \n']);
end




% ############################################################
%%
%%   PART-1  :       get images
%%
% ############################################################  
tb=[]; %table to fill:
for mo=1:N
    [pa name ext]=fileparts(files{mo} );
    animal=mname{mo};
    
    disp([ num2str(mo) '/' num2str(N) ': ' animal   ]);
    
    pafin=fullfile(pa,'fin');
    nametok=[strrep(name,'a1_','')];
    
    itx=regexpi2(tx(:,1),p.task);
    s=tx{itx,2};
    
    [sub namestr ext]=fileparts(s);
    paf=fullfile(pa,sub);
    
    if strcmp(p.task, 'otherImages')
        searchstr=[regexprep(namestr,'#',nametok) '.*.gif'];
    elseif strcmp(p.task, 'pseudoANOtiff')
        searchstr=[regexprep(namestr,'#',nametok) '.*.jpg'];
    end
    [filex] = spm_select('FPList',paf,['^' searchstr]);
    filex=cellstr(filex);
    if isempty(filex{1})
        filex=[];
    end
    
    
    img=filex;
    %-------ANIMATED gif ------------------------------------
    %
    m={};
    try      %__RAW-FILE_______________________
        lg=importdata(fullfile(pa,'importlog.txt'));
        iraw=regexpi2(lg,[ name ext '$'])-1;
        rawfile=regexprep(lg{iraw},'.*\[origin]: ','');
        m(end+1,1)={['RAW               : ' rawfile ]};
    end
    try
        %__TIF-IMAGE_______________________
        ht=imfinfo(files{mo});
        m(end+1,1)={['Width x Height    : ' num2str(ht.Width) ' x ' num2str(ht.Height) ...
            '; approx size: ' num2str(round(ht.FileSize/1e6)) '[MB]' ]};
    end
    
    try
        %__REF-IMAGE_______________________
        F2=fullfile(pa , [strrep(name,'a1','a2') '.mat']);
        q=load(F2); q=q.s;
        if isfield(q,'rotationmod')
            m(end+1,1)={['Rotation          : ' num2str(q.rotationmod) ]};
        end
        if isfield(q,'rotationmod')
            m(end+1,1)={['add Border        : ' num2str(q.bordermod) ]};
        end
        if isfield(q,'hemi')
            m(end+1,1)={['HemisphereType    :   ' (q.hemi) ]};
        else
            m(end+1,1)={['HemisphereType    :   ' 'L+R' ]};
        end
    end
    try
        %__MOD-IMAGE_______________________
        F2=fullfile(pa , [strrep(name,'a1','a2') 'mod' ext]);
        if exist(F2)==2
            m(end+1,1)={['use MOD-Image     : yes' ]};
        else
            m(end+1,1)={['use MOD-Image     : no' ]};
        end
    end
    %          m
    u.animal=animal;
    
    
    % abdate table
    dx= [animal {u} {m} {img}  ];
    tb=[tb; dx];
    
end %animal

% ==============================================
%%   mkdir
% ===============================================
% pastudy=fileparts(fileparts(w.dirs{1}));
% paresult=fullfile(pastudy,'results');




% ############################################################
%%
%%   PART-2  :       prepare HTML header/footer and dirs
%%
% ############################################################    

paresult=p.outdir ;
mkdir(paresult);

if isempty(p.HTMLfileName)
    subdir=p.task ;
else
    subdir=[p.task '_' p.HTMLfileName];
end


pahtml=fullfile(paresult,subdir);
mkdir(pahtml);



hs={
    '<!DOCTYPE html>'
    '<html>'
    '<head>'
    '<style>'
    'img {'
    '  width: 100%;'
    '}'
    '</style>'
    '</head>'
    '<body>'
    };
%  'testSubject  1s2222'
%  '<br>'
%  '<img src="images/a1.jpg" alt="HTML5 Icon" style="width:400px;height:400px;">'
he={
    '</body>'
    '</html>'
    ''
    };


% ############################################################
%%
%%   PART-3  :       create HTML & co
%%
% ############################################################ 

itask=find(strcmp(tx(:,1), p.task ));
formatOutput=tx{itask,3};
header      =tx{itask,4};
    
    v2={};
    v2{end+1,1}=[ '<h2> <font color="blue">' '*** ' header ' ***' '</h3>  </font> ' ];
    wid=p.imageSize;%800;
    for mo=1:size(tb,1)
        
        tt=tb(mo,:);
        animalname=tt{1};
        info=tt{3};
        img=tt{4};
        
        
        
        v={ [ '<h3> [ animal-' num2str(mo) ']..  <font color="green">' animalname '</h3>  </font> ' ]  };
        shortnamelist={};
        
        if ~isempty(img)
            for i=1:length(img)
                thisimg=img{i};
                [pax namex fmtx ]=fileparts(thisimg);
                sname=[ strrep(animalname,'\','__')  namex fmtx]; %file_name (link/copy)
                fsave =fullfile(pahtml, sname); %copy-destination
                flink =[ subdir '/' sname] ; %HTML-link
                shortnamelist{i,1}=[namex formatOutput ];
                
                if exist(thisimg)~=0
                    copyfile(thisimg,fsave,'f');
                    v=[v; {[ '<img src="' flink '" alt="-no imgae--> registration not finished" style="width:' num2str(wid) 'px;height:' num2str(wid) 'px;"'...
                        [' title="'   namex   '">']  ]} ];
                    
                else
                    v{end+1,1}='<font color="red">';
                    v{end+1,1}= [namex '-image not found not finished --> final result (Image) not found'];
                    v{end+1,1}='</font">';
                end
                if mod(i,3)==0
                    v{end+1}=[ '<br>'  ];
                end
            end
            
            v{end+1}=[ '<br>'  ];
            %v{end+1}=[ strjoin(shortnamelist, repmat('&nbsp;', [1 p.imageSize/10 ])) '<br>'  ];
            if length(shortnamelist)<=3
                tbwidth=p.imageSize*length(shortnamelist)+5*length(shortnamelist);
            else
               tbwidth=p.imageSize*(3)+5*length(3); 
            end
            v{end+1}=['<table border="0" width="'  num2str(tbwidth)  '" align="left">'];
            v{end+1}='<font color="green">';
            
            for i=1:length(shortnamelist)
                v{end+1}=['<td style="color:green;text-align: center; vertical-align: middle;">'  shortnamelist{i}   '</td>'];
                if mod(i,3)==0
                    v{end+1}=[ '<tr>'  ];
                end
            end
            v{end+1}=['</table>'];
            v{end+1}='</font">';
            v{end+1}=[ '<br>'  ];
        else
            v{end+1,1}='<font color="red">';
            v{end+1,1}= ['no other images warped to histoSpace image (other images not found)'];
            v{end+1,1}='</font">';
        end
        
        %_________INFO__________________________________
        v{end+1}=[ '<br>'  ];
        v{end+1}='<font color="blue">';
        v{end+1}=[ '<pre>'  ];
        for i=1:length(info)
            v{end+1}= [  info{i}  ];
        end
        v{end+1}=[ '</pre>'  ];
        v{end+1}='</font">';
        
        
       
        
        
     
        v=[v; {[ '<br>'  ]} ];
        
        v2=[v2; v];
    end
    
    z=[  hs ;v2; he];
    if isempty(p.HTMLfileName)
        htmlfile=fullfile(fileparts(pahtml),[p.task  '.html']);
    else
        htmlfile=fullfile(fileparts(pahtml),[p.task '_' p.HTMLfileName '.html']);
    end
    pwrite2file(htmlfile,z);
    showinfo2('HTML-file',htmlfile);
    
    

%% ===============================================








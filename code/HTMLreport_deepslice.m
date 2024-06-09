

% make HTMLreport: finalResult (registration)

function HTMLreport_deepslice(showgui,x )


global ak
%% ===============================================
wid1=300;
wid2=600;
wid3=1000;
tx=[...
    {
    
    'input' [ filesep 'a3_#_deepsliceIN.jpg' ]           wid1
    'prunemask' [ filesep 'a2_#.jpg'  ]                  wid2
    'deepslice' [ filesep 'a3_#_deepsliceOut.jpg' ]      wid1
    '' [ filesep 'a3_#_deepsliceQA1.gif']                wid1
    '' [ filesep 'a3_#_deepsliceQA2.jpg']                wid1
    'manually warped' [ filesep 'a4_#_warped.png']       wid1 
    '' [ filesep 'a4_#_warpedQA.png']                    wid1
    
    'post-warp' [ filesep 'a5_#_warpedQA1.png']          wid2
    '' [ filesep 'a5_#_warpedQA2.png']                   wid3
    '' [ filesep 'a5_#_warpedQA3.jpg']                   wid2
    }
    ];
outdir=fullfile(fileparts(ak.dat),'checks') ;
% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end


showgui=0;

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
    'imageSize'             600              'image size (width) in pixels'    {50 100 200 400 500 1000}          
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
%%   get selected  files and mdirs
% ===============================================

disp(['wait...']);
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
    cprintf([0 0 1],[' TEST of  N='  num2str(N) '  slices \n']);
else
    cprintf([0 0 1],[' SLICES  N='  num2str(N) '  slices \n']);
end

%% ===============================================
paresult=p.outdir ;
mkdir(paresult);

% if isempty(p.HTMLfileName)
%    subdir=p.task ;
% else
%     subdir=[p.task '_' p.HTMLfileName];
% end
subdir='sub'

pahtml=fullfile(paresult,subdir);
mkdir(pahtml);


v={}
% wid1=300
% wid2=500;
for mo=1:N
    [pa name ext]=fileparts(files{mo} );
    animal=mname{mo}
    pafin=fullfile(pa);
    [~,animal]=fileparts(pa)
    nametok=[strrep(name,'a1_','')];
      v(end+1,1)={ [ '<h2> [ animal-' num2str(mo) ']..  <font color="fuchsia">' animal '</h2>  </font> ' ]  };
    
    for i=1:size(tx,1)
        
        %title
        if ~isempty(tx{i,1})
            %v(end+1,1)={[  tx{i,1}   '<br>']}
            v(end+1,1)={ [ '<h4>  <font color="blue">' tx{i,1}  '</h4>  </font> ' ]  };
        end
        
        
        imname=regexprep(tx{i,2},'#', nametok)
        
        fi1=fullfile(pa,imname)
        
        fname=[animal    strrep(imname,filesep,'_')]
        fo1=fullfile(pahtml, fname)
        
        
%         sname=[ strrep(animalname,'\','__')  '.gif'];
%         fsave =fullfile(pahtml, sname);
        link =[ subdir '/' fname] ;
        
        wid=tx{i,3}
        
     
        if exist(fi1)==2
             copyfile(fi1,fo1,'f')
%                           v=[v; {[ '<img src="' link '" alt="-no imgae--> registration not finished" style="width:' num2str(wid) 'px;height:' num2str(wid) 'px;"'...
%  [' title="' 'registration' '-image'  '">']  ]} ];
           v=[v; {[ '<img src="' link '" alt="-no imgae--> registration not finished" style="width:' num2str(wid) 'px;"'...
                 [' title="' 'registration' '-image'  '">']  ]} ];
        else
            v{end+1,1}='<font color="red">';
            v{end+1,1}= [tx{i,1} ' <br>(Image) not found'];
            v{end+1,1}='</font">';
            
        end
        
        
        
    end
 
end%animal

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
   

 '<style>'
 '    h2, p {'
 '       margin: 0;'
 '    }'
  '    h4, p {'
 '       margin: 0;'
 '    }'
 '</style>'

    
    };
%  'testSubject  1s2222'
%  '<br>'
%  '<img src="images/a1.jpg" alt="HTML5 Icon" style="width:400px;height:400px;">'
he={
    '</body>'
    '</html>'
    ''
    };


    z=[  hs ;v; he];
    if isempty(p.HTMLfileName)
        htmlfile=fullfile(fileparts(pahtml),[   'index.html']);
    else
        htmlfile=fullfile(fileparts(pahtml),[p.task '_' p.HTMLfileName '.html']);
    end
    pwrite2file(htmlfile,z);
    showinfo2('HTML-file',htmlfile);


%% ===============================================



return




%% ===============================================



tb=[]; %table to fill:
for mo=1:N
    [pa name ext]=fileparts(files{mo} );
    animal=mname{mo};
    
    %disp([ num2str(mo) '/' num2str(N) ': ' animal   ]);
    
    %pafin=fullfile(pa,'fin');
    pafin=fullfile(pa);
    nametok=[strrep(name,'a1_','')];
    
    itx=regexpi2(tx(:,1),p.task);
    s=tx{itx,2};
    
    f1=fullfile(pa,[strrep(s,'#',nametok)]);
    %% __
    m={};
    %% __
    u.animal=animal;
    img=f1;
    
    
    dx= [animal {u} {m} img  ];
    tb=[tb; dx];
    
end

% ==============================================
%%   mkdir
% ===============================================
% pastudy=fileparts(fileparts(w.dirs{1}));
% paresult=fullfile(pastudy,'results');



%% ##################################################
% ==============================================
%%      make HTML-fie ##########
% ===============================================
%% ##################################################



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


if strcmp(p.task,'finalResult')
    
    
    v2={};
    wid=p.imageSize;%800;
    cprintf([0 .7 0],'..copying images:.. ');
    for mo=1:size(tb,1)
        
        tt=tb(mo,:);
        animalname=tt{1};
        info=tt{3};
        img=tt{4};
        
        sname=[ strrep(animalname,'\','__')  '.gif'];
        fsave =fullfile(pahtml, sname);
        flink =[ subdir '/' sname] ;
        
      v={ [ '<h3> [ animal-' num2str(mo) ']..  <font color="green">' animalname '</h3>  </font> ' ]  };
      if exist(img)~=0
          copyfile(img,fsave,'f');
          v=[v; {[ '<img src="' flink '" alt="-no imgae--> registration not finished" style="width:' num2str(wid) 'px;height:' num2str(wid) 'px;"'...
              [' title="' 'registration' '-image'  '">']  ]} ];
      else
           v{end+1,1}='<font color="red">';
           v{end+1,1}= 'registration not finished --> final result (Image) not found';
           v{end+1,1}='</font">';
          
      end
        
      if mod(mo,10)==0
          cprintf([0 .7 0],['' num2str(mo) '.. ']);
      end
        
        v{end+1}=[ '<br>'  ];
        
        
        
        %_________INFO__________________________________
        v{end+1}='<font color="blue">';
        v{end+1}=[ '<pre>'  ];
        for i=1:length(info)
            v{end+1}= [  info{i}  ];
        end
        v{end+1}=[ '</pre>'  ];
        v{end+1}='</font">';
        
        
        if 0
            B={};
            for i=1:length(info)
                dv={'<pre style="font-family:courier;color:191970;font-size:15px;line-height:.1;">'
                    info{i}
                    '</pre>'
                    }
                B=[B;dv]
            end
            v=[v;B]
        end
        
        
        %         for i=1:length(imgs)
        %             sname=[ animalname '__' head{i} '.jpg'];
        %             fsave =fullfile(pahtml, sname);
        %             flink =[ subdir '/' sname] ;
        %             if ~isempty(strfind(head{i},'ano'))
        %                 imgx= uint8(round(255.*imadjust(mat2gray(pseudocolorize(imgs{i})   ))));
        %             else
        %                 imgx= uint8(round(255.*imadjust(mat2gray(imgs{i}))));
        %             end
        %             imwrite(imgx,fsave);
        %
        %             %__HTML_links
        %             v=[v; {[ '<img src="' flink '" alt="HTML5 Icon" style="width:' num2str(wid) 'px;height:' num2str(wid) 'px;"'...
        %                 [' title="' upper(head{i}) '-image'  '">']  ]} ];
        %         end
        v=[v; {[ '<br>'  ]} ];
        
        v2=[v2; v];
    end
    disp('..copying done...creating HTML-file...');
    
    z=[  hs ;v2; he];
    if isempty(p.HTMLfileName)
        htmlfile=fullfile(fileparts(pahtml),[p.task  '.html']);
    else
        htmlfile=fullfile(fileparts(pahtml),[p.task '_' p.HTMLfileName '.html']);
    end
    pwrite2file(htmlfile,z);
    showinfo2('HTML-file',htmlfile);
    
    
else
    
    
    %% ===============================================
    v2={};
    wid=250;
    for mo=1:size(tb,1)
        tt=tb(mo,:);
        animalname=tt{1};
        head=tt{4}{1};
        imgs=tt{4}{2};
        
        v={ [ '<h3> [ animal-' num2str(mo) ']..  <font color="green">' animalname '</h3>  </font> ' ]  };
        for i=1:length(imgs)
            sname=[ animalname '__' head{i} '.jpg'];
            fsave =fullfile(pahtml, sname);
            flink =[ subdir '/' sname] ;
            if ~isempty(strfind(head{i},'ano'))
                imgx= uint8(round(255.*imadjust(mat2gray(pseudocolorize(imgs{i})   ))));
            else
                imgx= uint8(round(255.*imadjust(mat2gray(imgs{i}))));
            end
            imwrite(imgx,fsave);
            
            %__HTML_links
            v=[v; {[ '<img src="' flink '" alt="HTML5 Icon" style="width:' num2str(wid) 'px;height:' num2str(wid) 'px;"'...
                [' title="' upper(head{i}) '-image'  '">']  ]} ];
        end
        v=[v; {[ '<br>'  ]} ];
        
        v2=[v2; v];
    end
    
    z=[  hs ;v2; he];
    htmlfile=fullfile(fileparts(pahtml),'check.html');
    pwrite2file(htmlfile,z);
    showinfo2('HTML-file',htmlfile);
end
%% ===============================================
cprintf([0 .7 0],'..Done!\n');







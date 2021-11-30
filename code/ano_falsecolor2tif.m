
% see f_ano_falsecolor2tif
                



function ano_falsecolor2tif(file,p)

timex=tic;
% ==============================================
%%   
% ===============================================
warning off
timeTot=tic;
% ==============================================
%%   unpack
% ==============================================

p0.outDirName='fin';
% p0.saveIMG   =1;
p=catstruct(p,p0);

% ==============================================
%%   UNPACK SOME STUFF
% ===============================================
F1= char(file);

[pa name ext]=fileparts(F1);          
[~,mdir,~]=fileparts(fileparts(pa)); %animal-DIR
numberstr    =regexprep(name,{'s','_ANO'},{''});

% ==============================================
%%   check stuff
% ===============================================
 k=dir(F1);  


% check-bites
try
    cprintf('[0 0 1]',[ ['[' mdir ']' '  --> Slice: ' name  ' (Size: ' num2str(k.bytes/1e6) ' MB)' ]  '\n']);
catch
    disp(['[' mdir ']' '  --> Slice: ' name  ' (Size: ' num2str(k.bytes/1e6) ' MB)' ]);
end



% ==============================================
%%  load atlas if not existing
% ===============================================
if ~isfield(p,'at')
    F1xls=p.atlasExcelFile;
    if exist(F1xls)~=2
        msgbox({'proc: RGB-colorizing ANO','missing ANO.xls-file:' F1xls})
    end
    
    %   read excel-file
    [~,~,a0]=xlsread(F1xls);
    del=regexpi2(cellfun(@(a){[ num2str(a)  ]}, a0(:,1) ), 'NaN');
    a0(del,:)=[];
    p.hat=a0(1,1:5);
    p.at=a0(2:end,1:5); 
end


    
% ==============================================
%%  [1] process
% ===============================================

% ==============================================
%%   load ano
% ===============================================
s=load(F1);
d1=s.v; 
clear s
si=size(d1);

% ==============================================
%%   resize
% ===============================================
if isnumeric(p.inresize) && ~isnan(p.inresize)
    d1=imresize(d1,[p.inresize p.inresize],'nearest');
end

% ==============================================
%%   check mode
% ===============================================
mode=p.mode;
if mode==3
    mode=[1 2];
end
    
  
% ==============================================
%%   make small image
% ===============================================
s={};
for i=1:length(mode)
    if mode(i)==1
    % d2=uint8(round(255.*mat2gray(pseudocolorize(d1))));
     
     d2=mat2gray(pseudocolorize(d1));
     d2 = double2rgb(d2, parula);
    % d2=repmat( round(255*d2),[1 1 3]);
%      dx= (ind2rgb(d2,parula));
%      dx=round(dx.*255);
%      fg,image(dx)
%      
%      [R,G,B]=ind2rgb(d2,parula);
    s(i,:)={ '_pseudoColor'   d2  };
    end
    if mode(i)==2
        uni=unique(d1(:)); uni(uni==0)=[]; %get IDs
        tb=p.at(:,[4 3]);
        d2=(makeRGBslice( d1, tb,uni ));
    s(i,:)={ '_AllenColor'  d2 };
    end
end

% ==============================================
%%   write images
% ===============================================
% imwrite(im1,'myMultipageFile.tif')
fprintf(['..writing..' ]);

for i=1:length(s)
    

    d2=s{i,2};
    nameTag=s{i,1};
    nameout=[name  nameTag  '.tif'];
    fprintf([' |' nameout]);
    Fout=fullfile(pa, nameout);
    
    d3=d2;
    if 1
        d3=imresize((d2),[si],'nearest');
        
    end
    d3=uint8(round(d3.*255));
     imwrite(d3  ,Fout,'compression', p.compression  );
   
   


end
fprintf(['..DONE!\n' ]);

% ==============================================
%%   make thumbnail
% ===============================================
% ==============================================
%%  [4.0]   get orig resized image [a2_##.mat]
% ===============================================
% fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
pad=fileparts(pa);
fir=fullfile(pad,['a2_' numberstr '.mat']);
if exist(fir)~=2
    disp(['missing file: ' fir ]);
    return
end
so=load(fir); so=so.s;
ref=mat2gray(imresize(so.img,[500 500],'nearest'));
ref=repmat(ref,[1 1 3]);

%-----------THUMBS
u=s;  %THUMBS
for i=1:size(s,1)
    u{i,2}=imresize(u{i,2},[500 500],'nearest');
end
%% =====LAYOUT ==========================================
% w=imread(Fout,'PixelRegion',[{[1 1.5 si(1)],[1 1.5 si(2)]}]);
% teststr='dum__';
teststr='';
for i=1:size(u,1)
    r1=[ref];
    r1=[ r1 u{i,2} ];
    Fthumb=fullfile(pa, [teststr name  strjoin(u(i,1),'')  '.jpg' ] );
    imwrite(r1  ,Fthumb,'jpg');
    
%       if i==1
         showinfo2('snapshot:',Fthumb);
%      end
end


% ==============================================
%%   DISPLAY
% ===============================================

disp([ 'DONE. (pseudoANO-to-TIF-conversion; T=' sprintf('%2.1fmin',toc(timex)/60) ') for [' mdir filesep  name '.nii]'  ]);












function makeSelection_HTML()

%  clear
warning off;
clc
% ==============================================
%%   
% ===============================================



global ak

mix=bartcb('getsel');
% ==============================================
%%   
% ===============================================
paout=fullfile(fileparts(ak.dat),'selection');
mkdir(paout);
subdir='resources';
pasub=fullfile(paout,subdir);
try; rmdir(pasub,'s'); end
mkdir(pasub);



% ==============================================
%%   copy images
% ===============================================

% fis=mix(strcmp(mix(:,2),'file')==1,1);
pas=mix(strcmp(mix(:,2),'dir')==1,1);
tb={};
for i=1:length(pas)
    pa=pas{i} ;
    [~,name]=fileparts(pa);
    
    fastload=1;
    [fis] = spm_select('List',pa,'^a1_\d\d\d.jpg');
    fis=cellstr(fis);
    if isempty(char(fis))  %missing jpg-file --> created one!
        [fis0] = spm_select('List',pa,'^a1_\d\d\d.tif');
        if ~isempty(fis0)
            fis0=cellstr(fis0);
            for j=1:length(fis0)
                file=fullfile(pa, fis0{j});
                [pax namex extx]=fileparts(file);
                disp([ num2str(i) '/'  num2str(length(pas))  ': ' namex]   );
               % w=imread(fullfile(pa, fis0{j}));
                hi=imfinfo(file);
                if fastload==1
                    if sum([hi.Width hi.Height]>5000)==2 %above 5000
                        w=imread(file,'PixelRegion',{[1 20 inf],[1 20 inf]});
                    else
                        w=imread(file);
                    end
                else
                    w=imread(file);
                end
                
                w0=imadjust(imresize(max(w,[],3),[400 400]));
                w1=cat(3,w0,w0,w0);
                jpgout=fullfile(pa,  strrep(fis0{j},'.tif','.jpg'));
                imwrite(w1,jpgout);
            end
            [fis] = spm_select('List',pa,'^a1_\d\d\d.jpg');
             fis=cellstr(fis);
        end
    end
    
    imgnames={};
    if ~isempty(char(fis))
        for j=1:length(fis)
            f0=fullfile(pa,fis{j});
            imgname=[name '__' fis{j} ];
            f1=fullfile(pasub, imgname );
            copyfile(f0,f1,'f');
            imgnames=[imgnames; {imgname}];
        end
        tb=[tb; {name imgnames}];
    end  
end
% ==============================================
%%  copy javascript
% ===============================================
pa_resource=fullfile(fileparts(which('bart')),'code','HTML');

jsfile0 =fullfile(pa_resource,'resource.js');
jsfile1 =fullfile(paout,'resource.js');
copyfile(jsfile0,jsfile1, 'f' );

% ==============================================
%%   get html-file, split in twp part
% ===============================================

htmlfile0=fullfile(pa_resource,'blanko.html');
a=preadfile(htmlfile0);
a=a.all;



sep1=regexpi2(a,'<!--start-->');
sep2=regexpi2(a,'<!--stop-->');
p1=a(1:sep1);
p2=a(sep2:end);

% ==============================================
%%   create mouse-name, images, checkbox
% ===============================================
si=300;
siz=num2str(si);

s={};
for i=1:size(tb,1)
    %---NAME OF ANIMAL
    s{end+1,1}=['<hr>ANIMAL-' num2str(i)];
    s{end+1,1}=['<input type="text" name="' tb{i,1} '" value="' tb{i,1} '" disabled  style="color: #C0C0C0;" > '];
    s{end+1,1}=['<br>'];
    
    for j=1:length(tb{i,2})
        s{end+1,1}=['<img src="' [subdir '/' tb{i,2}{j} ]  '" width="' siz '" height="' siz '">']; 
    
    end
    
     s{end+1,1}=['BAD SLICES:'];
    for j=1:length(tb{i,2})
       s{end+1,1}=['<input type="checkbox" name="'  tb{i,2}{j} '">']; 
    end
end


% ==============================================
%%   
% ===============================================

ms=[p1;s;p2];
htmlfile1=fullfile(paout,'index.html');
 pwrite2file(htmlfile1, ms  );



showinfo2('..show HTMLfile',htmlfile1);







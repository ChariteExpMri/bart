cf;
 issave=1
 if 0
    clear;
   
    %———————————————————————————————————————————————
    %%   get files: UI
    %———————————————————————————————————————————————
    
    msg='select HISTO-files (TXT-files!!!!)'
    [t,sts] = spm_select(inf,'any',msg,[],pwd,'.*.txt',[])
    
    %[t,sts] = spm_select(n,typ,mesg,sel,wd,filt,frames)
    
    if isempty(char(t));
        disp('no TXT-files select...cancelled...'); return
    end
    fis=cellstr(t);
end
%———————————————————————————————————————————————
%%   get path
%———————————————————————————————————————————————

global ak
if isempty(ak)
    msgbox('load a BART_project before importing files');
    return
end
%———————————————————————————————————————————————
%%
%———————————————————————————————————————————————
padat=ak.dat;



% ==============================================
%%
% ===============================================
cf
for i=1:length(fis)
% for i=[21]

    
    fi=fis{i};
    [~, name, ~]=fileparts(fi);
    x=importdata(fi);
    x=x';
    disp(size(x));
    x=imresize(x,[1000 1000]);
    %fg,imagesc(x);
    
    
    
    
    
    % return
    
    
    
    %———————————————————————————————————————————————
    % create out-directory
    %———————————————————————————————————————————————
    warning off;
    mdir=fullfile(padat,name);
    mkdir(mdir);
    
    
    %———————————————————————————————————————————————
    % [1] save intensity image
    %———————————————————————————————————————————————
    
    f1=fullfile(mdir,['intens1_' pnum(1,3)  '.mat']);
    g.x=x;
    g.file=fi;
    if issave==1
        save(f1,'g');
    end
    
    %———————————————————————————————————————————————
    %% [2] save registration image
    %———————————————————————————————————————————————
     %w= ( (imadjust(mat2gray(x))));
     w=x;
     w0=medfilt2(w,[11 11]);
     nb=3;
     bo=[w0(:,[1:nb end-nb+1:end]) ; w0([1:nb end-nb+1:end],:)'];
     bo=bo(:);
     bo(bo==0)=[];
     
     vp=[9 19 21]
     tres=max(bo);
     if strcmp(name,'3083_158Gd_EAE07-01')
        tres= 1
     elseif strcmp(name,'3083_158Gd_HC06-03')
          tres= 2
    elseif strcmp(name,'3083_158Gd_HC07-03')
          tres= 2
     end
     
     w1=imerode(w0>tres,strel('disk',3));
     w2=imopen(w1,strel('disk',21));
    w3=imfill(w2,'holes');
    [cl no]=bwlabeln(w3);
    unis=unique(cl(:)); unis(unis==0)=[];
    if length(unis)>1
        t=[unis, histc(cl(:),unis)];
        t=flipud(sortrows(t,2));
        cl=cl(:);
        w3=zeros(numel(w2),1);
        w3(cl==t(1,1))=1;
        w3=reshape(w3,size(w2));
    end

    
    z=imadjust(mat2gray(x)).*w3;
    
    dosub=1;
    figure; 
    if dosub==1; subplot(3,3,1);else; fg;  end; imagesc(x);
    if dosub==1; subplot(3,3,2);else; fg;  end; imagesc(w1);
    if dosub==1; subplot(3,3,3);else; fg;  end; imagesc(w2);
    if dosub==1; subplot(3,3,4);else; fg;  end; imagesc(w3);
    if dosub==1; subplot(3,3,5);else; fg;  end; imagesc(z);
    title(i)
    %% -----------
    
    %w=uint8(round(imadjust(mat2gray(x))*255));
    w=uint8(round(imadjust(z)*255));
    % w2=cat(3,w,w,w);
    w2=w;
    
    f2=fullfile(mdir,['a1_' pnum(1,3)  '.tif']);
    
    if issave==1
        imwrite(w2,f2, 'tif','Compression','none');
    end
    
end
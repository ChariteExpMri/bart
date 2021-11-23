
% warp other images to histoSpace
% file       : selected file in bartGUI:  'F:\data5_histo\MRE_anna1\dat\test_2figs\a1_004.tif'
% otherimages: images to warp to histoSpace, 
% p: (struct) with:
%           template: 'F:\data3\histo2\bart_template\HISTOVOL.nii'
%              interp: 'auto'
%     check_DIRassign: 0
%          isparallel: 0

function warpotherimages(file, otherimages,p)

if 0
    disp('-----------');
    disp('file___:');
    disp(file);
    disp('otherimages___:');
    disp(char(otherimages));
    return
end
% ==============================================
%%   
% ===============================================
warning off
timeTot=tic;
% ==============================================
%%   unpack
% ===============================================


% fidi=bartcb('getsel');
% w.dirs  =fidi(strcmp(fidi(:,2),'dir'),1);
% w.files =fidi(strcmp(fidi(:,2),'file'),1);
% p.file      =w.files{1};

% p.file=file;

% p.file2warp ={'aux_AVGT.nii','aux_ANO.nii' 'aux_AVGThemi.nii'};
% p.interp    ='auto';
% p.template  ='F:\data3\histo2\bart_template\HISTOVOL.nii';

p0.outDirName='fin';
p0.saveIMG   =1;
p=catstruct(p,p0);

% ==============================================
%%   UNPACK SOME STUFF
% ===============================================

file        = char(file);
otherimages =cellstr(otherimages);
% pa=fileparts(file)
[pa name ext]=fileparts(file);           %name: "'a1_004'"
numberstr    =regexprep(name,'.*_','_'); % such as '_004'
elxout     =fullfile(pa,'elx2',['forward' numberstr]);

[~,mdir,~]=fileparts(pa); %animal-DIR


% ==============================================
%%   load best slice ...get paramter from [bestslice_###.mat']
% ===============================================

fib=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'bestslice_'],'.mat'});
if exist(fib)~=2
    disp(['missing file: ' fib ]);
    return
end
s2       =load(fib);
s2       =s2.s2;
parameter=s2.param;
% ==============================================
%%   get refImage-filename
% ===============================================

% global ak
% pa_template=ak.template;
% refImg=fullfile(pa_template, 'HISTOVOL.nii' );

refImg=p.template;
% [ cv    ]=p_getHIstvol(refImg,0) ;

% ############################################################
%%
%%   PART-1  :       reslice2volume..get slice...warp slize
%%
% ############################################################

tic
o ={};interps={};
sl={};

for j=1:length(otherimages)
    file2warp = otherimages{j};
    %file2warp =fullfile(fileparts(file),file2warp{j});
    [~,fiName]=fileparts(file2warp);
    fprintf([ '(' num2str(j) ') "' fiName '.nii"; ']);
    
    
    if exist(file2warp)==2
        
        [hq q]=rgetnii(file2warp);
        
        % ==============================================
        % obtain interpolation type
        % ===============================================
        if ischar(p.interp) && strcmp(p.interp,'auto')
            issim2round=all(unique(q)==round(unique(q)));
            if issim2round==1 % nearest
                interpx                        = 'nearest';
                FinalBSplineInterpolationOrder = 0;
                interpReslice                  = 0;
                interpResize                   = 'nearest'
            else
                interpx                        = 'linear';
                FinalBSplineInterpolationOrder = 3;
                interpReslice                  = 1;
                interpResize                   = 'bilinear';
            end
            
        elseif isnumeric(p.interp)
            if p.interp==0
                interpx                        = 'nearest';
                FinalBSplineInterpolationOrder = 0;
                interpReslice                  = 0;
                interpResize                   = 'nearest';
            elseif p.interp==1
                interpx                        = 'linear';
                FinalBSplineInterpolationOrder = 3;
                interpReslice                  = 1;
                interpResize                   = 'bilinear';
                
            end
        end
        
        interpstruct=struct('interpx',interpx,...
            'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder,...
            'interpReslice',interpReslice,'interpResize',interpResize);
        
        
        % ==============================================
        % resize source-Image
        % ===============================================
        % 92sec with linear interp vs 6s with NN-interp
        
        [h,d ]=rreslice2target(file2warp, refImg, [], interpReslice);
        d=permute(d,[2 3 1 ]);
        d=flipdim(d,3);
        
        if 0
            fg,imagesc(d(:,:,200))
        end
        
        
        
        % ==============================================
        %  [2.2]   get slice +resize
        % ===============================================
        xx        =parameter;
        slicenum  =xx(1);
        X          =xx(2);
        Y          =xx(3);
        cent       =[size(d,2)/2 size(d,1)/2];
        vol_center =[cent slicenum];
        
        %v     =uint8(obliqueslice(cv, vol_center, [Y -X 90]));
        w2    =      obliqueslice(d, vol_center, [Y -X 90],'Method',interpx);
        %% resize
        w2=imresize(w2,[1000 1000],interpResize);
        sl(end+1,:)={fiName w2};
        % ==============================================
        %   [2.3]   ELASTIX
        % ===============================================
        trafofile1=fullfile(elxout,'TransformParameters.0.txt');
        trafofile2=fullfile(elxout,'TransformParameters.1.txt');
        default_interp=get_ix(trafofile2,'FinalBSplineInterpolationOrder');
        set_ix(trafofile2,'FinalBSplineInterpolationOrder',FinalBSplineInterpolationOrder); %default:1500
        set_ix(trafofile1,'ResultImagePixelType','float');
        set_ix(trafofile2,'ResultImagePixelType','float'); %default:1500
        
        
        
        pawork =pwd;
        cd(fileparts(which('elastix.exe')));
        %[w3,log] = transformix(w2,elxout) ;
        [msg,w3,log]=evalc('transformix(w2,elxout)');
        cd(pawork);
        
        set_ix(trafofile2,'FinalBSplineInterpolationOrder',default_interp);
        %%___
        
        % ==============================================
        %  [2.4]   to struct
        % ===============================================
        % ------------------------------------------------------ put to [o]-cell
        o(end+1,:)={fiName w3};
        interps{end+1,1}=interpstruct;
        % ------------------------------------------------------ transformix
        
    end %file exist
end% imageNumber to warp
toc


% ############################################################
%%
%%   PART-2  :       back to histoSpace
%%
% ############################################################

% ==============================================
%%  [4.0]   get orig resized image [a2_##.mat]
% ===============================================
% fir=regexprep(file,{[filesep filesep 'a1_'], '.tif$'},{[filesep filesep 'a2_'],'.mat'});
fir=fullfile(pa,['a2' numberstr '.mat']);
if exist(fir)~=2
    disp(['missing file: ' fir ]);
    return
end
s=load(fir); so=s.s;
% ==============================================
%%  [4.1]   get info of tif
% ===============================================
tifname=fullfile(pa,['a1' numberstr '.tif']);
info=imfinfo(tifname);
info=info(1);
size_img=[info.Height info.Width ];

% ==============================================
%%   [4.2] output dir
% ===============================================
warning off;
outdir=fullfile(pa,p.outDirName);
mkdir(outdir);
outtag=[strrep(numberstr,'_', 's') '_'];  %PREFIX-outTage ('s001_','s002_', etc)


time_save=tic;
fprintf('saving(nonlinear): ');
thumb={};
for i=1:size(o,1)
    nameout=[outtag o{i,1} '.mat' ];
    fprintf([ '(' num2str(i) ') "' nameout '"; ']);
    
    interpy=interps{i}.interpResize;
    % ============================================================================================
    % ---unsing border and rotation--info ------------------------------------------
    % ============================================================================================
    %cf
    %fg,imagesc(s.img); title('orig')
    
    u2=imresize(o{i,2},[size(so.img)],interpy);
    if isfield(so,'rotationmod')
        u2=imrotate(u2,-so.rotationmod  ,'nearest','crop');
    end
    if isfield(so,'bordermod')
        border=so.bordermod;
        k=u2;
        k=imresize(k,[size(so.img,1)+2*border  size(so.img,2)+2*border ],interpy);
        k(  [ 1:border  end-border+1:end ],:)=[];
        k(:,[ 1:border  end-border+1:end ]  )=[];
        u2=k;
        if any(size(u2)~=size(so.img,1))
            u2=imresize(u2,[size(so.img) ],interpy);
        end
    end
    
    thumb{i,1}=u2;
    %fg; imagesc(u2); title('crap')
    
    % -----------------------------------------------------------------------------
    
    
    v=imresize(   u2      ,[size_img],interpy);
    %         if (length(unique(o{i,2})))/(numel(o{i,2})) >.4  % convert to uint8 ---file to large for intensbased images
    %             v=round((mat2gray(v).*255));
    %             %disp('..intensIMG..conv-to uin8');
    %         end
    % ------------------------------------------------------ save  [imageName_###.mat]
    
    fi_out=fullfile(outdir, nameout);
    if p.saveIMG==1
        save(fi_out, 'v','-v7.3');
    end
    
    
    
end

% ############################################################
%%
%%   PART-3 :       animated gifs
%%
% ############################################################
% ==============================================
%%   prepare animated-gif-images
% ===============================================

% fprintf(['...create image ' [ '"res'  numberstr '.gif"...' ] ]);
sizp=[500 500];

% ==============================================
%   layout images
% ===============================================
% ========== IMAGES-B1 =====================================

%----img
r=uint8(round(255*(imadjust(mat2gray(imresize(so.img,sizp,'nearest'))))));
r2=uint8(255*imcomplement(text2im(['Histo'])));
r(1:size(r2,1),1:size(r2,2))=r2;%    fg,imagesc(q);

for n=1:length(thumb)
    
    dx=(thumb{ [n ] ,1}); dx=dx(:);
    ismultinary=all((dx)==(round(dx)))==1;
    if ismultinary==1
       q=uint8(round(255*(imadjust(mat2gray( ...
           pseudocolorize(  imresize(thumb{ [n ] ,1},sizp,'nearest') )  ))))); 
    else
        q=uint8(round(255*(imadjust(mat2gray(imresize(thumb{ [n ] ,1},sizp,'nearest'))))));
    end
    q2=uint8(255*imcomplement(text2im([o{n,1} '.nii'])));
    q(1:size(q2,1),1:size(q2,2))=q2;%    fg,imagesc(q);
    
    
    if ismultinary==1
    qs=uint8(round(255*(imadjust(mat2gray( ...
           pseudocolorize(  imresize(sl{ [n ] ,2},sizp,'nearest') )  ))))); 
    else
           qs=uint8(round(255*(imadjust(mat2gray(imresize(sl{ [n ] ,2},sizp,'nearest'))))));
    end
    qs2=uint8(255*imcomplement(text2im(['slice:' o{n,1} '.nii'])));
    qs(1:size(qs2,1),1:size(qs2,2))=qs2;%    fg,imagesc(q);
    
    
    % ===============================================
    qi=qs.*0;
    ms={['[mdir-name]:' ]
        ['  ' mdir]
        ['[slice]:' ]
        ['  ' name]
        ['[warped image]:']
        [['  ' o{n,1} '.nii']]
        
        ['[parameter (S,p,y)]:' ]
        ['  ' sprintf('%2.1f, %2.1f, %2.1f', parameter(1),parameter(2),parameter(3))]
        
        ['[interp]:' ]
        ['  ' interps{n}.interpResize]
        };
    
    gap1=20;
    gap2=round(gap1/2);
    iv=gap1;
    for i=1:size(ms,1)
        qi2=uint8(255*imcomplement(text2im([ms{i}])));
        qi(   iv:size(qi2,1)+iv-1 ,1:size(qi2,2))=qi2;%    fg,imagesc(q);
        if mod(i,2)==0
            iv=iv+size(qi2,1)+gap1;
        else
            iv=iv+size(qi2,1)+gap2;
        end
    end
    r1=[ [ qi qs]; [r q]  ];
    r2=[ [ qi qs]; [r r]  ];
    if 0
        fg,imagesc(r1)
        fg,imagesc(r2)
    end
    %===================================================================================================
    % ==============================================
    %   write animated-gif
    % ===============================================
    
    nameout=[outtag 'other_' o{n,1} '.gif' ];
    fileout2=fullfile(outdir, nameout);
    if exist(fileout2)==2
        delete(fileout2);
    end
    
    dollop=1;
    while dollop==1
        try
            imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
            imwrite(r2  ,fileout2,'gif','WriteMode','append');
            %disp('image written.');
            dollop=0;
        catch ME
            uiwait(msgbox({ME.message '---> CLOSE IMAGE-VIEWER to proceed!!'},'ERROR','modal'));
            %     try
            %         imwrite(r1  ,fileout2,'gif', 'Loopcount',inf);
            %         imwrite(r2  ,fileout2,'gif','WriteMode','append');
            %         disp('image written.');
            %     catch
            %         disp('..could not write gif-image.')
            %     end
        end
    end
%     fprintf('Done.\n');
    showinfo2('..other image warped',fileout2);
    
    %===================================================================================================
    % ==============================================
    %  display
    % ===============================================
    nameoutmat=[outtag 'other_' o{n,1} '.mat' ];
    disp([ 'DONE(T=' sprintf('%2.1fmin',toc(timeTot)/60)  '): for [' mdir filesep  name '] warp2histo "' [ o{n,1} '.nii'] '" as "' nameoutmat '"'  ]);
    
    
end





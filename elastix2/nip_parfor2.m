


% ==============================================
%%   get slice
% ===============================================
fprintf('..estimate warp paramters...');
pawork=pwd;
cd(pa_el);

warning off;
elxout2={};
n=20
for i=1:n
    elxout2{i,1} = [elxout '_' pnum(i,3) ];
    mkdir(elxout2{i});
end

clc
poolobj = gcp;
addAttachedFiles(poolobj,{'readWholeTextFile.m'});%,'elastix.m'




siz=[330 450];
% siz=[200 200];
%n=20; parfor:  undefined threats ('all') :  2.8333min for 20 slices, 2.6667min, threds undefined
%n=20; parfor:             with 1 threat  :97.162214 seconds. !!!! [4.85s per IMG]

cellsize=16
% q=[]
% met1=[];
% met2=[];
q=zeros([siz n]);
met1=nan(n,1);
met2=nan(n,1);

fix=double(ss.img)          ;%imresize(double(ss.img),[size(d,1)  size(d,2)  ]) ;
fix=imresize(fix,[siz]);
hog_hi= vl_hog(single(fix ),cellsize);

poolobj = gcp;
 addAttachedFiles(poolobj,{'readWholeTextFile.m' ,'elastix2.m'});%,'elastix.m'
tic
parfor i=1:n%10
    
    xx=ss.s(i,:)
    slicenum=xx(1);   X=xx(2);  Y=xx(3);
    cent    =[size(cv,2)/2 size(cv,1)/2];
    vol_center=[cent slicenum];
    d=uint8(obliqueslice(cv, vol_center, [Y -X 90]));
    
    mov=double(d).*double((d>30));
    mov=imresize(mov,[siz]);
        
%       mov=uint8(mov);
%       fix=uint8(fix);
    
    % ----------------------------
    elxout3=elxout2{i};
    [wa,outs]= elastix2(mov,fix,elxout3,parfile(1:end),pa_el ,struct('threads',1));
    %[wa,outs]=  elastix(mov,fix,elxout3,parfile(1:end),struct('threads',1));
    %     [wa outs] = snip_parfor(mov,fix,elxout3,parfile)
    q(:,:,i)=wa;
    
    %---MI-------
    lg=outs.log;
    ix=max(regexpi2(lg,'Time spent in resolution 0 (ITK initialisation'));
    row=str2num(char(lg(ix-1)));
    val=row(2);
    met2(i,:)=val ;%row;
    %----HOG
    hog_at= vl_hog(single(wa ),cellsize);
    hog_diff=hog_hi-hog_at;
    met1(i,:)=norm(reshape(hog_diff,1,numel(hog_diff)));
    
end
toc

fg;
subplot(2,1,1); plot(met1,'-r.'); title(['HOG' ' min (' num2str(min(find(met1==min(met1)))) ')']);
subplot(2,1,2); plot(met2,'-r.'); title(['MI' ' min (' num2str(min(find(met2==min(met2)))) ')']);

% fg,plot(mean(zscore([met1 met2]),2),'.-')
% ==============================================
%%
% ===============================================

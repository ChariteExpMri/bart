function [warpedmoving,tform]=warp_with_shape(moving,static)
V1=double(moving);
V2=double(static);
mask1=bwareafilt(V1>0,1);
mask2=bwareafilt(V2>0,1);
V1=imfill(mask1,'holes');
V2=imfill(mask2,'holes');
display_flag=0;
polarity_flag=1;
nsamp=100;
eps_dum=0.25;
ndum_frac=0.25;
mean_dist_global=[];
ori_weight=0.1;
nbins_theta=12;
nbins_r=5;
r_inner=1/8;
r_outer=2;
[x2,y2,t2]=bdry_extract_3(V2);
nsamp2=length(x2);
if nsamp2>=nsamp
    [x2,y2,t2]=get_samples_1(x2,y2,t2,nsamp);
else
    disp('shape #2 doesn''t have enough samples')
    return;
end
Y=[x2 y2];
[x1,y1,t1]=bdry_extract_3(V1);
nsamp1=length(x1);
if nsamp1>=nsamp
    [x1,y1,t1]=get_samples_1(x1,y1,t1,nsamp);
else
    disp('shape #1 doesn''t have enough samples')
    return;
end
X=[x1 y1];
if display_flag
    subplot(2,2,1)
    imagesc(V1);axis('image')
    subplot(2,2,2)
    imagesc(V2);axis('image')
    colormap(cmap)
    drawnow
    subplot(2,2,3)
    plot(X(:,1),X(:,2),'b+')
    hold on
    quiver(X(:,1),X(:,2),cos(t1),sin(t1),0.5,'b')
    hold off
    axis('ij');axis([1 N2 1 N1])
    title([int2str(length(x1)) ' samples'])
    subplot(2,2,4)
    plot(Y(:,1),Y(:,2),'ro')
    hold on
    quiver(Y(:,1),Y(:,2),cos(t2),sin(t2),0.5,'r.')
    hold off
    axis('ij');axis([1 N2 1 N1])
    title([int2str(length(x2)) ' samples'])
    drawnow
    [x,y]=meshgrid(linspace(1,N2,36),linspace(1,N1,36));
    x=x(:);y=y(:);M=length(x);
end
Xk=X;
tk=t1;%tangent direction
ndum=round(ndum_frac*nsamp);%0.25x100
out_vec_1=zeros(1,nsamp);
out_vec_2=zeros(1,nsamp);
%%
    [BH1,mean_dist_1]=sc_compute(Xk',zeros(1,nsamp),mean_dist_global,nbins_theta,nbins_r,r_inner,r_outer,out_vec_1);
    [BH2,mean_dist_2]=sc_compute(Y',zeros(1,nsamp),mean_dist_global,nbins_theta,nbins_r,r_inner,r_outer,out_vec_2);
    costmat_shape=hist_cost_2(BH1,BH2);
    theta_diff=repmat(tk,1,nsamp)-repmat(t2',nsamp,1);
    if polarity_flag
        costmat_theta=0.5*(1-cos(theta_diff));
    else
        costmat_theta=0.5*(1-cos(2*theta_diff));
    end
    costmat=(1-ori_weight)*costmat_shape+ori_weight*costmat_theta;
    nptsd=nsamp+ndum;%1.25x100
    costmat2=eps_dum*ones(nptsd,nptsd);%0.25
    costmat2(1:nsamp,1:nsamp)=costmat;%other entries are all ones, costmat<1
    cvec=hungarian(costmat2);
    X2b=NaN*ones(nptsd,2);
    X2b(1:nsamp,:)=X;
    X2b=X2b(cvec,:);
    Y2=NaN*ones(nptsd,2);
    Y2(1:nsamp,:)=Y;
    ind_good=find(~isnan(X2b(1:nsamp,1)));
    X3b=X2b(ind_good,:);
    Y3=Y2(ind_good,:);
    scale=mean_dist_2/mean_dist_1;
    [R,translation] = rigid_transform_2D(X3b, Y3,scale);
    tform=maketform('affine',[scale 0 0; 0 scale 0; 0 0 1]*[R(1,:) 0; R(2,:) 0; 0 0 1]);
    Xs = tformfwd(tform,X(:,1),X(:,2));
    scalex = (max(Y(:,1))-min(Y(:,1)))/(max(Xs(:,1))-min(Xs(:,1)));
    scaley = (max(Y(:,2))-min(Y(:,2)))/(max(Xs(:,2))-min(Xs(:,2)));
    tform = maketform('affine',[scalex 0 0; 0 scaley 0; 0 0 1]);
    Xss = tformfwd(tform,Xs(:,1),Xs(:,2));
    translationx = (max(Y(:,1))+min(Y(:,1)))/2-(max(Xss(:,1))+min(Xss(:,1)))/2;
    translationy = (max(Y(:,2))+min(Y(:,2)))/2-(max(Xss(:,2))+min(Xss(:,2)))/2;
    T = [R(1,:) 0; R(2,:) 0; 0 0 1]*[scale 0 0; 0 scale 0; 0 0 1]*[scalex 0 0; 0 scaley 0; 0 0 1]*...
        [1 0 0; 0 1 0; translationx translationy 1];
    tform = maketform('affine',T);
    warpedmoving = imwarp(moving,projective2d(tform.tdata.T),'nearest','OutputView',imref2d(size(static)));

function [hogdiff2 sq]=compute_siftflow(experimental_file,maskfile,tatlas,p)

if 0
    % try
    %     % prevVers: compute_hog_single_
    %
    
    
    %     indices=1;
    %     endslice=1;
    %     startslice=1;
    
    % exp_slice=single(experimental_file(:,:,1));
    exp_slice  =single(experimental_file);
    small_exp  =exp_slice; %---------->NO RESLICING
    mask_slice =logical(maskfile);
    small_mask =mask_slice; %---------->NO RESLICING
    
    % hogdiff2=rand(1); return
    
    try
        hog_hi= vl_hog(single(experimental_file  ),p.cellsize);
        %     'worked'
    catch
        'fehler'
        disp(lasterr);
    end
    % %     disp(sum(hog_hi(:)));
    
    %    hogdiff2=rand(1); return
    
    
    %  parfor k=round(startposition):min(endslice,round(endposition))
    % for k=round(startposition):min(endslice,round(endposition))
    atlasslice=tatlas;%(:,:,k);
    %warp to downsized experimental slice
    atlasmask = imfill(atlasslice>0,'holes');
    atlasmask = bwareafilt(atlasmask,1);
    
end
    
    
    
    %% ===============================================
    paSF=fileparts(which('mexDenseSIFT'));
    if isempty(paSF)
        %paSF='C:\Users\skoch\Desktop\SIFTflow';
        paSF=fullfile(fileparts(which('bart.m')),'slicedetection','SIFTflow');
        addpath(paSF);
    end
    
%     im1=imread(fullfile(paSF,'Mars-1.jpg'));
%     im2=imread(fullfile(paSF,'Mars-2.jpg'));
%     
%     im1=imresize(imfilter(im1,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
%     im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
%     
%     im1=im2double(im1);
%     im2=im2double(im2);
%% ===============================================

% tic
%  im1=mat2gray(im2double(experimental_file));   
%  im2=mat2gray(imresize(tatlas,[size(experimental_file)]));
 
 im2=mat2gray(im2double(experimental_file));   
 im1=mat2gray(imresize(tatlas,[size(experimental_file)]));
%  -------
if 0
    small_mask=logical(maskfile);
    atlasmask = imfill(tatlas>0,'holes');
    atlasmask = bwareafilt(atlasmask,1);
    am=imresize(atlasmask,[size(experimental_file)]);
    [~,tform]=warp_with_shape(am,bwareafilt(small_mask,1));
    im3 = imtransform(im2,tform,'bilinear','XData',[1 size(im2,2)],'YData', [1 size(im1,1)]);
    
    fg, imagesc(imrotate(im1,12,'crop'))
end
%  -------
%     im1=im2double(imresize(atlasslice,[size(experimental_file)]));
%     im2=im2double(experimental_file);
if 1
    siz=100;
    %siz=200;
    im1=mat2gray(imresize(im1,[siz siz],'bicubic'));
    im2=mat2gray(imresize(im2,[siz siz],'bicubic'));
end
    
%      im1=imresize(imfilter(im1,fspecial('gaussian',7,1.),'same','replicate'),[100 100],'bicubic');
%     im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),[100 100],'bicubic');
%  
    
    
%     im1=imresize(imfilter(im1,fspecial('gaussian',7,1.),'replicate'),0.5,'bicubic');
%     im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
    
    %figure;imshow(im1);figure;imshow(im2);
    

    
%     addpath(fullfile(paSF,'mexDenseSIFT'));
%     addpath(fullfile(paSF,'mexDiscreteFlow'));
  %% ===============================================
%   size(im1),class(im1),min(im1(:)),max(im1(:))
%  [  450   416     3], double,    0.0392 --     0.9373
%   sift1 = mexDenseSIFT(im1,cellsize,gridspacing);
%     sift2 = mexDenseSIFT(im2,cellsize,gridspacing);
    
% tic
    cellsize=1; %prev: 3
    gridspacing=15;
    
    sift1 = mexDenseSIFT(im1,cellsize,1);
    sift2 = mexDenseSIFT(im2,cellsize,1);
    
    SIFTflowpara.alpha=2*255;
    SIFTflowpara.d=40*255;
    SIFTflowpara.gamma=0.005*255;
    SIFTflowpara.nlevels=10;
    SIFTflowpara.wsize=2;
    SIFTflowpara.topwsize=10;
    SIFTflowpara.nTopIterations = 60;
    SIFTflowpara.nIterations= 30;
    
    
%     tic;
    [vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);
%     toc
    
     warpI2=warpImage(im2,vx,vy);
%     toc
    %imoverlay(warpI2,im1);
    %% ===============================================
    if 0
        figure;imagesc(im1);figure;imagesc(warpI2);
        flow(:,:,1)=vx; flow(:,:,2)=vy;
        figure;imagesc(flowToColor(flow));
    end
    
    hogdiff2=min([energylist(end).data]);
    %hogdiff2=5-calcMI(warpI2,im1);
    
    hogdiff2=FeatureSIM(im1, warpI2);
    if 1
        hog_at= vl_hog(single(im1),p.cellsize);
        hog_hi= vl_hog(single(warpI2 ),p.cellsize);
        hog_diff=hog_hi-hog_at;
        hogdiff2=norm(reshape(hog_diff,1,numel(hog_at))) ;
        
        %hogdiff2= 1-multissim3(hog_at,hog_hi);
    end
    sq=[];
    %     if nargout>1
%         sq.tatlas =tatlas;
%         sq.ef     =experimental_file;
%     end
    
%     toc
    %% ===============================================   
    return
    
 
    
     
    try
        %[atlasmask2,tform]=warp_with_shape(atlasmask,bwareafilt(small_mask,1));
        [~,tform]=warp_with_shape(atlasmask,bwareafilt(small_mask,1));
        warpedatlas = imtransform(atlasslice,tform,'bilinear','XData',[1 size(small_mask,2)],'YData',...
            [1 size(small_mask,1)]);
        %-------paul-------
        hog_at= vl_hog(single(warpedatlas),p.cellsize);
        %hog_at= vl_hog(single(warpedatlas).*single(small_mask),p.cellsize); %TEST WITH SAME MASK
        
        
        % ==============================================
        %%   ssim
        % ===============================================

        if p.useSSIM==0
            hog_diff=hog_hi-hog_at;
            hogdiff2=norm(reshape(hog_diff,1,numel(hog_at))) ;
        elseif p.useSSIM==1
            %hogdiff2= 1-ssim(single(warpedatlas),single(small_exp));
            hogdiff2= 1-multissim3(hog_at,hog_hi);
        elseif p.useSSIM==2
            %'mi'
            hogdiff2=3-calcMI(imresize(tatlas,[size(experimental_file)]),experimental_file);
        end
        %      hogdiff2=100-((mi(hog_diff,hog_at))*30);
        %     hogdiff2=100-mi(small_exp,warpedatlas);
        if 0
            %hogdiff2=hogdiff2 *((1/jaccard(warpedatlas>0,small_mask>0)));
            hogatm=vl_hog(single(warpedatlas>0  ),p.cellsize) ;
            hoghim=vl_hog(single(small_mask>0  ),p.cellsize) ;
            hog_diff_mask=hoghim-hogatm;
            hogdiff3=norm(reshape(hog_diff_mask,1,numel(hog_at))) ;
            %     hogdiff2=hogdiff2+hogdiff3;
            hogdiff2=hogdiff3; %ONLY MASK
        end
        
        
    catch
        hogdiff2  =222;
        
    end
    % end
    
% catch
%     hogdiff2  =222;
%     
% end
sq=[];
if nargout>1
    sq.tatlas =tatlas;
    sq.ef     =experimental_file;
end
    





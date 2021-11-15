function [hogdiff2 sq]=compute_hog_single_v3(experimental_file,maskfile,tatlas,p)


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
        elseif p.useSSIM==3
            
           hogdiff2= 1-UIQ(montageout(permute(hog_hi,[1 2 4 3])),...
            montageout(permute(hog_at,[1 2 4 3])) );
            
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
    





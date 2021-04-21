function [hogdiff2 ]=compute_hog_single_v4(experimental_file,maskfile,tatlas,fib,cellsize)


%% USING FIB


   
    
% disp('ok')  ;  


    
    % exp_slice=single(experimental_file(:,:,1));
    exp_slice  =single(experimental_file);
    small_exp  =exp_slice; %---------->NO RESLICING
    mask_slice =logical(maskfile);
    small_mask =mask_slice; %---------->NO RESLICING
    
% hogdiff2=rand(1); return

    try
    hog_hi= vl_hog(single(experimental_file  ),cellsize);
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
        
         fibatlas = imtransform(fib,tform,'bilinear','XData',[1 size(small_mask,2)],'YData',...
            [1 size(small_mask,1)]);
        %-------paul-------
        hog_at       =vl_hog(single(warpedatlas),cellsize);
        hog_diff     =hog_hi-hog_at;
        hogdf_at     =norm(reshape(hog_diff,1,numel(hog_at))) ;
        
        if 0
            hog_fib      =vl_hog(single(fibatlas+warpedatlas),cellsize);
            %hog_fib      =vl_hog(single(  (fibatlas+warpedatlas).*uint8(small_mask)  ),cellsize);
            hog_fibdiff  =hog_hi-hog_fib;
            hogdf_fib    =norm(reshape(hog_fibdiff,1,numel(hog_at))) ;
        end
        %------------2classe
        if 1
            notsu=5;
           
            otH=otsu(experimental_file,5)==notsu;
            exp=experimental_file;
            exp(otH==1)=0;
            otH=exp;
            
            wat=warpedatlas;
            otF=(fibatlas>1)  ;%+(fibatlas>0);
            wat(otF==1)=0;
            otF=wat;
            
            otHhog= vl_hog(single(otH),cellsize);
            otFhog= vl_hog(single(otF),cellsize);
            otdiff=otHhog-otFhog;
            hogdf_ot    =norm(reshape(otdiff,1,numel(hog_at))) ;
            %         hogdf_ot=ssim(otF,otH);
            %hogdf_ot=10-calcMI(otH,otF);
            %hogdf_ot=1-jaccard(otH,otF);
        end
%         mi=20-calcMI(warpedatlas,experimental_file);
        
       hogdiff2=hogdf_ot  ;% 
      %     hogdiff2=hogdf_at.*hogdf_ot.*mi  ;% 
%           hogdiff2=hogdf_at.*hogdf_ot  ;%   hogdf_fib;%.*hogdf_ot;
%           disp(num2str([hogdf_ot    hogdf_fib]));
%         hogdiff2     = sqrt(sum([ hogdf_fib+hogdf_ot].^2));
        %hogdiff2     = sqrt(sum([ hogdf_fib].^2)); %sqrt(sum([hogdf_at hogdf_fib].^2));
%        disp(hogdiff2);
%         
        %      hogdiff2=100-((mi(hog_diff,hog_at))*30);
        %     hogdiff2=100-mi(small_exp,warpedatlas);
        if 0
            %hogdiff2=hogdiff2 *((1/jaccard(warpedatlas>0,small_mask>0)));
            hogatm=vl_hog(single(warpedatlas>0  ),cellsize) ;
            hoghim=vl_hog(single(small_mask>0  ),cellsize) ;
            hog_diff_mask=hoghim-hogatm;
            hogdiff3=norm(reshape(hog_diff_mask,1,numel(hog_at))) ;
            %     hogdiff2=hogdiff2+hogdiff3;
            hogdiff2=hogdiff3; %ONLY MASK
        end
        
        
    catch
        hogdiff2  =2000;
        
    end
    % end
    
% catch
%     hogdiff2  =222;
%     
% end







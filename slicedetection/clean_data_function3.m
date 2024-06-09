function [maskfile,brainfile]=clean_data_function3(img,filtsize)
% this function roughly cleans the background noise in the experimental
% file. you will need to manually move the tissues/extra
% staining/background. this function only smoothes the boundaries of the
% tissue in the experimental file, and this function assumes there is just
% one tissue.
% filtsize=30;
area_threshold=2*1e4;
% info=imfinfo(filename);
% num_slice=numel(info);
num_slice=1;

% img=imread(filename,1);

masks=cell(1,num_slice);

[m,n]=size(img);
maskfile=zeros(m,n,num_slice);
brainfile=zeros(m,n,num_slice);
for i=1:num_slice
    %img=imread(filename,i);
    bw=img>0;
    bw2= bwareafilt(bw,1);
    bw3=imfill(bw2,'holes');
    se = strel('disk',20);
    bw4=imerode(bw3,se);
    bw5= imdilate(bw4,se);
    labels=bwlabel(bw5);
    stats=regionprops(labels,'area');
    areas=[stats.Area];
    [sorted_areas,sorted_blob_index]=sort(areas,'descend');
    remaining_blob_index=sorted_blob_index(find(sorted_areas>area_threshold));
    final_mask=zeros(size(labels));
    for k=1:length(remaining_blob_index)
        mask=(labels==remaining_blob_index(k));
        %smooth the contour
        % find the boundary of the shape as a sequence of x,y values
        [b,~] = bwboundaries(mask,8);
        % assume we only have one boundary
        b1 = b{1};
        % get x and y components
        x = b1(:,2);
        y = b1(:,1);
        % take the fft of each component
        xs = fft(x);
        ys = fft(y);
        % computing FFT-based derivative:
        % http://www.mathworks.co.uk/matlabcentral/answers/16141
        % and
        % http://math.mit.edu/~stevenj/fft-deriv.pdf
        nx = length(xs);
        hx = ceil(nx/2)-1;
        ftdiff = (2i*pi/nx)*(0:hx);
        ftdiff(nx:-1:nx-hx+1) = -ftdiff(2:hx+1);
        ftddiff = (-(2i*pi/nx)^2)*(0:hx);
        ftddiff(nx:-1:nx-hx+1) = ftddiff(2:hx+1);
        % remove high frequency components with crude low pass filter.  high
        % frequency components are bad since they are sensitive to the
        % discretization of the curve around the shape.
        if filtsize > 0
            xs(filtsize:end-(filtsize-1)) = 0;
            ys(filtsize:end-(filtsize-1)) = 0;
        end
        filt_xs = real(ifft(xs));
        filt_ys = real(ifft(ys));
        %plot(filt_xs,filt_ys,'b.');
        convmask=roipoly(img,filt_xs,filt_ys);
        final_mask=final_mask+convmask;
        final_mask=imfill(final_mask,'holes');
    end
    %dilate mask a little bit, to be consistent with atlas slice
    masks{1,i}=final_mask;
    masked_img=bsxfun(@times,img,cast(final_mask,class(img)));
    maskfile(:,:,i)=final_mask;
    brainfile(:,:,i)=masked_img;
end
end


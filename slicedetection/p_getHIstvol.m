
function [ cv]=p_getHIstvol(histvolNifti,flt)

% ==============================================
%%   from testbed7.m
% ===============================================
if 0
    [ cv]=p_getHIstvol('F:\data3\histo1\templates\HISTOVOL.nii') ; 
end

atnew=histvolNifti;
% atnew='F:\data3\histo1\templates\HISTOVOL.nii'
% atnew=('F:\anttemplates\mouse_hikishima\AVGT.nii')
[hcv cv0  ]  =rgetnii(atnew);
cv0=single(cv0);
cv=permute(cv0,[2 3 1 ]);
cv=mat2gray(cv);
%%cv=imadjustn(cv);
cv=flipdim(cv,3);
if flt~=0
    for i=1:size(cv,3)
            cv(:,:,i)= imgaussfilt(cv(:,:,i),.7);%previous
         %    cv(:,:,i)= imgaussfilt(cv(:,:,i),1.5);%previous
    end
end
%     for i=1:size(cv,2)
%         cv(:,i,:)= imgaussfilt(cv(:,i,:),3);
%     end
%      for i=1:size(cv,1)
%         cv(i,:,:)= imgaussfilt(cv(i,:,:),3);
%     end

%     cv= smooth3(cv,'box',5);
cv=uint8(mat2gray(cv)*255);
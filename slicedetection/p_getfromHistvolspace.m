
function [ cv]=p_getfromHistvolspace(histvolNifti)

[hcv cv0  ]  =rgetnii(histvolNifti);
cv0=single(cv0);
cv=permute(cv0,[2 3 1 ]);
cv=flipdim(cv,3);

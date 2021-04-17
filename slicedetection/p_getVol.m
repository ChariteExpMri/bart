
function [ cv]=p_getVol(histvolNifti)

[hcv cv0  ]  =rgetnii(histvolNifti);
cv=permute(cv0,[2 3 1 ]);
cv=flipdim(cv,3);

%pseudocolorize allen-atlas-slice
function wx2=pseudocolorize(w3)
% ==============================================
%%
% ===============================================

wx=w3(:);
wx2=zeros(size(wx));
uni=unique(wx); uni(uni==0)=[];
for j=1:length(uni)
    wx2(wx==uni(j))=j;
end
wx2=reshape(wx2,[size(w3)]);
% fg,imagesc(wx2)
% ==============================================
%%
% ===============================================


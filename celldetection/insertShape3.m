
function im1=insertShape2(I,form,cv,varargin)

im1=I;
if isempty(cv); return; end
%  im1 = insertShape(I, 'circle',cv, 'Color','y');

p=cell2struct(varargin(2:2:end),varargin(1:2:end),2);

%     if 0
%         figure(10),
%         subplot(2,2,1);imagesc(b); hold on; viscircles(ce, ra*0+1,'Color','r','linewidth',.5);
%         subplot(2,2,2);imagesc(b2); hold on; viscircles(ce, ra*0+1,'Color','r','linewidth',.5);
%         subplot(2,2,3);imagesc(im1);
%     end
%

col={...
    'y' [1 1 0]
    'm' [1 0 1]
    'c' [0 1 1]
    'r' [1 0 0]
    'g' [0 1 0]
    'b' [0 0 1]
    'w' [1 1 1]
    'k' [0 0 0]
    };

colvec=col{find(strcmp(col(:,1),p.Color)),2};
if strcmp(class(I),'uint8')
    colvec=colvec*255;
end
% ==============================================
%   mask
% ===============================================
m=zeros([size(I,1)*size(I,2) 1]);
if ~isempty(cv)
    ce=round(cv(:,[2 1])); %FLIP XY
    ind = sub2ind([size(I,1),size(I,2)],ce(:,1),ce(:,2));
    m(ind)=1;
end
m2=reshape(m,[size(I,1),size(I,2)]);
if isfield(p,'size')==0
    m3=m2(:);
else
   m3=imdilate(m2,strel('disk',p.size));
   m3=m3(:);
end

ig=find(m3==1);

if size(I,3)==3
    im1=I;
else
    im1=cat(3,I,I,I);
end
for ii=1:3
    r=im1(:,:,ii);
    r(ig)=colvec(ii);
    im1(:,:,ii)=reshape(r,[size(I,1) size(I,2)]);
end





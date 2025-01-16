%smooth binary mask
%   bw: binary mask
%   polynomial order, K, must be a integer less than window size, F, which must
%   be an odd integer. If the polynomial order, K, equals F-1, no smoothing will
%   occur. Each of the K+1 columns of G is a differentiation filter for
%   derivatives of order P-1 where P is the column index.
%
% w2: smoothed mask
% w=smoothmask(bw, K, 55);

function [w2]=smoothmask(bw, K, F)


if exist('K')~=1 || isempty(K); K = 2 ; end
if exist('F')~=1 || isempty(F); F = 55; end



%% ===============================================
% mask=imfill(bw,'holes');
% bw=bwskel(bw);
% dum=(imcomplement(bw)+mask)-1;
% boundaries = bwboundaries(dum);


boundaries = bwboundaries(bw);

% Get the x and y coordinates.
% x = firstBoundary(:, 2);
% y = firstBoundary(:, 1);

% % Now smooth with a Savitzky-Golay sliding polynomial filter
% windowWidth = 45
% polynomialOrder = 2
% smoothX = sgolayfilt(x, polynomialOrder, windowWidth);
% smoothY = sgolayfilt(y, polynomialOrder, windowWidth);


K = 2; F = 55;
w=zeros(numel(bw),1);
bw_siz=size(bw);
nadd=round(F/K)+5;
for i=1:length(boundaries)
    
    %% ===============================================
    firstBoundary = boundaries{i};
    x = firstBoundary(:, 2);
    y = firstBoundary(:, 1);
    % x(1:10)'
    %     xb=x;
    
    if K>0
        
        siz=length(y);
        x=[ ones(nadd,1)*x(1) ; x  ];
        y=[ ones(nadd,1)*y(1) ; y  ];
        x([end+1:end+1+nadd])=x(end);
        y([end+1:end+1+nadd])=y(end);
        
        % ===============================================
        
        
        % K = 2; F = 55;
        G = sgolayfilt(K,F);
        % dt = 5e-2; t = 0:dt:4*pi;
        % y = sin(t)+1e-2*randn(size(t));    % Noisy sinusoid
        xx = conv(x,G(:,1).','same');     % 0-th derivative, smoothed
        yy = conv(y,G(:,1).','same');     % 0-th derivative, smoothed
        
        
        
        xx=xx(nadd+1:nadd+1+siz-1);
        yy=yy(nadd+1:nadd+1+siz-1);
    end
    xx=round(xx);
    yy=round(yy);
    xx(find(xx==0))=1; yy(find(yy==0))=1;

    
    %      fg, hold on; plot(x,y,'b') ;   plot(xx,yy,'r')
    %
    %% ===============================================
    
    
    in = sub2ind(bw_siz,yy,xx) ;
    w(in)=1;
end

w2=reshape(w,bw_siz);
% fg,imagesc(w2);





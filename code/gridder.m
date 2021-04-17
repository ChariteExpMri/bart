% make grid
% imoverlay(fix,pseudocolorize(w3));gridder(20,'color','r')
function gridder(step,varargin)


% ==============================================
%%   
% ===============================================
% step=[50 50]
% step=[20]

% fg,imagesc(pseudocolorize(w3))
% imoverlay(fix,pseudocolorize(w3)); grid on
if nargin==0
   step=10; 
end
if length(step)==1; step(2)=step(1); end
xl=xlim;
yl=ylim;

if nargin<=1
    vline(round(xl(1):step(1):xl(2))-1,'color','w');
    hline(round(yl(1):step(2):yl(2))-1,'color','w');
else
    vline(round(xl(1):step(1):xl(2))-1,varargin{:});
    hline(round(yl(1):step(2):yl(2))-1,varargin{:});
end


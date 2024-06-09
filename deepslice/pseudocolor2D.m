
%generate pseudocolor image (2D) (for ANO)
%  [pimg]=pseudocolor2D(img);
% img: [2d-image]
% pimg: pseudocolorImage

function [pimg]=pseudocolor2D(img,varargin)
warning off;

p.dummy=0;
if ~isempty(varargin)
   pin =cell2struct(varargin(2:2:end),varargin(1:2:end),2);
   p=catstruct(p,pin);
end
pimg=[];

%% ===============================================



%% ===============================================
if 0
   %% TESTS
   %% ===============================================
   [pimg]=pseudocolor2D(img);
   
   %% ===============================================
end
%% ===============================================


d=img(:);
uni   =unique(d);
newnum=[1:length(uni)]';
[M, ia] = ismember(d, uni);
d(M)    = newnum(ia(M));
pimg=reshape(d,size(img));

% https://de.mathworks.com/matlabcentral/answers/458732-replace-value-by-value-without-a-loop-from-2-vectors
%% ===============================================

% d=[1 1 3 3 1 4 4]'
% uni   =unique(d);
% newnum=[1:length(uni)]'*10
% 
% [M, ia] = ismember(d, uni);
% d(M)    = newnum(ia(M))

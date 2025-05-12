
% get slice from NIFTI via mm-cordinates
% templatefile: Nifti toread out
% co: n-by-[x-y-z] cordinates (mm)   
% imagesize: size of output image (same as histoImage)
% interpolationOrder :0,1,2,3

function [img]=getslice_fromcords(templatefile,co,imagesize,interp,varargin)
warning off;

p.dummy=0;
if ~isempty(varargin)
   pin =cell2struct(varargin(2:2:end),varargin(1:2:end),2);
   p=catstruct(p,pin);
end
dum=[];

%% ===============================================
if 0
   %% TESTS
   %% ===============================================
   templatefile='F:\tools\bart_template\AVGT.nii'
   img=getslice_fromcords(templatefile,co,[1000 1000],1);
   
   img=getslice_fromcords(templatefile,co,st.histo_size,1);
   
   
   templatefile='F:\tools\bart_template\ANO.nii'
   img=getslice_fromcords(templatefile,co,[1000 1000],0);
   
   %% ===============================================
end
%% ===============================================

ha=spm_vol(templatefile);
% ==============================================
%%   coordinates to read out
% ===============================================
sx=co;
sx(:,2)=ha.dim(1)-sx(:,2)+1;%+0.0250;
% sx(:,1)=ha.dim(2)-sx(:,1);
sx(:,3)=ha.dim(2)-sx(:,3)+1;%+13.0250;
% sx(:,2)=ha.dim(3)-sx(:,2);
sx(:,1)=sx(:,1);%-0.0250;

sx(:,1) = (ha.dim(3) + 1) - sx(:,1);  %LEFT-RIGHT FLIP such that hemimask id 1==left, and 2==right

q=spm_sample_vol(ha,sx(:,2)',sx(:,3)',sx(:,1)',interp);
q2=reshape(q, imagesize);
img=permute(q2,[2 1]);
% fg; imagesc(fliplr(flipud(permute(q2,[2 1]))))

% % fg; imagesc(q2)
% fg; imagesc(permute(q2,[2 1]))
% fg; imagesc(v2')

% xmlfile=fullfile('C:\paul_projects\python_deepslice\paul_histoIMG', 'est.xml')
% s=getestimation_xml(xmlfile);
% [s st]=getestimation_xml(xmlfile,'loadhistoimage',1); %get histoImage
% co: coordinates (in mm)
% st: struct with infos (and histoImage)


function [s  st]=getestimation_xml(xmlfile,varargin)
warning off;

p.loadhistoimage=0;
if ~isempty(varargin)
   pin =cell2struct(varargin(2:2:end),varargin(1:2:end),2);
   p=catstruct(p,pin);
end


if 0
   %% TESTS
   %% ===============================================
   xmlfile=fullfile('C:\paul_projects\python_deepslice\paul_histoIMG', 'est.xml')
   co=getestimation_xml(xmlfile);
   
   [co st]=getestimation_xml(xmlfile,'loadhistoimage',1); %get histoImage
   %% ===============================================
   
end

imagepath=fileparts(xmlfile);

% f2=fullfile(imagepath, 'est.xml');
g=xml2struct(xmlfile);
eval(regexprep(['&' g.Children(2).Attributes(1).Value ';'],'&',';r.'));
imagename  =g.Children(2).Attributes(2).Value;
histimage  =fullfile(imagepath, imagename);


%% ======reasd histo image or get size==========================================

if p.loadhistoimage==1;
   b=imread(histimage); 
   % fg,image(b)
    b_size=[size(b,1) size(b,2)];
else
    binfo=imfinfo(histimage);
    b_size=[binfo.Height binfo.Width];
end



w= [ r.ux  r.uy  r.uz;
    r.vx  r.vy  r.vz ;
    r.ox  r.oy  r.oz ];

% a2=permute(a,[3 1 2 ]);
% a2=flipdim(a2,2);
% a2=flipdim(a2,3);
% size(a2)
% ===============================================
% bx=b(:,:,1);
% b2=bx(:);
clear co
[co(:,1),co(:,2)] = ind2sub(b_size,[1:(prod(b_size))]);

% co=co./1000;
co=co./[b_size];
co2=[co  ones(size(co,1),1) ];

% ===============================================

s=co2*w;
st.histimage=histimage;
st.xmlfile  =xmlfile;
st.w        =w;
st.histo_size   =b_size;

if p.loadhistoimage==1
    st.image=b;
end
varargout{1}=st;

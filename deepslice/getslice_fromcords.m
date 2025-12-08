
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
species='mouse';
pat=fileparts(templatefile);
template_paramfile=fullfile(pat,'parameter.m');
if exist(template_paramfile)==2
    run(template_paramfile);
end
% ==============================================
%%   coordinates to read out
% ===============================================
if strcmp(species,'mouse')
    ha=spm_vol(templatefile);
    
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
else
    %% ===============================================
    
    %% ===============================================
    %% Load deepslice parameters for one slice
    % Example values from your CSV
    % ox = 485.2279;
    % oy = 544.4262;
    % oz = 482.1928;
    % ux = -474.6223;
    % uy = 10.3333;
    % uz = 10.3110;
    % vx = -11.5775;
    % vy = 45.1002;
    % vz = -388.6211;
    % width = 1000;   % pixels
    % height = 1000;  % pixels
    lin=strjoin(cellfun(@(a){[a '=co.' a ';' ]}, (fieldnames(co))),';');
    eval(lin);
    % ===============================================
    %% ======[cropped version]=========================================
    % Load original header (before crop)
    file_origHDR     =fullfile(fileparts(templatefile),'origmat.mat'); %saved HDR of the original, uncropped template
    s = load(file_origHDR);
    Horig = s.hh;                 % original uncropped header
    Hcrop = spm_vol(templatefile);% Load cropped NIfTI header
    % 1) Build normalized grid
    [u_grid, v_grid] = meshgrid(linspace(0,1,imagesize(2)), linspace(0,1,imagesize(1)));
    % 2) DeepSlice plane in ORIGINAL voxel space
    Xo = ox + u_grid .* ux + v_grid .* vx;
    Yo = oy + u_grid .* uy + v_grid .* vy;
    Zo = oz + u_grid .* uz + v_grid .* vz;
    % 3) Convert ORIGINAL voxel to mm (world coordinates)
    Xmm = Horig.mat(1,1)*Xo + Horig.mat(1,2)*Yo + Horig.mat(1,3)*Zo + Horig.mat(1,4);
    Ymm = Horig.mat(2,1)*Xo + Horig.mat(2,2)*Yo + Horig.mat(2,3)*Zo + Horig.mat(2,4);
    Zmm = Horig.mat(3,1)*Xo + Horig.mat(3,2)*Yo + Horig.mat(3,3)*Zo + Horig.mat(3,4);
    % 4) Convert mm to CROPPED voxel coordinates
    Mcrop_inv = inv(Hcrop.mat);
    Xc = Mcrop_inv(1,1)*Xmm + Mcrop_inv(1,2)*Ymm + Mcrop_inv(1,3)*Zmm + Mcrop_inv(1,4);
    Yc = Mcrop_inv(2,1)*Xmm + Mcrop_inv(2,2)*Ymm + Mcrop_inv(2,3)*Zmm + Mcrop_inv(2,4);
    Zc = Mcrop_inv(3,1)*Xmm + Mcrop_inv(3,2)*Ymm + Mcrop_inv(3,3)*Zmm + Mcrop_inv(3,4);
    % 5) Sample CROPPED volume
    img = spm_sample_vol(Hcrop, Xc, Yc, Zc, 0);
    img(isnan(img)) = 0;
    
    if 0
        figure; imagesc(img);        axis image;  colormap gray;
    end
    %% ======[uncropped version]=========================================
    if 0
        V = spm_vol(templatefile);   % load header
        %     F1='F:\tools\make_bart_templateRat\WHS_SD_rat_atlas_v4_pack\WHS_SD_rat_T2star_v1.01.nii.gz'
        %     V = spm_vol(F1);
        % Read volume data
        % Optional: can use spm_sample_vol directly without reading full volume
        % Generate grid of pixel coordinates in slice plane
        % u and v are vectors along width and height
        % Create normalized grid (0 to 1)
        %[u_grid, v_grid] = meshgrid(linspace(0,1,width), linspace(0,1,height));
        [u_grid, v_grid] = meshgrid(linspace(0,1,imagesize(2)), linspace(0,1,imagesize(1)));
        % Map grid to 3D atlas coordinates
        X = ox + u_grid * ux + v_grid * vx;
        Y = oy + u_grid * uy + v_grid * vy;
        Z = oz + u_grid * uz + v_grid * vz;
        % Sample atlas values
        img = spm_sample_vol(V, X, Y, Z, 0); % 0 = nearest neighbor interpolation
        if 0
            figure; imagesc(img);            axis image;  colormap gray;
        end
    end
    %% ===============================================
    
end



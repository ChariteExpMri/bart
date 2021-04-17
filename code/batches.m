






% % =====================================================
% % #g FUNCTION:        [f_warp2histo.m]
% % #b info :            f_warp2histo is a function.
% % =====================================================
z=[];
z.outDirName                = 'fin';                                                                                  % % Name of the output Directory: ("fin": folder with output images)
z.refImg                    = 'F:\data3\histo2\bart\templates\AVGT.nii';                                              % % Reference image for registration
z.filesTP                   = { 'F:\data3\histo2\bart\templates\AVGT.nii' 	'1'                                        % % Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) 
                                'F:\data3\histo2\bart\templates\AVGThemi.nii' 	'0'                                      
                                'F:\data3\histo2\bart\templates\ANO.nii' 	'0' };                                        
z.NumResolutions            = [2  2];                                                                                 % % number of resolutions for affine(arg1) & B-spline(arg2) transformation
z.MaximumNumberOfIterations = [250  1000];                                                                            % % number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation
z.FinalGridSpacingInVoxels  = [40];                                                                                   % % control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)
z.files                     = { 'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_003.tif' };     % % histo-files
f_warp2histo(1,z);












% ==============================================
%%   warp2hist   HISTOVOL
% ===============================================

z=[];
z.outDirName                = 'fin';                                                                                  % % Name of the output Directory: ("fin": folder with output images)
z.refImg                    = 'F:\data3\histo2\bart\templates\HISTOVOL.nii';                                          % % Reference image for registration
z.filesTP                   = { 'F:\data3\histo2\bart\templates\AVGT.nii' 	'1'                                        % % Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) 
                                'F:\data3\histo2\bart\templates\AVGThemi.nii' 	'0'                                      
                                'F:\data3\histo2\bart\templates\ANO.nii' 	'0' };                                        
z.NumResolutions            = [2  6];                                                                                 % % number of resolutions for affine(arg1) & B-spline(arg2) transformation
z.MaximumNumberOfIterations = [250  4000];                                                                            % % number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation
z.FinalGridSpacingInVoxels  = [20];                                                                                   % % control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)
z.files                     = { 'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_001.tif' };     % % histo-files
f_warp2histo(0,z);



% ==============================================
%%   warp2hist  -...AVGT
% ===============================================

z=[];
z.outDirName                = 'fin';                                                                                  % % Name of the output Directory: ("fin": folder with output images)
z.refImg                    = 'F:\data3\histo2\bart\templates\AVGT.nii';                                          % % Reference image for registration
z.filesTP                   = { 'F:\data3\histo2\bart\templates\AVGT.nii' 	'1'                                        % % Files to transform from Template-path: NAME + INTERPOLATION (0:NN; 1:linear) 
                                'F:\data3\histo2\bart\templates\AVGThemi.nii' 	'0'                                      
                                'F:\data3\histo2\bart\templates\ANO.nii' 	'0' };                                        
z.NumResolutions            = [2  3];                                                                                 % % number of resolutions for affine(arg1) & B-spline(arg2) transformation
z.MaximumNumberOfIterations = [1250  12000];                                                                            % % number of iterations within each resolution for affine(arg1) & B-spline(arg2) transformation
z.FinalGridSpacingInVoxels  = [140];                                                                                   % % control point spacing of the bspline transformation (lower value: improve accuracy but may cause unrealistic deformations)
z.files                     = { 'F:\data3\histo2\josefine\dat\Wildlinge_fr_h_20_2_000000000001EADF\a1_001.tif' };     % % histo-files
f_warp2histo(0,z);

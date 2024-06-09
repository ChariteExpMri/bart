

function f=deepslice_fcn()

%fctName    label  description                        useparalelPossible
f={...
% % % 'f_makeProject.m'   'make a new project'                               0
% % % 'f_importTiff.m'    'IMPORT TIFF from external source'              1

''     '' ''  
''     '<html><b><font color=fuchsia> DeepSlice PIPELINE_________ ' ''  

'f_resizeTiff.m'     'resize TIFF to register image'                   1
'f_prunegui.m'     'prune image (rotate)'                   1

'f_deepslice.m'   'DEEPSLICE, to find slice in volume'                1
'f_manwarp.m'      'manually warp image '    0
 
'f_warpslice.m'           'posthoc warp image '    1

'f_warp2histospace.m'     'trafo atlas to histospace '    1

% 'f_cuttiffs.m'      'CUT large TIFF, The TIFF contains all slices '    1
% 'f_resizeTiff.m'     'resize TIFF to register image'                   1
% 
% 'f_prunegui.m'     'prune image (rotate)'                   1
% 
% ...        
% ''     '<html><b><font color=blue> SLICE SELECTION SECTION_________ ' ''  
% 
% ... 
% % % % 'f_rotateSlices.m'     'rotate slices'                                 0
% 'f_estimateSlice.m'   'estimate slice in 3D volume'                    0
% 'f_warpestSlices.m'   'warp estimated slices to reference slice'       0
% 
% 'f_selectslice.m'   'select best matching slice'                       0
% ''  '<html><b><font color=blue> WARPING SECTION_________ ' ''  
% 'f_warp2histo.m'        'warp image back to Histo-space'                    0
% 'f_warpotherimages.m'   'warp other images (NIFTIs) back to Histo-space'    0

};



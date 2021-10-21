
function f_prunegui(isopengui,s)

files=s.files;

%% ===============================================
% requested input for prunegui
% {'F:\data4\Lina_HISTO_gadolinium\dat\39__2021-1_M4a_0000000000021839a2_007.mat'}
% {'F:\data4\Lina_HISTO_gadolinium\dat\39__2021-1_M4a_0000000000021839a2_008.mat'}

%% ===============================================

if isempty(char(files))
   disp('...no files selected');
   return
end


[pas fis ext]=fileparts2(files);
fis=regexprep(fis,{'^a1_'},{'a2_'});
ext=regexprep(ext,{'.tif'},{'.mat'});

fis2=cellfun(@(a,b,c){[a filesep  [ b c ]]}, pas,fis,ext );
prunegui(fis2);
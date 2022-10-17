
function f_prunegui(isopengui,s)
if exist('s')==1
    files=s.files;
else
    
     fidi=bartcb('getsel')  ;
    files=fidi(strcmp(fidi(:,2),'file'),1); 
end

%% ===============================================
% requested input for prunegui
% {'F:\data4\Lina_HISTO_gadolinium\dat\39__2021-1_M4a_0000000000021839a2_007.mat'}
% {'F:\data4\Lina_HISTO_gadolinium\dat\39__2021-1_M4a_0000000000021839a2_008.mat'}

%% ===============================================

if isempty(char(files))
   disp('...no files selected');
   return
end

% ==============================================
%%   batchfile
% ===============================================
h=evalin('base','anth');

w1={'% % ====================================================='
    ['% %  prune image [' mfilename '.m]']
    '% % ====================================================='
    'f_prunegui(); % prune image'
    '       '
    };
h2=[h; w1];
assignin('base','anth',h2);

% ==============================================
%%   
% ===============================================

[pas fis ext]=fileparts2(files);
fis=regexprep(fis,{'^a1_'},{'a2_'});
ext=regexprep(ext,{'.tif'},{'.mat'});

fis2=cellfun(@(a,b,c){[a filesep  [ b c ]]}, pas,fis,ext );
fis2=cellstr(fis2);
for i=1:length(fis2)
    prunegui(fis2{i});
    
end



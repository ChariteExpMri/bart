

function importTiff(file, s)
warning off;
file=char(file);

disp(['*** prosessing:' file]);
[pa fi ext]=fileparts(file);

outDir0=fi;
outDir=regexprep(outDir0,{'\.', '\s+' ,'#'},{'_' ,'_',''});
fpoutDir=fullfile(s.dat ,outDir,'raw');
mkdir(fpoutDir);
fiout=fullfile(fpoutDir, [outDir ext]);
disp(['copying....[' fi ext ']' ]);
copyfile( file, fiout, 'f');


% ==============================================
%%   ndpi -conversion
% ===============================================

if strcmp(ext, '.ndpi')
    disp(['converting ndpi-to-tiff....' ]);
    eval(['! ' which('ndpisplit.exe') ' "' fiout '"']);
end


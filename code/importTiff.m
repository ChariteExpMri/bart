

function importTiff(file, s)
warning off;
file=char(file);

disp(['*** prosessing:' file]);
[pa fi ext]=fileparts(file);

outDir0=fi;
outDir=regexprep(outDir0,{'\.', '\s+' ,'#'},{'_' ,'_',''});
fpoutDir=fullfile(s.dat ,outDir,'raw');
mkdir(fpoutDir);





% ==============================================
%%   ndpi -conversion
% ===============================================

if strcmp(ext, '.ndpi')
    disp(['converting ndpi-to-tiff....' ]);
    %eval(['! ' which('ndpisplit.exe') ' "' fiout '"']); %prev version
    if ischar(s.ndpi_magnification) && strcmp(s.ndpi_magnification,'all')        %all magnifications
        magstr='';
    else
        magstr=[' -x' num2str(s.ndpi_magnification)    ]  ; %specific magnification
    end
    str=['! ' which('ndpisplit.exe')  ' -O "' fpoutDir '"'   magstr   ' "' file '"' ];
   % str=['! ' which('ndpisplit.exe')  ' -O "' fpoutDir '" '   "' file '"' ] 
   % str=['! ' which('ndpisplit.exe')  ' -O "' fpoutDir '"'  ' -x' num2str(10)   ' "' file '"' ]
    eval(str);
else  %TIF
  disp(['copying....[' fi ext ']' ]);
  fiout=fullfile(fpoutDir, [outDir ext]);  
  copyfile( file, fiout, 'f');
end

% keyboard
% eval(['!' which('ndpisplit.exe') ' -h' ])








% ==============================================
%%   delete files
% ===============================================
if 0
    
    delfi=cellstr(s.deleteFiles);
    if ~isempty(delfi{1})
        if strcmp(delfi{1},'none')==0
            deltag=strsplit(delfi{1},';');
            for i=1:length(deltag)
                try; delete(fullfile(fpoutDir,['*' deltag{i} '*'])); end
            end
        end
    end
end
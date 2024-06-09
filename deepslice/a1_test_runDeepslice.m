

clear; cf; warning off
imagepath   ='C:\paul_projects\python_deepslice\paul_histoIMG'
imagepath   ='C:\paul_projects\python_deepslice\paul_histoIMG\test3'


conda_path  ='C:\Users\skoch\miniconda3'
% conda_path  ='C:\Users\skoch\anaconda3'
conda_env   ='C:\Users\skoch\anaconda3\envs\deepslice'
% pythonscript='C:\paul_projects\python_deepslice\runDeepslice.py'
pythonscript=which('runDeepslice_single.py')




%% ===============================================
pythonscript_pyt =strrep(pythonscript,filesep,'/')
imagepath_pyt    =strrep(imagepath,filesep,'/')

% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate "C:\Users\skoch\anaconda3\envs\deepslice";cd "C:\paul_projects\python_deepslice"; python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
%===================================================================================================
%windir%\System32\cmd.exe "/K" C:\Users\skoch\anaconda3\Scripts\activate.bat C:\Users\skoch\anaconda3

%% ===============================================
clc

c={
['%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit ']
['-Command "& "' conda_path  '\shell\condabin\conda-hook.ps1"; ']
['conda activate "' conda_env '"; ']
['python '  '"' pythonscript_pyt  '"  "' imagepath_pyt  '";']
['exit']
};
cm=strjoin(c,' ');
system(cm);



return
%% ===============================================
clc

c={
['%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit ']
['-Command "& ''C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1'' ; ']
['conda activate "C:\Users\skoch\anaconda3\envs\deepslice"; ']
['cd "C:\paul_projects\python_deepslice"; ']
['python' ' '  'test2.py'  ' ' '"C:/paul_projects/python_deepslice/paul_histoIMG";']
['exit']
};
cm=strjoin(c,' ');
system(cm);

% 
% % ==============================================
% %%   
% % ===============================================
% 
% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate 'C:\Users\skoch\miniconda3' "
% 
% 
% sleep 10
% 
% conda activate C:\Users\skoch\anaconda3\envs\deepslice
% cd "C:\paul_projects\python_deepslice"
% 
% python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
% 
% exit
% 
% 
% % system('%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& ''C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1'' ; conda activate ''C:\Users\skoch\miniconda3'' "')
% % system('conda activate C:\Users\skoch\anaconda3\envs\deepslice')
% % system('cd "C:\paul_projects\python_deepslice"')
% 
% 
% !%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -NoExit -Command "& 'C:\Users\skoch\miniconda3\shell\condabin\conda-hook.ps1' ; conda activate "C:\Users\skoch\anaconda3\envs\deepslice";cd "C:\paul_projects\python_deepslice"; python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
% 
% 
% conda activate 'C:\Users\skoch\miniconda3' " 
% && conda activate "C:\Users\skoch\anaconda3\envs\deepslice"
% 
% 
% && cd "C:\paul_projects\python_deepslice" && python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
% 
% python 'test2.py' 'C:/paul_projects/python_deepslice/paul_histoIMG'
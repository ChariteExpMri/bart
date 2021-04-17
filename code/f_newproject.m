
function f_newproject()


%% make new project
[m z]=bartconfig(1);

if isempty(m) && isempty(z); return; end

% ==============================================
%%   check dat-folder name
% ===============================================
pat=z.dat;
[pa fi ext]=fileparts(pat);
if strcmp(fi,'dat')~=1;
    errordlg('"datpath" folder must terminate to a folder namd "dat", such as "c:\study-1\dat" ','File Error');
    return
end
% ==============================================
%%   make dat-dir
% ===============================================
%% make dir and UI for projectName
if exist(pat)==0
    mkdir(pat);
end
% ==============================================
%%   save project file
% ===============================================
[fi pa]=uiputfile('*.m','save configfile (example "project_study1")' ,fullfile(fileparts(pat),'proj.m'));
if pa~=0
    pwrite2file(fullfile(pa,fi),m);
end

% try;
%     %explorer(pa) ;
% %     disp(['open folder with new project <a href="matlab: explorer('' ' pa '  '')">' pa '</a>']);% show h<perlink
%      disp(['open folder with new project <a href="matlab: ' systemopen(fullfile(pwd,'t2.nii'),1)  '">' pa '</a>']);% show h<perlink
% end



%% questDLG
dlgTitle    = '';
dlgQuestion = ['load the new project: ' fullfile(pa,fi) ' now' ];
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if strcmp(choice,'Yes')
    cd(pa)
    %ant; antcb('load',fullfile(pa,fi)) ;
    bartcb('close');bartcb('load', fullfile(pa,fi));
end





clear

% ==============================================
%%   make excelfile for evaluation: left/right, excludings
% ===============================================
cprintf('*[0  0 1]','..MAKE EVALUATON TABLE!\n');



fidi=bartcb('getall')  ;
z.files=fidi(strcmp(fidi(:,2),'file'),1);


%% ===============================================
t1={};
flipside=nan;

anialcount=0;
animalprev='unsinn111';
animalvec=[];
for i=1:length(z.files)
    thisslice=z.files{i};
    [pa fi ext]=fileparts(thisslice);
    [paf animal]=fileparts(pa);
    slicename=strrep(fi,'a1_','');
    
    finpa=fullfile(pa,'fin');
    isok=[0];
    if exist(fullfile(finpa, ['s' slicename '_ANO.mat']));  %check if final warping existed
        isok(1)=1;
    end
    comment={nan};
    if isok(1)==0
        comment={' final warping not performed (bad slice)'};
    end
    
    
    notused=nan;
    if sum(isok)~=length(isok)
        notused=1;
    end
    
    if strcmp(animalprev, animal)==0
        anialcount=anialcount+1;
        animalprev=animal;
    end
    
    t1(i,:) =[ animal num2cell(anialcount)   ['s' slicename] num2cell([notused  flipside ]) comment];
    
end

ht1={'animal' 'animalIndex'        'slice'   'excludeSlice'             'flipSide'       'comment______________________'};
ht2={''       'arbitrary index'     ''        'add "1" to exclude Slice' 'add "1" to  flip hemisphere' 'make comments here'};
%  uhelp(plog([],[ht1;t1],0, [  ' table'],'s=4;al=1;'),1);
% ==============================================
%   save file
% ===============================================
global ak

paout=fullfile(fileparts(ak.dat),'result');
if ~exist(paout)==7
    mkdir(paout);
end


cprintf([1  0 1],'..write Excelfile...');
fout=fullfile(paout,'bart_evaluationTable.xlsx');
sheetname='slice-info';
pwrite2excel(fout,{1 sheetname},ht1,ht2,t1);
cprintf([1  0 1],'..DONE!\n');

% ==============================================
%%   colorize
% ===============================================
id=cell2mat(t1(:,2));
unianimals=unique(id);
nanimals=length(unianimals);


warning odd;
col=cbrewer('qual', 'Pastel1', nanimals);

cprintf([1  0 1],'..colorizing...');
for i=1:nanimals
    ix=find(id==unianimals(i));
    
    ixh=ix+2;
    
    idx=['[' num2str(ixh') '],[' num2str([1:3]) ']'];
    xlscolorizeCells(fout,sheetname, idx, col(i,:));
end
cprintf([1  0 1],'..DONE!\n');

% ==============================================
%%   show cmd-link
% ===============================================
showinfo2('..evaluationTable',fout);








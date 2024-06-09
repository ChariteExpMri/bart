

% f_statistic_twoIndependentGroups.m


function varargout=f_statistic_twoIndependentGroups(showgui,x )

disp(['executing: ' mfilename '.m']);


% ==============================================
%%   PARAMS
% ===============================================
if exist('showgui')==0 || isempty(showgui) ;    showgui=1                   ;end
if exist('x')==0                           ;    x=[]                        ;end

% ==============================================
%% PARAMETER-FILES
% ===============================================

if exist('x')~=1;        x=[]; end
% if isstruct(x) && ~isempty(x.files)
% %     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a2','.mat' })
%     x.files =regexprep(x.files,{ '\a1' '.tif'},{'\a1','.tif' });
% end

global ak
outputpath=fullfile(fileparts(ak.dat),'result', 'regdensity','BigTable');
% mkdir(outputpath);
f1=fullfile(outputpath,'bigtable.xlsx');
if exist(f1)==2
    bigtable=f1;
else
    bigtable='';
end
% ==============================================
%%   struct
% ===============================================
para={...
    'bigtable'         bigtable 'select the excelfile containing the celldensities across all animals' ,'f'
    'groupfile'        ''       'select excelfile containing the group assignment (colum-1:animalNames col-2: group-name)'  'f'
    'densityMode'      1        'type of data to test {1} Density-affine, {2}Density-warped, {3} cellcounts ' {1,2,3}
    'relativeChanges'  0         'statistic relative to the other hemisphere (in percent)'  'b'
    
    'statistic'    'ttest2'   'type of within-statistic {"ttest2" or "ranksum" (Wilcoxon rank sum test) }' {'ttest2' 'ranksum'}
    'tail'         'left'    'select the statistical tail {both,left,right}'  {'both' 'left' 'right'}
    'FDRqlevel'     0.05     'q-The desired false discovery rate {0.1, 0.05, 0.001}' {0.1, 0.05, 0.001}
    'sortPvalues'     1      'sort p-values by value  [0]no [1] yes'    'b'
    'removeAnimals'  []      'remove animals by ID; example: remove animals 1 and 3 is [1,3]' ,{'' '1' '3' '1 3'}
    '' '' '' ''
    'inf2' '___OUTPUTS__' '' ''
    'showResults'  1     'show results (tables'    {'b'}
%     'saveReducedTable' 1 'save a reduced table {0,1} (containing only regions that exist in all animals)'  {'b'}
    'saveOutput'       1 'save results as excel-file {0,1} ' {'b'}
    'outputDir'      outputpath 'output directory'  'd'
    'prefix'           ''  'additiona option to add prefix-string to filename of "saveOutput" '  {'test_' 'LR_'}
    };
%     '' '' '' ''
%     '' '____OPTIONAL USED FILES_______' '' ''
%      'files'                  ''                'select files'                   'mf'

% z.saveReducedTable=0;
% z.usedDensityMode=[1];
% % z.tstat_tail     ='right'   ;%'left' ,'right'
% z.tstat_tail     ='left'   ;%'left' ,'right'
%  z.FDR_qlevel     =0.05;     ;%FDR qlevel
% %z.FDR_qlevel     =0.1;     ;%FDR qlevel
% z.plotResults    =1  ; %[0,1]
% ==============================================
%%   GUI
% ===============================================
p=paramadd(para,x);


if showgui==1 || showgui==2
    if     showgui==1; pb1string='OK'    ; pb1color='w';
    elseif showgui==2; pb1string='PASS' ;  pb1color=[0.9294    0.6941    0.1255];
    end
    hlp=help(mfilename); hlp=strsplit2(hlp,char(10))';
    [m z parse q2]=paramgui(p,'uiwait',1,'close',1,'editorpos',[.03 0 1 1],...
        'figpos',[.2 .2 .5 .3 ],...
        'title',['statistic left vs right (' mfilename '.m)'],...
        'pb1string',pb1string,'pb1color',pb1color,'info',hlp);
    if isempty(m);
        varargout{1}=[];
        varargout{2}=[];
        return;
    end
    fn=fieldnames(z);
    z=rmfield(z,fn(regexpi2(fn,'^inf\d')));
else
    z=param2struct(p);
end

xmakebatch(z,p, mfilename); % ## BATCH

if showgui==1
    varargout{1}=z;
    if ischar(parse)==1 && strcmp(parse,'parse')
        showgui=-1;
    end
elseif showgui==2
    showgui=-1;   %just parse data
end
% ==============================================
%%   Parse parameter without runnning rest
% ===============================================
if showgui==-1
    p2=struct2param(p,z);
    p2=[{['@' mfilename] 0 'FunctionName' ''}; p2]; % add functionName
    varargout{1}=p2;
    varargout{2}= z;
    return
end




% ==============================================
%%   PROCEED
% ===============================================
cprintf([0 0 1],[' statistic-left vs vs right [' mfilename '.m]... '  '\n']);
timex=tic;
proc(z);
cprintf([0 0 1],[' Done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);


%% ===============================================






function proc(z)






% ==============================================
%%   reduced table
% ===============================================


% ==============================================
%%   read xlsfile
% ===============================================
[~,~,a0]=xlsread(z.bigtable);
a0(:,strcmp(cellfun(@(a){[num2str(a)  ]}, a0(1,:) ),'NaN'))=[];
a0(strcmp(cellfun(@(a){[num2str(a)    ]}, a0(:,1)),'NaN'),:)=[];

ha=a0(1,:);
a=a0(2:end,:);

% ==============================================
%%   obtain ID,animals
% ===============================================
v.animals=unique(a(:,1));

if ~isempty(num2str([z.removeAnimals])); %               REMOVE ANIMALS BY id
    animalsremoved=v.animals(z.removeAnimals);
    cprintf([1 .1 0],['__removed animals (n=' num2str(length(animalsremoved)) ')____\n']);
    disp(char(animalsremoved));
    
    v.animals(z.removeAnimals)=[];
    %size(a)
    for i=1:length(animalsremoved)
        a(strcmp(a(:,1), animalsremoved{i}),:)=[];
        %size(a)
    end
    v.animalsremoved =animalsremoved;
    v.Nanimalsremoved=length(animalsremoved);
else
    v.animalsremoved ='none';
    v.Nanimalsremoved=0;
end
%% ===============================================



v.no_animals=length(v.animals);
v.isDiffIn_IDs=unique(cell2mat(a(:,3))-cell2mat(a(:,4)));
v.IDall=cell2mat(a(:,3));
v.ID   =unique(v.IDall);


% ==============================================
%%
% ===============================================
% nanimalbyID=zeros(length(v.ID),1);
idcount=repmat({0  '' },[length(v.ID)  1]);
for i=1:length(v.ID)
    ix= find(v.IDall==v.ID(i));
    idcount(i,:) = {length(ix) ix};
end
nanimalbyID=cell2mat(idcount(:,1));




% ==============================================
%%   reduzed table
% ===============================================
v.info2='__reduced table__';
v.samplethresh=length(v.animals)-0;
isvalid=find(nanimalbyID>=v.samplethresh);
v.Nregs_samplethresh=length(isvalid);

ha2=ha;
a2={};
for i=1:length(isvalid)
    ix=idcount{isvalid(i),2};
    a2=[a2; a(ix,:)];
end

v.animals_reduced    =unique(a2(:,1));
v.no_animals_reduced =length(v.animals_reduced);


% ==============================================
%%   save reduzed table
% ===============================================
if 0
    if z.saveReducedTable==1
        cprintf([0 .7 0],'..saving REDUCED-TABLE...');
        %     [paout animal ext]=fileparts(char(z.bigtable));
        %     paout2=fullfile(paout);
        
        paout2=z.outputDir;
        if exist(paout2)~=7
            mkdir(paout2);
        end
        
        warning off;
        mkdir(paout2);
        f1=fullfile(paout2,['reducedtable_n' num2str(v.samplethresh) '.xlsx']);
        try; delete(f1); end
        pwrite2excel(f1,{1 'celldensReduced'},ha2,[],a2);
        showinfo2('..REDUCED-TABLE',f1);
        cprintf([0 .7 0],'..Done!\n');
    end
end


% ==============================================
%%   group-assignment
% ===============================================
 if exist(z.groupfile)~=2
    error('no group-file assigned ...don''t know which animal belongs to whcih group!') ;
 end

[~,~,gr0]=xlsread(z.groupfile);
gr0=xlsprunesheet(gr0);
hgr=gr0(1,:);
gr =gr0(2:end,:);
gr(find(cell2mat(cellfun(@(a){[strcmp(a,'NaN')  ]}, gr(:,1)))==1),:)=[]; %remove nan-entries
 
%% =============get groups, names and IDSperGroup ==================================
v.info3='___groups___';
v.grouplabels=unique(gr(:,2));

if length(v.grouplabels)~=2
    disp(['number of groups must be 2..but ' num2str(length(v.grouplabels)) ' groups found: grouplabels: ' ['"' strjoin(v.grouplabels,'","') '"']])
end
g1=gr(ismember(gr(:,2),v.grouplabels{1}),1);
g2=gr(ismember(gr(:,2),v.grouplabels{2}),1);

%--valid.i.e. present in HistoData
gv1=v.animals_reduced(ismember(v.animals_reduced,g1));
gv2=v.animals_reduced(ismember(v.animals_reduced,g2));

v.groupIDs  ={gv1 gv2};
v.groupsizes=cell2mat(cellfun(@(a){[size(a,1) ]}, v.groupIDs));


% ==============================================
%%   simple T-test
% ===============================================
if z.densityMode==1
    icol=find(ismember(ha2, {'DENSaffL' 'DENSaffR'} ));
    densmode='Density-affine';
elseif z.densityMode==2
    icol=find(ismember(ha2, {'warpNpixL' 'warpNpixR'} ))  ;
    densmode='Density-warped';
elseif z.densityMode==3
    icol=find(ismember(ha2, {'ccL' 'ccR'} ));
    densmode='cellcounts';
end

outlier=[];
j=0;
% for j=1:v.no_animals;
outlier=[j];

v.IDreduced=unique(cell2mat(a2(:,3)));
v.N_IDreduced=length(v.IDreduced);
idall=cell2mat(a2(:,3));
b={};
zerosdens=[];
for i=1:length(v.IDreduced)
    ic=find(idall==v.IDreduced(i));

    
    w=a2(ic,:) ;% reduced table to this region
    
    %check ID
%     if 1 %check
%         %disp(sum(abs(cell2mat(w(:,3))-v.IDreduced(i))));
%         
%         isreg=strcmp(w(1,2),'Anterior cingulate area, ventral part, layer 5');
%         if isreg==1
%             disp(i)
%         end
%     end
%     
    
    ix1=ismember(w(:,1), v.groupIDs{1});
    ix2=ismember(w(:,1), v.groupIDs{2});
    
    m1=[[w{ix1,icol(1)}]' [w{ix1,icol(2)}]'];  %group1: left, right
    m2=[[w{ix2,icol(1)}]' [w{ix2,icol(2)}]'];  %group2: left, right
    
    %% ===============================================
    %deal with percentage: values are zero or 'inf'
    %% ===============================================
    
    % option-1 : REPLACE BY MEAN OF GROUP
    option0=2;
    %===================================================================================================
    if option0==1
        for j=1:2
            if     j==1; mx=m1;
            elseif j==2; mx=m2;
            end
            ie=find(mx(:,1)==0); %find zeros in col-1
            mx(ie,1)=mean(mx(setdiff(1:size(mx,1),ie),1));
            ie=find(mx(:,2)==0); %find zeros in col-2
            mx(ie,2)=mean(mx(setdiff(1:size(mx,1),ie),2));
            if     j==1; m1=mx;
            elseif j==2; m2=mx;
            end
        end
        %===================================================================================================
    elseif option0==2
        izero=find([m1(:);m2(:)]==0);
        if ~isempty(izero)
            zerosdens=[zerosdens i];
            continue
        end
    end
    
    m1(:,3)=m1(:,1)./m1(:,2)*100;  %add relative changes rel. to right Hemisphere (in %)
    m2(:,3)=m2(:,1)./m2(:,2)*100;
    
    % ===============================================
    for j=1:size(m1,2) % loop: left,right, percent
        v1=m1(:,j);
        v2=m2(:,j);
        
       v1=sqrt(v1);  v2=sqrt(v2);
      %      v1=log(v1+1);  v2=log(v2+1);
  %   v1=log10(v1+1);  v2=log10(v2+1);
        
        
        ME     =[mean(v1)   mean(v2)];
        SD     =[std(v1)    std(v2)];
        MED    =[median(v1) median(v2)];
        RA     =[range(v1)  range(v2)];
        MEdif  =ME(1)-ME(2);
        MEDdif =MED(1)-MED(2);
      
        
        if strcmp(z.statistic,'ttest2')
            [h,pv,~,st ]=ttest2(v1,v2,'tail',z.tail);
            b(i,j,:)=...
                [ a2(ic(1),[2 3]) num2cell([...
                h pv st.tstat st.df...
                ME(1) ME(2) MEdif ...
                SD(1) SD(2) ...
                MED(1) MED(2) MEDdif ...
                RA(1) RA(2)])]            ;
        elseif  strcmp(z.statistic,'ranksum')
            [pv,h,st ]=ranksum(v1,v2,'tail',z.tail);
            if isfield(st,'zval')==0
                st.zval=nan;
            end
            b(i,j,:)=...
                [ a2(ic(1),[2 3]) num2cell([...
                h pv st.zval st.ranksum...
                ME(1) ME(2) MEdif ...
                SD(1) SD(2) ...
                MED(1) MED(2) MEDdif ...
                RA(1) RA(2)])]            ;
            
        end
%         if isnan(pv);
%             disp([i j]);
%         end
        % ===============================================
    end % loop: left,right, percent
    
end % for all regions


if ~isempty(zerosdens)
    b(zerosdens,:,:)=[];
end

% ==============================================
%%   Header
% ===============================================
if strcmp(z.statistic,'ttest2')
    hb={'region' 'id' 'Huncor' 'p' 'T' 'df' 'ME1' 'ME2' 'MEdiff' 'SD1' 'SD2' ...
        'MED1' 'MED2' 'MEDdiff' 'Range1' 'Range2'};
elseif  strcmp(z.statistic,'ranksum')
    hb={'region' 'id' 'Huncor' 'p' 'Zvalue' 'ranksum' 'ME1' 'ME2' 'MEdiff' 'SD1' 'SD2' ...
        'MED1' 'MED2' 'MEDdiff' 'Range1' 'Range2'};
end
% ==============================================
%%   FDR-correction
% ===============================================
v.info4= '___statistic___';
v.tables={'leftHem' 'rightHem' 'relative'};
ipval=find(ismember(hb,'p' ));
id=find(ismember(hb,'id' ));
for i=1:size(b,2)
    d=squeeze(b(:,i,:));
    if z.sortPvalues==1         %sort p-values by value
       d=sortrows(d,ipval); 
    end
    
    ifdr=find(fdr_bh(cell2mat(d(:,ipval)),z.FDRqlevel,'pdep','yes'));
    cfdr=zeros(size(d,1),1);
    cfdr(ifdr)=1;
    
    
   s =[d(:,1:id)   num2cell(cfdr)   d(:,id+1:end)  ];
   hs=[hb(:,1:id)  'Hfdr'          hb(:,id+1:end)  ];
   
   
   v.hb=hs;
   if     i==1;   v.b1=s;
   elseif i==2;   v.b2=s;
   elseif i==3;   v.b3=s;
   end
end

%% ===============================================


% ==============================================
%%  intersection of regions across animals
% ===============================================

atlasUnionAnimal=sortrows(v.b1(:,1:2),2);
if z.showResults==1
%     uhelp(plog([],[{'region' 'ID'}; atlasUnionAnimal],0, ...
%         [  'INTERSECTION OF REGIONS ( n=' num2str(size(v.b1,1)) '): regions that exist in all animals '],'s=4;al=1;'),1); 
end

v.intersections='__intersected regions_';
v.atlasUnionAnimal=atlasUnionAnimal;

% ==============================================
%%   show results
% ===============================================


if z.showResults==1
    
    for i=1:3
        if     i==1;  dx=v.b1;
        elseif i==2;  dx=v.b2;
        elseif i==3;  dx=v.b3;
        end
        
        compStr=['("' strjoin(v.grouplabels,'" vs "') '")'];
        title1=[ v.tables{i}  '-' compStr ' Regions (n=' num2str(size(dx,1)) ') ' '[STAT]: ' z.statistic ', [mode]:' densmode ', [tail]: ' z.tail '' ];
       uhelp(plog([],[v.hb;dx],0, title1,'s=4;al=1;'),1); 
        
    end
end

% ==============================================
%%   save table
% ===============================================
if z.saveOutput==1
    warning off;
    cprintf([1  0 1],'..saving results as excel-files');
    
    paout2=z.outputDir;
    if exist(paout2)~=7
        mkdir(paout2);
    end
    fname=[char(z.prefix) 'statGRP_' densmode '_' z.statistic '_tail' z.tail '_FDRq' num2str(z.FDRqlevel) '.xlsx'  ];
    f2=fullfile(paout2,fname);
    
    try; delete(f2); end
    
    
    pwrite2excel(f2,{1 ['' v.tables{1}]},v.hb,[],v.b1);
    pwrite2excel(f2,{2 ['' v.tables{2}]},v.hb,[],v.b2);
    pwrite2excel(f2,{3 ['' v.tables{3}]},v.hb,[],v.b3);
    
    pwrite2excel(f2,{4 ['region_All_animals ' ]},{'regions' 'ID'},[],v.atlasUnionAnimal);
  
    
    
    % ==============================================
    %%   info sheet
    % ===============================================
    
    
    l={['__STATISTIC: GROUP-COMPARISON__'                       ],''};
    l(end+1,:)={'DATE: ' datestr(now)                           };
    l(end+1,:)={'source(bigtable): '   z.bigtable               };
    l(end+1,:)={'densityMode: '        densmode                 };
    l(end+1,:)={'statistic: '          z.statistic              };
    l(end+1,:)={'tail: '               z.tail                   };
    l(end+1,:)={'FDRqlevel: '          num2str(z.FDRqlevel) };
    l(end+1,:)={'  '};
    l(end+1,:)={'__RESULTS__' '' };
    l(end+1,:)={'N_regions_invested:    ' num2str(length(unique(cell2mat((a(:,3)))))) };
    l(end+1,:)={'N_regions_intersected: ' num2str(length(unique(cell2mat((a2(:,3)))))) };
    l(end+1,:)={'N_regions_sign(uncor) LEFT HEMI: ' num2str(sum(cell2mat(v.b1(:,4)))) };
    l(end+1,:)={'N_regions_sign(FDR)   LEFT HEMI: ' num2str(sum(cell2mat(v.b1(:,3)))) };
    
    l(end+1,:)={'N_regions_sign(uncor)Right HEMI: ' num2str(sum(cell2mat(v.b2(:,4)))) };
    l(end+1,:)={'N_regions_sign(FDR)  Right HEMI: ' num2str(sum(cell2mat(v.b2(:,3)))) };
    
    l(end+1,:)={'N_regions_sign(uncor)relative (left vs right): ' num2str(sum(cell2mat(v.b3(:,4)))) };
    l(end+1,:)={'N_regions_sign(FDR)  relative (left vs right): ' num2str(sum(cell2mat(v.b3(:,3)))) };
    
    l(end+1,:)={'  '};
    l(end+1,:)={'__GROUPS __________' ''};
    
    % ===============group.members================================
    t=repmat({'-'},[200 2]);
    t(1,:)={...
        [v.grouplabels{1} '(n=' num2str(v.groupsizes(1)) ')' ] ...
        [v.grouplabels{2} '(n=' num2str(v.groupsizes(2)) ')' ]};
    t(2:size(v.groupIDs{:,1},1)+1,1)=v.groupIDs{:,1};
    t(2:size(v.groupIDs{:,2},1)+1,2)=v.groupIDs{:,2};
    t(max([size(v.groupIDs{:,1},1) size(v.groupIDs{:,2},1)])+2:end,:)=[];
    %t=plog([],[t],0, [mfilename 'ERRORS' ],'s=1;al=1;plotlines=0');
    
    l=[l; t];
    % =================[removed animals]==============================
    
    l(end+1,:)={'  '};
    l(end+1,:)={['__ANIMALS removed (n='  num2str(v.Nanimalsremoved) ') __________'] ' '};
    if ischar(v.animalsremoved)
        v.animalsremoved=cellstr(v.animalsremoved);
    end
    t2=[v.animalsremoved(:) repmat({' '},[ length(v.animalsremoved) 1])];
    l=[l; t2];
    
    %% ===============================================
    if 1
        pwrite2excel(f2,{5 ['info ' ]},{'_INFO_' },[],l);
        cprintf([1  0 1],'..DONE!\n');
        showinfo2('..RESULTS',f2);
    end
end


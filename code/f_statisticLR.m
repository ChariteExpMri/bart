

% make left-right-statistic
% % =====================================================
% % #g FUNCTION:        [f_statisticLR.m]
% % #b info :              make left-right-statistic
% % =====================================================
% z=[];
% z.bigtable         = 'G:\data1\josefine\result\regdensity\BigTable\bigtable.xlsx';     % % select the excelfile containing the celldensities across all animals
% z.densityMode      = [1];                                                              % % type of data to test {1} Density-affine, {2}Density-warped, {3} cellcounts 
% z.statistic        = 'signrank';                                                       % % type of within-statistic {ttest or signrank}
% z.tail             = 'left';                                                           % % select the statistical tail {both,left,right}
% z.FDRqlevel        = [0.05];                                                           % % q-The desired false discovery rate {0.1, 0.05, 0.001}
% z.showResults      = [1];                                                              % % show results (tables
% z.saveReducedTable = [1];                                                              % % save a reduced table {0,1} (containing only regions that exist in all animals)
% z.saveOutput       = [0];                                                              % % save results as excel-file {0,1} 
% z.prefix           = '';                                                               % % additiona option to add prefix-string to filename of "saveOutput" 
% f_statisticLR(1,z);


function varargout=f_statisticLR(showgui,x )

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
    'bigtable'      bigtable 'select the excelfile containing the celldensities across all animals' ,'f'
    'densityMode'   1        'type of data to test {1} Density-affine, {2}Density-warped, {3} cellcounts ' {1,2,3}
    'statistic'    'ttest'   'type of within-statistic {ttest or signrank}' {'ttest' 'signrank'}
    'tail'         'left'    'select the statistical tail {both,left,right}'  {'both' 'left' 'right'}
    'FDRqlevel'     0.05     'q-The desired false discovery rate {0.1, 0.05, 0.001}' {0.1, 0.05, 0.001}
    '' '' '' ''
    'inf2' '___OUTPUTS__' '' ''
    'showResults'  1     'show results (tables'    {'b'}
    'saveReducedTable' 1 'save a reduced table {0,1} (containing only regions that exist in all animals)'  {'b'}
    'saveOutput'       1 'save results as excel-file {0,1} ' {'b'}
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
cprintf([0 0 1],[' stitistic-left vs vs right [' mfilename '.m]... '  '\n']);
timex=tic;
proc(z);
cprintf([0 0 1],[' Done... dT=' sprintf('%2.2f min',toc(timex)/60)  '\n']);


%% ===============================================






function proc(z)






% ==============================================
%%   reduced table
% ===============================================
% z=[];
% z.file='G:\data1\josefine\result\regdensity\BigTable\bigtable.xlsx';
% z.saveReducedTable=0;
% z.usedDensityMode=[1];
% % z.tstat_tail     ='right'   ;%'left' ,'right'
% z.tstat_tail     ='left'   ;%'left' ,'right'
%  z.FDR_qlevel     =0.05;     ;%FDR qlevel
% %z.FDR_qlevel     =0.1;     ;%FDR qlevel
% z.plotResults    =1  ; %[0,1]

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
if z.saveReducedTable==1
    cprintf([0 .7 0],'..saving REDUCED-TABLE...');
    [paout animal ext]=fileparts(char(z.bigtable));
    paout2=fullfile(paout);
    warning off;
    mkdir(paout2);
    f1=fullfile(paout2,['reducedtable_n' num2str(v.samplethresh) '.xlsx']);
    try; delete(f1); end
    pwrite2excel(f1,{1 'celldensReduced'},ha2,[],a2);
    showinfo2('..REDUCED-TABLE',f1);
    cprintf([0 .7 0],'..Done!\n');
end




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
for i=1:length(v.IDreduced)
    ic=find(idall==v.IDreduced(i));
    m=[[a2{ic,icol(1)}]' [a2{ic,icol(2)}]'];
    
    m=m(setdiff([1:size(m,1)],  outlier   ),:);
    
    %         m=log10(m+1);
    %         m=sqrt(m);
    %         m=m.^2;
    
    ME =mean(m);
    SD =std(m);
    MED=median(m);
    RA =range(m);
    MEdif =ME(1)-ME(2);
    MEDdif=MED(1)-MED(2);
    % [h,pv,~,st ]=ttest(m(:,1),m(:,2));
    %  [h,pv,~,st ]=ttest(m(:,1),m(:,2),'tail','left');
    % [h,pv,~,st ]=ttest(m(:,1),m(:,2),'tail','right');
    if strcmp(z.statistic,'ttest')
        [h,pv,~,st ]=ttest(m(:,1),m(:,2),'tail',z.tail);
        b(i,:)=...
            [ a2(ic(1),[2 3]) num2cell([...
            h pv st.tstat st.df...
            ME(1) ME(2) MEdif ...
            SD(1) SD(2) ...
            MED(1) MED(2) MEDdif ...
            RA(1) RA(2)])]            ;
    elseif  strcmp(z.statistic,'signrank')
        
        [pv,h,st ]=signrank(m(:,1),m(:,2),'tail',z.tail);
        b(i,:)=...
            [ a2(ic(1),[2 3]) num2cell([...
            h pv st.zval st.signedrank...
            ME(1) ME(2) MEdif ...
            SD(1) SD(2) ...
            MED(1) MED(2) MEDdif ...
            RA(1) RA(2)])]            ;
        
    end
end
if strcmp(z.statistic,'ttest')
    hb={'region' 'id' 'H' 'p' 'T' 'df' 'ME1' 'ME2' 'MEdiff' 'SD1' 'SD2' ...
        'MED1' 'MED2' 'MEDdiff' 'Range1' 'Range2'};
elseif  strcmp(z.statistic,'signrank')
    hb={'region' 'id' 'H' 'p' 'Zvalue' 'SignedRank' 'ME1' 'ME2' 'MEdiff' 'SD1' 'SD2' ...
        'MED1' 'MED2' 'MEDdiff' 'Range1' 'Range2'};
end

ipval=find(ismember(hb,'p' ));
b=sortrows(b,ipval);
title1=[ 'UNCORRECTED: Regions (n=' num2str(size(b,1)) ') L vs R:' '[STAT]: ' z.statistic ', [mode]:' densmode ', [tail]: ' z.tail '' ];
if z.showResults==1
    uhelp(plog([],[hb;b],0, title1,'s=4;al=1;'),1);
end

zz.uncocrrected='___uncorrected___';
zz.hb=hb;
zz.b=b;



% ==============================================
%%  FDR
% ===============================================
ifdr=find(fdr_bh(cell2mat(b(:,ipval)),z.FDRqlevel,'pdep','no'));
% title2=[ 'Surviving FDR-Regions (n=' num2str(length(ifdr)) ') L vs R: mode:' densmode '; FDR q=' num2str(z.FDR_qlevel) ';tail(' z.tstat_tail ')' ];
title2=[ 'FDR-CORRECTED (q=' num2str(z.FDRqlevel) '): Regions (n=' num2str(length(ifdr)) ') L vs R:' '[STAT]: ' z.statistic ', [mode]:' densmode ', [tail]: ' z.tail '' ];

% if isempty(ifdr)
%     cprintf([1  0 1],'..NO FDR-survivors!\n');
% else
%     if z.showResults==1
%         uhelp(plog([],[hb;b(ifdr,:)],0, title2,'s=4;al=1;'),1);
%     end
% end

disp([ 'N_sigFDR (q=' num2str(z.FDRqlevel) '): ' num2str(length(ifdr))  '   ; N_sigUNCOR: ' num2str(sum(cell2mat(b(:,ipval))<0.05))]);
% end
b2=b(ifdr,:);
if isempty(b2)
    b2=repmat({' '},[1 length(hb)]);
    b2{1}='no FDR_survivors!';
end
if z.showResults==1
    uhelp(plog([],[hb;b2],0, title2,'s=4;al=1;'),1);
end

zz.FDRcorrected='___FDR_corrected___';
zz.hb2=regexprep(hb,'^H$','H_FDR');
zz.b2=b2;

% ==============================================
%%   intersection of regions across animals
% ===============================================

v.atlasUnionAnimal=sortrows(b(:,1:2),2);
if z.showResults==1
    uhelp(plog([],[{'region' 'ID'}; v.atlasUnionAnimal],0, ...
        [  'INTERSECTION OF REGIONS ( n=' num2str(size(b,1)) '): regions that exist in all animals '],'s=4;al=1;'),1); 
end

zz.intersections='__intersected regions_';
zz.intreg=v.atlasUnionAnimal;

% ==============================================
%%   save table
% ===============================================
if z.saveOutput==1
    cprintf([1  0 1],'..saving results to excel');
    paout=fileparts(z.bigtable);
    fname=[char(z.prefix) 'statLR_' densmode '_' z.statistic '_tail' z.tail '_FDRq' num2str(z.FDRqlevel) '.xlsx'  ];
    f2=fullfile(paout,fname);
    
    try; delete(f2); end
    
    
    pwrite2excel(f2,{1 ['FDR ' num2str(z.FDRqlevel) ]},zz.hb2,[],zz.b2);
    pwrite2excel(f2,{2 ['uncorrected ' ]},zz.hb,[],zz.b);
    pwrite2excel(f2,{3 ['region_All_animals ' ]},{'regions' 'ID'},[],zz.intreg);
  
    
    %% ===============================================
    
    
    
    l={['__STATISTIC LEFT VS RIGHT__'  ]};
    l{end+1,1}=['DATE: ' datestr(now) ];
    l{end+1,1}=['source(bigtable): ' z.bigtable ];
    l{end+1,1}=['densityMode: ' densmode ];
    l{end+1,1}=['statistic: ' z.statistic ];
    l{end+1,1}=['tail: '     z.tail ];
    l{end+1,1}=['FDRqlevel: ' num2str(z.FDRqlevel) ];
    l{end+1,1}=['  '];
    l{end+1,1}=['__RESULTS__'];
    l{end+1,1}=['N_regions_invested:    ' num2str(length(unique(cell2mat((a(:,3)))))) ];
    l{end+1,1}=['N_regions_intersected: ' num2str(length(unique(cell2mat((a2(:,3)))))) ];
    l{end+1,1}=['N_regions_sign(uncor): ' num2str(sum(cell2mat(zz.b(:,3)))) ];
    l{end+1,1}=['N_regions_sign(FDR): '   num2str(length(ifdr)) ];
    
    l{end+1,1}=['  '];
    l{end+1,1}=['__ANIMALS (n='  num2str(v.no_animals_reduced) ') __________'];
    l=[l; v.animals_reduced ];
    %% ===============================================
    pwrite2excel(f2,{4 ['info ' ]},{'_INFO_' },[],l);
    cprintf([1  0 1],'..DONE!\n');
      showinfo2('..RESULTS',f2);
end


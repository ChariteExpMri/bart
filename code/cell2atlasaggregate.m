
%aggregate atlas-based cell-regions
function cell2atlasaggregate(p0)
% cf;
warning off
%% ===============================================
p=struct();
%...p.struct-defaults can be filled later
p=catstruct(p,p0);
%% ===============================================
[~, animal]=fileparts(fileparts(p.files{1}));


% ==============================================
%%   check existence of files
% ===============================================
files={};
for i=1:length(p.files)
    [pa fi ext]=fileparts(p.files{i});
    pafin=(fullfile(pa,'fin'));
    fi2=[regexprep(fi,{'^a1_' ''},{'s'}) '_cellcountsRegion.mat'];
    fi_rc=fullfile(pafin,fi2);
    if exist(fi_rc)==2
        files(end+1,1)={fi_rc};
    else
       disp([ 'not found file: ' fi_rc]) ;
    end
end%files

% ==============================================
%%   load atlas
% ===============================================
try
[~,~,a0]=xlsread(p.atlas);
catch
    error('no atlas was specified in the GUI!! aborted...');
end

a0(:,strcmp(cellfun(@(a){[num2str(a)  ]}, a0(1,:) ),'NaN'))=[];
a0(strcmp(cellfun(@(a){[num2str(a)  ]}, a0(:,1) ),'NaN'),:)=[];
hat=a0(1,:);
at=a0(2:end,:);

% ==============================================
%%   unique IDS
% ===============================================
u1=cell2mat(at(:,4));
r=cellfun(@(a){[num2str(a)  ]}, at(:,5) );
u2=unique(str2num(strjoin(r,';')));
u2(isnan(u2))=[];
% idAT=unique([u1; u2]);
idAT=u1;

% ==============================================
%%   load cell2reg-mats and concatenate
% ===============================================
t=[];
for i=1:length(files)
    v=load(files{i}); v=v.v;
    
    isexcluded=0;
    
    if isfield(p,'et')
        [pdum sliceName]=fileparts(files{i});
        [pdum2, animal ]=fileparts(fileparts(pdum));
        sliceName=strrep(sliceName,'_cellcountsRegion','');
        itab=find(strcmp(p.et(:,1),animal ) & strcmp(p.et(:,3), sliceName ));
        
        if ~isempty(itab) % if IMAGE is not in Ecelfile...ignore flips/rejections...just include
            %__CHECK IF SLICE IS EXCLUDES: [1]-TAG IN COLUMN-4: {'excludeSlice'}
            %p.het: {'animal'}{'animalIndex'}{'slice'}{'excludeSlice'}{'flipSide'}{'comment________…'}
            if ~isempty(strfind(num2str(p.et{itab,4}),'1'))
                isexcluded=1;
            end
            %__CHECK IF SLICE IS FLIPPED [1]-TAG IN COLUMN-5 :{'flipSide'}
            %[imgNum],[ID],[ccL],[ccR],[affNpixL],[affNpixR],[warpNpixL],[warpNpixR']
            if ~isempty(strfind(num2str(p.et{itab,5}),'1'))
                tf=v.t;
                tf=tf(:,[1 2  [4 3] [6 5] [8 7] ]);
                v.t=tf;
                disp(['flipped: [' animal  ']: slice: ' sliceName ]);
            end
        end
    end
    
    if isexcluded==0
        t=[t;  v.t];
    else
         disp(['excluded: [' animal  ']: slice: ' sliceName ]);
    end
    %     disp(['img-no:' num2str(size(v.t,1))]);
end%files
ht=v.ht;

% ==============================================
%%   sum cellcounts and area over slices
% header:   1×8 cell array
%     {'imgNum'}    {'ID'}    {'ccL'}    {'ccR'}    {'affNpixL'}    {'affNpixR'}
%     {'warpNpixL'}    {'warpNpixR'}
% ===============================================
idall=t(:,2);
id=unique(idall);


sliceused={};
ta       =[];
for i=1:length(id)
   ix=find(idall==id(i)); 
   slicenum=cell2line(num2str(t(ix,1)),1,';');
   tx=sum(t(ix,:),1); %summed table
   tx(1,2)=id(i); %id back
   
   ta(i,:)=[tx];
   sliceused{i,1}=slicenum;
end

% % ==============================================
% %%   for each subregion
% % ===============================================
% tbat=[];
% for i=1:length(idAT)
%     is=find(ta(:,2)==idAT(i));
%     if ~isempty(is)
%         tbat(i,:)=ta(is,:);
%     end 
% end






% ==============================================
%%   calc densities
% ===============================================
cc=ta(:,3:4);
dens=repmat(cc,[1 2])./ta(:,[5:6 7:8]);
hdens=stradd(regexprep(ht(:,[5:6 7:8]),{'Npix'},{''}),'DENS',1 )';
% ==============================================
%% make  table
% ===============================================
htb=[ht hdens];
tb=[ta dens];



% ==============================================
%%   get label 
% ===============================================
[ins ia ib]=intersect( idAT ,tb(:,2));
% check: [ins idAT(ia) tb(ib,2) ]

lab=at(ia,[1 4]);
tb1       =tb(ib,:);
sliceused1=sliceused(ib);

% ==============================================
%%  make table
% ===============================================
Nslices=cellfun(@(a){[length(str2num(a))  ]}, sliceused1 );
hb2=['animal' 'region' 'ID' regexprep(htb,{'ID' ,'imgNum'},{ 'IDregHisto' ,'NumSlices'}) ...
   'Nsclices' 'slices' ];
b2=[ repmat({animal},[ size(lab,1) 1]) lab num2cell(tb1)  Nslices  sliceused1];

hb2(:,4)=[];
b2(:,4)=[];


% ==============================================
%%   reduce table in case of nan/inf
% ===============================================
if p.removeNANrows==1
    icol=regexpi2(hb2,'^DENSaff|^DENSwarp');
    ivalid=find(~isnan(sum(cell2mat(b2(:,icol)),2)));
    b2=b2(ivalid,:);
end

% ==============================================
%%   show table
% ===============================================

if p.showTable==1
    uhelp(plog([],[hb2; b2],0, 'rr','s=4;al=1;'),1);
end



% ==============================================
%%   save excelfile
% ===============================================
if p.save==1
    
    namestr=[ p.save_prefix animal ];
    f1=fullfile(p.save_dir, [namestr '.xlsx']) ;
    try; delete(f1); end
    pwrite2excel(f1,{1 'celldens'},hb2,[],b2);
    try
        showinfo2('..cell-folder',f1);
    end
end












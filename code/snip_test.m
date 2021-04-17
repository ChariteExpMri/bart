
function [dirs fpdirs ms]=snip_test()
% ==============================================
%%
% ===============================================
global ak
pa=ak.dat
kk=dir(pa);
dirs={kk(find(cellfun('isempty',regexpi({kk.name}','^\.$|^\..$')))).name}';
isdirx=[];
for i=1:length(dirs)
    fpdirs{i,1}=fullfile(pa,dirs{i} );
    isdirx(i)=isdir(fpdirs{i,1});
end
dirs=dirs(isdirx==1);
fpdirs=fpdirs(isdirx==1);


list={...
    'raw\*.tif'      'raw'
    '*.tif'          'SL'
    %     'o_struct.mat'  'Ostruct'
    %     'bestslice.mat' 'bslice'
    %     'par_*.txt'     'warped'
    };
list2={};

fpdir={};
for i=1:length(dirs)
    fpdirs{i,1}=fullfile(pa,dirs{i} );
    
    tg={};
    
    for j=1:size(list,1)
        k=dir(fullfile(fpdirs{i,1},list{j,1}));
        if isempty(k)
            v=0;
            date='-';
        else
            v=1;
            date=k(1).date;
        end
        tg=[tg; {list{j,2} v  date}];
        
    end
    list2{i}=tg;
end

% %  set(lb,'string',{'<html>234 HS<font color =#008000> &#9632'})
% % set(lb,'string',{'<html>234 HS<font color =#e6e6e6> &#9632'})
% status
lenMax=size(char(dirs),2);

% make max dirs-length
dirs2=cellfun(@(a){[ a repmat(' ', [1 lenMax-length(a)]) ]},dirs);
dirs2=strrep(dirs2,' ','&nbsp;');

ms={};
for i=1:length(list2);
    m=['<html>' dirs2{i}  ' # '];
    for j=1:size(list2{i},1)
        if  list2{i}{j,2} ==1 %exist
            m=[m    '<font color =#008000> &#9632' ] ;
        else
            m=[m    '<font color =#e6e6e6> &#9632' ];
        end
        
        m=[m '<font color =#000000>'  list2{i}{j,1}  ];
    end
    ms{i,1}=m;
end

% set(hb,'string',ms,'fontname','courier');
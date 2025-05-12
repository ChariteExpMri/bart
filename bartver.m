
% .
% 
% #yk BART
% 
% #b &#8658; Respository: <a href= "https://github.com/ChariteExpMri/bart">https://github.com/ChariteExpMri/bart</a>
% 
% 
% 
%======= CHANGES ================================
% #ba 04 Oct 2021 (21:16:50)
% [+] added [bartver] version-control available via Bart-gui-button
% 
% #k [f_importTiff_single.m] and [importTiff_single.m] #n  allows to import single tiff-images
% -Use this function, if there is only one single tif-image per animal
% 
% #ba 05 Oct 2021 (14:35:51)
% [selectslice.m]: added tag-function + tooltips
% 
% 
% #ba 21 Oct 2021 (11:27:06)
% added surrogate-method for slice-estimation
% 
% 
% #ba 17 Nov 2021 (00:27:12)
% #k [HTMLreport.m ] #n   make HTMLreport: finalResult (registration)
% available via BART-main-gui: snips/makeHTMLreport
% 
% #ba 18 Nov 2021 (18:56:08)
% #k &#8658;  registration of slices if only the left or right hemispheric tissue parts are present
% (in case that the other hemisphere is missing on the slice...for what ever reason)  
% 
% #k &#8658; grouping tag added in left listbox
% selection of specific dirs/files via grouping/rating tag or string in name 
% select files/dirs in listbox
% ---------select via grouping tag-----
% bartcb('sel','group',[1]);
% bartcb('sel','group',[1 3]);
% ---------select via  ratng tag-----
% bartcb('sel','tag','ok');
% bartcb('sel','tag','issue|ok');
% ---------select string in FILEs-----
% bartcb('sel','file','Nai|half');
% bartcb('sel','file','Nai|half|a1');
% bartcb('sel','file','a1_001');
% bartcb('sel','file','all');  %select all files
% ---------select string in DIRs-----
% bartcb('sel','dir','Nai|half');
% bartcb('sel','dir','fside');
% bartcb('sel','dir','all'); %select all dirs
% 
% % #k &#8658;  select folders/files by string/tag/group using [sel]-button
% 
% #ba 22 Nov 2021 (16:55:16)
%  #k [manucut_image ] #n manually cut multiSlice-Tiff  
% --> via: "Cut large Tiff" (right listbox): select approach: 3 tu use manual mode
% 
% #ba 23 Nov 2021 (13:36:56)
% #k [HTMLreportotherimages.m] #n  make HTMLreport for other images warped to histospace 
% --> access via MENU: HTML/'make HTMLfile Report:  other images to histoSpace [HTMLreportotherimages.m]
% 
% #ba 23 Nov 2021 (16:18:01)
% #k [f_warpotherimages.m] #n warp other images to histospace
% --> access via right listbox/warping section
% .
% 
% #ba 30 Nov 2021 (17:09:30)
% #k [f_ano_falsecolor2tif.m] #n convert ANO-atlas in histoSpace to pseudoatlas-TIF (pseudo-color or Allen-color)
% --> access via MENU: Conversion/"convert Histo-ATLAS(ANO)-slice(mat) to pseudocolor-TIF"
% 
% #ba 03 Dec 2021 (12:13:41) 
% #k [bartcfm.m] #n case-file-matrix for bart: visualize data (files x dirs), basic file-manipulation
% --> accessible: via "grid" ICON main BART-gui (next to load project button)
% 
% #ba 14 Dec 2021 (22:03:21)
% #k [cfm.m] #n case-file-matrix from from ANT-project used , 
% [bartcfm.m] is not used anymore 
% 
% #ba 25 Jul 2022 (14:52:11)
% #k [elastix2.m] #n  ---removed bug: 
% solved: warping n-best slices resulted in error when usong parallel processing
% #k [updatebart.m] #n  -new function to update changes
% 
% #ba 14 Oct 2022 (09:40:52) several revisions
% added code history:select [H]-Button or it's context menu to obtain the code of previously executed processes 
% 
% 
% 
% #ba 17 Oct 2022 (15:34:09)
% #k [f_statisticLR.m] #n  -new function to statistically evaluate regionwise left-right differences in cell-density 
% 
% #ba 07 Nov 2022 (15:06:23)
% #k [f_statisticLR.m] #n  ---modified: option to remove animals from statistic 
% 
% #ba 09 May 2025 (14:50:34)
% misc updates
% 
% 

%----- EOF
% make bartver.md for GIT: bartver('makebartver')


function bartver(varargin)
r=strsplit(help('bartver'),char(10))';
ichanges=regexpi2(r,'#*20\d{2}.*(\d{2}:\d{2}:\d{2})' );
lastchange=r{ichanges(end)};
lastchange=regexprep(lastchange,{'#\w+ ', ').*'},{'',')'});
r=[r(1:3); {[' last modification: ' lastchange ]}  ;  r(4:end)];

if nargin==1
    if strcmp(varargin{1},'makebartver')
        makebartver(r);
        return
    elseif strcmp(varargin{1},'new')
           clipboard('copy', [    ['% #ba '   datestr(now,'dd mmm yyyy (HH:MM:SS)') repmat(' ',1,0) ]           ]); 
           a=preadfile(which('bartver.m'))
           matlab.desktop.editor.openAndGoToLine(which('bartver.m'), min(regexpi2(a.all,'EOF')));
           return
    end
end

uhelp(r,0, 'cursor' ,'end');
set(gcf,'NumberTitle','off', 'name', 'BART - VERSION');
if 0
    clipboard('copy', [    ['% #ba '   datestr(now,'dd mmm yyyy (HH:MM:SS)') repmat(' ',1,0) ]           ]);
    clipboard('copy', [    ['% #T '   datestr(now,'dd mmm yyyy (HH:MM:SS)') '' ]           ]);
end


return

function makebartver(r)
% this makes a human readable bartver.md


i1=min(regexpi2(r,'CHANGES'));
head=r(1:i1);

s1=r(i1+1:end); % changes
lastline=max(regexpi2(s1,'\w'));
s1=[s1(1:lastline); {' '}];

%resort time: new-->old
it=find(~cellfun(@isempty,regexpi(s1,['#\w+.*(\d\d:\d\d:\d\d)'])));
it(end+1)=size(s1,1);

% % https://stackoverflow.com/questions/11509830/how-to-add-color-to-githubs-readme-md-file
% tb(1,:)={ '#yk'    '![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) '  'red' } ;
% tb(2,:)={ '#ok'    '![#c5f015](https://via.placeholder.com/15/c5f015/000000?text=+) '  'green' } ;
% tb(3,:)={ '#ra'    '![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) '  'blue' } ;
% tb(4,:)={ '#bw'    '![#FF00FF](https://via.placeholder.com/15/FF00FF/000000?text=+) '  'margenta' } ;
% tb(5,:)={ '#gw -->' '&#8618;'  'green arrow' } ;
% tb(6,:)={ '#ba'    '![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) '  'blue' } ;
% tb(7,:)={ '#k '     ' '  'remove tag' } ;
% tb(8,:)={ ' #n '    ' '  'remove tag' } ;
% tb(9,:)={ ' #b '    ' '  'remove tag' } ;
%% ============[new dots/symbols]===================================
tb={};
tb(end+1,:)={ '#ba'    '&#x1F535; ' '&#x1F535; LARGE BLUE CIRCLE --new date dot '   } ;
tb(end+1,:)={ '#bw'    '&#x1F4D7; ' '&#x1F4D7; GREEN BOOK -->new tutorial '   } ;
tb(end+1,:)={ '#ra'    '&#x1F535; ' '&#x1F535; LARGE BLUE CIRCLE --new date dot (used in older dates in antver) '   } ;
tb(end+1,:)={ '#ok'    '&#x1F34E; ' '&#x1F34E; green apple   new antx-version' } ;
tb(end+1,:)={ '#T'     '&#x1F4D9; ' '&#x1F4D9; :ORANGE BOOK, new   github pages' } ;

tb(end+1,:)={ '#yk'    '![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) '  'red' } ;
tb(end+1,:)={ '#gw -->' '&#8618;'  'green arrow' } ;
tb(end+1,:)={ '#wm -->' '&#9829;'  'SCRIPTS' } ;
tb(end+1,:)={ '#k '     ' '  'remove tag' } ;
tb(end+1,:)={ ' #n '    ' '  'remove tag' } ;
tb(end+1,:)={ ' #b '    ' '  'remove tag' } ;


s2=[];
for i=length(it)-1:-1:1
    dv2=s1(it(i):it(i+1)-1);
    
    dv2=regexprep(dv2, {'\[','\]'},{'__[',']__' }); %bold inside brackets
    
    l1=dv2{1};
    idat=regexpi(l1,'\d\d \w\w\w');
    dat=l1(idat:end);
    col=l1(1:idat-1);
    
    dat2=[col ' <ins>**' dat '</ins>' ]; %underlined+bold
    dat2=regexprep(dat2,')',')**');
    
    
    dv2=[ dat2;  dv2(2:end) ];
    %    dv2=[{ro};{ro2}; dv2];
    
    
    for j=1:size(tb,1)
        dv2=cellfun(@(a) {[regexprep(a,tb{j,1},tb{j,2})]} ,dv2 ) ; %green icon for #ok
    end
    
    
    dv2=cellfun(@(a) {[a '  ']} ,dv2 ); % add two spaces for break <br>
%     dv2{end}(end-1:end)=[]; %remove last two of list to avoid break ..would hapen anyway
%   dv2(end+1,1)={'<!---->'}; %force end of list
%     el=dv2{end};
    if ~isempty(regexpi(dv2 ,'^\s*-\s|^\s*\(\d+)\s|^\s*\d+)\s'))
        dv2(end+1,1)={'<!---->'}; %force end of list
    end
    s2=[s2; dv2];
end


head0={'## **BART Modifications**'};
head1=head(regexpi2(head,'BART')+1:end);
head1(regexpi2(head1,' CHANGES'))=[];%remove  '=== CHANGES ==' line
head1=[head1; '------------------' ];%'**CHANGES**'
head1=cellfun(@(a) {[regexprep(a,'last modification:',[tb{1,2} 'last modification:']) ]} ,head1 ) ; %red icon for last modific
head1=cellfun(@(a) {[a '  ']} ,head1 ); % add two spaces for break <br>

w=[head0; head1; s2];

% tes1='```js ...
%   import { Component } from '@angular/core';
%   import { MovieService } from './services/movie.service';
% 
%   @Component({
%     selector: 'app-root',
%     templateUrl: './app.component.html',
%     styleUrls: ['./app.component.css'],
%     providers: [ MovieService ]
%   })
%   export class AppComponent {
%     title = 'app works!';
%   }
% ```'

% w=[ '<font size="+5">' ;w; '</font>'];
w=regexprep(w,' #b ','');

fileout=fullfile(fileparts(which('bartver.m')),'bartver.md');
pwrite2file(fileout,w);







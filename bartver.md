## **BART Modifications**
 &#x1F535; last modification:   17 Jun 2025 (13:16:44)  
    
 &#8658; Respository: <a href= "https://github.com/ChariteExpMri/bart">https://github.com/ChariteExpMri/bart</a>  
    
    
    
------------------  
  &#x1F535;   <ins>**17 Jun 2025 (13:16:44)**</ins>  
   __[cell2region2.m]__  new, read cellcounts-file (csv) and calc. regionwise density  
<!---->
  &#x1F535;   <ins>**09 May 2025 (14:50:34)**</ins>  
  misc updates  
    
<!---->
  &#x1F535;   <ins>**07 Nov 2022 (15:06:23)**</ins>  
   __[f_statisticLR.m]__  ---modified: option to remove animals from statistic   
    
<!---->
  &#x1F535;   <ins>**17 Oct 2022 (15:34:09)**</ins>  
   __[f_statisticLR.m]__  -new function to statistically evaluate regionwise left-right differences in cell-density   
    
<!---->
  &#x1F535;   <ins>**14 Oct 2022 (09:40:52)** several revisions</ins>  
  added code history:select __[H]__-Button or it's context menu to obtain the code of previously executed processes   
    
    
    
<!---->
  &#x1F535;   <ins>**25 Jul 2022 (14:52:11)**</ins>  
   __[elastix2.m]__  ---removed bug:   
  solved: warping n-best slices resulted in error when usong parallel processing  
   __[updatebart.m]__  -new function to update changes  
    
<!---->
  &#x1F535;   <ins>**14 Dec 2021 (22:03:21)**</ins>  
   __[cfm.m]__ case-file-matrix from from ANT-project used ,   
  __[bartcfm.m]__ is not used anymore   
    
<!---->
  &#x1F535;   <ins>**03 Dec 2021 (12:13:41)** </ins>  
   __[bartcfm.m]__ case-file-matrix for bart: visualize data (files x dirs), basic file-manipulation  
  --> accessible: via "grid" ICON main BART-gui (next to load project button)  
    
<!---->
  &#x1F535;   <ins>**30 Nov 2021 (17:09:30)**</ins>  
   __[f_ano_falsecolor2tif.m]__ convert ANO-atlas in histoSpace to pseudoatlas-TIF (pseudo-color or Allen-color)  
  --> access via MENU: Conversion/"convert Histo-ATLAS(ANO)-slice(mat) to pseudocolor-TIF"  
    
<!---->
  &#x1F535;   <ins>**23 Nov 2021 (16:18:01)**</ins>  
   __[f_warpotherimages.m]__ warp other images to histospace  
  --> access via right listbox/warping section  
  .  
    
<!---->
  &#x1F535;   <ins>**23 Nov 2021 (13:36:56)**</ins>  
   __[HTMLreportotherimages.m]__  make HTMLreport for other images warped to histospace   
  --> access via MENU: HTML/'make HTMLfile Report:  other images to histoSpace __[HTMLreportotherimages.m]__  
    
<!---->
  &#x1F535;   <ins>**22 Nov 2021 (16:55:16)**</ins>  
    __[manucut_image ]__ manually cut multiSlice-Tiff    
  --> via: "Cut large Tiff" (right listbox): select approach: 3 tu use manual mode  
    
<!---->
  &#x1F535;   <ins>**18 Nov 2021 (18:56:08)**</ins>  
   &#8658;  registration of slices if only the left or right hemispheric tissue parts are present  
  (in case that the other hemisphere is missing on the slice...for what ever reason)    
    
   &#8658; grouping tag added in left listbox  
  selection of specific dirs/files via grouping/rating tag or string in name   
  select files/dirs in listbox  
  ---------select via grouping tag-----  
  bartcb('sel','group',__[1]__);  
  bartcb('sel','group',__[1 3]__);  
  ---------select via  ratng tag-----  
  bartcb('sel','tag','ok');  
  bartcb('sel','tag','issue|ok');  
  ---------select string in FILEs-----  
  bartcb('sel','file','Nai|half');  
  bartcb('sel','file','Nai|half|a1');  
  bartcb('sel','file','a1_001');  
  bartcb('sel','file','all');  %select all files  
  ---------select string in DIRs-----  
  bartcb('sel','dir','Nai|half');  
  bartcb('sel','dir','fside');  
  bartcb('sel','dir','all'); %select all dirs  
    
  %  &#8658;  select folders/files by string/tag/group using __[sel]__-button  
    
<!---->
  &#x1F535;   <ins>**17 Nov 2021 (00:27:12)**</ins>  
   __[HTMLreport.m ]__   make HTMLreport: finalResult (registration)  
  available via BART-main-gui: snips/makeHTMLreport  
    
<!---->
  &#x1F535;   <ins>**21 Oct 2021 (11:27:06)**</ins>  
  added surrogate-method for slice-estimation  
    
    
<!---->
  &#x1F535;   <ins>**05 Oct 2021 (14:35:51)**</ins>  
  __[selectslice.m]__: added tag-function + tooltips  
    
    
<!---->
  &#x1F535;   <ins>**04 Oct 2021 (21:16:50)**</ins>  
  __[+]__ added __[bartver]__ version-control available via Bart-gui-button  
    
   __[f_importTiff_single.m]__ and __[importTiff_single.m]__  allows to import single tiff-images  
  -Use this function, if there is only one single tif-image per animal  
    
<!---->

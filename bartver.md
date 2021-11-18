## **BART Modifications**
 ![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) last modification:   18 Nov 2021 (18:56:08)  
    
 &#8658; Respository: <a href= "https://github.com/ChariteExpMri/bart">https://github.com/ChariteExpMri/bart</a>  
    
    
    
------------------  
  ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)   <ins>**18 Nov 2021 (18:56:08)**</ins>  
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
<!---->
  ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)   <ins>**17 Nov 2021 (00:27:12)**</ins>  
   __[HTMLreport.m ]__   make HTMLreport: finalResult (registration)  
  available via BART-main-gui: snips/makeHTMLreport  
    
<!---->
  ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)   <ins>**21 Oct 2021 (11:27:06)**</ins>  
  added surrogate-method for slice-estimation  
    
    
<!---->
  ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)   <ins>**05 Oct 2021 (14:35:51)**</ins>  
  __[selectslice.m]__: added tag-function + tooltips  
    
    
<!---->
  ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)   <ins>**04 Oct 2021 (21:16:50)**</ins>  
  __[+]__ added __[bartver]__ version-control available via Bart-gui-button  
    
   __[f_importTiff_single.m]__ and __[importTiff_single.m]__  allows to import single tiff-images  
  -Use this function, if there is only one single tif-image per animal  
    
<!---->

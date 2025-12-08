# -*- coding: utf-8 -*-
"""
Created on Sat May 25 22:55:04 2024

@author: skoch
"""

# -*- coding: utf-8 -*-



import sys,os

folderpath=sys.argv[1]
print('path:',folderpath)


if os.path.isdir(folderpath)==True:
    print('Workingdir exits:')
else:
    print('Workingdir not found:')
    sys.exit(0)

# ====================================

from DeepSlice import DSModel     
species = 'mouse' #available species are 'mouse' and 'rat'
Model = DSModel(species)



print("hallo")


#folderpath='C:\paul_projects\python_deepslice\paul_histoIMG'
folderpath=folderpath.replace('\\','/')+'/'

#here you run the model on your folder
#try with and without ensemble to find the model which best works for you
#if you have section numbers included in the filename as _sXXX specify this :)
Model.predict(folderpath, ensemble=True, section_numbers=False)    
#If you would like to normalise the angles (you should)
#Model.propagate_angles()                     
#To reorder your sections according to the section numbers 
#Model.enforce_index_order()    
#alternatively if you know the precise spacing (ie; 1, 2, 4, indicates that section 3 has been left out of the series) Then you can use      
#Furthermore if you know the exact section thickness in microns this can be included instead of None
#if your sections are numbered rostral to caudal you will need to specify a negative section_thickness      
#Model.enforce_index_spacing(section_thickness = None)
#now we save which will produce a json file which can be placed in the same directory as your images and then opened with QuickNII. 
#Model.save_predictions(folderpath + 'MyResults') 

# %%
#folderpath = 'C:\paul_projects\python_deepslice\paul_histoIMG\'
#folderpath = 'C:/paul_projects/python_deepslice/paul_histoIMG/'


Model.save_predictions(folderpath + 'est') 

# %% 

k='C:\paul_projects\python_deepslice\paul_histoIMG'


a=imread('C:\paul_projects\python_deepslice\paul_histoIMG\test2\5ht.tif');
b=imresize(a,[1000 1000]);
fg,imagesc(b)
imwrite(uint8((imadjust(mat2gray(b))*255)),'test2.jpg')
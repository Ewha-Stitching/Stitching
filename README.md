Pseudo-code for the proposed method for stitching of tile scanned fluorescence microscope images. 
The proposed method works for field images constructed in a grid form (e.g., 2x2, 2x3, 3x3) starting with function MAIN. Function DETECTION is for the cell detection process using a triangular method-based threshold as explained in section 2.3.2. Function TRANSLATION is for estimating translational alignment between the two adjacent field images, and function ALIGNMENT is to optimize alignment between entire fields by using the obtained correlation information between two fields, and the two functions are corresponding to section 2.3.3 and 2.3.4, respectively. Note that the pseudo-code is simplified than the actual version to show only the core process in a concise format. For instance, Function TRANSLATION describes the procedure of estimating the translation between neighboring images location in the horizontal direction only.
function MAIN(Field Images f_im, Field Order f_order, Maximum Overlap Range mor)

create f_local than will contain relative position to neighbor field, correlation, and its #neighbor field 
	 
    f_im← Denoising  f_im using ANISOTROPIC_DIFFUSION
    [height,width]← row and column size of f_im
    [row_size,col_size] ← row and col size of f_order 
    centerNum ← ceil(col_size/2)+(ceil(row_size/2)-1)*col_size

for each f_im
if f_im(i) amd f_im(i+1) exists
           [tx,ty,corr]←TRANSLATION(f_im(i) ,f_im(i+1),mor) in vertical direction
           f_trans←[i,i+1,tx,ty,corr ]
end if
if f_im(i) amd f_im(i+1) exists
           [tx,ty,corr]←TRANSLATION(f_im(i) ,f_im(i+col_size),mor) in horizontal direction
           f_trans←[i,i+col_size,tx,ty,corr ]
end if
end for
	
    f_local← ALIGNMENT(centerNum,f_local,f_trans,f_order,[0]);  
    
for each f_im
        f_global← merge local x,y to neighbor field untill it reaches center 
end for
  Stitchedimage ← based on f_global merge field images 	
return Stitchedimage
end function

function TRANSLATION(Field Image im1, Field Image im2, Maximum Overlap Range mor)
    [height,width] ← row and column size of im1
	
create threshold th1 of im1 using TRIANGLE method
create threshold th2 of im2 using TRIANGLE method
    p_im1 ← im1(:,width(1-mor):width)
    p_im2 ← im1(:,1: width*mor)

    [bin_im1,bin_im2,condition] ← DETECTION(p_im1,p_im2,th1,th2)
	
if neither p_im1 and p_im2 has an object 
     tx ← width - floor(width*mor/2)
        ty ← 0
else
        start ← overlap depth where both p_im1 & p_im2 contain obejct
for depth_x = start∶ width*mor
for depth_y = -height*mor*0.8: height*mor*0.8
               weight1 ← p_im1-mean(p_im1)
               weight2 ← p_im2-mean(p_im2)
               corr← ∑▒∑▒〖weight1*weight2〗/√(∑▒〖∑▒〖weight1^2 〗* ∑▒〖∑▒〖weight2^2 〗  〗  〗) 
end for
if corr >= MaxCorr
               MaxCorr ← corr
               tx ← depth_x
               ty ← depth_y
end if		 
	end for
	if the percentage of overlapping pixels on partial binary image is smaller than 0.4
               tx ← width - floor(width*MaxOverlap/2)
               ty← 0
               MaxCorr← corr
end if
end if
end function

function DETECTION(Field Image im1,Field Image im2,Threshold th1,Threshold th2)

    condtion
  
create gray level image bin_im1 ← (im1 > th1)
create gray level image bin_im2 ← (im2 > th2)

if bin_im1 & bin_im2 contains element with value 1, then
        condition ← 1
else
        condition ←-1
end if
	
return bin_image1,bin_image2,condition
end function
function ALIGNMENT(Field Number fnum, f_local, paths_f, f_order, list_path)
    [row_size,col_size] ← row and col size of f_order
    current_row ← floor((fnum-1)/col_size)+1
    current_col ← fnum-floor((fnum-1)/col_size)*col_size
	
if Field (fnum+1) exist and its alignment to center field is yet set
     [tx,ty,corr]← translation and correlation between field (fnum)&(fnum+1)
     f_local(fnum+1,:)← [tx,ty,corr,fnum]
end if
if Field (fnum-1) exist and its alignment to center field is yet set 
     [tx,ty,corr]← translation and correlation between field (fnum)&(fnum-1)
     f_local(fnum-1,:)← [tx,ty,corr,fnum]
end if
if Field (fnum+ col_size) exist and its alignment to center field is yet set 
    [tx,ty,corr]← translation and correlation between field (fnum)&(fnum+col_size)
     f_local(fnum+col_size,:)← [tx,ty,corr,fnum]
end if
if Field (fnum-col_size) exist and its alignment to center field is yet set 
    [tx,ty,corr]← translation and correlation between field (fnum)&(fnum-col_size)
     f_local(fnum-col_size,:)← [tx,ty,corr,fnum]
end if
    centerNum ← ceil(col_size/2)+(ceil(row_size/2)-1)*col_size

if Field (fnum+ col_size+1) exist and its alignment to center field is yet set
      f_local← OPTIMAL_PATH(f fnum+ col_size+1, fnum+ col_size, fnum+1, centerNum, f_local)
end if
if Field (fnum+ col_size-1) exist and its alignment to center field is yet set 
      f_local← OPTIMAL_PATH(f fnum+ col_size-1, fnum+ col_size, fnum-1, centerNum, f_local)
end if
if Field (fnum-col_size+1) exist and its alignment to center field is yet set 
      f_local← OPTIMAL_PATH(f fnum- col_size+1, fnum- col_size, fnum+1, centerNum, f_local)
end if
if Field (fnum-col_size-1) exist and its alignment to center field is yet set 
      f_local← OPTIMAL_PATH(f fnum- col_size-1, fnum- col_size, fnum-1, centerNum, f_local)
end if
	
if field image attached to diagonal field exist and its alignment to center field is yet set
      f_local← ALIGNMENT(fieldNum,f_local,paths_f,f_order,list_path)
end if
  return f_local	
end function



function OPTIMAL_PATH(Field Number fnum, fnum1, fnum2, centerNum, f_local)

  [tx1,ty1,corr1]←translation and correlation between field (fnum)&(fnum1)	
  [tx2,ty2,corr2]←translation and correlation between field (fnum)&(fnum2)	

minCorr1 ← minimum correlation in path from field fnum1 to field centerNum
minCorr2 ← minimum correlation in path from field fnum2 to field centerNum
  if maxCorr1 > maxCorr2 
        f_local(fnum,:)← [tx1,ty1,corr1,fnum1]
if minimum correlation from fnum2 to fnum, then to center is larger than fnum2’s original path
     f_local(fnum2,:)← [tx2,ty2,corr2,fnum]
endif
elseif maxCorr1 < maxCorr2 
    f_local(fnum,:)← [tx2,ty2,corr2,fnum2]
 if minimum correlation from fnum1 to fnum, then to center is larger than fnum1’s original path
     f_local(fnum1,:)← [tx1,ty1,corr1,fnum]
endif
else
if corr1 >= corr2
  f_local(fnum,:)← [tx1,ty1,corr1,fnum1]   
if minimum correlation from fnum2 to fnum, then to center is larger than fnum2’s original path
       f_local(fnum2,:)← [tx2,ty2,corr2,fnum]
endif
else
      f_local(fnum,:)← [tx2,ty2,corr2,fnum2]
   if minimum correlation from fnum1 to fnum, then to center is larger than fnum1’s original path
       f_local(fnum1,:)← [tx1,ty1,corr1,fnum]
endif
endif
endif
return f_local
end function



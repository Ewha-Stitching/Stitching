function [r_x, r_y, maxCorr]=left2right(l_image1, l_image2, MaxOverlap)
%FInd overlapping area using Normalized cross correlation
height=size(l_image1,1);
width =size(l_image1,2);
ov= ceil(width*MaxOverlap); %Maximum overlap(pixel) in horizontal direction
ov_y = ceil(height*MaxOverlap*0.8); %Maximum overlap(pixel) in vertical direction


%Cut only neccessary part of the image
temp_image1 = l_image1(:,width-ov+1:width);
temp_image2 = l_image2(:,1:ov);

%Tumor cell ditections : Figure threshold value of each image and detect whether it contains cell 
level1=triangle_th(l_image1);
level2=triangle_th(l_image2);
[Label1, Label2, condition]=checkBlack(temp_image1, temp_image2,level1,level2);
clear l_image1; clear l_image2;

switch condition
    case -1
        r_x = width - floor(ov/2);
        r_y = 0;
        maxCorr = -1;
        
    case 1
        [r1, c1] = find(Label1~=0); %r is 'y', c is 'x'
        [r2, c2] = find(Label2~=0);
        start=ov+1-max(max(c1))+min(min(c2))-1;
        
        maxCorr=-1;maxX=width;maxY=0;
        max_loc1=1;max_loc2=1;
             
        if start > ov
            start=ov;
        end
        overlap=start;
        %Translation estimation : using normalized cross correlation
        for x_loc=start:ov
            loc2=1;
            for loc1=-ov_y:ov_y
                if loc1 < loc2
                    [Label1, Label2, condition]=checkBlack(temp_image1(1:loc1+height-loc2,ov-x_loc+1:ov), temp_image2(loc2-loc1+1:height,1:x_loc),level1,level2);
                else
                    [Label1, Label2, condition]=checkBlack(temp_image1(loc1-loc2+1:height,ov-x_loc+1:ov), temp_image2(1:loc2+height-loc1,1:x_loc),level1,level2);
                end
                if condition==-1
                    corr=-2;
                elseif loc1 < loc2 
                    temp_im1=temp_image1(1:loc1+height-loc2,ov-x_loc+1:ov);
                    temp_im2=temp_image2(loc2-loc1+1:height,1:x_loc);
                    mean_im1=mean2(temp_im1);mean_im2=mean2(temp_im2);
                    t_im1=temp_im1-mean_im1>0; t_im2=temp_im2-mean_im2>0;
                    temp_im1=double(temp_im1).*t_im1;temp_im2=double(temp_im2).*t_im2;
                    pcorr1=sqrt(sum(sum(temp_im1.^2)));pcorr2=sqrt(sum(sum(temp_im2.^2)));
                    corr=sum(sum(temp_im1.*temp_im2))/(pcorr1*pcorr2);
                else 
                    temp_im1=temp_image1(loc1-loc2+1:height,ov-x_loc+1:ov);
                    temp_im2=temp_image2(1:loc2+height-loc1,1:x_loc);
                    mean_im1=mean2(temp_im1);mean_im2=mean2(temp_im2);
                    t_im1=temp_im1-mean_im1>0; t_im2=temp_im2-mean_im2>0;
                    temp_im1=double(temp_im1).*t_im1;temp_im2=double(temp_im2).*t_im2;
                    pcorr1=sqrt(sum(sum(temp_im1.^2)));pcorr2=sqrt(sum(sum(temp_im2.^2)));
                    corr=sum(sum(temp_im1.*temp_im2))/(pcorr1*pcorr2);        
                end
                if corr >= maxCorr
                    overlap=x_loc;
                    maxX=width-x_loc;
                    maxY=loc1-loc2;
                    max_loc1=loc1; max_loc2=loc2;
                    maxCorr=corr;
                end
            end
  
        end
 

      binImage1=imbinarize(temp_image1,level1);
      binImage2= imbinarize(temp_image2,level2);
      
      if max_loc1 > max_loc2
          temp_im1=binImage1(max_loc1-max_loc2+1:height,ov-overlap+1:ov);
          temp_im2=binImage2(1:max_loc2+height-max_loc1,1:overlap);
      else
          temp_im1=binImage1(1:max_loc1+height-max_loc2,ov-overlap+1:ov);
          temp_im2=binImage2(max_loc2-max_loc1+1:height,1:overlap);
      end
      Label1=bwlabel(temp_im1);
      Label2=bwlabel(temp_im2);
      
      if sum(sum(temp_im1)) > sum(sum(temp_im2))
          percentage=sum(sum(temp_im1.*temp_im2))/sum(sum(temp_im1));
      else
          percentage=sum(sum(temp_im1.*temp_im2))/sum(sum(temp_im2));
      end
      
      if percentage < 0.4 
          r_x=width;
          r_y=0;
          maxCorr=-1;
      else
          r_x=maxX;
          r_y=maxY;
      end
        
        
end
end
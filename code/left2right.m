function [r_x, r_y, maxCorr]=left2right(l_image1, l_image2, uncertainty, Overlap,max_fnum)
%FInd overlapping area using Normalized cross correlation
height=size(l_image1,1);
width =size(l_image1,2);
ov_s=ceil(max(1,width*Overlap-width*uncertainty*0.01));
ov= ceil(width*Overlap+width*uncertainty*0.01); %Maximum overlap(pixel) in horizontal direction
if max_fnum==2
    ov_y = 20; %Maximum overlap(pixel) in vertical direction
elseif max_fnum==3
    ov_y =5; %Maximum overlap(pixel) in vertical direction
end

%Cut only neccessary part of the image
temp_image1 = l_image1(:,width-(ov-1):width);
temp_image2 = l_image2(:,1:ov);

%Tumor cell ditections : Figure threshold value of each image and detect whether it contains cell 
level1=triangle_th(l_image1);
level2=triangle_th(l_image2);
[Label1, Label2, condition]=checkBlack(temp_image1, temp_image2,level1,level2);
clear l_image1; clear l_image2;


%Translation estimation : using normalized cross correlation
switch condition
    case -1
         maxCorr=-1;maxX=width;maxY=0;
          for x_loc=ov_s:size(temp_image1,2)
            loc2=1;
            for loc1=-ov_y:ov_y
                if loc1 < loc2
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
                    maxX=width-x_loc;
                    maxY=loc1-loc2;
                    r_x=maxX;
                    r_y=maxY;
                    maxCorr=corr;
                end
            end
         end
         maxCorr=maxCorr-2;
    case 1
        %%Find closest area
        [r1, c1] = find(Label1~=0); %r is 'y', c is 'x'
        [r2, c2] = find(Label2~=0);
        start=ov-max(max(c1))+min(min(c2))-min(ov-max(max(c1)),min(min(c2)));
        start=ceil(start);
        maxCorr=-1;maxX=width;maxY=0;
        max_loc1=1;max_loc2=1;
        
        if start > size(temp_image1,2)
            start=size(temp_image1,2);
        end
        if start < ov_s
            start=ov_s;
        end
        overlap=start;
        for x_loc=start:size(temp_image1,2)
            loc2=1;
            for loc1=-ov_y:ov_y
                if loc1 < loc2
                    [~, ~, condition]=checkBlack(temp_image1(1:loc1+height-loc2,ov-x_loc+1:ov), temp_image2(loc2-loc1+1:height,1:x_loc),level1,level2);
                else
                    [~, ~, condition]=checkBlack(temp_image1(loc1-loc2+1:height,ov-x_loc+1:ov), temp_image2(1:loc2+height-loc1,1:x_loc),level1,level2);
                end
                if condition==-1
                    corr=-2;
                    continue;
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
        binImage1 = bwmorph(binImage1,'clean');
        binImage1= bwareaopen(binImage1, 4);
        binImage2= imbinarize(temp_image2,level2);
        binImage2 = bwmorph(binImage2,'clean');
        binImage2= bwareaopen(binImage2, 4);
        
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
            r_x=maxX;
            r_y=maxY;
            maxCorr=-1+maxCorr;
        else
            r_x=maxX;
            r_y=maxY;
        end
        
end


end
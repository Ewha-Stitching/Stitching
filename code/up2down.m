function [r_x, r_y, maxCorr]=up2down(u_image1, u_image2 ,uncertainty, Overlap,max_fnum)
%FInd overlapping area using Normalized cross correlation
height=size(u_image1,1);
width =size(u_image1,2);
ov_s=ceil(max(1,height*Overlap-height*uncertainty*0.01));
ov= ceil(height*Overlap+height*uncertainty*0.01); %Maximum overlap(pixel) in vertical direction
if max_fnum==2
    ov_x =20; %Maximum overlap(pixel) in horizontal direction
elseif max_fnum==3
   ov_x =5; %Maximum overlap(pixel) in horizontal direction
end


%Cut only neccessary part of the image
temp_image1 = u_image1(height-(ov-1):height,:);
temp_image2 = u_image2(1:ov,:);

%Tumor cell ditections : Figure threshold value of each image and detect whether it contains cell 
level1=triangle_th(u_image1);
level2=triangle_th(u_image2);
[Label1, Label2, condition]=checkBlack(temp_image1, temp_image2, level1,level2);
clear l_image1; clear l_image2;


%%%%%%%%%%%%%%%%%%%%%%
switch condition
    case -1
        maxCorr=-1; maxY=height;maxX=0;
        for y_loc=ov_s:size(temp_image1,1)
            loc2=1;
            for loc1=-ov_x:ov_x
                if loc1 < loc2
                    temp_im1=temp_image1(ov-y_loc+1:ov,1:loc1+width-loc2);% is this right?
                    temp_im2=temp_image2(1:y_loc,loc2-loc1+1:width);

                else
                    temp_im1=temp_image1(ov-y_loc+1:ov,loc1-loc2+1:width);% is this right?
                    temp_im2=temp_image2(1:y_loc,1:loc2+width-loc1);
                end
                mean_im1=mean2(temp_im1);mean_im2=mean2(temp_im2);
                t_im1=temp_im1-mean_im1>0; t_im2=temp_im2-mean_im2>0;
                temp_im1=double(temp_im1).*t_im1;temp_im2=double(temp_im2).*t_im2;
                pcorr1=sqrt(sum(sum(temp_im1.^2)));pcorr2=sqrt(sum(sum(temp_im2.^2)));
                cor=sum(sum(temp_im1.*temp_im2))/(pcorr1*pcorr2);
                if cor >= maxCorr
                    maxY=height-y_loc;
                    maxX= loc1-loc2;
                    r_x=maxX;
                    r_y=maxY;
                    maxCorr=cor;
                end
            end
        end
        maxCorr=maxCorr-2;
    case 1
        
        [r1, c1] = find(Label1~=0);
        [r2, c2] = find(Label2~=0);
        
        start=ov-max(max(r1))+min(min(r2))-min(ov-max(max(r1)),min(min(r2)))/2;
        start=ceil(start);
        maxCorr=-1;maxY=height;maxX=0;max_loc1=1; max_loc2=1;
        
        if start>size(temp_image1,1)
            start=size(temp_image1,1);
        end
        if start< ov_s
            start=ov_s;
        end
        
        overlap=start;
        %Translation estimation : using normalized cross correlation
        for y_loc=start:size(temp_image1,1)
            loc2=1;
            for loc1=-ov_x:ov_x
                if loc1 < loc2
                    [~, ~, condition]=checkBlack(temp_image1(ov-y_loc+1:ov,1:loc1+width-loc2), temp_image2(1:y_loc,loc2-loc1+1:width), level1,level2);
                else
                    [~, ~, condition]=checkBlack(temp_image1(ov-y_loc+1:ov,loc1-loc2+1:width), temp_image2(1:y_loc,1:loc2+width-loc1), level1,level2);
                end
                
                if condition==-1
                    cor=-2;
                    continue;
                elseif loc1 < loc2
                    temp_im1=temp_image1(ov-y_loc+1:ov,1:loc1+width-loc2);% is this right?
                    temp_im2=temp_image2(1:y_loc,loc2-loc1+1:width);
                else
                    temp_im1=temp_image1(ov-y_loc+1:ov,loc1-loc2+1:width);% is this right?
                    temp_im2=temp_image2(1:y_loc,1:loc2+width-loc1);
                end
                mean_im1=mean2(temp_im1);mean_im2=mean2(temp_im2);
                t_im1=temp_im1-mean_im1>0; t_im2=temp_im2-mean_im2>0;
                temp_im1=double(temp_im1).*t_im1;temp_im2=double(temp_im2).*t_im2;
                pcorr1=sqrt(sum(sum(temp_im1.^2)));pcorr2=sqrt(sum(sum(temp_im2.^2)));
                cor=sum(sum(temp_im1.*temp_im2))/(pcorr1*pcorr2);
                if cor >= maxCorr
                    overlap=y_loc;
                    maxY=height-y_loc;
                    
                    maxX= loc1-loc2;
                    max_loc1=loc1; max_loc2=loc2;
                    maxCorr=cor;
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
            temp_im1=binImage1(ov-overlap+1:ov,max_loc1:width);
            temp_im2=binImage2(1:overlap,max_loc2:max_loc2+width-max_loc1);
        else
            temp_im1=binImage1(ov-overlap+1:ov,1:max_loc1+width-max_loc2);
            temp_im2=binImage2(1:overlap,max_loc2-max_loc1+1:width);
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


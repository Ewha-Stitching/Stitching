function [level] = triangle_th(image)

% Zack, G. W., Rogers, W. E. and Latt, S. A., 1977,
% Automatic Measurement of Sister Chromatid Exchange Frequency,
% Journal of Histochemistry and Cytochemistry 25 (7), pp. 741-753
%  modified from Johannes Schindelin plugin


% find min and max
%data is histogram of the image
nbins= 65536;
[data x]=imhist(image, nbins);

min = 0;dmax=0;max = 0; min2=0;

for i = 1:size(data,1)  
    if (data(i)>0)
        min=i;
        break;    
    end  
end

if (min>1)
    min=min-1; %line to the (p==0) point, not to data(min)
end


% The Triangle algorithm cannot tell whether the data is skewed to one side or another.
% This causes a problem as there are 2 possible thresholds between the max and the 2 extremes
% of the histogram.
% Here I propose to find out to which side of the max point the data is furthest, and use that as
%  the other extreme.

for i = nbins:-1:1
    if (data(i)>0)
        try
            if sum(data(i-10:i))>5
                min2=i;
                break;
            end
        catch
            if sum(data(1:i))>i
                min2=i;
                break;
            end
        end
          
    end  
end

if (min2<nbins)
    min2=min2+1; % line to the (p==0) point, not to data(min)
end


for i =1:nbins
    if (data(i) > dmax)
        max=i;
        dmax=data(i);
    end
end

% find which is the furthest side
%IJ.log(""+min+" "+max+" "+min2);

inverted = false;

if ((max-min)<(min2-max))
    % reverse the histogram
    %IJ.log("Reversing histogram.");
    inverted = true;
    left  = 1;          % index of leftmost element
    right = nbins;% index of rightmost element
    
    while (left < right)
        % exchange the left and right elements
        temp = data(left);
        data(left)  = data(right);    
        data(right) = temp;
        
        % move the bounds toward the center 
        left=left+1;
        right=right-1;  
    end
    
    min=nbins-min2;
    max=nbins-max; 
end



if (min == max)
    %IJ.log("Triangle:  min == max.");
    level= min/(nbins);
    %%%Stop running. Finish at this point
else    
    % describe line by nx * x + ny * y - d = 0
    % nx is just the max frequency as the other point has freq=0
    nx = data(max);  %-min; % data(min); % lowest value bmin = (p=0)% in the image
    ny = min - max;
    d = sqrt(nx * nx + ny * ny); 
    nx = nx/d; 
    ny = ny/d;
    d = nx * min + ny * data(min);
    
    
    
    % find split point
    split = min;
    splitDistance = 0;
    for i = min + 1: max
        newDistance = nx * i + ny * data(i) - d;
        if (newDistance > splitDistance)
            split = i;
            splitDistance = newDistance;
        end
    end
    split=split-1;
    
    if (inverted)
        % The histogram might be used for something else, so let's reverse it back
        left  =1;
        right = (nbins);
        
        while (left < right)  
            temp = data(left);
            data(left)  = data(right);
            data(right) = temp;
 
            left=left+1; 
            right=right-1;     
        end
        
        level=(nbins-split)/(nbins);   
    else
        level= split/(nbins);
    end
end

%%%%%%%Adding offset%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%average background within 6 pixels around object
 binImage1=imbinarize(image,level);
[object_y, object_x]=find(binImage1==1);
% neighbor_x=zeros(size(object_x,1)*4,1);
% neighbor_y=zeros(size(object_x,1)*4,1);
% 
% neighbor_x(1:size(object_x,1))=object_x-1;
% neighbor_y(1:size(object_x,1))=object_y;
% 
% neighbor_x(size(object_x,1)+1:size(object_x,1)*2)=object_x+1;
% neighbor_y(size(object_x,1)+1:size(object_x,1)*2)=object_y;
% 
% neighbor_x(size(object_x,1)*2+1:size(object_x,1)*3)=object_x;
% neighbor_y(size(object_x,1)*2+1:size(object_x,1)*3)=object_y-1;
% 
% neighbor_x(size(object_x,1)*3+1:size(object_x,1)*4)=object_x;
% neighbor_y(size(object_x,1)*3+1:size(object_x,1)*4)=object_y+1;


SE = strel('square',3);
BW2 = imdilate( binImage1, SE);
BW2=BW2-binImage1;
[neighbor_y, neighbor_x]=find(BW2==1);
delete_idx=find(neighbor_x <= 0 | neighbor_x > size(binImage1,2));

neighbor_x(delete_idx)=[];
neighbor_y(delete_idx)=[];

delete_idx=find(neighbor_y <= 0 | neighbor_y > size(binImage1,1));

neighbor_x(delete_idx)=[];
neighbor_y(delete_idx)=[];

delete_idx=find(ismember(neighbor_x,object_x)+ismember(neighbor_y,object_y)==2);

neighbor_x(delete_idx)=[];
neighbor_y(delete_idx)=[];


avg_background=sum(sum(image(neighbor_y,neighbor_x)))/size(neighbor_x,1);

end


function [Label1, Label2, condition]=checkBlack(cimage1, cimage2,level1,level2)
%Check whether the given image contains objects or not
% Output : condition
%% condition -1 : Object is not detected in Image1&2
%% condition 1 : Object is detected in Image1&2
binImage1=imbinarize(cimage1,level1);
binImage1 = bwmorph(binImage1,'clean');
binImage1= bwareaopen(binImage1, 4);
binImage2= imbinarize(cimage2,level2);
binImage2 = bwmorph(binImage2,'clean');
binImage2 = bwareaopen(binImage2, 4);

Label1=bwlabel(binImage1);
Label2=bwlabel(binImage2);


if min(min(Label1))==max(max(Label1)) || min(min(Label2))==max(max(Label2))
    condition=-1; 
else
    condition=1;
end

end
      


function output_image = localContrastEnhancement(input_image)
sigma=30;

%Step 1 : Detect transitions and create Local constrast Mask
LocalContrastMask=zeros(size(input_image));
LocalContrastMask=double(LocalContrastMask)-double(input_image)-double(imgaussfilt(input_image,sigma));

%Step 2: Use Mask to Increase Contrast at Transitions
output_image=imadjust(input_image,[double(min(min(input_image)))/65535 double(max(max(input_image)))/65535],[double(min(min(input_image)))/65535 double(max(max(input_image)))/65535*2]);

output_image=uint16(double(output_image) + LocalContrastMask) ;

end


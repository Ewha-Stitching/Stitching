function [minCorr]=findminCorr(num,location,center_f)
%Reterns minimum correlation of connection path to center field
temp=num; 
minCorr=location(num,3);
while location(temp, 4)~=center_f
    if minCorr > location(temp,3)
        minCorr=location(temp,3);  
    end
    temp=location(temp,4);
end
end

function location=decideField(num, preNum1, preNum2,location,paths_f, center_f)
%Decide connection of diagonal(to the center) field image in optimal way

idx1=find(paths_f(:,1)==num & paths_f(:,2)==preNum1);
if (isempty(idx1))
    idx1=find(paths_f(:,1)==preNum1 & paths_f(:,2)==num);
end
idx2=find(paths_f(:,1)==num & paths_f(:,2)==preNum2);
if (isempty(idx2))
    idx2=find(paths_f(:,1)==preNum2 & paths_f(:,2)==num);
end

result_x1=paths_f(idx1,3);
result_y1=paths_f(idx1,4);
Corr1=paths_f(idx1,5);
result_x2=paths_f(idx2,3);
result_y2=paths_f(idx2,4);
Corr2=paths_f(idx2,5);

if min(Corr1, findminCorr(preNum1,location,center_f)) > min(Corr2, findminCorr(preNum2,location,center_f))
    location(num, :)=[result_x1, result_y1, Corr1, preNum1];
    if Corr2 > -1 && findminCorr(preNum2,location,center_f) < min(Corr2, min(Corr1, findminCorr(preNum1,location,center_f)))
        location(preNum2, :)=[result_x2, result_y2, Corr2, num];
    end
    if Corr2 > -1 && location(preNum2,3) <= -1
        location(preNum2, :)=[result_x2, result_y2, Corr2, num];
    end
elseif min(Corr1, findminCorr(preNum1,location,center_f)) < min(Corr2, findminCorr(preNum2,location,center_f))
    location(num, :)=[result_x2, result_y2, Corr2, preNum2];
    if Corr1 > -1 && findminCorr(preNum1,location,center_f) < min(Corr1, min(Corr2, findminCorr(preNum2,location,center_f)))
        location(preNum1, :)=[result_x1, result_y1, Corr1, num];
    end
    if Corr1 > -1 && location(preNum1,3) <= -1
        location(preNum1, :)=[result_x1, result_y1, Corr1, num];
    end
else
    if Corr1 >= Corr2
        location(num, :)=[result_x1, result_y1,Corr1, preNum1];
        if Corr2 > -1 && findminCorr(preNum2,location,center_f) < min(Corr2, min(Corr1, findminCorr(preNum1,location,center_f)))
            location(preNum2, :)=[result_x2, result_y2, Corr2, num];
        end
        if Corr2 > -1 && location(preNum2,3) <= -1
            location(preNum2, :)=[result_x2, result_y2, Corr2, num];
        end
    else
        location(num, :)=[result_x2, result_y2, Corr2, preNum2];
        if Corr1 > -800 && min(min(Corr2,findminCorr(preNum2,location,center_f)), Corr1) > findminCorr(preNum1,location,center_f)
            location(preNum1, :)=[result_x1, result_y1, Corr1, num];
        end
        if Corr1 > -1 && location(preNum1,3) <= -1
            location(preNum1, :)=[result_x1, result_y1, Corr1, num];
        end
    end
end
end
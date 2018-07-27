function [location,list_path] = optimizedPath(field, location, paths_f, f_Order, list_path)
row_size =size(f_Order,1);
col_size =size(f_Order,2);
Current_row = floor((field-1)/col_size)+1;
Current_col = field-floor((field-1)/col_size)*col_size;

if (Current_col - 1 > 0 && sum(location(field-1,:)) == 0)
    idx=find(paths_f(:,1)==field-1 & paths_f(:,2)==field);
    loc_x=paths_f(idx, 3);
    loc_y=paths_f(idx, 4);
    Corr=paths_f(idx, 5);
    location(field-1,:)=[loc_x, loc_y, Corr,field];
end

if (Current_col + 1 <= size(f_Order, 2)&& sum(location(field+1,:)) == 0)
    idx=find(paths_f(:,1)==field & paths_f(:,2)==field+1);
    loc_x=paths_f(idx, 3);
    loc_y=paths_f(idx, 4);
    Corr=paths_f(idx, 5);
    location(field+1,:)=[loc_x,loc_y, Corr, field];
end

if (Current_row - 1 > 0&& sum(location(field-col_size,:)) == 0)
    idx=find(paths_f(:,1)==field-col_size & paths_f(:,2)==field);
    loc_x=paths_f(idx, 3);
    loc_y=paths_f(idx, 4);
    Corr=paths_f(idx, 5);
    location(field-col_size,:)=[loc_x, loc_y, Corr,field];
end

if (Current_row + 1 <= size(f_Order,1)&& sum(location(field+col_size,:)) == 0)
    idx=find(paths_f(:,1)==field & paths_f(:,2)==field+col_size);
    loc_x=paths_f(idx, 3);
    loc_y=paths_f(idx, 4);
    Corr=paths_f(idx, 5);
    location(field+col_size,:)=[loc_x, loc_y, Corr,field];
end

center_f=ceil(col_size/2)+(ceil(row_size/2)-1)*col_size;
%Diagonal 
if (Current_col - 1 > 0 )
    if (Current_row - 1 > 0)
        num=  (Current_col-1)+col_size*(Current_row-2);
        preNum1= num+1;
        preNum2 = num+ col_size;
        location=decideField(num, preNum1, preNum2,location,paths_f, center_f);
    end
    
    if (Current_row + 1 <= size(f_Order,1))
        num=  (Current_col-1)+col_size*(Current_row);
        preNum1= num+1;
        preNum2 = num - col_size;
        location=decideField(num, preNum1, preNum2,location,paths_f, center_f);
    end
end

if (Current_col + 1 <= size(f_Order, 2))
    if (Current_row - 1 > 0)
        num=  (Current_col+1)+col_size*(Current_row-2);
        preNum1= num-1;
        preNum2 = num + col_size;
        location=decideField(num, preNum1, preNum2,location,paths_f, center_f);
        
    end
    
    if (Current_row + 1 <= size(f_Order,1))
        num=  (Current_col+1)+col_size*(Current_row);
        preNum1= num-1;
        preNum2 = num - col_size;
        location=decideField(num, preNum1, preNum2,location,paths_f, center_f);
    end
end

%recursive
if (Current_col - 1 > 0 )
    newfield =(Current_col-1)+col_size*(Current_row-2);
    if (Current_row - 1 > 0 && any(list_path,newfield))
        list_path=[list_path, newfield];
        [location,list_path] = optimizedPath(newfield, location, paths_f, f_Order, list_path);
    end
    newfield=(Current_col-1)+col_size*(Current_row);
    if (Current_row + 1 <= size(f_Order,1)&& any(list_path,newfield))
        list_path=[list_path, newfield];
        [location,list_path] = optimizedPath(newfield, location, paths_f, f_Order, list_path);
    end
end

if (Current_col + 1 <= size(f_Order, 2))
    newfield=(Current_col+1)+col_size*(Current_row-2);
    if (Current_row - 1 > 0&& any(list_path,newfield))
        list_path=[list_path, newfield];
        [location,list_path] = optimizedPath(newfield, location, paths_f, f_Order, list_path);
    end
    newfield=(Current_col+1)+col_size*(Current_row);
    if (Current_row + 1 <= size(f_Order,1)&& any(list_path,newfield))
        list_path=[list_path, newfield];
        [location,list_path] = optimizedPath(newfield, location, paths_f, f_Order, list_path);
    end
end

end


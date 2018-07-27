function location = recursiveStitch(field, image,location,  f_Order,MaxOverlap)

col_size =size(f_Order,2);
Current_row = floor((field-1)/col_size)+1;
Current_col = field-floor((field-1)/col_size)*col_size);

if (Current_col - 1 > 0 )
    location(field-1,:)=[result_x, result_y, Corr,field];
end

if (Current_col + 1 <= size(f_Order, 2))
    location(field+1,:)=[result_x, result_y, Corr, field];
end

if (Current_row - 1 > 0)
    location(field-3,:)=[result_x, result_y, Corr,field];
end

if (Current_row + 1 <= size(f_Order,1))
    location(field+3,:)=[result_x, result_y, Corr,field];
end

%Diagonal 
if (Current_col - 1 > 0 )
    if (Current_row - 1 > 0)
        location = recursiveStitch((Current_col-1)+col_size*(Current_row-1), image,location,  f_Order,MaxOverlap);
    end
    
    if (Current_row + 1 <= size(f_Order,1))
        location = recursiveStitch((Current_col-1)+col_size*(Current_row+1), image,location,  f_Order,MaxOverlap);
    end
end

if (Current_col + 1 <= size(f_Order, 2))
    if (Current_row - 1 > 0)
        location = recursiveStitch((Current_col+1)+col_size*(Current_row-1), image,location,  f_Order,MaxOverlap);
        
    end
    
    if (Current_row + 1 <= size(f_Order,1))
        location = recursiveStitch((Current_col+1)+col_size*(Current_row+1), image,location,  f_Order,MaxOverlap);
    end
end

end


function [location] = optimized_Path(location, paths_f, f_Order)

paths_f(paths_f(:,1)==0,:)=[];
groups=cell(size(paths_f,1),1);
group_labels=zeros(numel(f_Order),1);
connection_true=zeros(size(paths_f,1),1);

%Connect image to any neighbor image that has maximum correlation
numb=1;
for i=1:numel(f_Order)
    idx=find(or(paths_f(:,1)==i,paths_f(:,2)==i));
    [~,idx_idx]=max(paths_f(idx,5));
    idx2=idx(idx_idx);
    connection_true(idx2)=1;
    pair=paths_f(idx2,1:2);
    if (group_labels( pair(1))==0) && (group_labels(pair(2))==0)
        groups{numb}=pair;
        group_labels(pair(1))=numb;
        group_labels(pair(2))=numb;
        numb=numb+1;
    elseif ((group_labels(pair(1))~=0) && (group_labels(pair(2))==0)) % One has label and one has not
         groups{group_labels(pair(1))}=[groups{group_labels(pair(1))}, pair(2)];
          group_labels(pair(2))=group_labels(pair(1));
    elseif ((group_labels(pair(1))==0) && (group_labels(pair(2))~=0))
        groups{group_labels(pair(2))}=[groups{group_labels(pair(2))}, pair(1)];
         group_labels(pair(1))=group_labels(pair(2));
    else
        if group_labels(pair(1)) < group_labels(pair(2))
            groups{group_labels(pair(1))}=[groups{group_labels(pair(1))}, groups{group_labels(pair(2))}];
             groups{group_labels(pair(2))}=[];
            group_labels(group_labels==group_labels(pair(2)))=group_labels(pair(1));
            
        elseif group_labels(pair(1)) > group_labels(pair(2))
            groups{group_labels(pair(2))}=[groups{group_labels(pair(2))}, groups{group_labels(pair(1))}];
             groups{group_labels(pair(1))}=[];
            group_labels(group_labels==group_labels(pair(1)))=group_labels(pair(2));
           
        end
    end
end

%Remove groups one-by-one by connecting groups together
numb=max(group_labels);
for i= numb:-1:1
    if i==1
        break;
    end
    
    if isempty(groups{i})
        continue;
    end
    %Find all links that are still not connected
    group_members=groups{i};
    idx=find(sum(ismember(paths_f(:,1:2),group_members),2)==1);
    [~,idx_idx]=max(paths_f(idx,5));
    idx2=idx(idx_idx);
    connection_true(idx2)=1;
    pair=paths_f(idx2,1:2);
    
    if group_labels(pair(1)) < group_labels(pair(2))
        groups{group_labels(pair(1))}=[groups{group_labels(pair(1))}, groups{group_labels(pair(2))}];
         groups(group_labels(pair(2)))=[];
        group_labels(group_labels==group_labels(pair(2)))=group_labels(pair(1));
    elseif group_labels(pair(1)) > group_labels(pair(2))
        groups{group_labels(pair(2))}=[groups{group_labels(pair(2))}, groups{group_labels(pair(1))}];
         groups(group_labels(pair(1)))=[];
        group_labels(group_labels==group_labels(pair(1)))=group_labels(pair(2));
    end
end


location(1,:)=[1, 1, 0,0];
numb=1;
while any(location(2:end,4)==0)
    next_numb=[];
    for i=1:numel(numb)
        idx=find(and(any(paths_f(:,1:2)==numb(i),2),connection_true));
        
        for j=1:numel(idx)
            field_numb=paths_f(idx(j),1:2);
            field_numb(field_numb==numb(i))=[];
            if location(field_numb,4)~=0 || field_numb==1
                continue;
            end
            if field_numb==paths_f(idx(j),2)
                location(field_numb,:)=[paths_f(idx(j),3), paths_f(idx(j),4), paths_f(idx(j),5),numb(i)];
            else
                location(field_numb,:)=[-paths_f(idx(j),3), -paths_f(idx(j),4), paths_f(idx(j),5),numb(i)];
            end
            next_numb=[next_numb;field_numb];
        end
    end
    numb=next_numb;
end


end


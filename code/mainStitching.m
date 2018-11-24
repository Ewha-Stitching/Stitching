function fin_loc=mainStitching( Nrow, Ncol ,Overlap, uncertainty, f_Order, denoise_option)

global location;
fprintf('Stitch image r%dc%d\n',Nrow,Ncol);


%Preprocessing : Load field images & Denoising
 f_num= numel(f_Order);%number of field images 
if (f_num ==0)
    error('ERROR : The order of field images is needed');
end

if f_num < 10
    max_fnum=2;
elseif f_num >= 100
    max_fnum=3;
end
image=cell(f_num,1);
row_size = size(f_Order, 1);
col_size =size(f_Order,2);
for i=1:f_num
    image{i}=loadImage(Nrow, Ncol,f_Order(floor((i-1)/col_size)+1,i-floor((i-1)/col_size)*col_size),max_fnum, denoise_option);
end

%field image's height and width
height=size(image{1},1);
width =size(image{1},2);

%Location : [ x, y, correlation, connected Field#]
%FIn_loc : final location [x,y] of field images
paths_f = zeros(f_num*2,5);
location=zeros(f_num,4);
fin_loc=zeros(f_num,2);

%Find Overlapping area between center field and it's neighboring fields
%%In horizontal direction

for field= 1: f_num
    Current_row = floor((field-1)/col_size)+1;
    Current_col = field-floor((field-1)/col_size)*col_size;
    if (Current_col + 1 <= size(f_Order, 2))
        fprintf('field : %d field+1:%d\n',field,field+1);
        [result_x, result_y, Corr]=left2right(image{field}, image{field+1},uncertainty, Overlap,max_fnum);
        paths_f(2*field-1,:)=[field, field+1, result_x, result_y, Corr];
    end
    
    if (Current_row + 1 <= size(f_Order,1))
        [result_x, result_y, Corr]=up2down(image{field},image{field+3},uncertainty,Overlap,max_fnum);
         paths_f(2*field,:)=[field, field+col_size, result_x, result_y, Corr];
    end
    
end
paths_f(paths_f(1,:)==0,:)=[];
[location] = optimized_Path(location, paths_f, f_Order);

%calculate Global location of each fields
for n=1:f_num
    for num=1:f_num
        pre_num=location(num,4);
        if pre_num >0
            fin_loc(num,1)=fin_loc(pre_num,1)+location(num,1);
            fin_loc(num,2)=fin_loc(pre_num,2)+location(num,2);
        end
    end
    
end


%Shift field images
min_x=0; min_y=0;
for num=1:f_num
    if min_x > fin_loc(num,1)
        min_x=fin_loc(num,1);
    end
    if min_y > fin_loc(num,2)
        min_y=fin_loc(num,2);
    end
end
for num=1:f_num
    fin_loc(num,1)= fin_loc(num,1)-min_x;
    fin_loc(num,2)=fin_loc(num,2)-min_y;
end


%OUTPUT : stitched image
total_image=zeros(height*size(f_Order,1)+20,width*size(f_Order,2)+45);
total_image=uint16(total_image);
if Nrow < 10 && Ncol < 10
    title=strcat('r0',num2str(Nrow),'c0',num2str(Ncol),'.tiff');
elseif Nrow < 10 && 9 < Ncol
    title=strcat('r0',num2str(Nrow),'c',num2str(Ncol),'.tiff');
elseif Nrow > 9 && Ncol < 10
    title=strcat('r',num2str(Nrow),'c0',num2str(Ncol),'.tiff');
else
    title=strcat('r',num2str(Nrow),'c',num2str(Ncol),'.tiff');
end

for i=1:f_num
    field=f_Order(floor((i-1)/col_size)+1,i-floor((i-1)/col_size)*col_size);
    if max_fnum==2
        image=imread(['../input/',strcat('r',sprintf('%02d',Nrow),'c',sprintf('%02d',Ncol),'f',sprintf('%02d',field),'.tiff')]);
    elseif max_fnum==3
        image=imread(['../input/',strcat('r',sprintf('%02d',Nrow),'c',sprintf('%02d',Ncol),'f',sprintf('%03d',field),'.tiff')]);
    end
    first_y=fin_loc(i,2);first_x=fin_loc(i,1);
    fprintf('Numb %d : First_x %d First_y %d\n',i, first_x,first_y);
    total_image(first_y + 1:first_y +height ,first_x+1:first_x+width)=max(total_image(first_y + 1:first_y +height ,first_x+1:first_x+width),image(:,:));
end

imwrite(total_image,['../result/',title]);
clear image; clear total_image;



end



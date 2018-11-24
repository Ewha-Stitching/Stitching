%Demo
close all; clear all; clc;


row_array=[2];%
col_array=[1]; %
for seq=1:1%numel(row_array)
    
    %Input image's row number, column number
    Nrow = row_array(seq);
    Ncol = col_array(seq);
    
    Overlap = 0.1;% Overlap : 0~1
    uncertainty =2;%uncertainty : 0~ 100%
    denoise_option =0; 
    f_Order = zeros(20,20);
    seq=1;
    for i=1:20
        for j=1:20
            f_Order(i,j)=seq;
            seq=seq+1;
        end
    end
    %Stitch
    tic
    fin_loc=mainStitching(Nrow, Ncol, Overlap, uncertainty, f_Order, denoise_option);
    toc    
end



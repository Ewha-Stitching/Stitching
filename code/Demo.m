%Demo
close all; clear all; clc;


row_array=[2];%
col_array=[6]; %
for seq=1:1%numel(row_array)
    
    %Input image's row number, column number
    Nrow = row_array(seq);
    Ncol = col_array(seq);
    
    Overlap = 0.01;% Overlap : 0~1
    uncertainty =1;%uncertainty : 0~ 100%
    denoise_option =1;%Denoising option. 0:No denoising, 1:Denoising 
    %Order of field images in Grid form
    %  ___________
    % | 1 | 2 | 3 |
    % | 4 | 5 | 6 |
    % | 7 | 8 | 9 |
    %  -----------
    f_Order = [1 2 3;4 5 6;7 8 9];
    
    %Stitch
    tic
    fin_loc=mainStitching(Nrow, Ncol, Overlap, uncertainty, f_Order,denoise_option);
    toc    
end




 
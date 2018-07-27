%Demo
close all; clear all; clc;

%Input image's row number, column number 
%Image field is total 9
Nrow = 15;
Ncol = 23;

%Maximum Overlap(%) between neighboring images
MaxOverlap = 0.025;
%Order of field images in Grid form
%  ___________
% | 2 | 3 | 4 |
% | 6 | 1 | 5 |
% | 7 | 8 | 9 |
%  -----------
f_Order = [2 3 4;6 1 5;7 8 9];

%Stitch
mainStitching(Nrow, Ncol, MaxOverlap, f_Order);



 
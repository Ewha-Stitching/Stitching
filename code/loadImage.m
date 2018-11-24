function image = loadImage( Nrow, Ncol,fnum ,max_fnum, denoise_option)
%Load, and then denoise the image using anisotropic diffusion
%INPUT%%%%%%%
%%Nrow : row number of the image
%%Ncol : column number of the image
%%fnum : field number of the image
%The anisotropic diffusion might be uncerssary when input image is clear
%Load image
if max_fnum==2
    image=imread(['../input/',strcat('r',sprintf('%02d',Nrow),'c',sprintf('%02d',Ncol),'f',sprintf('%02d',fnum),'.tiff')]);
elseif max_fnum==3
    image=imread(['../input/',strcat('r',sprintf('%02d',Nrow),'c',sprintf('%02d',Ncol),'f',sprintf('%03d',fnum),'.tiff')]);
elseif max_fnum==4
    image=imread(['../input/',strcat('r',sprintf('%02d',Nrow),'c',sprintf('%02d',Ncol),'f',sprintf('%04d',fnum),'.tiff')]);
end

if denoise_option==1
    image=double(image);
    kappa=10;
    image = anisodiff2D(image, 5, 1/7, kappa,2);
    image = anisodiff2D(image,3, 1/7, kappa, 1);
    image = localContrastEnhancement(uint16(image));
    image = anisodiff2D(double(image), 3, 1/7, kappa,2);
end

image=uint16(image);

end


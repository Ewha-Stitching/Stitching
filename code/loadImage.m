function image = loadImage( Nrow, Ncol,fnum )
%Load, and then denoise the image using anisotropic diffusion
%INPUT%%%%%%%
%%Nrow : row number of the image
%%Ncol : column number of the image
%%fnum : field number of the image

%Load image
if Nrow < 10 && Ncol < 10
    image=imread(['../input/',strcat('r0',int2str(Nrow),'c0',int2str(Ncol),'f0',int2str(fnum),'.tiff')]);
elseif Nrow >= 10 && Ncol < 10
    image=imread(['../input/',strcat('r',int2str(Nrow),'c0',int2str(Ncol),'f0',int2str(fnum),'.tiff')]);
elseif Nrow < 10 && Ncol >= 10
    image=imread(['../input/',strcat('r0',int2str(Nrow),'c',int2str(Ncol),'f0',int2str(fnum),'.tiff')]);
else
    image=imread(['../input/',strcat('r',int2str(Nrow),'c',int2str(Ncol),'f0',int2str(fnum),'.tiff')]);
end

%Anisotropic diffusion
image=anisodiff(image, 30, 20, 0.25, 2);
image=uint16(image);
 
end


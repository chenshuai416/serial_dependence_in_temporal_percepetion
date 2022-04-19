function pixs=deg2pix(degree,screenWidth,pwidth,vdist) 
% parameters: degree(visual angle), screenWidth (monitor width in cm), pwidth (width in pixels ; Resolution(1) ),
% vdist: viewing distance 

pixs = round(2*tan((degree/2)*pi/180) * vdist / screenWidth * pwidth); 
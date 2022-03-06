clear all;
close all;

img_file_name = 'baby.png';

% Read image, convert to gray, resize to fixed size.
I1 = imread(['test_images/' img_file_name]);
disp('Loaded image.');
I2=imresize(I1, 0.5, 'nearest');

%用双线性插值方法获得插值图像Y1
[Y1,~]=imresize(I2,2,'bilinear');
[psnr_bilinear, ~] = psnr(Y1, I1);
%用最近邻域插值得到邻域插值图像Y2
[Y2,map]=imresize(I2,2);
[psnr_near, ~] = psnr(Y2, I1);
[c,s]=wavedec2(Y1,2,'haar');
sizey1=size(Y1);
%从小波分解的结构[c，s]中提取Y1第一层的尺度系数和小波系数
Xa1=appcoef2(c,s,'haar',1);
Xh1=detcoef2('h',c,s,1);
Xv1=detcoef2('v',c,s,1);
Xd1=detcoef2('d',c,s,1);
ded1=[Xa1,Xh1,Xv1,Xd1];

[c,s]=wavedec2(Y1,2,'haar');
sizey2=size(Y2);
%从小波分解的结构[c，s]中提取Y2第一层的尺度系数和小波系数
Xa2=appcoef2(c,s,'haar',1);
Xh2=detcoef2('h',c,s,1);
Xv2=detcoef2('v',c,s,1);
Xd2 =detcoef2('d',c,s,1);
ded1=[Xa2,Xh2,Xv2,Xd2];
Y=idwt2(Xa2,Xh1,Xv1,Xd1,'haar');
Y = uint8(Y);
[psnr_wavelet, ~] = psnr(Y, I1);

%%%%% DISPLAY %%%%%

subplot(2, 2, 1);
imshow(I1);
title(['Original Image']);

subplot(2, 2, 2);
imshow(Y1);
title(['Bilinear Upscale' num2str(psnr_bilinear) ')']);

subplot(2, 2, 3);
imshow(Y2);
title(['Bilinear Upscale' num2str(psnr_near) ')']);

subplot(2, 2, 4);
imshow(Y);
title(['Wavelet Upscale(' num2str(psnr_wavelet) ')']);



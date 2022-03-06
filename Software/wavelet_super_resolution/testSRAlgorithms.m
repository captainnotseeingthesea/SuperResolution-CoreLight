% Runs the implemented wavelet-based SR algorithms and compares them.

img_file_name = 'lena.jpg';
scale = 2;

% Load file if not already loaded.
if ~exist('img')
    img = imread(['test_images/' img_file_name]);
    img = rgb2gray(img);
    img = imresize(img, [512, 512]);
    img = im2double(img);
    disp('Loaded image.');
end

% Generate the LR image.
img_small = imresize(img, 1.0 / scale, 'bicubic');

% Do upsampling for comparison.
img_upsampled = imresize(img_small, size(img), 'bicubic');
[psnr_upsampled, ~] = psnr(img_upsampled, img);

% Run the DSWT Super-Resolution code.
img_sr_1 = DSWTSR(img_small, scale);
disp(['Sizes: ' mat2str(size(img_sr_1)) ' vs. ' mat2str(size(img))]);
[psnr_sr_1, ~] = psnr(img_sr_1, img);

% Run the WBIRE Super-Resolution code.
img_sr_2 = WBIRE(img_small, scale);
disp(['Sizes: ' mat2str(size(img_sr_2)) ' vs. ' mat2str(size(img))]);
[psnr_sr_2, ~] = psnr(img_sr_2, img);

% Run the WBIR Super-Resolution code.
img_sr_3 = WBIR(img_small, scale);
disp(['Sizes: ' mat2str(size(img_sr_3)) ' vs. ' mat2str(size(img))]);
[psnr_sr_3, ~] = psnr(img_sr_3, img);

subplot(2, 3, 1);
imshow(img);
title('Ground Truth');

subplot(2, 3, 2);
imshow(img_small);
title('Low-Resolution Original');

subplot(2, 3, 3);
imshow(img_upsampled);
title(['Upsampled (' num2str(psnr_upsampled) ')']);

subplot(2, 3, 4);
imshow(img_sr_1);
title(['SR DSWT (' num2str(psnr_sr_1) ')']);

subplot(2, 3, 5);
imshow(img_sr_2);
title(['SR WBIRE (' num2str(psnr_sr_2) ')']);

subplot(2, 3, 6);
imshow(img_sr_3);
title(['SR WBIR (' num2str(psnr_sr_3) ')']);
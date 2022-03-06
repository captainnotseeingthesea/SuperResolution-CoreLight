function [ sr_image ] = WBIR( lr_image, scale )
%WBIR 此处显示有关此函数的摘要
%   此处显示详细说明
% Constants. Define as needed.
filter = 'haar';

% DWT of the small image.
[LL_small, LH_small, HL_small, HH_small] = dwt2(lr_image, filter);

% Upsample each DWT component.
dwt_upsampling_mode = 'bilinear';
LL_upsampled = imresize(LL_small, scale, dwt_upsampling_mode);
LH_upsampled = imresize(LH_small, scale, dwt_upsampling_mode);
HL_upsampled = imresize(HL_small, scale, dwt_upsampling_mode);
HH_upsampled = imresize(HH_small, scale, dwt_upsampling_mode);

% IDWT of the upsampled.
sr_image = idwt2(LL_upsampled, LH_upsampled, HL_upsampled, HH_upsampled, filter);

end


#ifndef __SCALE_H__
#define __SCALE_H__

#include "bmp.h"

BMPImage *bmp_downscale(BMPImage *img, uint32_t width_out, uint32_t height_out);
BMPImage *upscale_round(BMPImage *img, uint32_t width_out, uint32_t height_out);


typedef int (*ImgHandler)(void *, uint32_t, uint32_t, void *, uint32_t, uint32_t, uint32_t);

int bilinear(void *data_in, uint32_t width_in, uint32_t height_in, void *data_out, uint32_t width_out, uint32_t height_out, uint32_t num_instance);

#endif /* __SCALE_H__ */
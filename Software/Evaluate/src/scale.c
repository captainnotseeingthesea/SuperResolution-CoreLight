#include <stdio.h>
#include <math.h>
#include "bmp.h"

BMPImage *bmp_downscale(BMPImage *img, uint32_t width_out, uint32_t height_out)
{
    if (img->header.width_px < width_out || img->header.height_px < height_out) {
        printf("downscale should have smaller dimensions!\n");
        return 0;
    }

    if (!width_out || !height_out) {
        printf("?\n");
        return 0;
    }

    uint32_t w = img->header.width_px;
    uint32_t h = img->header.height_px;
    uint32_t w_o = width_out;
    uint32_t h_o = height_out;

    BMPImage *res = bmp_create(width_out, height_out);

    uint32_t num_sample_x = w / w_o; 
    uint32_t num_sample_y = h / h_o; 

    uint32_t x, y, _x, _y;
    for (y = 0; y < height_out; y++) {
        for (x = 0; x < width_out; x++) {
            uint32_t _x_base = x * w / w_o;
            uint32_t _y_base = y * h / h_o;
            uint32_t num_accum = 0;
            uint32_t ac_r = 0, ac_g = 0, ac_b = 0; //accumulated color channels
            for (_y = 0; _y < num_sample_y && _y + _y_base < h; _y++) {
                for (_x = 0; _x < num_sample_x && _x + _x_base < w; _x++) {
                    Pixel *p = bmp_pixel_at(img, _x + _x_base, _y + _y_base);
                    ac_r += p->r;
                    ac_g += p->g;
                    ac_b += p->b;
                    num_accum++;
                }
            }
            Pixel *t = bmp_pixel_at(res, x, y);
            t->r = (uint8_t)(ac_r / num_accum);
            t->g = (uint8_t)(ac_g / num_accum);
            t->b = (uint8_t)(ac_b / num_accum);
        }
    }
    return res;
}
BMPImage *upscale_round(BMPImage *img, uint32_t width_out, uint32_t height_out)
{
    if (img->header.width_px < width_out || img->header.height_px < height_out) {
        printf("downscale should have smaller dimensions!\n");
        return 0;
    }

    if (!width_out || !height_out) {
        printf("?\n");
        return 0;
    }

    uint32_t w = img->header.width_px;
    uint32_t h = img->header.height_px;
    uint32_t w_o = width_out;
    uint32_t h_o = height_out;

    BMPImage *res = bmp_create(width_out, height_out);

    uint32_t x, y;
    for (y = 0; y < height_out; y++) {
        for (x = 0; x < width_out; x++) {
            Pixel *s = bmp_pixel_at(img, x * w_o / w, y * h_o / h);
            Pixel *t = bmp_pixel_at(res, x, y);
            t->r = s->r;
            t->g = s->g;
            t->b = s->b;
        }
    }
    return res;
}


static inline uint8_t *ptr_at(void *data, uint32_t width, uint32_t height, uint32_t x, uint32_t y)
{
    if (x >= width || y >= height) { return 0; }
    return ((uint8_t *)data) + (x + y * width) * 3;
}

static inline uint8_t weighted_average(uint8_t v1, double w, uint8_t v2)
{
    return floor((1-w) * v1 + w * v2);
}

int bilinear(void *data_in, uint32_t width_in, uint32_t height_in, void *data_out, uint32_t width_out, uint32_t height_out, uint32_t num_instance)
{
    uint32_t x, y, x_in, y_in, ch;
    uint8_t *lu, *ld, *ru, *rd, *pix;
    double scale_x, scale_y;

    scale_x = width_out / (double)width_in;
    scale_y = height_out / (double)height_in;

    for (y = 0; y < height_out; y++) {
        for (x = 0; x < width_out; x++) {
            x_in = floor(x / scale_x);
            y_in = floor(y / scale_y);
            lu = ptr_at(data_in, width_in, height_in, x_in  , y_in  );
            ld = ptr_at(data_in, width_in, height_in, x_in  , y_in+1);
            ru = ptr_at(data_in, width_in, height_in, x_in+1, y_in  );
            rd = ptr_at(data_in, width_in, height_in, x_in+1, y_in+1);
            pix = ptr_at(data_out, width_out, height_out, x, y);
            for (ch = 0; ch < 3; ch++) {
                uint8_t v1 = lu && ru ? weighted_average(lu[ch], x / scale_x - x_in, ru[ch]) : lu[ch];
                uint8_t v2 = ld ? (ld && rd ? weighted_average(ld[ch], x / scale_x - x_in, rd[ch]) : ld[ch]) : 0;
                pix[ch] = lu && ld ? weighted_average(v1, y/scale_y - y_in, v2) : v1;
            }
        }
    }

    return 0;
}
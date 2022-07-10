#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "bcci.h"

char default_filename[] = "upscaled.bmp";

void usage()
{
    printf("Usage: ./upscale <filename> <ouput_width> <output_height> [<output_filename>]\n");
}

int main(int argc, char const *argv[])
{
    if (argc < 4) {
        usage();
        exit(1);
    }

    int result;
    BMPImage *img = bmp_read(argv[1]);
    BMPImage *res = bmp_create(atoi(argv[2]), atoi(argv[3]));
    bcci(img->data, img->header.width_px, img->header.height_px, res->data, res->header.width_px, res->header.height_px, 4);
    result = bmp_write(res, argc > 4 ? argv[4] : default_filename);
    if(res)
        free(res);
    return result;
}
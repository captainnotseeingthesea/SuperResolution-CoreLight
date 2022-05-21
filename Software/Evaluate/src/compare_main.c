#include <stdio.h>
#include "bmp.h"
char default_filename[] = "diff.bmp";

#define abs(a) (a < 0 ? -a : a)

void usage()
{
    printf("Usage: ./compare <filename1> <filename2> [<output_filename>]\n");
}

static int pixel_diff(Pixel *p, Pixel *a, Pixel *b)
{
    int diff = 0;
    for (size_t ch = 0; ch < 3; ch++) {
        uint8_t v = a->color[ch] > b->color[ch] ? a->color[ch] - b->color[ch] : b->color[ch] - a->color[ch];
        p->color[ch] = v < 0x10 ? v << 4 : 0xFF;
        diff = diff || v ? 1 : 0;
    }
    return diff;
}


int main(int argc, char const *argv[])
{
    if (argc < 3) {
        usage();
        return 1;
    }

    
    BMPImage *p1 = bmp_read(argv[1]);
    BMPImage *p2 = bmp_read(argv[2]);

    if (!p1 || !p2) { printf("Open file fail!\n"); return 1; }

    if (p1->header.width_px != p2->header.width_px || p1->header.height_px != p2->header.height_px) {
        printf("Dimension not match(%dX%d != %dX%d)\n", p1->header.width_px, p1->header.height_px, p2->header.width_px, p2->header.height_px);
        return 1;
    }

    int w = p1->header.width_px;
    int h = p1->header.height_px;
    BMPImage *diff = bmp_create(w, h);
    int is_diff = 0;
    
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            is_diff = pixel_diff(bmp_pixel_at(diff, x, y), bmp_pixel_at(p1, x, y), bmp_pixel_at(p2, x, y)) ? 1 : 0;
        }
    }

    printf("%s!\n", is_diff ? "Different" : "Same");

    return bmp_write(diff, argc > 3 ? argv[3] : default_filename);
}
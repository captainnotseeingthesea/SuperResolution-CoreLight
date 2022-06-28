/*
 *  bmp文件读写
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "bmp.h"

/*
 *  功能: 读取bmp格式图片
 *  参数:
 *      filename: 文件地址
 *
 *  返回: NULL失败,否则BMPImage, 用完需释放 !!
 */
BMPImage *bmp_read(const char *filename)
{
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        printf("file %s open failed!\n", filename);
        goto OPEN_FAIL;
    }

    BMPImage *img = malloc(sizeof(BMPImage));
    if (!img) {
        printf("image malloc fail!\n");
        goto IMG_MALLOC_FAIL;
    }

    fread(&img->header, 1, sizeof(BMPHeader), fp);
    if (img->header.type != 0x4D42) {
        printf("illegal bmp file %s", filename);
        goto NOT_BMP;
    }

    if (!img->header.image_size_bytes) {
        img->header.image_size_bytes = img->header.size - img->header.offset;
    }

    Pixel *pixel_data = malloc(img->header.image_size_bytes);
    if (!pixel_data) {
        printf("pixel data malloc fail!\n");
        goto PIX_MALLOC_FAIL;
    }

    rewind(fp);
    fread(pixel_data, 1, img->header.offset, fp);
    // Process from the last line of the picture
    fread(pixel_data, 1,  img->header.image_size_bytes, fp);

    // Process from the first line of the pixture
    // for(int i = 0; i < img->header.height_px; i++)
    // {
    //     fread(pixel_data + ((img->header.height_px - i - 1) * img->header.width_px), 1, img->header.width_px * (img->header.bits_per_pixel / 8), fp);
    // }
    img->data = pixel_data;


    fclose(fp);

    return img;

PIX_MALLOC_FAIL:

NOT_BMP:
    free(img);
IMG_MALLOC_FAIL:
    fclose(fp);
OPEN_FAIL:
    return NULL;
}

/*
 *  行处理模式
 *  参数:
 *      outFile: 路径
 *      width: 宽(像素)
 *      height: 高(像素)
 *      pixelBytes: 每像素字节数
 *  返回: 行处理指针,NULL失败
 */
BMP_Private *bmp_createLine(char *outFile, int width, int height, int pixelBytes, int quality)
{
    BMP_Private *bp = (BMP_Private *)calloc(1, sizeof(BMP_Private));

    bp->filename = outFile;
    bp->img = bmp_create(width, height);
    bp->rowMax = height;
    bp->rowSize = width * pixelBytes;
    bp->rw = 1;

    return bp;
}

/*
 * 写回bmp图片的一行
 *  参数:
 *      bp: 保存要写回BMP的信息
 *      rgbLine: 指向bmp中一行像素的指针
 *      line: 向下读取的行数
 *
 *  返回: 向下读取了第几行的像素
 */

int _bmp_createLine(BMP_Private *bp, unsigned char * rgbLine, int line)
{
    // 行计数
    bp->rowCount += line;
    if (bp->rowCount > bp->rowMax)
    {
        line -= bp->rowCount - bp->rowMax;
        bp->rowCount = bp->rowMax;
    }

    // 行数据扫描
    memcpy(bp->img->data + (bp->rowCount - line) * bp->img->header.width_px, rgbLine, bp->rowSize);

    // 完毕内存回收
    if (bp->rowCount == bp->rowMax)
    {
        bmp_write(bp->img, bp->filename);
        bp->filename = NULL;
    }
    return line;
}

/*
 *  读取bmp图片的一行
 *  参数:
 *      bp: 保存当前读取到的BMP信息
 *      rgbLine: 指向bmp中一行像素的指针
 *      line: 向下读取的行数
 *
 *  返回: 向下读取了第几行的像素
 */
int _bmp_getLine(BMP_Private *bp, unsigned char * rgbLine, int line)
{
     // 行计数
    bp->rowCount += line;
    if (bp->rowCount > bp->rowMax)
    {
        line -= bp->rowCount - bp->rowMax;
        bp->rowCount = bp->rowMax;
    }
    memcpy(rgbLine, bp->img->data + (bp->rowCount - line) * bp->img->header.width_px, bp->rowSize * line);

    // 完毕内存回收
    if (bp->rowCount == bp->rowMax)
    {
        bp->filename = NULL;
    }
    return line;
}

/*
 *  行处理模式
 *  参数: 
 *  inFile: 路径
*   width: 返回图片宽(像素), 不接收置NULL
*   height: 返回图片高(像素), 不接收置NULL
*   pixelBytes: 返回图片每像素的字节数, 不接收置NULL
 *  返回: 行处理指针,NULL失败
 */
BMP_Private *bmp_getline(char *inFile, int *width, int *height, int *pixelBytes)
{
    BMP_Private *bp = (BMP_Private *)calloc(1, sizeof(BMP_Private));

    bp->filename = inFile;

    BMPImage *img = bmp_read(inFile);
    if(!img)
    {
        free(bp);
        return NULL;
    }

    bp->img = img;
    bp->rowMax = bp->img->header.height_px;
    bp->rowSize = bp->img->header.width_px * bp->img->header.bits_per_pixel / 8;

    if(width)
        *width = bp->img->header.width_px;
    if(height)
        *height = bp->img->header.height_px;
    if(pixelBytes)
        *pixelBytes = bp->img->header.bits_per_pixel / 8;
    
    return bp;
}

/*
 *  按行rgb数据读、写
 *  参数:
 *      bp: 行处理指针
 *      rgbLine: 一行数据量,长度为 width * height * pixelBytes
 *      line: 要处理的行数
 *  返回:
 *      写图片时返回实际写入行数,
 *      读图片时返回实际读取行数,
 *      返回0时结束(此时系统自动回收内存)
 */
int bmp_line(BMP_Private *bp, unsigned char *rgbLine, int line)
{
    // 参数检查
    if (bp && bp->img && rgbLine && line > 0)
    {
        if (bp->rw)
            return _bmp_createLine(bp, rgbLine, line);
        else
            return _bmp_getLine(bp, rgbLine, line);
    }
    return 0;
}

/*
 *  完毕释放指针
 */
void bmp_closeLine(BMP_Private *bp)
{
    if(bp)
    {
        if(bp->filename)
        {
            bp->filename = NULL;
        }
        if(bp->img)
        {
            free(bp->img);
            bp->img = NULL;
        }
        free(bp);
    }
}

/*
 *  创建图片
 *  参数:
 *      filePath: 文件地址
 *      width: 图片横向的像素个数
 *      height: 图片纵向的像素个数
 *
 *  返回: BMPImage
 */
BMPImage *bmp_create(uint32_t width, uint32_t height) {
    BMPImage *img = malloc(sizeof(BMPImage));
    if (!img) {
        printf("img create malloc fail!\n");
        return 0;
    }
    memset(img, 0, sizeof(BMPImage));
    img->data = malloc(width * height * 3);
    if (!img->data) {
        printf("img create data malloc fail!\n");
        return 0;
    }

    BMPHeader *h = &img->header;
    h->type = 0x4D42;
    h->size = width * height * 3 + 54;
    h->offset = 54;
    h->dib_header_size = 40;
    h->width_px = width;
    h->height_px = height;
    h->num_planes = 1;
    h->bits_per_pixel = 24;
    h->compression = 0;
    h->image_size_bytes = width * height * 3;

    return img;
}

int32_t   bmp_write(BMPImage *img, const char *filename)
{
    FILE *fp = fopen(filename, "wb+");
    if (!fp) {
        printf("open/create file %s failed!\n", filename);
        return -1;
    }

    fwrite(&img->header, 1, sizeof(BMPHeader), fp);

    // Proces from the first line of the pixture
    // for(int i = 0; i < img->header.height_px; i++)
    // {
    //     fwrite((img->data + (img->header.height_px - i - 1) * img->header.width_px), 1, img->header.width_px * (img->header.bits_per_pixel / 8), fp);
    // }

    // Proces from the last line of the pixture
    fwrite(img->data, 1, img->header.image_size_bytes, fp);
    return 0;
}

Pixel    *bmp_pixel_at(BMPImage *img, uint32_t x, uint32_t y)
{
    if (x >= img->header.width_px || y >= img->header.height_px) {
        return 0;
    }
    return (Pixel *)((void *)img->data + (x + y * img->header.width_px) * img->header.bits_per_pixel / 8);
}

void bmp_print_header(BMPImage *img)
{
    BMPHeader *h = &img->header;
    printf("type=%x\n", h->type);             
    printf("size=%u\n", h->size);            
    printf("reserved1=%u\n", h->reserved1);       
    printf("reserved2=%u\n", h->reserved2);       
    printf("offset=%u\n", h->offset);           
    printf("dib_header_size=%u\n", h->dib_header_size);  
    printf("width_px=%d\n", h->width_px);        
    printf("height_px=%d\n", h->height_px);       
    printf("num_planes=%u\n", h->num_planes);       
    printf("bits_per_pixel=%u\n", h->bits_per_pixel);  
    printf("compression=%u\n", h->compression);     
    printf("image_size_bytes=%u\n", h->image_size_bytes);
    printf("x_resolution_ppm=%d\n", h->x_resolution_ppm);
    printf("y_resolution_ppm=%d\n", h->y_resolution_ppm);
    printf("num_colors=%u\n", h->num_colors);      
    printf("important_colors=%u\n", h->important_colors);
}

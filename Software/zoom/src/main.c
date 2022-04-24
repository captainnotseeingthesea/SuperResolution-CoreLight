#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "jpeg.h"
#include "zoom.h"
#include "bmp.h"

/*
 *  模式选择:
 *      0: 使用 jpeg_zoom 整幅图读入缩放(临近点插值)
 *      1: 使用 jpeg + zoom 流模式缩放(临近点插值、双线性插值、双三次插值)
 *      2: 使用 jpeg + zoom 整图加载多线程处理模式(临近点插值、双线性插值)
 */
// #define TEST_MODE 2

#include <sys/time.h>
long getTickUs(void)
{
    struct timeval tv = {0};
    gettimeofday(&tv, NULL);
    return (long)(tv.tv_sec * 1000000u + tv.tv_usec);
}

void help(char **argv)
{
    printf(
        "Usage: %s [file: src.jpg(bmp)] [file: dst.jpg(bmp)] [zoom: 0.0~1.0~max] [type: 0/near(default) 1/linear]\r\n"
        "Example: %s ./in.jpg 3\r\n",
        argv[0], argv[0]);
}

#if(TEST_MODE == 0) // 使用 jpeg_zoom 缩放

int main(int argc, char **argv)
{
    long tickUs1, tickUs2;
    //缩放倍数: 0~1缩小,等于1不变,大于1放大
    float zm = 1.0;
    printf("mode 0 \r\n");
    //传参检查
    if (argc < 4)
    {
        help(argv);
        return 0;
    }
    //缩放倍数
    zm = atof(argv[2]);
    //用时
    tickUs1 = getTickUs();
    //开始缩放
    jpeg_zoom(argv[1], argv[3], zm, 75);
    // jpeg_zoom2(argv[1], "./out.jpg", 75);
    //用时
    tickUs2 = getTickUs();
    printf("total time: %.3fms \r\n", (float)(tickUs2 - tickUs1) / 1000);
    return 0;
}

#elif(TEST_MODE == 1) //使用 jpeg/bmp + zoom 流模式缩放

int main(int argc, char **argv)
{
    long tickUs1, tickUs2, tickUs3, tickUs4;
    void *Src = NULL, *Dist = NULL;
    // 拷贝源文件的文件路径
    char * src_file = (char *)malloc(strlen(argv[1]));
    strcpy(src_file, argv[1]);
    // 图片的后缀
    char *p = strtok(src_file, ".");
    char *suffix = NULL;

    //输入图像参数
    int width = 0, height = 0, pb = 3;
    //输出图像参数
    int outWidth = 0, outHeight = 0;
    //缩放倍数: 0~1缩小,等于1不变,大于1放大
    float zm = 1.0;
    //缩放方式: 默认使用最近插值
    Zoom_Type zt = ZT_NEAR;

    // 针对BMP和JPG文件的按行操作函数的指针
    void * (*getLine)(char *, int *, int *, int *);
    void * (*createLine)(char *, int, int, int, int);
    int (*srcRead)(void *, unsigned char *, int);
    int (*distWrite)(void *, unsigned char *, int);
    void (*closeLine)(void *);

    printf("mode 1 \r\n");
    //传参检查
    if (argc < 4)
    {
        help(argv);
        return 0;
    }
    //用时
    tickUs1 = getTickUs();
    //缩放倍数
    zm = atof(argv[3]);
    //缩放方式
    if(argc > 4)
        zt = atoi(argv[4]);
    
    //解文件
    while(p != NULL)
    {
        suffix = p;
        p = strtok(NULL, ".");
    }

    // 输入, 输出流准备
    if(!strcmp(suffix, "bmp"))
    {
        getLine = (void *)bmp_getline;
        createLine = (void *)bmp_createLine;
        srcRead = bmp_line;
        distWrite = bmp_line;
        closeLine = bmp_closeLine;
    }
    else if(!(strcmp(suffix, "jpg") && strcmp(suffix, "jpeg")))
    {
        getLine = (void *)jpeg_getLine;
        createLine = (void *)jpeg_createLine;
        srcRead = jpeg_line;
        distWrite = jpeg_line;
        closeLine = jpeg_closeLine;
    }
    else
    {
        printf("unsupported image type, only bmp and jpeg are supported!!!\r\n");
        return 0;
    }
    Src = getLine(argv[1], &width, &height, &pb);
    Dist = createLine(argv[2], (int)(width * zm), (int)(height * zm), pb, 75);
    printf("input: %s / %dx%dx%d bytes / zoom %.2f / type %d \r\n",
            argv[1], width, height, pb, zm, zt);
    //用时
    tickUs2 = getTickUs();
    //缩放
    if (Src && Dist)
    {
        zoom_stream(
            Src, Dist, srcRead, distWrite,
            width, height, &outWidth, &outHeight, zm, zt);
    }
    //用时
    tickUs3 = getTickUs();
    //内存回收

    closeLine(Src);
    closeLine(Dist);
    //用时
    tickUs4 = getTickUs();
    printf("output: %s / %dx%dx%d bytes / zoom time %.3fms / total time %.3fms\r\n",
           argv[2], outWidth, outHeight, pb,
           (float)(tickUs3 - tickUs2) / 1000,
           (float)(tickUs4 - tickUs1) / 1000);
    return 0;
}

#elif(TEST_MODE == 2) // 使用 jpeg/bmp + zoom 整图加载多线程处理模式

int main(int argc, char **argv)
{
    long tickUs1, tickUs2, tickUs3, tickUs4;
    //输入图像参数
    unsigned char *map = NULL;
    int width = 0, height = 0, pb = 3;
    //输出图像参数
    unsigned char *outMap = NULL;
    int outWidth = 0, outHeight = 0;
    // 拷贝源文件的文件路径
    char * src_file = (char *)malloc(strlen(argv[1]));
    strcpy(src_file, argv[1]);
    // 图片的后缀
    char *p = strtok(src_file, ".");
    char *suffix = NULL;

    //缩放倍数: 0~1缩小,等于1不变,大于1放大
    float zm = 1.0;
    //缩放方式: 默认使用最近插值
    Zoom_Type zt = ZT_NEAR;
    printf("mode 2 \r\n");
    if (argc < 4)
    {
        help(argv);
        return 0;
    }
    //用时
    tickUs1 = getTickUs();
    //缩放倍数
    zm = atof(argv[3]);
    //缩放方式
    if (argc > 4)
        zt = atoi(argv[4]);
    //解文件
    while(p != NULL)
    {
        suffix = p;
        p = strtok(NULL, ".");
    }
    if(!strcmp(suffix, "bmp"))
    {
        BMPImage *img =  bmp_read(argv[1]);
        map = (unsigned char *)img->data;
        width = img->header.width_px;
        height = img->header.height_px;
        pb = img->header.bits_per_pixel / 8;
    }
    else if(!(strcmp(suffix, "jpg") && strcmp(suffix, "jpeg")))
    {
        map = jpeg_get(argv[1], &width, &height, &pb);
    }
    else
    {
        printf("unsupported image type, only bmp and jpeg are supported!!!\r\n");
        return 0;
    }
    printf("input: %s / %dx%dx%d bytes / zoom %.2f / type %d \r\n",
           argv[1], width, height, pb, zm, zt);
    //用时
    tickUs2 = getTickUs();
    //缩放
    if (map)
        outMap = zoom(map, width, height, &outWidth, &outHeight, zm, zt);
    //用时
    tickUs3 = getTickUs();
    //输出文件
    if (outMap)
    {
        if(!strcmp(suffix, "bmp"))
        {
            BMPImage *img = bmp_create(outWidth, outHeight);
            free(img->data); // 释放已分配好的数据空间
            img->data = (Pixel *)outMap;
            bmp_write(img, argv[2]);
        }
        else if(!(strcmp(suffix, "jpg") && strcmp(suffix, "jpeg")))
        {
            jpeg_create(argv[2], outMap, outWidth, outHeight, pb, 75);
        }
        else
        {
            printf("unsupported image type, only bmp and jpeg are supported!!!\r\n");
            return 0;
        }

        //用时
        tickUs4 = getTickUs();
        printf("output: %s / %dx%dx%d bytes / zoom time %.3fms / total time %.3fms\r\n",
               argv[2], outWidth, outHeight, pb,
               (float)(tickUs3 - tickUs2) / 1000,
               (float)(tickUs4 - tickUs1) / 1000);
    }
    else
        printf("Error: zoom failed !!\r\n");
    //内存回收
    if (map)
        free(map);
    if (outMap)
        free(outMap);

    return 0;
}

#endif
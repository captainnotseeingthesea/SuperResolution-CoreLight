#include <stdio.h>
#include <stdlib.h>

#include "zoom.h"
#include "bcci.h"

/*
 *  功能:
 *      使用 bmp + zoom 多线程处理模式(临近点插值、双线性插值、双三次插值) + 锐化
 */

void bcci(void *data_in, uint32_t width_in, uint32_t height_in, void *data_out, uint32_t width_out, uint32_t height_out, uint32_t num_instance)
{
    //输入图像参数
    unsigned char *map = (unsigned char *)data_in;

    Zoom_Type zt = ZT_BICUBIC;
    if (map)
        zoom(map, width_in, height_in, (unsigned char *)data_out, width_out, height_out, zt, num_instance);
    else
    {
        printf("Error: input data is invalid !!\r\n");
    }
    if (data_out == NULL)
    {
        printf("Error: zoom failed !!\r\n");
    }

    //内存回收
    if (map)
        free(map);
}
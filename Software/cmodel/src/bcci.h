#ifndef __BCCI_H_
#define __BCCI_H_
#include "bmp.h"
#include <stdint.h>
/*
 *  缩放rgb图像(双线性插值算法)
 *  参数:
 *      data_in: 源图像数据指针,rgb排列,3字节一像素
 *      width_in, height_in: 源图像宽、高
 *      data_out: 目标图像数据指针,rgb排列,3字节一像素
 *      width_out, Height_out: 输出图像宽、高
 *      thread_num: 启动的线程数
 *
 */
void bcci(
    void *data_in, uint32_t width_in, uint32_t height_in, 
    void *data_out, uint32_t width_out, uint32_t height_out, 
    uint32_t num_instance);

#endif

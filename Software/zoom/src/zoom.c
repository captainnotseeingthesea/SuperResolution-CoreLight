#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <pthread.h>
#include <sys/sysinfo.h> // get_nprocs() 获取有效cpu 核心数

#include "zoom.h"

// 原版计算方式
#define LINEAR1(p11, p12, p21, p22, le, re, ue, de) \
    (unsigned char)((p11 * re + p12 * le) * de + (p21 * re + p22 * le) * ue)

// 简化版,用re替换le后
#define LINEAR2(p11, p12, p21, p22, re, ue, de) \
    (unsigned char)((p12 + re * (p11 - p12)) * de + (p22 + re * (p21 - p22)) * ue)

// 选择一种计算方式
// #define LINEAR(p11, p12, p21, p22, le, re, ue, de) LINEAR1(p11, p12, p21, p22, le, re, ue, de)
#define LINEAR(p11, p12, p21, p22, le, re, ue, de) LINEAR2(p11, p12, p21, p22, re, ue, de)

typedef struct
{
    unsigned char r, g, b;
} Zoom_Rgb;

typedef struct
{
    //输入输出图像信息
    Zoom_Rgb *rgb;
    int width, height;
    Zoom_Rgb *rgbOut;
    int widthOut, heightOut;
    //多线程
    int lineDiv;
    int threadCount;
    int threadFinsh;
} Zoom_Info;

typedef struct
{
    Zoom_Info *info; // 进行高斯滤波的原图片
    Zoom_Rgb *dst_img; // 高斯滤波后的图片
    float **weight; // 高斯核权值矩阵
    int _size; //高斯核的大小
} Gaussian_blur_info;

typedef struct
{
    Zoom_Info *info; // 原图片
    float alpha; // 原图片的权重
    Zoom_Rgb *src_img; // 要叠加图片的信息
    float beta; // 叠加图片的权重
    float gama; // 附加的值
} addWeighted_info;


/*
 *  多线程并行的方式来缩放图像(双三次插值算法)
 */
void _zoom_bicubic(Zoom_Info *info);

/*
 *  多线程并行的方式来缩放图像(基于Opencv的双三次插值算法)
 */
void _zoom_bicubic_opencv(Zoom_Info *info);

//抛线程工具
static void new_thread(void *obj, void *callback)
{
    pthread_attr_t attr;
    pthread_t th;
    int ret;
    //禁用线程同步,线程运行结束后自动释放
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    //抛出线程
    ret = pthread_create(&th, &attr, callback, (void *)obj);
    if (ret != 0)
        printf("new_thread failed !! %s\r\n", strerror(ret));
    // attr destroy
    pthread_attr_destroy(&attr);
}

// 对x进行截断处理
static inline int clip(int x, int a, int b)
{
    return x >= a ? (x < b ? x : b-1) : a;
}

/************************************************
函  数  名: getGaussianArray
功       能 : 获取高斯分布数组 
输入参数 :
arr_size   :矩阵大小
sigma      : 标准差
输出参数 :
array      :二维数组
**********************************************/
float **getGaussianArray(int arr_size, float sigma)
{
    int i, j;
    // [1] 初始化权值数组
    float ** array = (float **)calloc(arr_size, sizeof(float *));
    for(int i = 0; i < arr_size; i++)
    {
        array[i] = (float *)calloc(arr_size, sizeof(float));
    }
    // [2] 高斯分布计算
    int center_i, center_j;
    center_i = center_j = arr_size / 2;
    float pi = 3.141592653589793;
    float sum = 0.0f;
    // [2-1] 高斯函数
    for (i = 0; i < arr_size; i++ ) {
        for (j = 0; j < arr_size; j++) {
            array[i][j] = 
                1.0 / (2 * pi * sigma * sigma) *
                exp( -1.0f* ( ((i-center_i)*(i-center_i)+(j-center_j)*(j-center_j)) / (2.0f*sigma*sigma) ));
            sum += array[i][j];
        }
    }
    // [2-2] 归一化求权值
    for (i = 0; i < arr_size; i++) {
        for (j = 0; j < arr_size; j++) {
            array[i][j] /= sum;
        }
    }
    return array;
}

/* 
* 通过高斯模糊完成对图片的模糊处理
* 参数：
*   info: 保存要进行模糊处理的图片信息
*   _size: 高斯核的大小
*   sigma: 标准差
* 返回：
*   进行高斯模糊处理后的图片
*/

void Gaussian_blur(Gaussian_blur_info *blur_info)
{
    Zoom_Info *info = blur_info->info;
    Zoom_Rgb *dst_img = blur_info->dst_img;
    float ** weight = blur_info->weight;
    int _size = blur_info->_size;
    float r_sum, g_sum, b_sum;
    int center = _size / 2;
    int pix_x, pix_y;
    int ii, jj;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    int row_region_cnt, col_region_cnt;
    int left_side, right_side, top_side, down_side;
    for(ii = startLine; ii < endLine; ii++)
    {
        row_region_cnt = ii / 4;
        top_side = row_region_cnt * 4;
        down_side = top_side + 4;
        for(jj = 0; jj < info->widthOut; jj++)
        {
            col_region_cnt = jj / 4;
            left_side = col_region_cnt * 4;
            right_side = left_side + 4;
            // 计算每个像素对应的值
            r_sum = 0, g_sum = 0, b_sum = 0;
            for(int u = 0; u < _size; u++)
            {
                // 采用BORDER_REFLECT_101的边缘填充方式，opencv的默认填充方式
                pix_y = (ii - center + u) < 0 ? (center - u - ii) : (ii - center + u) >= info->heightOut ? (2 * info->heightOut - ii + center - u - 2) : (ii - center + u);
                pix_y = clip(pix_y, top_side, down_side);
                for(int v = 0; v < _size; v++)
                {
                    pix_x = (jj - center + v) < 0 ? (center - v - jj) : (jj - center + v) >= info->widthOut ? (2 * info->widthOut - jj + center - v - 2) : (jj - center + v);
                    pix_x = clip(pix_x, left_side, right_side);
                    r_sum += info->rgbOut[pix_y * info->widthOut + pix_x].r * weight[u][v];
                    g_sum += info->rgbOut[pix_y * info->widthOut + pix_x].g * weight[u][v];
                    b_sum += info->rgbOut[pix_y * info->widthOut + pix_x].b * weight[u][v];
                }
            }
            dst_img[ii * info->widthOut + jj].r = r_sum;
            dst_img[ii * info->widthOut + jj].g = g_sum;
            dst_img[ii * info->widthOut + jj].b = b_sum;
        }
    }
    //多线程,处理完成行数
    info->threadFinsh++;
}

/* 
* 完成两幅图的加权叠加，对原图片进行修改 (alpga * src1 + beta * src2 + gama)
*/

void addWeighted(addWeighted_info *weight_info)
{
    //多线程
    int startLine, endLine;
    int ii, jj;
    int r, g, b;
    Zoom_Info *info = weight_info->info;
    Zoom_Rgb *src_img = weight_info->src_img;
    float alpha = weight_info->alpha;
    float beta = weight_info->beta;
    float gama = weight_info->gama;

    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;
    for(ii = startLine; ii < endLine; ii++)
    {
        for(jj = 0; jj < info->widthOut; jj++)
        {
            r = alpha * info->rgbOut[ii * info->widthOut + jj].r + beta * src_img[ii * info->widthOut + jj].r + gama;
            g = alpha * info->rgbOut[ii * info->widthOut + jj].g + beta * src_img[ii * info->widthOut + jj].g + gama;
            b = alpha * info->rgbOut[ii * info->widthOut + jj].b + beta * src_img[ii * info->widthOut + jj].b + gama;
            info->rgbOut[ii * info->widthOut + jj].r = clip(r, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].g = clip(g, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].b = clip(b, 0, 256);
        }
    }
    //多线程,处理完成行数
    info->threadFinsh++;
}

/* 
* 使用USM(Unsharp masking)对图像进行锐化增强（高斯滤波+图片叠加）
* 参数：
*   info: 保存原图片的信息
*   _size: 高斯核的大小
*   sigma: 标准差
*   alpha: 原图片的权重
*   beta: 叠加图片的权重
*   gama: 附加的值
*   processor: 并行的线程数
*/

void usm(Zoom_Info *info, int _size, float sigma, float alpha, float beta, float gama, int processor)
{
    //获得高斯核
	float ** weight;
	weight = getGaussianArray(_size, sigma);
    int i, threadCount;

    // 重置info中有关多线程的变量
    info->threadCount = 0;
    info->threadFinsh = 0;
    
    // 分配高斯滤波后的图片存储空间
    Zoom_Rgb *dst_img = (Zoom_Rgb *)calloc(info->widthOut * info->heightOut, sizeof(Zoom_Rgb));

    // 初始化高斯滤波的参数结构体
    Gaussian_blur_info blur_info = 
    {
        .dst_img = dst_img,
        .info = info,
        .weight = weight,
        ._size = _size
    };

    // 初始化图片权值叠加的参数结构体
    addWeighted_info weight_info = 
    {
        .info = info,
        .alpha = alpha,
        .src_img = dst_img,
        .beta = beta,
        .gama = gama
    };

     //普通处理
    if (processor < 2)
    {
        info->lineDiv = info->heightOut;
        Gaussian_blur(&blur_info);
        info->threadCount = 0;
        info->threadFinsh = 0;
        addWeighted(&weight_info);
    }
    //多线程处理
    else
    {
        /* 
        * 进行高斯滤波处理
        */
        info->lineDiv = info->heightOut / processor; //每核心处理行数
        if (info->lineDiv < 1)
            info->lineDiv = 1;
        //多线程
        for (i = threadCount = 0; i < info->heightOut; i += info->lineDiv)
        {            
            new_thread(&blur_info, Gaussian_blur);
            threadCount += 1;
        }
        //等待各线程处理完毕
        while (info->threadFinsh != threadCount)
            usleep(1000);

        /* 
        * 进行图像叠加处理
        */
        info->threadCount = 0;
        info->threadFinsh = 0;

        for (i = threadCount = 0; i < info->heightOut; i += info->lineDiv)
        {
            new_thread(&weight_info, &addWeighted);
            threadCount += 1;
        }
        //等待各线程处理完毕
        while (info->threadFinsh != threadCount)
            usleep(1000);
    }

    free(weight); // 释放权重矩阵
    free(dst_img); // 释放高斯滤波图片空间
}

/* 
    多线程并行的方式来缩放图像(基于opencv的双线性插值算法)
*/
void _zoom_linear_opencv(Zoom_Info *info)
{
    float fWStep = 0.0f, fHStep = 0.0f;
    int ii = 0, jj = 0;
    float fx = 0.0f, fy = 0.0f;
    int sx = 0, sy = 0;
    short cbufY[2], cbufX[2];
    int mm = 0, nn = 0;
    Zoom_Rgb * pCurr = 0;

    int r_sum = 0, g_sum = 0, b_sum = 0;
    fWStep = 1.0f * info->width / info->widthOut;
    fHStep = 1.0f * info->height / info->heightOut;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    for(ii = startLine; ii < endLine; ii++)
    {
        fy = (float)((ii + 0.5) * fHStep - 0.5);
        sy = (int)floor(fy);
        fy -= sy;

        cbufY[0] = (short)((1.f - fy) * 2048);
        cbufY[1] = 2048 - cbufY[0];

        for(jj = 0; jj < info->widthOut; jj++)
        {
            fx = (float)((jj + 0.5) * fWStep - 0.5);
            sx = (int)floor(fx);
            fx -= sx;

            if(sx < 0)
            {
                fx = 0, sx = 0;
            }

            if(sx >= info->width - 1)
            {
                fx = 0, sx = info->width - 1;
            }

            cbufX[0] = (short)((1.f - fx) * 2048);
            cbufX[1] = 2048 - cbufX[0];

            for(mm = 0; mm < 2; mm++) // cols
            {
                pCurr = info->rgb + clip((sy + mm), 0, info->height) * info->width;
                for(nn = 0; nn < 2; nn++) // rows
                {
                    r_sum += pCurr[clip(sx + nn, 0, info->width)].r * cbufY[mm]*cbufX[nn];
                    g_sum += pCurr[clip(sx + nn, 0, info->width)].g * cbufY[mm]*cbufX[nn];
                    b_sum += pCurr[clip(sx + nn, 0, info->width)].b * cbufY[mm]*cbufX[nn];
                }
            }
            r_sum >>= 22;
            g_sum >>= 22;
            b_sum >>= 22;
            info->rgbOut[ii * info->widthOut + jj].r = clip(r_sum, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].g = clip(g_sum, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].b = clip(b_sum, 0, 256);
        }
    }
    //多线程,处理完成行数
    info->threadFinsh++;
}

/* 
    多线程并行的方式来缩放图像(简单双线性插值算法)
*/
void _zoom_linear(Zoom_Info *info)
{
    float floorX, floorY, ceilX, ceilY;
    float errUp, errDown, errLeft, errRight;
    int x1, x2, y1, y2;
    float xStep, yStep, xDiv, yDiv;
    int x, y;
    int offsetOut, offset11, offset12, offset21, offset22;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //列像素遍历
    for (y = startLine, yStep = (startLine + 0.5) * yDiv - 0.5,
        offsetOut = startLine * info->widthOut;
         y < endLine; y += 1, yStep += yDiv)
    {
        //上下2个相邻点: 距离计算
        floorY = floor(yStep);
        ceilY = ceil(yStep);
        errUp = yStep - floorY;
        errDown = 1 - errUp;

        //上下2个相邻点: 序号
        y1 = (int)floorY;
        y2 = (int)ceilY;
        if (y2 == info->height)
            y2 -= 1;

        //避免下面for循环中重复该乘法
        y1 *= info->width;
        y2 *= info->width;

        //行像素遍历
        for (x = 0, xStep = (x + 0.5) * xDiv - 0.5; x < info->widthOut; x += 1, xStep += xDiv, offsetOut += 1)
        {
            //左右2个相邻点: 距离计算
            floorX = floor(xStep);
            ceilX = ceil(xStep);
            errLeft = xStep - floorX;
            errRight = 1 - errLeft;

            //左右2个相邻点: 序号
            x1 = (int)floorX;
            x2 = (int)ceilX;
            if (x2 == info->width)
                x2 -= 1;

            //双线性插值
            offset11 = x1 + y1;
            offset12 = x2 + y1;
            offset21 = x1 + y2;
            offset22 = x2 + y2;
            info->rgbOut[offsetOut].r = LINEAR(
                info->rgb[offset11].r, info->rgb[offset12].r,
                info->rgb[offset21].r, info->rgb[offset22].r,
                errLeft, errRight, errUp, errDown);
            info->rgbOut[offsetOut].g = LINEAR(
                info->rgb[offset11].g, info->rgb[offset12].g,
                info->rgb[offset21].g, info->rgb[offset22].g,
                errLeft, errRight, errUp, errDown);
            info->rgbOut[offsetOut].b = LINEAR(
                info->rgb[offset11].b, info->rgb[offset12].b,
                info->rgb[offset21].b, info->rgb[offset22].b,
                errLeft, errRight, errUp, errDown);
        }
    }

    //多线程,处理完成行数
    info->threadFinsh++;
}

/* 
    流式输入的方式来缩放图像(基于opencv的双线性插值算法)
*/
void _zoom_linear_stream_opencv(
    Zoom_Info *info,
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int))
{
    float fWStep = 0.0f, fHStep = 0.0f;
    int ii = 0, jj = 0;
    float fx = 0.0f, fy = 0.0f;
    int sx = 0, sy = 0;
    short cbufY[2], cbufX[2];
    int mm = 0, nn = 0;

    //当前读取行数
    int readLine = 0;
    //两行数据的指针,对应y1,y2来使用
    Zoom_Rgb *line[2];
    line[0] = &info->rgb[0];
    line[1] = &info->rgb[info->width];
    Zoom_Rgb *lineX;

    Zoom_Rgb * pSamp = 0;
    Zoom_Rgb * pCurr = 0;
    int r_sum = 0, g_sum = 0, b_sum = 0;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    fWStep = 1.0f * info->width / info->widthOut;
    fHStep = 1.0f * info->height / info->heightOut;
    pSamp = info->rgbOut;

    //读取新1行数据
    srcRead(objSrc, (unsigned char *)line[1], 1);
    //填充满2行
    memcpy(line[0], line[1], info->width * 3);

    for(ii = 0; ii < info->heightOut; ii++)
    {
        fy = (float)((ii + 0.5) * fHStep - 0.5);
        sy = (int)floor(fy);
        fy -= sy;
        
        if(sy + 1 < info->height)
        {
            while (readLine < sy + 1)
            {
                //后面数据往前挪
                lineX = line[0];
                line[0] = line[1];
                line[1] = lineX;
                //读取新一行数据
                if (srcRead(objSrc, (unsigned char *)line[1], 1) == 1)
                    readLine += 1;
                else
                    break;
            }
        }
        else
        {
            //后面数据往前挪
            memcpy(line[0], line[1], info->width * 3);
        }
        
        cbufY[0] = (short)((1.f - fy) * 2048);
        cbufY[1] = 2048 - cbufY[0];

        for(jj = 0; jj < info->widthOut; jj++)
        {
            fx = (float)((jj + 0.5) * fWStep - 0.5);
            sx = (int)floor(fx);
            fx -= sx;

            if(sx < 0)
            {
                fx = 0, sx = 0;
            }

            if(sx >= info->width - 1)
            {
                fx = 0, sx = info->width - 1;
            }

            cbufX[0] = (short)((1.f - fx) * 2048);
            cbufX[1] = 2048 - cbufX[0];

            for(mm = 0; mm < 2; mm++) // cols
            {
                pCurr = line[mm];
                for(nn = 0; nn < 2; nn++) // rows
                {
                    r_sum += pCurr[clip(sx + nn, 0, info->width)].r * cbufY[mm]*cbufX[nn];
                    g_sum += pCurr[clip(sx + nn, 0, info->width)].g * cbufY[mm]*cbufX[nn];
                    b_sum += pCurr[clip(sx + nn, 0, info->width)].b * cbufY[mm]*cbufX[nn];
                }
            }
            r_sum >>= 22;
            g_sum >>= 22;
            b_sum >>= 22;
            (pSamp + jj)->r = clip(r_sum, 0, 256);
            (pSamp + jj)->g = clip(g_sum, 0, 256);
            (pSamp + jj)->b = clip(b_sum, 0, 256);
        }
        distWrite(objDist, (unsigned char *)info->rgbOut, 1);
    }
}

/* 
    流式输入的方式来缩放图像(基于简单双线性插值算法)
*/
void _zoom_linear_stream(
    Zoom_Info *info,
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int))
{
    float floorX, floorY, ceilX, ceilY;
    float errUp, errDown, errLeft, errRight;
    int x1, x2, y2;
    float xStep, yStep, xDiv, yDiv;
    int x, y;

    //当前读取行数
    int readLine = 0;
    //两行数据的指针,对应y1,y2来使用
    Zoom_Rgb *line1 = &info->rgb[0];
    Zoom_Rgb *line2 = &info->rgb[info->width];
    Zoom_Rgb *lineX;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //读取新1行数据
    srcRead(objSrc, (unsigned char *)line2, 1);
    //填充满2行
    memcpy(line1, line2, info->width * 3);

    //列像素遍历
    for (y = 0, yStep = (y + 0.5) * yDiv - 0.5; y < info->heightOut; y += 1, yStep += yDiv)
    {
        //上下2个相邻点: 距离计算
        floorY = floor(yStep);
        ceilY = ceil(yStep);
        errUp = yStep - floorY;
        errDown = 1 - errUp;

        //上下2个相邻点: 序号
        // y1 = (int)floorY;
        y2 = (int)ceilY;
        if (y2 == info->height)
            y2 -= 1;

        //读取足够的行数据(移动info->rgb中的行数据到能覆盖y1,y2所在行)
        while (readLine < y2)
        {
            //后面数据往前挪
            lineX = line1;
            line1 = line2;
            line2 = lineX;
            //读取新一行数据
            if (srcRead(objSrc, (unsigned char *)line2, 1) == 1)
                readLine += 1;
            else
                break;
        }

        // printf("y1 %d y2 %d - readLine %d \r\n", y1, y2, readLine);

        //行像素遍历
        for (x = 0, xStep = (x + 0.5) * xDiv - 0.5; x < info->widthOut; x += 1, xStep += xDiv)
        {
            //左右2个相邻点: 距离计算
            floorX = floor(xStep);
            ceilX = ceil(xStep);
            errLeft = xStep - floorX;
            errRight = 1 - errLeft;

            //左右2个相邻点: 序号
            x1 = (int)floorX;
            x2 = (int)ceilX;
            if (x2 == info->width)
                x2 -= 1;

            //双线性插值
            info->rgbOut[x].r = LINEAR(
                line1[x1].r, line1[x2].r,
                line2[x1].r, line2[x2].r,
                errLeft, errRight, errUp, errDown);
            info->rgbOut[x].g = LINEAR(
                line1[x1].g, line1[x2].g,
                line2[x1].g, line2[x2].g,
                errLeft, errRight, errUp, errDown);
            info->rgbOut[x].b = LINEAR(
                line1[x1].b, line1[x2].b,
                line2[x1].b, line2[x2].b,
                errLeft, errRight, errUp, errDown);
        }

        //输出一行数据
        distWrite(objDist, (unsigned char *)info->rgbOut, 1);
    }
}

void _zoom_near(Zoom_Info *info)
{
    int xSrc, ySrc;
    float xStep, yStep, xDiv, yDiv;
    int x, y, offset;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //列像素遍历
    for (y = startLine, yStep = startLine * yDiv,
        offset = startLine * info->widthOut;
         y < endLine; y += 1, yStep += yDiv)
    {
        //最近y值
#if 0
        ySrc = (int)round(yStep);
        if (ySrc == info->height)
            ySrc -= 1;
#else
        //直接类型转换可以提升速度,效果相当于floor
        ySrc = (int)(yStep);
#endif

        //避免下面for循环中重复该乘法
        ySrc *= info->width;

        //行像素遍历
        for (x = 0, xStep = 0; x < info->widthOut; x += 1, xStep += xDiv)
        {
            //最近x值
#if 0
            xSrc = (int)round(xStep);
            if (xSrc == info->width)
                xSrc -= 1;
#else
            //直接类型转换可以提升速度,效果相当于floor
            xSrc = (int)(xStep);
#endif
            //拷贝最近点
            info->rgbOut[offset++] = info->rgb[ySrc + xSrc];
        }
    }

    //多线程,处理完成行数
    info->threadFinsh++;
}

void _zoom_near_stream(
    Zoom_Info *info,
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int))
{
    int xSrc, ySrc;
    float xStep, yStep, xDiv, yDiv;
    int x, y;

    //当前已读取行数
    int readLine = 0;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //读取新一行数据
    srcRead(objSrc, (unsigned char *)info->rgb, 1);

    //列像素遍历
    for (y = 0, yStep = 0 * yDiv; y < info->heightOut; y += 1, yStep += yDiv)
    {
        //最近y值
#if 0
        ySrc = (int)round(yStep);
#else
        //直接类型转换可以提升速度,效果相当于floor
        ySrc = (int)(yStep);
#endif

        //读取足够的行数据(移动info->rgb中的行数据到能覆盖ySrc所在行)
        while (readLine < ySrc)
        {
            //读取新一行数据
            if (srcRead(objSrc, (unsigned char *)info->rgb, 1) == 1)
                readLine += 1;
            else
                break;
        }

        // printf("ySrc %d - readLine %d \r\n", ySrc, readLine);

        //行像素遍历
        for (x = 0, xStep = 0; x < info->widthOut; x += 1, xStep += xDiv)
        {
            //最近x值
#if 0
            xSrc = (int)round(xStep);
            if (xSrc == info->width)
                xSrc -= 1;
#else
            //直接类型转换可以提升速度,效果相当于floor
            xSrc = (int)(xStep);
#endif
            //拷贝最近点
            info->rgbOut[x] = info->rgb[xSrc];
        }

        //输出一行数据
        distWrite(objDist, (unsigned char *)info->rgbOut, 1);
    }
}

/*
 *  缩放rgb图像(双线性插值算法)
 *  参数:
 *      rgb: 源图像数据指针,rgb排列,3字节一像素
 *      width, height: 源图像宽、高
 *      retWidth, retHeigt: 输出图像宽、高
 *      zm: 缩放倍数,(0,1)小于1缩小倍数,(1,~]大于1放大倍数
 *      zt: 缩放方式
 *
 *  返回: 输出rgb图像数据指针 !! 用完记得free() !!
 */
unsigned char *zoom(
    unsigned char *rgb,
    int width, int height,
    int *retWidth, int *retHeight,
    float zm,
    Zoom_Type zt)
{
    int i;
    int outSize;
    int threadCount;
    int processor = 0;
    void (*callback)(Zoom_Info *);

    Zoom_Info info = {
        .rgb = (Zoom_Rgb *)rgb,
        .width = width,
        .height = height,
        .widthOut = (int)(width * zm),
        .heightOut = (int)(height * zm),
        .threadCount = 0,
        .threadFinsh = 0,
    };

    //参数检查
    if (zm <= 0 || width < 1 || height < 1)
        return NULL;

    //输出图像内存准备
    outSize = info.widthOut * info.heightOut;
    info.rgbOut = (Zoom_Rgb *)calloc(outSize, sizeof(Zoom_Rgb));

    //缩放方式
    if (zt == ZT_LINEAR)
        callback = &_zoom_linear_opencv;
    else if(zt == ZT_NEAR)
        callback = &_zoom_near;
    else if(zt == ZT_BICUBIC)
        callback = &_zoom_bicubic_opencv;
    else
    {
        printf("Unsupported upscaling method!!\r\n");
        return 0;
    }
    
    //多线程处理(输出图像大于320x240时)
    if (outSize > 76800)
    {
        //获取cpu可用核心数
        processor = 1;
    }

    //普通处理
    if (processor < 2)
    {
        info.lineDiv = info.heightOut;
        callback(&info);
    }
    //多线程处理
    else
    {
        //每核心处理行数
        info.lineDiv = info.heightOut / processor;
        if (info.lineDiv < 1)
            info.lineDiv = 1;
        //多线程
        for (i = threadCount = 0; i < info.heightOut; i += info.lineDiv)
        {
            new_thread(&info, callback);
            threadCount += 1;
        }
        //等待各线程处理完毕
        while (info.threadFinsh != threadCount)
            usleep(1000);
    }
    //返回
    if (retWidth)
        *retWidth = info.widthOut;
    if (retHeight)
        *retHeight = info.heightOut;
    
    // 使用高斯滤波进行锐化处理 (USM(Unshrpen Mask)算法)
    usm(&info, 3, 6, 2, -1, 0, processor);

    return (unsigned char *)info.rgbOut;
}

/*计算系数*/
float BSpline(float x)
{
    float f = x;
    if (f < 0.0)
        f = -f;

    if (f >= 0.0 && f <= 1.0)
        return (2.0 / 3.0) + (0.5) * (f * f * f) - (f * f);
    else if (f > 1.0 && f <= 2.0)
        return 1.0 / 6.0 * pow((2.0 - f), 3.0);
    return 1.0;
}

/*
 *  按照数据流的方式缩放图像(双三次插值算法)
 */
void _zoom_bicubic_stream(
    Zoom_Info *info,
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int))
{
    float xStep, yStep, xDiv, yDiv;
    int x, y;

    float dx, dy; // delta_x and delta_y
    float Bmdx;   // Bspline m-dx
    float Bndy;   // Bspline dy-n

    int i_original_img_hnum, i_original_img_wnum;

    //当前读取行数
    int readLine = 0;
    //两行数据的指针,对应y1,y2来使用
    Zoom_Rgb *line[4];
    for (int i = 0; i < 4; i++)
    {
        line[i] = &info->rgb[info->width * i];
    }
    Zoom_Rgb *lineX;

    //读取新1行数据
    srcRead(objSrc, (unsigned char *)line[3], 1);
    for (int i = 0; i < 3; i++)
    {
        memcpy(line[i], line[3], info->width * 3);
    }

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //列像素遍历
    for (y = 0, yStep = 0 * yDiv; y < info->heightOut; y += 1, yStep += yDiv)
    {
        i_original_img_hnum = (int)ceil(yStep) + 1;
        if (i_original_img_hnum >= info->height)
            i_original_img_hnum = info->height - 1;
        dx = yStep - (int)yStep;

        //读取足够的行数据(移动info->rgb中的行数据到能覆盖y1,y2所在行)
        while (readLine < i_original_img_hnum)
        {
            //后面数据往前挪
            for (int i = 0; i < 3; i++)
            {
                lineX = line[i + 1];
                line[i + 1] = line[i];
                line[i] = lineX;
            }
            //读取新一行数据
            if (srcRead(objSrc, (unsigned char *)line[3], 1) == 1)
                readLine += 1;
            else
                break;
        }

        // printf("y1 %d y2 %d - readLine %d \r\n", y1, y2, readLine);

        //行像素遍历

        for (x = 0, xStep = 0; x < info->widthOut; x += 1, xStep += xDiv)
        {
            info->rgbOut[x] = (Zoom_Rgb){0, 0, 0};
            i_original_img_wnum = (int)xStep;
            dy = xStep - (int)xStep;
            for (int i = 0; i < 4; i++)
            {
                Bmdx = BSpline(i - dx - 1);
                for (int j = 0; j < 4; j++)
                {
                    Bndy = BSpline(j - dy - 1);
                    int y_point = i_original_img_wnum + j - 1;
                    y_point = (y_point < info->width) ? (y_point < 0 ? 0 : y_point ) : info->width - 1;
                    info->rgbOut[x].r += line[i][y_point].r * Bmdx * Bndy;
                    info->rgbOut[x].g += line[i][y_point].g * Bmdx * Bndy;
                    info->rgbOut[x].b += line[i][y_point].b * Bmdx * Bndy;
                }
            }
        }
        //输出一行数据
        distWrite(objDist, (unsigned char *)info->rgbOut, 1);
    }
}

/* 
    按照数据流的方式缩放图像(基于opencv的双三次插值算法)
*/
void _zoom_bicubic_stream_opencv(
    Zoom_Info *info,
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int))
{
    float fWStep = 0.0f, fHStep = 0.0f;
    int ii = 0, jj = 0;
    Zoom_Rgb * pCurr = 0;
    Zoom_Rgb * pSamp = 0;

    const float A = -0.75f;
    float coeffsX[4], coeffsY[4];
    float fx = 0.0f, fy = 0.0f;
    int sx = 0, sy = 0;
    short cbufX[4], cbufY[4];

    int mm = 0, nn = 0;
    int r_sum = 0, g_sum = 0, b_sum = 0;

    //当前读取行数
    int readLine = 0;
    //两行数据的指针,对应y1,y2来使用
    Zoom_Rgb *line[4];
    for (int i = 0; i < 4; i++)
    {
        line[i] = &info->rgb[info->width * i];
    }
    Zoom_Rgb *lineX;

    //读取新1行数据
    srcRead(objSrc, (unsigned char *)line[3], 1);
    for (int i = 0; i < 3; i++)
    {
        memcpy(line[i], line[3], info->width * 3);
    }

    fWStep = 1.0f * info->width / info->widthOut;
    fHStep = 1.0f * info->height / info->heightOut;
    pSamp = info->rgbOut;

    for(ii = 0; ii < info->heightOut; ii++)
    {
        fy = (float)((ii + 0.5) * fHStep - 0.5);
        sy = (int)floor(fy);
        fy -= sy;

        //读取足够的行数据(移动info->rgb中的行数据到能覆盖y1,y2所在行)
        while (readLine < sy + 2)
        {
            //后面数据往前挪
            for (int i = 0; i < 3; i++)
            {
                lineX = line[i + 1];
                line[i + 1] = line[i];
                line[i] = lineX;
            }
            //读取新一行数据
            if((sy + 2) < info->height)
            {
                if (srcRead(objSrc, (unsigned char *)line[3], 1) == 1)
                    readLine += 1;
                else
                    break;
            }
            else
            {
                memcpy(line[3], line[2], info->width * 3);
                readLine++;
            }
        }
        
        coeffsY[0] = ((A*(fy + 1) - 5*A)*(fy + 1) + 8 * A)*(fy + 1) - 4 * A;
		coeffsY[1] = ((A + 2)*fy - (A + 3))*fy*fy + 1;
		coeffsY[2] = ((A + 2)*(1 - fy) - (A + 3))*(1 - fy)*(1 - fy) + 1;
		coeffsY[3] = 1.f - coeffsY[0] - coeffsY[1] - coeffsY[2];

        cbufY[0] = (short)(coeffsY[0] * 2048);
		cbufY[1] = (short)(coeffsY[1] * 2048);
		cbufY[2] = (short)(coeffsY[2] * 2048);
		cbufY[3] = (short)(coeffsY[3] * 2048);
        // printf("cbufY:");
        // for(int i = 0; i < 4; i++)
        // {
        //     printf("%d\t", (short)(coeffsY[i] * 128));
        // }
        // printf("\r\n");

        for(jj = 0; jj < info->widthOut; jj++)
        {
            fx = (float)((jj + 0.5) * fWStep - 0.5);
            sx = (int)floor(fx);
            fx -= sx;

            coeffsX[0] = ((A*(fx + 1) - 5*A)*(fx + 1) + 8*A)*(fx + 1) - 4*A;
			coeffsX[1] = ((A + 2)*fx - (A + 3))*fx*fx + 1;
			coeffsX[2] = ((A + 2)*(1 - fx) - (A + 3))*(1 - fx)*(1 - fx) + 1;
			coeffsX[3] = 1.f - coeffsX[0] - coeffsX[1] - coeffsX[2];
			
			cbufX[0] = (short)(coeffsX[0] * 2048);
			cbufX[1] = (short)(coeffsX[1] * 2048);
			cbufX[2] = (short)(coeffsX[2] * 2048);
			cbufX[3] = (short)(coeffsX[3] * 2048);

            // printf("cbufX:");
            // for(int i = 0; i < 4; i++)
            // {
            //     printf("%d\t", (short)(coeffsX[i] * 128));
            // }
            // printf("\r\n");

            for(mm = 0; mm < 4; mm++) // rows
            {
                pCurr = line[mm];
                for(nn = 0; nn < 4; nn++) // cols
                { 
                    r_sum += pCurr[clip(sx + nn - 1, 0, info->width)].r * cbufY[mm]*cbufX[nn];
                    g_sum += pCurr[clip(sx + nn - 1, 0, info->width)].g * cbufY[mm]*cbufX[nn];
                    b_sum += pCurr[clip(sx + nn - 1, 0, info->width)].b * cbufY[mm]*cbufX[nn];
                    // printf("axis_x: %d", clip(sx + nn - 1, 0, info->width));
                }
                // printf("\r\n");
            }
            r_sum >>= 22;
            g_sum >>= 22;
            b_sum >>= 22;
            (pSamp + jj)->r = clip(r_sum, 0, 256);
            (pSamp + jj)->g = clip(g_sum, 0, 256);
            (pSamp + jj)->b = clip(b_sum, 0, 256);
        }
        //输出一行数据
        distWrite(objDist, (unsigned char *)info->rgbOut, 1);
    }
}

/*
 *  多线程并行的方式来缩放图像(OpenCV的双三次插值算法)
 */
void _zoom_bicubic_opencv(Zoom_Info *info)
{
    float fWStep = 0.0f, fHStep = 0.0f;
    int ii = 0, jj = 0;
    Zoom_Rgb * pCurr = 0;

    const float A = -0.75f;
    float coeffsX[4], coeffsY[4];
    float fx = 0.0f, fy = 0.0f;
    int sx = 0, sy = 0;
    short cbufX[4], cbufY[4];

    int mm = 0, nn = 0;
    int r_sum = 0, g_sum = 0, b_sum = 0;

    fWStep = 1.0f * info->width / info->widthOut;
    fHStep = 1.0f * info->height / info->heightOut;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    for(ii = startLine; ii < endLine; ii++)
    {
        fy = (float)((ii + 0.5) * fHStep - 0.5);
        sy = (int)floor(fy);
        fy -= sy;

        coeffsY[0] = ((A*(fy + 1) - 5*A)*(fy + 1) + 8 * A)*(fy + 1) - 4 * A;
		coeffsY[1] = ((A + 2)*fy - (A + 3))*fy*fy + 1;
		coeffsY[2] = ((A + 2)*(1 - fy) - (A + 3))*(1 - fy)*(1 - fy) + 1;
		coeffsY[3] = 1.f - coeffsY[0] - coeffsY[1] - coeffsY[2];

        cbufY[0] = (short)(coeffsY[0] * 2048);
		cbufY[1] = (short)(coeffsY[1] * 2048);
		cbufY[2] = (short)(coeffsY[2] * 2048);
		cbufY[3] = (short)(coeffsY[3] * 2048);

        for(jj = 0; jj < info->widthOut; jj++)
        {
            fx = (float)((jj + 0.5) * fWStep - 0.5);
            sx = (int)floor(fx);
            fx -= sx;

            coeffsX[0] = ((A*(fx + 1) - 5*A)*(fx + 1) + 8*A)*(fx + 1) - 4*A;
			coeffsX[1] = ((A + 2)*fx - (A + 3))*fx*fx + 1;
			coeffsX[2] = ((A + 2)*(1 - fx) - (A + 3))*(1 - fx)*(1 - fx) + 1;
			coeffsX[3] = 1.f - coeffsX[0] - coeffsX[1] - coeffsX[2];
			
			cbufX[0] = (short)(coeffsX[0] * 2048);
			cbufX[1] = (short)(coeffsX[1] * 2048);
			cbufX[2] = (short)(coeffsX[2] * 2048);
			cbufX[3] = (short)(coeffsX[3] * 2048);

            for(mm = 0; mm < 4; mm++) // rows
            {
                pCurr = info->rgb + clip((sy + mm - 1), 0, info->height) * info->width;
                for(nn = 0; nn < 4; nn++) // cols
                { 
                    r_sum += pCurr[clip(sx + nn - 1, 0, info->width)].r * cbufY[mm]*cbufX[nn];
                    g_sum += pCurr[clip(sx + nn - 1, 0, info->width)].g * cbufY[mm]*cbufX[nn];
                    b_sum += pCurr[clip(sx + nn - 1, 0, info->width)].b * cbufY[mm]*cbufX[nn];
                }
            }
            r_sum >>= 22;
            g_sum >>= 22;
            b_sum >>= 22;
            info->rgbOut[ii * info->widthOut + jj].r = clip(r_sum, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].g = clip(g_sum, 0, 256);
            info->rgbOut[ii * info->widthOut + jj].b = clip(b_sum, 0, 256);
        }
    }
    //多线程,处理完成行数
    info->threadFinsh++;
}

/*
 *  多线程并行的方式来缩放图像(双三次插值算法)
 */
void _zoom_bicubic(Zoom_Info *info)
{
    float xStep, yStep, xDiv, yDiv;
    int x, y;

    float dx, dy; // delta_x and delta_y
    float Bmdx;   // Bspline m-dx
    float Bndy;   // Bspline dy-n
    int i_original_img_hnum, i_original_img_wnum; // Corresponding -y and -x of the original img
    int x_point, y_point;

    //多线程
    int startLine, endLine;
    //多线程,获得自己处理行信息
    startLine = info->lineDiv * (info->threadCount++);
    endLine = startLine + info->lineDiv;
    if (endLine > info->heightOut)
        endLine = info->heightOut;

    //步宽计算(注意谁除以谁,这里表示的是在输出图像上每跳动一行、列等价于源图像跳过的行、列量)
    xDiv = (float)info->width / info->widthOut;
    yDiv = (float)info->height / info->heightOut;

    //列像素遍历
    for (y = startLine, yStep = startLine * yDiv;
         y < endLine; y += 1, yStep += yDiv)
    {
        i_original_img_hnum = (int)yStep;
        dx = yStep - (int)yStep;

        // 行像素遍历
        for(x = 0, xStep = 0; x < info->widthOut; x += 1, xStep += xDiv)
        {
            i_original_img_wnum = (int)xStep;
            dy = xStep - (int)xStep;
            for(int i = 0; i < 4; i++)
            {
                Bmdx = BSpline(i - dx - 1);
                x_point = i_original_img_hnum + i - 1;
                x_point = (x_point < info->height) ? (x_point < 0 ? 0 : x_point) : info->height - 1;
                for(int j = 0; j < 4; j++)
                {
                    Bndy = BSpline(j - dy - 1);
                    y_point = i_original_img_wnum + j - 1;
                    y_point = (y_point < info->width) ? (y_point < 0 ? 0 : y_point ) : info->width - 1;
                    info->rgbOut[y * info->widthOut + x].r += info->rgb[x_point * info->width + y_point].r * Bmdx * Bndy;
                    info->rgbOut[y * info->widthOut + x].g += info->rgb[x_point * info->width + y_point].g * Bmdx * Bndy;
                    info->rgbOut[y * info->widthOut + x].b += info->rgb[x_point * info->width + y_point].b * Bmdx * Bndy;
                }
            }
        }
    }
    //多线程,处理完成行数
    info->threadFinsh++;
}


/*
 *  数据流处理(为避免大张图片占用巨大内存空间)
 *  参数:
 *      obj: 用户私有参数,在调用下面回调函数时传回给用户
 *      srcRead: 源图片行数据读取回调函数
 *             : 函数原型 int srcRead(void *obj, unsigned char *rgbLine, int line)
 *      distWrite: 输出图片行数据回调函数
 *             : 函数原型 int distWrite(void *obj, unsigned char *rgbLine, int line)
 *  说明: 关于回调函数的返回,返回成功读写行数,返回0结束
 */
void zoom_stream(
    void *objSrc, void *objDist,
    int (*srcRead)(void *, unsigned char *, int),
    int (*distWrite)(void *, unsigned char *, int),
    int width, int height,
    int *retWidth, int *retHeight,
    float zm,
    Zoom_Type zt)
{
    Zoom_Info info = {
        .width = width,
        .height = height,
        .widthOut = (int)(width * zm),
        .heightOut = (int)(height * zm),
    };

    //参数检查
    if (zm <= 0 || width < 1 || height < 1)
        return;

    //输入流,行缓冲内存准备(至少4行)
    info.rgb = (Zoom_Rgb *)calloc(info.width * 4, sizeof(Zoom_Rgb));
    //输出流,行缓冲内存准备(只需1行)
    info.rgbOut = (Zoom_Rgb *)calloc(info.widthOut, sizeof(Zoom_Rgb));

    //开始缩放
    if (zt == ZT_LINEAR)
        _zoom_linear_stream_opencv(&info, objSrc, objDist, srcRead, distWrite);
    else if (zt == ZT_NEAR)
        _zoom_near_stream(&info, objSrc, objDist, srcRead, distWrite);
    else if (zt == ZT_BICUBIC)
        _zoom_bicubic_stream_opencv(&info, objSrc, objDist, srcRead, distWrite);
    //返回
    if (retWidth)
        *retWidth = info.widthOut;
    if (retHeight)
        *retHeight = info.heightOut;

    //内内回收
    free(info.rgb);
    free(info.rgbOut);
}
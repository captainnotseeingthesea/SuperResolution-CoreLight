# -*- coding:utf-8 -*-
# @Time : 2022/2/26 0026 下午 12:40
# @Author: xuanyi
# @File : edi_rgb.py

import cv2
import numpy as np
import math
import sys
from pnsr_ssim import pnsr_ssim

weight_A = []
weight_B = []

# 完成一次downscale 2操作
def EDI_downscale(img):
    # initializing downgraded image
    w, h, c = img.shape
    imgo2 = np.zeros((w // 2, h // 2, c))

    # downgrading image
    for i in range(w // 2):
        for j in range(h // 2):
            for k in range(c):
                imgo2[i][j][k] = int(img[2 * i][2 * j][k])

    return imgo2.astype(img.dtype)


# 图像边缘检测算法，支持Canny和Sobel
def edge_detect(img, method):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)  # 转化为灰度图
    blur = cv2.GaussianBlur(img_gray, (3, 3), 0)  # 高斯滤波处理原图像降噪

    if method == "canny":
        edge_image = cv2.Canny(blur, 50, 150)
    elif method == "sobel":
        x = cv2.Sobel(blur, cv2.CV_16S, 1, 0)  # Sobel函数求完导数后会有负值，还有会大于255的值
        y = cv2.Sobel(blur, cv2.CV_16S, 0, 1)  # 使用16位有符号的数据类型，即cv2.CV_16S
        Scale_absX = cv2.convertScaleAbs(x)  # 转回uint8
        Scale_absY = cv2.convertScaleAbs(y)
        edge_image = cv2.addWeighted(Scale_absX, 0.5, Scale_absY, 0.5, 0)
    elif method == "none":
        w, h, c = img.shape
        edge_image = np.ones((w, h))
    else:
        exit("Please input correct edge detection method!")
    cv2.imwrite("edge.jpg", edge_image)
    return edge_image


# 使用NEDI算法完成upscale操作
# img：要进行upscale的图像
# m：NEDI算法的window大小
# method：完成边缘检测的算法
def EDI_upscale(img, m, method):
    # m should be equal to a power of 2
    if m % 2 != 0:
        m += 1

    # initializing image to be predicted
    w, h, c = img.shape
    imgo = np.zeros((w * 2, h * 2, c))
    edge = edge_detect(img, method)
    nedi_region = np.zeros((w, h))
    bicubic_img = cv2.resize(img, (0, 0), fx=2, fy=2, interpolation=cv2.INTER_LINEAR).astype(img.dtype)

    for i in range(w):
        for j in range(h):
            for k in range(c):
                imgo[2 * i][2 * j][k] = img[i][j][k]

    for i in range(math.floor(m / 2), w - math.floor(m / 2)):
        for j in range(math.floor(m / 2), h - math.floor(m / 2)):
            nedi_region[i][j] = edge[i][j]

    for i in range(w):
        for j in range(h):
            if nedi_region[i][j] == 0:
                for k in range(c):
                    imgo[2 * i + 1][2 * j + 1][k] = bicubic_img[2 * i + 1][2 * j + 1][k]
                    imgo[2 * i + 1][2 * j][k] = bicubic_img[2 * i + 1][2 * j][k]
                    imgo[2 * i][2 * j + 1][k] = bicubic_img[2 * i][2 * j + 1][k]

    y = np.zeros((m ** 2, 1))  # pixels in the window
    C = np.zeros((m ** 2, 4))  # interpolation neighbours of each pixel in the window

    # Reconstruct the points with the form of (2*i+1,2*j+1)
    for i in range(math.floor(m / 2), w - math.floor(m / 2)):
        for j in range(math.floor(m / 2), h - math.floor(m / 2)):
            if edge[i][j] != 0:
                for k in range(c):
                    tmp = 0
                    for ii in range(i - math.floor(m / 2), i + math.floor(m / 2)):
                        for jj in range(j - math.floor(m / 2), j + math.floor(m / 2)):
                            y[tmp][0] = imgo[2 * ii][2 * jj][k]
                            C[tmp][0] = imgo[2 * ii - 2][2 * jj - 2][k]
                            C[tmp][1] = imgo[2 * ii + 2][2 * jj - 2][k]
                            C[tmp][2] = imgo[2 * ii + 2][2 * jj + 2][k]
                            C[tmp][3] = imgo[2 * ii - 2][2 * jj + 2][k]
                            tmp += 1

                    # calculating weights
                    # a = (C^T * C)^(-1) * (C^T * y) = (C^T * C) \ (C^T * y)
                    a = np.matmul(np.matmul(np.linalg.pinv(np.matmul(np.transpose(C), C)), np.transpose(C)), y)
                    imgo[2 * i + 1][2 * j + 1][k] = np.matmul(
                        [imgo[2 * i][2 * j][k], imgo[2 * i + 2][2 * j][k], imgo[2 * i + 2][2 * j + 2][k],
                         imgo[2 * i][2 * j + 2][k]], a)

    # Reconstructed the points with the forms of (2*i+1,2*j) and (2*i,2*j+1)
    for i in range(math.floor(m / 2), w - math.floor(m / 2)):
        for j in range(math.floor(m / 2), h - math.floor(m / 2)):
            if edge[i][j] != 0:
                for k in range(c):
                    tmp = 0
                    for ii in range(i - math.floor(m / 2), i + math.floor(m / 2)):
                        for jj in range(j - math.floor(m / 2), j + math.floor(m / 2)):
                            y[tmp][0] = imgo[2 * ii + 1][2 * jj - 1][k]
                            C[tmp][0] = imgo[2 * ii - 1][2 * jj - 1][k]
                            C[tmp][1] = imgo[2 * ii + 1][2 * jj - 3][k]
                            C[tmp][2] = imgo[2 * ii + 3][2 * jj - 1][k]
                            C[tmp][3] = imgo[2 * ii + 1][2 * jj + 1][k]
                            tmp += 1

                    # calculating weights
                    # a = (C^T * C)^(-1) * (C^T * y) = (C^T * C) \ (C^T * y)
                    a = np.matmul(np.matmul(np.linalg.pinv(np.matmul(np.transpose(C), C)), np.transpose(C)), y)
                    imgo[2 * i + 1][2 * j][k] = np.matmul(
                        [imgo[2 * i][2 * j][k], imgo[2 * i + 1][2 * j - 1][k], imgo[2 * i + 2][2 * j][k],
                         imgo[2 * i + 1][2 * j + 1][k]], a)
                    imgo[2 * i][2 * j + 1][k] = np.matmul(
                        [imgo[2 * i - 1][2 * j + 1][k], imgo[2 * i][2 * j][k], imgo[2 * i + 1][2 * j + 1][k],
                         imgo[2 * i][2 * j + 2][k]], a)

    # Fill the rest with bilinear interpolation
    np.clip(imgo, 0, 255.0, out=imgo)
    return imgo.astype(img.dtype)


# 顶层的对图像处理的封装方法
# img：待处理的图像
# m：NEDI算法中window的大小
# s：scale的尺寸（<1进行downscale，>1进行upscale）
# method：边缘检测的算法
def EDI_predict(img, m, s, method="canny"):
    try:
        w, h, c = img.shape
    except:
        sys.exit("Error input: Please input a valid RGB image!")

    output_type = img.dtype

    if s <= 0:
        sys.exit("Error input: Please input s > 0!")

    elif s == 1:
        print("No need to rescale since s = 1")
        return img

    elif s < 1:
        # Calculate how many times to do the EDI downscaling
        n = math.floor(math.log(1 / s, 2))

        # Downscale to the expected size with linear interpolation
        linear_factor = 1 / s / math.pow(2, n)
        if linear_factor != 1:
            img = cv2.resize(img, dsize=(int(h / linear_factor), int(w / linear_factor)),
                             interpolation=cv2.INTER_LINEAR).astype(output_type)

        for i in range(n):
            img = EDI_downscale(img)
        return img

    elif s < 2:
        # Linear Interpolation is enough for upscaling not over 2
        return cv2.resize(img, dsize=(int(h * s), int(w * s)), interpolation=cv2.INTER_LINEAR).astype(output_type)

    else:
        # Calculate how many times to do the EDI upscaling
        n = math.floor(math.log(s, 2))
        for i in range(n):
            img = EDI_upscale(img, m, method)

        # Upscale to the expected size with linear interpolation
        linear_factor = s / math.pow(2, n)
        if linear_factor == 1:
            return img.astype(output_type)

        # Update new shape
        w, h = img.shape
        return cv2.resize(img, dsize=(int(h * linear_factor), int(w * linear_factor)),
                          interpolation=cv2.INTER_LINEAR).astype(output_type)


if __name__ == '__main__':
    img_path = "Set14/original/lenna.png"
    img = cv2.imread(img_path)

    # 完成downscale
    factor = 4
    downscale_img = EDI_predict(img, 4, 1 / factor)
    cv2.imwrite("lenna_downscale.jpg", downscale_img)

    # 使用线性插值
    linear_img = cv2.resize(downscale_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_LINEAR)
    bicubic_img = cv2.resize(downscale_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_CUBIC)
    cv2.imwrite("linear_lenna.jpg", linear_img)
    cv2.imwrite("bicubic_lenna.jpg", bicubic_img)

    # 使用NEDI进行插值（非边缘部分选择Bicubic算法，边缘部分使用NEDI算法）
    size = 4
    nedi_img = EDI_predict(downscale_img, size, factor, "canny")
    cv2.imwrite("nedi_canny_lenna.jpg", nedi_img)

    # 输出各种upscaling算法的pnsr和ssim
    src_img_path = img_path
    upscale_img_paths = ["linear_lenna.jpg", "bicubic_lenna.jpg", "nedi_lenna.jpg", "nedi_sobel_lenna.jpg", "nedi_canny_lenna.jpg"]
    psnr, ssim = pnsr_ssim(src_img_path, upscale_img_paths)
    print("Method", "PSNR", "SSIM")
    for i in range(len(upscale_img_paths)):
        method = upscale_img_paths[i].split("/")[-1].split("_")[0]
        print(method, psnr[i].numpy(), ssim[i].numpy())

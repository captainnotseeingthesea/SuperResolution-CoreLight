# -*- coding:utf-8 -*-
# @Time : 2022/2/25 0025 上午 11:48
# @Author: xuanyi
# @File : downscale.py
import cv2 as cv
import numpy as np
import sys

def downscale(img, factor):

    # initializing downgraded image
    w, h, c = img.shape
    dst_img = np.zeros((w//factor, h//factor, c))

    # downgrading image
    for i in range(w//factor):
        for j in range(h//factor):
            for k in range(c):
                dst_img[i][j][k] = img[factor*i][factor*j][k]
    return dst_img.astype(img.dtype)


if __name__ == '__main__':
    if(len(sys.argv) < 3):
        print("too few arguments!")
        exit()
    src_img = cv.imread(sys.argv[1])
    dst_img = downscale(src_img, int(sys.argv[2]))
    # show
    cv.imshow('downscale image', dst_img)
    # save
    cv.imwrite(sys.argv[3], dst_img)

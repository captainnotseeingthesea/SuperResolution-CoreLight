import cv2
import numpy as np
import math
import sys
from pnsr_ssim import pnsr_ssim
"""
Author:

    hu.leying@columbia.edu

Usage:

    EDI_predict(img, m, s)
    
    # img is the input image
    # m is the sampling window size, not scaling factor! The larger the m, more blurry the image. Ideal m >= 4. 
    # s is the scaling factor, support any s > 0 (e.g. use s=2 to upscale by 2, use s=0.5 to downscale by 2) 
    
If you want to directly call EDI_upscale to upscale image by the scale of 2:

    EDI_upscale(img, m) 

    # m should be the power of 2. Will increment by 1 if input m is odd 
    
If you want to directly call EDI_downscale to downscale image by the scale of 2:

    EDI_downscale(img) 

"""


def gray_image(img_path, out_path):
    #读取灰度图
    img_gray = cv2.imread(img_path,cv2.IMREAD_GRAYSCALE)
    cv2.imwrite(out_path, img_gray)
    return img_gray


def EDI_downscale(img):
    
    # initializing downgraded image
    w, h = img.shape
    imgo2 = np.zeros((w//2, h//2))

    # downgrading image
    for i in range(w//2):
        for j in range(h//2):
            imgo2[i][j] = int(img[2*i][2*j])
            
    return imgo2.astype(img.dtype)

def EDI_upscale(img, m):
    
    # m should be equal to a power of 2
    if m%2 != 0:
        m += 1
        
    # initializing image to be predicted
    w, h = img.shape
    imgo = np.zeros((w*2,h*2))
    
    # Place low-resolution pixels
    for i in range(w):
        for j in range(h):
            imgo[2*i][2*j] = img[i][j]    

    y = np.zeros((m**2,1)) # pixels in the window
    C = np.zeros((m**2,4)) # interpolation neighbours of each pixel in the window
    
    # Reconstruct the points with the form of (2*i+1,2*j+1)
    for i in range(math.floor(m/2), w-math.floor(m/2)):
        for j in range(math.floor(m/2), h-math.floor(m/2)):
            tmp = 0
            for ii in range(i-math.floor(m/2), i+math.floor(m/2)):
                for jj in range(j-math.floor(m/2), j+math.floor(m/2)):
                    y[tmp][0] = imgo[2*ii][2*jj]
                    C[tmp][0] = imgo[2*ii-2][2*jj-2]
                    C[tmp][1] = imgo[2*ii+2][2*jj-2]
                    C[tmp][2] = imgo[2*ii+2][2*jj+2]
                    C[tmp][3] = imgo[2*ii-2][2*jj+2]
                    tmp += 1

            # calculating weights
            # a = (C^T * C)^(-1) * (C^T * y) = (C^T * C) \ (C^T * y)
            a = np.matmul(np.matmul(np.linalg.pinv(np.matmul(np.transpose(C),C)), np.transpose(C)), y)
            imgo[2*i+1][2*j+1] = np.matmul([imgo[2*i][2*j], imgo[2*i+2][2*j], imgo[2*i+2][2*j+2], imgo[2*i][2*j+2]], a)
            
    # Reconstructed the points with the forms of (2*i+1,2*j) and (2*i,2*j+1)
    for i in range(math.floor(m/2), w-math.floor(m/2)):
        for j in range(math.floor(m/2), h-math.floor(m/2)):
            tmp = 0
            for ii in range(i-math.floor(m/2), i+math.floor(m/2)):
                for jj in range(j-math.floor(m/2), j+math.floor(m/2)):
                    y[tmp][0] = imgo[2*ii+1][2*jj-1]
                    C[tmp][0] = imgo[2*ii-1][2*jj-1]
                    C[tmp][1] = imgo[2*ii+1][2*jj-3]
                    C[tmp][2] = imgo[2*ii+3][2*jj-1]
                    C[tmp][3] = imgo[2*ii+1][2*jj+1]
                    tmp += 1

            # calculating weights
            # a = (C^T * C)^(-1) * (C^T * y) = (C^T * C) \ (C^T * y)
            a = np.matmul(np.matmul(np.linalg.pinv(np.matmul(np.transpose(C),C)), np.transpose(C)), y)
            imgo[2*i+1][2*j] = np.matmul([imgo[2*i][2*j], imgo[2*i+1][2*j-1], imgo[2*i+2][2*j], imgo[2*i+1][2*j+1]], a)
            imgo[2*i][2*j+1] = np.matmul([imgo[2*i-1][2*j+1], imgo[2*i][2*j], imgo[2*i+1][2*j+1], imgo[2*i][2*j+2]], a)

    # Fill the rest with bilinear interpolation
    np.clip(imgo, 0, 255.0, out=imgo)
    imgo_bilinear = cv2.resize(img, dsize=(h*2,w*2), interpolation=cv2.INTER_LINEAR)
    imgo[imgo==0] = imgo_bilinear[imgo==0]
    
    return imgo.astype(img.dtype)

def EDI_predict(img, m, s):

    try:
        print(img.shape)
        w, h = img.shape
    except:
        sys.exit("Error input: Please input a valid grayscale image!")
    
    output_type = img.dtype

    if s <= 0:
        sys.exit("Error input: Please input s > 0!")
        
    elif s == 1:
        print("No need to rescale since s = 1")
        return img
    
    elif s < 1:
        # Calculate how many times to do the EDI downscaling
        n = math.floor(math.log(1/s, 2))
        
        # Downscale to the expected size with linear interpolation
        linear_factor = 1/s / math.pow(2, n)
        if linear_factor != 1:
            img = cv2.resize(img, dsize=(int(h/linear_factor),int(w/linear_factor)), interpolation=cv2.INTER_LINEAR).astype(output_type)

        for i in range(n):
            img = EDI_downscale(img)
        return img
        
    elif s < 2:
        # Linear Interpolation is enough for upscaling not over 2
        return cv2.resize(img, dsize=(int(h*s),int(w*s)), interpolation=cv2.INTER_LINEAR).astype(output_type)
    
    else:
        # Calculate how many times to do the EDI upscaling
        n = math.floor(math.log(s, 2))
        for i in range(n):
            img = EDI_upscale(img, m)
        
        # Upscale to the expected size with linear interpolation
        linear_factor = s / math.pow(2, n)
        if linear_factor == 1:
            return img.astype(output_type)

        # Update new shape
        w, h = img.shape
        return cv2.resize(img, dsize=(int(h*linear_factor),int(w*linear_factor)), interpolation=cv2.INTER_LINEAR).astype(output_type)


if __name__ == '__main__':
    img = "Set14/original/lenna.png"

    # 转为灰度图像
    gray_img = gray_image(img, "gray_lenna.jpg")

    # 完成downscale 2
    factor = 2
    downscale_gray_img = EDI_predict(gray_img, 4, 0.5)
    cv2.imwrite("downscale_gray_lenna.jpg", downscale_gray_img)

    # 使用线性插值
    linear_gray_img = cv2.resize(downscale_gray_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_LINEAR)
    bicubic_gray_img = cv2.resize(downscale_gray_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_CUBIC)
    cv2.imwrite("linear_gray_lenna.jpg", linear_gray_img)
    cv2.imwrite("bicubic_gray_lenna.jpg", bicubic_gray_img)

    # 使用NEDI进行插值
    size = 4
    nedi_gray_img = EDI_predict(downscale_gray_img, size, factor)
    cv2.imwrite("nedi_gray_lenna.jpg", nedi_gray_img)

    # 输出各种upscaling算法的pnsr和ssim
    src_img_path = "gray_lenna.jpg"
    upscale_img_paths = ["linear_gray_lenna.jpg", "bicubic_gray_lenna.jpg", "nedi_gray_lenna.jpg"]
    psnr, ssim = pnsr_ssim(src_img_path, upscale_img_paths)
    print("Method", "PSNR", "SSIM")
    for i in range(len(upscale_img_paths)):
        method = upscale_img_paths[i].split("/")[-1].split("_")[0]
        print(method, psnr[i].numpy(), ssim[i].numpy())

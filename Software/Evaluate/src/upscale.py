import sys
import os
import cv2
import numpy as np

if __name__ == "__main__":
    if(len(sys.argv) < 5):
        print("too few args!!")
        exit(0)

    if(not os.path.isfile(sys.argv[1])):
        print("Invalid input image!!")
        exit(0)

    sharpen_method = 1 # No sharpen method is exploited
    if(len(sys.argv) > 5):
        sharpen_method = int(sys.argv[5])

    src_img = cv2.imread(sys.argv[1]) # 原图片
    factor = int(sys.argv[3]) # 上采样系数
    method = int(sys.argv[4]) # 上采样方法
    if(method == 0): # 最邻近插值
        dst_img = cv2.resize(src_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_NEAREST)
    elif(method == 1): # 双线性插值
        dst_img = cv2.resize(src_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_LINEAR)
    elif(method == 2): # 双三次插值
        dst_img = cv2.resize(src_img, (0, 0), fx=factor, fy=factor, interpolation=cv2.INTER_CUBIC)
    elif(method == 3): # 区域插值
        dst_img = cv2.resize(src_img, (0,0), fx=factor, fy=factor, interpolation=cv2.INTER_AREA)
    elif(method == 4): # Lanczos插值
        dst_img = cv2.resize(src_img, (0,0), fx=factor, fy=factor, interpolation=cv2.INTER_LANCZOS4)
    else:
        print(f"Method {method} is unsupported!!!")
        exit(0)

    if(sharpen_method == 1):
        gaussian = cv2.GaussianBlur(src_img, (5, 5), 6)
        dst_img = cv2.addWeighted(src_img, 2, gaussian, -1, 0)
    elif(sharpen_method == 2):
        kernel_sharpen = np.array([
        [-1,-1,-1],
        [-1,9,-1],
        [-1,-1,-1]])
        dst_img = cv2.filter2D(dst_img,-1,kernel_sharpen)
    elif(sharpen_method == 3):
        kernel_sharpen = np.array([
        [1,1,1],
        [1,-7,1],
        [1,1,1]])
        dst_img = cv2.filter2D(dst_img,-1,kernel_sharpen)
    elif(sharpen_method == 4):
        kernel_sharpen = np.array([
        [-1,-1,-1,-1,-1],
        [-1,2,2,2,-1],
        [-1,2,8,2,-1],
        [-1,2,2,2,-1], 
        [-1,-1,-1,-1,-1]])/8.0
        dst_img = cv2.filter2D(dst_img,-1,kernel_sharpen)
    elif(sharpen_method == 5):
        kernel_sharpen = np.array([
        [0,-1,0],
        [-1,5,-1],
        [0,-1,0]])
        dst_img = cv2.filter2D(dst_img,-1,kernel_sharpen)
    elif(sharpen_method == 6):
        gaussian = cv2.GaussianBlur(dst_img, (0, 0), 25)
        dst_img = cv2.addWeighted(dst_img, 1.5, gaussian, -0.5, 0)
    elif(sharpen_method == 7):
        blur_laplace = cv2.Laplacian(dst_img, -1)
        dst_img      = cv2.addWeighted(dst_img, 1, blur_laplace, -0.5, 0)
    elif(sharpen_method == 8):
        kernel_sharpen = np.array([
        [0,1,0],
        [1,-3,1],
        [0,1,0]])
        dst_img = cv2.filter2D(dst_img,-1,kernel_sharpen)
    else:
        print(f"Sharpening Method {sharpen_method} is unsupported!!!")
        exit(0)

    cv2.imwrite(sys.argv[2], dst_img)

from ast import arg
import sys
import os
import cv2

if __name__ == "__main__":
    if(len(sys.argv) < 5):
        print("too few args!!")
        exit(0)

    if(not os.path.isfile(sys.argv[1])):
        print("Invalid input image!!")
        exit(0)

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
    cv2.imwrite(sys.argv[2], dst_img)

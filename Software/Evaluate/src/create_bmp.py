# -*- coding: utf-8 -*-
import cv2
import numpy as np

# 生成一张图片
def create_pic():
    height = 2160
    width = 3840
    img = np.zeros([height, width, 3], dtype=np.uint8)
    # 遍历每个像素点，并进行赋值
    for i in range(height):
        for j in range(width // 4):
            for k in range(4):
                img[i, j * 4 + k, :] = [j % 100, 0, 0]

    cv2.imwrite("image.bmp", img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

if __name__ == '__main__':
    create_pic()

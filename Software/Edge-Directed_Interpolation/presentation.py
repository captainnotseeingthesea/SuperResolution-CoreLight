# -*- coding:utf-8 -*-
# @Time : 2022/2/25 0025 下午 12:27
# @Author: xuanyi
# @File : presentation.py

from PIL import Image
import matplotlib.pyplot as plt

img_ground_truth = Image.open("./Set14/original/lenna.png")
img_linear = Image.open("./linear_lenna.jpg")
img_bicubic = Image.open("./bicubic_lenna.jpg")
img_nedi = Image.open("./nedi_lenna.jpg")
img_nedi_sobel = Image.open("./nedi_sobel_lenna.jpg")
img_nedi_canny = Image.open("./nedi_canny_lenna.jpg")

plt.figure(facecolor='white') #设置窗口样式
plt.suptitle('Multi_Upscaling_Image') # 图片名称

plt.subplot(2, 3, 1)
plt.title("Groud_Truth")
plt.imshow(img_ground_truth)
plt.axis("off")

plt.subplot(2, 3, 2)
plt.title("Linear")
plt.imshow(img_linear)
plt.axis("off")

plt.subplot(2, 3, 3)
plt.title("Bicubic")
plt.imshow(img_bicubic)
plt.axis("off")

plt.subplot(2, 3, 4)
plt.title("NEDI")
plt.imshow(img_nedi)
plt.axis("off")

plt.subplot(2, 3, 5)
plt.title("NEDI_Sobel")
plt.imshow(img_nedi_sobel)
plt.axis("off")

plt.subplot(2, 3, 6)
plt.title("NEDI_Canny")
plt.imshow(img_nedi_canny)
plt.axis("off")

plt.show()

# -*- coding:utf-8 -*-
# @Time : 2022/2/25 0025 下午 13:06
# @Author: xuanyi
# @File : pnsr_ssim.py

import tensorflow as tf


# 计算upscaling后图片的PSNR和SSIM值
# src_img_path：原图片的路径
# upscale_img_paths：upscaling图片的路径（多个）
def pnsr_ssim(src_img_path, upscale_img_paths):
    upscale_imgs = []
    ssim = []
    psnr = []
    src_img = tf.image.decode_jpeg(tf.io.read_file(src_img_path))
    for upscale_path in upscale_img_paths:
        upscale_imgs.append(tf.image.decode_jpeg(tf.io.read_file(upscale_path)))
        psnr.append(tf.image.psnr(src_img, upscale_imgs[-1], max_val=255))
        ssim.append(tf.image.ssim(src_img, upscale_imgs[-1], max_val=255))
    return psnr, ssim


if __name__ == '__main__':
    src_img_path = "mountain.jpg"
    upscale_img_paths = ["upscale_LINEAR.jpg", "upscale_CUBIC.jpg"]
    psnr, ssim = pnsr_ssim(src_img_path, upscale_img_paths)
    print("Method", "PSNR", "SSIM")
    for i in range(len(upscale_img_paths)):
        method = upscale_img_paths[i].split("/")[-1].split("_")[0]
        print(method, psnr[i].numpy(), ssim[i].numpy())

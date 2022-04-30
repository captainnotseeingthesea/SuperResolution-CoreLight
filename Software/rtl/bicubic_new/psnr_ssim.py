from skimage.metrics import peak_signal_noise_ratio, structural_similarity
import cv2
img1 = cv2.imread("49_4k.bmp")
img2 = cv2.imread("49.bmp")

psnr = peak_signal_noise_ratio(img1, img2)
ssim = structural_similarity(img1, img2, multichannel=True)
print('psnr:{}, ssim:{}', psnr, ssim)


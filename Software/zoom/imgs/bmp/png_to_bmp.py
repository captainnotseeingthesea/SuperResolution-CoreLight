import numpy as np
import cv2

def png_to_bmp(img):
    img_encode = cv2.imencode('.bmp', img)[1]
    return img_encode

for i in range(21):
    img = cv2.imdecode(np.fromfile("../png/"+str(i)+".png", dtype=np.uint8), -1)
    img_encode = png_to_bmp(img)
    with open("./"+str(i)+".bmp", 'wb') as f:
        f.write(img_encode)


import argparse
import os
import glob
from pathlib import Path
from natsort import natsort
import cv2

""" 
    Find all the files with the given pattern
"""
def fiFindByWildcard(wildcard):
    return natsort.natsorted(glob.glob(wildcard, recursive=True))

""" 
    Downscale the single image
"""
def downscale_image(exe, src_path, dst_path, factor):
    img = cv2.imread(src_path)
    img_h, img_w, img_c = img.shape
    imgo_w = img_w // factor
    imgo_h = img_h // factor
    para = f'{exe} {src_path} {imgo_w} {imgo_h} {dst_path}'
    os.system(para)
    print(para)

""" 
    Downscale all the images in the directory
"""
def downscale_dir_imgs(exe, src_path, dst_path, factor):
    src_paths = fiFindByWildcard(os.path.join(src_path, f'*.{type}'))
    dst_paths = []
    for path in src_paths:
        dst_paths.append(os.path.join(dst_path, path.split('/')[-1]))

    for pathSrc, pathDst in zip(src_paths, dst_paths):
        downscale_image(exe, pathSrc, pathDst, factor)
    
    print(f"Downscaling {len(dst_paths)} imgs complete!!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Downscaling the images in a batch")
    parser.add_argument("-exe", default="", type=str, help="The path of the execution file conducting downscaling function")
    parser.add_argument("-src", default='', type=str, help="The path of the dir containing GT images")
    parser.add_argument('-dst', default='', type=str, help="The path of the dir to save the downscaled images")
    parser.add_argument('-type', default="bmp", help="The type of images to process")
    parser.add_argument("-factor", default=4, type=int, help="The downscaling factor")
    args = parser.parse_args()

    exe = args.exe
    src_dir = args.src
    dst_dir = args.dst
    type = args.type
    factor = args.factor

    if len(src_dir) > 0 and len(dst_dir) > 0 and len(exe) > 0:
        if(Path(src_dir).exists() and Path(exe).exists()):
            if(not Path(dst_dir).exists()):
                os.makedirs(dst_dir, exist_ok=True)
        downscale_dir_imgs(exe, src_dir, dst_dir, factor)
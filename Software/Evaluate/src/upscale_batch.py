import argparse
import os
import glob
from pathlib import Path
from importlib_metadata import method_cache
from natsort import natsort

""" 
    Find all the files with the given pattern
"""
def fiFindByWildcard(wildcard):
    return natsort.natsorted(glob.glob(wildcard, recursive=True))

""" 
    Upscale the single image
"""
def upscale_image(exe, src_path, dst_path, factor, method):
    para = f'{exe} {src_path} {dst_path} {factor} {method}'
    os.system(para)
    print(para)

""" 
    Upscale all the images in the directory
"""
def upscale_dir_imgs(exe, src_path, dst_path, factor, method):
    src_paths = fiFindByWildcard(os.path.join(src_path, f'*.{type}'))
    dst_paths = []
    for path in src_paths:
        dst_paths.append(os.path.join(dst_path, path.split('/')[-1]))

    for pathSrc, pathDst in zip(src_paths, dst_paths):
        upscale_image(exe, pathSrc, pathDst, factor, method)
    
    print(f"Upscaling {len(dst_paths)} imgs complete!!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Upscaling the images in a batch")
    parser.add_argument("-exe", default="", type=str, help="The path of the execution file conducting upscaling function")
    parser.add_argument("-src", default='', type=str, help="The path of the dir containing downscaled images")
    parser.add_argument('-dst', default='', type=str, help="The path of the dir to save the upscaled images")
    parser.add_argument('-type', default="bmp", help="The type of images to process")
    parser.add_argument("-factor", default=4, type=int, help="The upscaling factor")
    parser.add_argument("-method", default=2, type=int, help="Method to upscale images, 0 : Near, 1 : Linear, 2 : BICUBIC")
    args = parser.parse_args()

    exe = args.exe
    src_dir = args.src
    dst_dir = args.dst
    type = args.type
    factor = args.factor
    method = args.method

    if len(src_dir) > 0 and len(dst_dir) > 0 and len(exe) > 0:
        if(Path(src_dir).exists()):
            if(not Path(dst_dir).exists()):
                os.makedirs(dst_dir, exist_ok=True)
        else:
            print("No such source dir!!!")
            exit(0)
    else:
        print("Invalid input arguments!!")
        exit(0)
    upscale_dir_imgs(exe, src_dir, dst_dir, factor, method)


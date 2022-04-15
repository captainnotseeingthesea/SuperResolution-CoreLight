#!/usr/bin/python3

from PIL import Image;
import numpy as np;
import os;
import sys;

def bmp2bin(bmpname = "", binname = ""):
    img = Image.open(bmpname);
    a = np.array(img);
    print("Transform "+bmpname+" to "+binname);
    height, width = a.shape[0], a.shape[1];

    with open(binname, "w") as f:
        for j in range(height):
            for i in range(width):
                r,g,b = format(a[j,i,0], "02x"), format(a[j,i,1], "02x"), format(a[j,i,2], "02x")
                f.writelines([r, g, b, os.linesep]);


def bin2bmp(binname = "", bmpname = "", height=None, width=None):
    lines = [];
    with open(binname, "r") as f:
        lines = f.readlines();
    print("Transform "+binname+" to "+bmpname);
    a = np.zeros((height, width, 3), dtype=np.uint8);
    i = 0;
    j = 0;
    for line in lines:
        r,g,b = line[0:2], line[2:4], line[4:];
        a[j,i,0] = int(r, 16);
        a[j,i,1] = int(g, 16);
        a[j,i,2] = int(b, 16);
        if(i == width-1):
            i = 0;
            j += 1;
        else:
            i += 1;
    
    img = Image.fromarray(a);
    img.save(bmpname)


if(sys.argv[1] == "bmp2bin"):
    bmp2bin(bmpname=sys.argv[2], binname=sys.argv[3]);
elif(sys.argv[1] == "bin2bmp"):
    bin2bmp(binname=sys.argv[2], bmpname=sys.argv[3], height=int(sys.argv[4]), width=int(sys.argv[5]));
else:
    print("bmp_bin: error, no such funtion called %s", sys.argv[1]);

#!/usr/bin/python3

from PIL import Image;
import numpy as np;
import os;
import sys;

def bmp2bin(bmpname = "", binname = ""):
    img = Image.open(bmpname);
    a = np.array(img);

    height, width = a.shape[0], a.shape[1];
    apaddig = np.zeros((height+3, width+3, 3), dtype=np.uint8);
    for j in range(height):
        for i in range(width):
            apaddig[j+1][i+1] = a[j][i];
    
    for i in range(width):
        apaddig[0][i+1] = a[0][i];
        apaddig[height+1][i+1] = a[height-1][i];
        apaddig[height+2][i+1] = a[height-1][i];

    for j in range(height):
        apaddig[j+1][0] = a[j][0];
        apaddig[j+1][width+1] = a[j][width-1];
        apaddig[j+2][width+2] = a[j][width-1];

    with open(binname, "w") as f:
        for j in range(height+3):
            for i in range(width+3):
                r,g,b = format(apaddig[j,i,0], "02x"), format(apaddig[j,i,1], "02x"), format(apaddig[j,i,2], "02x");
                f.writelines([r, g, b, os.linesep]);
    
    print("\nTransformed "+bmpname+" to "+binname+"\n");


def bin2bmp(binname = "", bmpname = "", height=None, width=None):
    lines = [];
    with open(binname, "r") as f:
        lines = f.readlines();

    a = np.zeros((height, width, 3), dtype=np.uint8);
    i = 0;
    j = 0;
    for line in lines:
        b,g,r = line[0:2], line[2:4], line[4:];
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

    print("\nTransformed "+binname+" to "+bmpname+"\n");


if(sys.argv[1] == "bmp2bin"):
    bmp2bin(bmpname=sys.argv[2], binname=sys.argv[3]);
elif(sys.argv[1] == "bin2bmp"):
    bin2bmp(binname=sys.argv[2], bmpname=sys.argv[3], height=int(sys.argv[4]), width=int(sys.argv[5]));
else:
    print("\nbmp_bin: error, no such funtion called %s\n", sys.argv[1]);

print("\nbmp_bin processing finished\n");
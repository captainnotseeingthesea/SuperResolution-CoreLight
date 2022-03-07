#!/bin/sh
cd jpg
echo "generate png..."
python3 add_trans.py
echo "generate bmp..."
cd ../bmp
python3 png_to_bmp.py
echo "generate png_1k..."
cd ../png_1k
source downscale_png.sh
echo "generate bmp_1k..."
cd ../bmp_1k
source downscale_bmp.sh
echo "generate jpg_1k..."
cd ../jpg_1k
source downscale_jpg.sh
cd ..



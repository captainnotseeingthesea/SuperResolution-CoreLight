#!/bin/sh
for ((i = 0; i < 21; i++))
do
    python3 ../../../Edge-Directed_Interpolation/downscale.py ../bmp/$i.bmp 4 ../bmp_1k/$i.bmp
done

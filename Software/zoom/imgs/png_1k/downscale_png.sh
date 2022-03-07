#!/bin/sh
for ((i = 0; i < 21; i++))
do
    python3 ../../../Edge-Directed_Interpolation/downscale.py ../png/$i.png 4 ../png_1k/$i.png
done

#!/bin/sh
for ((i = 0; i < 21; i++))
do
    python3 ../../../Edge-Directed_Interpolation/downscale.py ../jpg/$i.jpg 4 ../jpg_1k/$i.jpg
done

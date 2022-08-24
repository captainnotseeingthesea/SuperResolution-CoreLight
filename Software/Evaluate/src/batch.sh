#!/bin/bash
make

# Downscale all the images contained in '../GT' to '../downscaled' using the function 'bin/downscale'
python3 downscale_batch.py -exe bin/downscale -src ../GT/ -dst ../downscaled/

# Upscale all the images contained in '../downscaled' to '../upscaled' using the function '../../zoom/app' 
python3 upscale_batch.py -exe ../../zoom/app -src ../downscaled/ -dst ../upscaled/ -method 2
python3 upscale_batch.py -exe 'python upscale.py' -src ../downscaled/ -dst ../linear_upscaled/ -method 2

# Measure the quality of the upscaled images
python3 Measure.py -dirA ../GT/ -dirB ../upscaled/





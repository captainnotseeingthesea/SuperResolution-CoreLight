## Structure of the code
- bicubic_mult.v
    - Basic multiplication operator, whose inputs are a weight data and an image pixel data.
- bicubic_vercotr_mult.v
    - Vector multiplication operator, which has an input length of 4 for a vector of weight data and a vector of image data.
- bicubic_verctor_mult_matrix.v
    - Vector multiplication matrix operator, it's now not used!
- bicubic_upsample.v
    - The upsample module, used 9 clock to generate the 16 interpolations.
- bicubic_read_bmp.v
    - Read the initial image for interpolation
- line_buffer.v
    - The line buffer module
- buffer.v
    - Buffer control module, currently used to provide data to the upsampleing module
- dffs.v
    - Provide general DFF
- gen_bmp.py
    - Generate the result image
- sim_main.cpp
    - For verilator simulation

## Result
I used two images of different size (11*6, 960*540) and interpolated them each by the factor of 4, respectively, the result is ![before -w100](2.bmp) ![after](test.bmp)

1k ![before](49_1k.bmp)  4k_interpolation ![after](49_4k.bmp)4k_origin ![origin](49.bmp) 


The comparation result of the 2nd img is :

| Method | PSNR   | SSIM | lpips |
|  ----  |  ----  | ---- | ---- |
|    -   | 31.25 | 0.88 | 0.332 |

Note : Since the libarry is used, there may be differences with the official one
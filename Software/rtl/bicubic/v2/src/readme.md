
## Structure of the code
- bicubic_mult.v
    - Basic multiplication operator, whose inputs are a weight data and an image pixel data.
- bicubic_vecoter_mult.v
    - Vector multiplication operator, which has an input length of 4 for a vector of weight data and a vector of image data.
- bicubic_pvector_mult_wmatrix.v
    - Pixel vector multiplication weight matrix operator.
- bicubic_wvector_mult_pmatrix.v
    - Weight vector multiplication pixel matrix operator.
- bicubic_upsample.v
    - The upsample module.
- buffer_sram.v
    - Buffer control module, currently used to provide data to the upsampleing module
- bicubic_processing_element.v
    - Single upsampling block.
- dffs.v
    - Provide general DFF

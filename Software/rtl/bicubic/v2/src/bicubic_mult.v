
module bicubic_mult #
(
    parameter PRODUCT_WIDTH = 31
)

(
    input wire [2:0] weight,
    input wire weight_sign,
    input wire [PRODUCT_WIDTH - 1:0] pixel,
    input wire pixel_sign,
    output wire [PRODUCT_WIDTH - 1:0] product,
    output wire product_sign
);
    wire multi_by_21   = (weight == 3'd0) ? 1'b1 : 1'b0;
    wire multi_by_135  = (weight == 3'd1) ? 1'b1 : 1'b0;
    wire multi_by_147  = (weight == 3'd2) ? 1'b1 : 1'b0;
    wire multi_by_225  = (weight == 3'd3) ? 1'b1 : 1'b0;
    wire multi_by_235  = (weight == 3'd4) ? 1'b1 : 1'b0;
    wire multi_by_873  = (weight == 3'd5) ? 1'b1 : 1'b0;
    wire multi_by_1535 = (weight == 3'd6) ? 1'b1 : 1'b0;
    wire multi_by_1981 = (weight == 3'd7) ? 1'b1 : 1'b0;

    // wire [14:0] pixel_in_mult_half = {'b0, pixel[7:1]};
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_1    = pixel;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_2    = pixel << 1;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_4    = pixel << 2;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_8    = pixel << 3;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_16   = pixel << 4;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_32   = pixel << 5;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_64   = pixel << 6;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_128  = pixel << 7;
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_256  = pixel << 8; 
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_512  = pixel << 9;  
    wire [PRODUCT_WIDTH - 1:0] pixel_in_mult_1024 = pixel << 10;
    // wire [18:0] pixel_in_mult_2048 = {      pixel, 11'b0};


    wire [PRODUCT_WIDTH -1:0] result0 = pixel_in_mult_16 + pixel_in_mult_4 + pixel_in_mult_1;
    wire [PRODUCT_WIDTH -1:0] result1 = pixel_in_mult_128 + pixel_in_mult_4 + pixel_in_mult_2 + pixel_in_mult_1;
    wire [PRODUCT_WIDTH -1:0] result2 = pixel_in_mult_128 + pixel_in_mult_16 + pixel_in_mult_2 + pixel_in_mult_1;
    wire [PRODUCT_WIDTH -1:0] result3 = pixel_in_mult_128 + pixel_in_mult_64 + pixel_in_mult_32 + pixel_in_mult_1;
    // wire [18:0] result4 = (pixel_in_mult_128 + pixel_in_mult_64) + (pixel_in_mult_32 + pixel_in_mult_8) + (pixel_in_mult_2 + pixel_in_mult_1);
    // wire [18:0] t1 = pixel_in_mult_128 + pixel_in_mult_64;
    // wire [18:0] t2 = pixel_in_mult_32 + pixel_in_mult_8;
    // wire [18:0] t3 = pixel_in_mult_2 + pixel_in_mult_1;  
    // wire [18:0] result4 = t1 + t2 + t3;

    wire [PRODUCT_WIDTH -1:0] result4 = pixel_in_mult_256 - pixel_in_mult_16 - pixel_in_mult_4 - pixel_in_mult_1;

    // wire [18:0] result5 = (pixel_in_mult_512 + pixel_in_mult_256) + (pixel_in_mult_64 + pixel_in_mult_32) + (pixel_in_mult_8 + pixel_in_mult_1);
    wire [PRODUCT_WIDTH -1:0] t4 = pixel_in_mult_512 + pixel_in_mult_256 + pixel_in_mult_8;
    wire [PRODUCT_WIDTH -1:0] t5 = pixel_in_mult_64 + pixel_in_mult_32 + pixel_in_mult_1;
    // wire [18:0] t6 = pixel_in_mult_8 + pixel_in_mult_1;  
    wire [PRODUCT_WIDTH -1:0] result5 = t4 + t5;


    // wire [18:0] result5 = pixel_in_mult_1024 - pixel_in_mult_128 - pixel_in_mult_16 - pixel_in_mult_4 - pixel_in_mult_2 - pixel_in_mult_1;
    // wire [18:0] result5 = pixel_in_mult_1024 - pixel_in_mult_128 - pixel_in_mult_16 - pixel_in_mult_4 - pixel_in_mult_2 - pixel_in_mult_1;
    


    // wire [18:0] result6 = pixel_in_mult_1024 + pixel_in_mult_256 + pixel_in_mult_128 + pixel_in_mult_64 + pixel_in_mult_32 + pixel_in_mult_16 + pixel_in_mult_8 + pixel_in_mult_4 + pixel_in_mult_2 + pixel_in_mult_1;
    // wire [18:0] t1 = pixel_in_mult_1024 + pixel_in_mult_256;
    // wire [18:0] t2 = pixel_in_mult_128 + pixel_in_mult_64;
    // wire [18:0] t3 = pixel_in_mult_32 + pixel_in_mult_16;
    // wire [18:0] t4 = pixel_in_mult_8 + pixel_in_mult_4;
    // wire [18:0] t5 = pixel_in_mult_2 + pixel_in_mult_1;
    // wire [18:0] t6 = t1 + t2;
    // wire [18:0] t7 = t3 + t4;
    // wire [18:0] result6 = t5 + t6 + t7;

    wire [PRODUCT_WIDTH -1:0] result6 = pixel_in_mult_1024 + pixel_in_mult_512 - pixel_in_mult_1;

    // wire [18:0] result7 = pixel_in_mult_1024 + pixel_in_mult_512 + pixel_in_mult_256 + pixel_in_mult_128 + pixel_in_mult_32 + pixel_in_mult_16 + pixel_in_mult_8 + pixel_in_mult_4 + pixel_in_mult_1;
    wire [PRODUCT_WIDTH -1:0] t8 = pixel_in_mult_1024 + pixel_in_mult_512 + pixel_in_mult_256;
    wire [PRODUCT_WIDTH -1:0] t9 = pixel_in_mult_128 + pixel_in_mult_32 + pixel_in_mult_16;
    wire [PRODUCT_WIDTH -1:0] t10 = pixel_in_mult_8 + pixel_in_mult_4 + pixel_in_mult_1;
    wire [PRODUCT_WIDTH -1:0] result7 = t8 + t9 + t10;

    // wire [18:0] result7 = pixel_in_mult_2048 - pixel_in_mult_64 - pixel_in_mult_2 - pixel_in_mult_1;

    wire [PRODUCT_WIDTH -1:0] product_data = ({PRODUCT_WIDTH{multi_by_21}}   & result0)
                             | ({PRODUCT_WIDTH{multi_by_135}}  & result1)
                             | ({PRODUCT_WIDTH{multi_by_147}}  & result2)
                             | ({PRODUCT_WIDTH{multi_by_225}}  & result3)
                             | ({PRODUCT_WIDTH{multi_by_235}}  & result4)
                             | ({PRODUCT_WIDTH{multi_by_873}}  & result5)
                             | ({PRODUCT_WIDTH{multi_by_1535}} & result6)
                             | ({PRODUCT_WIDTH{multi_by_1981}} & result7);

    wire product_is_0 = (~(|pixel)) | (~(|product_data));

    assign product_sign = product_is_0 ? 1'b0 : weight_sign ^ pixel_sign;
    assign product = product_is_0 ? {PRODUCT_WIDTH{1'b0}} : product_data;

endmodule


// module bicubic_mult_tb();
//     parameter PRODUCT_WIDTH = 31;
//     reg [2:0] weight_tb;
//     reg weight_sign_tb;
//     reg [PRODUCT_WIDTH - 1:0] pixel_tb;
//     reg pixel_sign_tb;
//     wire [PRODUCT_WIDTH - 1:0] product_tb;
//     wire product_sign_tb;
//     bicubic_mult u_bicubic_mult_tb(
//         .weight(weight_tb),
//         .weight_sign(weight_sign_tb),
//         .pixel(pixel_tb),
//         .pixel_sign(pixel_sign_tb),
//         .product(product_tb),
//         .product_sign(product_sign_tb)
//     );

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, bicubic_mult_tb);
//     end

//     initial begin
//         weight_tb = 3'd0; // mult_by_0
//         weight_sign_tb = 1'b0;
//         pixel_tb = 128;
//         pixel_sign_tb = 1'b0;


//         #5 weight_tb = 3'd1; // mult_by_3
//         #5 weight_tb = 3'd2; // mult_by_8
//         #5 weight_tb = 3'd3; // mult_by_9
//         #5 weight_tb = 3'd4; // mult_by_29
//         #5 weight_tb = 3'd5; // mult_by_72 
//            pixel_sign_tb = 1'b1; // (the sign bit is negative)
//         #5 weight_tb = 3'd6; // mult_by_111
//            pixel_sign_tb = 1'b0;
//         #5 weight_tb = 3'd7; // mult_by_128

//         #5 weight_tb = 3'd0; // mult_by_0
//            pixel_sign_tb = 1'b1; // the sign bit of this pixel is negative

//         #5 weight_tb = 3'd1; // mult_by_3
//         #5 weight_tb = 3'd2; // mult_by_8
//         #5 weight_tb = 3'd3; // mult_by_9
//         #5 weight_tb = 3'd4; // mult_by_29
//         #5 weight_tb = 3'd5; // mult_by_72 
//            pixel_sign_tb = 1'b1;
//         #5 weight_tb = 3'd6; // mult_by_111
//            pixel_sign_tb = 1'b0;
//         #5 weight_tb = 3'd7; // mult_by_128

//         #5 $finish;

//     end




// endmodule




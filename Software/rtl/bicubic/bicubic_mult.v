
module bicubic_mult(
    input wire [2:0] weight,
    input wire weight_sign,
    input wire [7:0] pixel,
    input wire pixel_sign,
    output wire [7:0] product,
    output wire product_sign
);
    wire multi_by_0   = (weight == 3'd0) | (~(|pixel)) ? 1'b1 : 1'b0;
    wire multi_by_3   = (weight == 3'd1) ? 1'b1 : 1'b0;
    wire multi_by_8   = (weight == 3'd2) ? 1'b1 : 1'b0;
    wire multi_by_9   = (weight == 3'd3) ? 1'b1 : 1'b0;
    wire multi_by_29  = (weight == 3'd4) ? 1'b1 : 1'b0;
    wire multi_by_72  = (weight == 3'd5) ? 1'b1 : 1'b0;
    wire multi_by_111 = (weight == 3'd6) ? 1'b1 : 1'b0;
    wire multi_by_128 = (weight == 3'd7) ? 1'b1 : 1'b0;

    wire [14:0] pixel_in_mult_1   = {7'b0, pixel};  
    wire [14:0] pixel_in_mult_2   = {6'b0, pixel, 1'b0};
    wire [14:0] pixel_in_mult_4   = {5'b0, pixel, 2'b0};
    wire [14:0] pixel_in_mult_8   = {4'b0, pixel, 3'b0};
    wire [14:0] pixel_in_mult_16  = {3'b0, pixel, 4'b0};
    wire [14:0] pixel_in_mult_32  = {2'b0, pixel, 5'b0};
    wire [14:0] pixel_in_mult_64  = {1'b0, pixel, 6'b0};
    wire [14:0] pixel_in_mult_128 = {      pixel, 7'b0};

    
    wire adder1_src1_ena = (multi_by_3 | multi_by_9 | multi_by_29 | multi_by_111) ? 1'b1 : 1'b0;
    wire [14:0] adder1_src1 = adder1_src1_ena ? pixel_in_mult_1 : 15'd0;
    wire [14:0] adder1_src2 = multi_by_3 ? pixel_in_mult_2 
                            : multi_by_29 ? pixel_in_mult_16
                            : multi_by_111 ? pixel_in_mult_2 : 15'd0;

    wire [14:0] adder2_src1 = pixel_in_mult_8;
    wire [14:0] adder2_src2 = multi_by_9 ? pixel_in_mult_1
                            : multi_by_29 ? pixel_in_mult_4 
                            : multi_by_111 ? pixel_in_mult_4 : 15'd0;
    
    wire [14:0] adder3_src1 = pixel_in_mult_64;
    wire [14:0] adder3_src2 = multi_by_111 ? pixel_in_mult_32 : 15'd0;

    wire [15:0] result1 = adder1_src1 + adder1_src2;
    wire [15:0] result2 = adder2_src1 + adder2_src2;
    wire [15:0] result3 = adder3_src1 + adder3_src2;
    wire [15:0] result4 = result1 + result2;
    wire [15:0] result5 = result3 + result4;

    wire [14:0] product_data = ({15{multi_by_0}}  & 15'b0)
                            | ({15{multi_by_3}}   & result1)
                            | ({15{multi_by_8}}   & pixel_in_mult_8)
                            | ({15{multi_by_9}}   & result2)
                            | ({15{multi_by_29}}  & result4)
                            | ({15{multi_by_72}}  & result5)
                            | ({15{multi_by_111}} & result5)
                            | ({15{multi_by_128}} & pixel_in_mult_128);


    assign product_sign = multi_by_0 ? 1'b0 : weight_sign ^ pixel_sign;
    assign product = product_data[14:7];

    

endmodule

// module bicubic_mult_tb();

//     reg [2:0] weight_tb;
//     reg weight_sign_tb;
//     reg [7:0] pixel_tb;
//     reg pixel_sign_tb;
//     wire [7:0] product_tb;
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
//         pixel_tb = 8'd128;
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




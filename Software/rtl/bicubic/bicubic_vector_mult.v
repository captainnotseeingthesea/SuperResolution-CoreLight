`ifndef BICUBIC_MULT
    `define BICUBIC_MULT
`endif
`include "bicubic_mult.v"
module bicubic_vector_mult(
    input wire [3:0] weight_1,
    input wire [8:0] pixel_1,
    input wire [3:0] weight_2,
    input wire [8:0] pixel_2,
    input wire [3:0] weight_3,
    input wire [8:0] pixel_3,
    input wire [3:0] weight_4,
    input wire [8:0] pixel_4,

    output wire [7:0] inner_product,
    output wire inner_product_sign
);


    wire [8:0] product_t1, product_t2, product_t3, product_t4;
    bicubic_mult u_bicubic_mult_1(
        .weight       (weight_1[2:0]  ),
        .weight_sign  (weight_1[3]    ),
        .pixel        (pixel_1[7:0]   ),
        .pixel_sign   (pixel_1[8]     ),
        .product      (product_t1[7:0]),
        .product_sign (product_t1[8]  )
    );
    bicubic_mult u_bicubic_mult_2(
        .weight       (weight_2[2:0]  ),
        .weight_sign  (weight_2[3]    ),
        .pixel        (pixel_2[7:0]   ),
        .pixel_sign   (pixel_2[8]     ),
        .product      (product_t2[7:0]),
        .product_sign (product_t2[8]  )
    );
    bicubic_mult u_bicubic_mult_3(
        .weight       (weight_3[2:0]  ),
        .weight_sign  (weight_3[3]    ),
        .pixel        (pixel_3[7:0]   ),
        .pixel_sign   (pixel_3[8]     ),
        .product      (product_t3[7:0]),
        .product_sign (product_t3[8]  )
    );
    bicubic_mult u_bicubic_mult_4(
        .weight       (weight_4[2:0]  ),
        .weight_sign  (weight_4[3]    ),
        .pixel        (pixel_4[7:0]   ),
        .pixel_sign   (pixel_4[8]     ),
        .product      (product_t4[7:0]),
        .product_sign (product_t4[8]  )
    );

    wire t1_is_0 = (~(|product_t1[7:0])) ? 1'b1 : 1'b0;
    wire t2_is_0 = (~(|product_t2[7:0])) ? 1'b1 : 1'b0;
    wire t3_is_0 = (~(|product_t3[7:0])) ? 1'b1 : 1'b0;
    wire t4_is_0 = (~(|product_t4[7:0])) ? 1'b1 : 1'b0;
        
    wire [7:0] t1_complement = (~product_t1[7:0]) + 1;
    wire [7:0] t2_complement = (~product_t2[7:0]) + 1;
    wire [7:0] t3_complement = (~product_t3[7:0]) + 1;
    wire [7:0] t4_complement = (~product_t4[7:0]) + 1;

    wire [9:0] adder1_src1 = t1_is_0 ? 10'd0 : product_t1[8] ? {2'b11, t1_complement} : {2'b00, product_t1[7:0]};
    wire [9:0] adder1_src2 = t2_is_0 ? 10'd0 : product_t2[8] ? {2'b11, t2_complement} : {2'b00, product_t2[7:0]};

    wire [9:0] adder2_src1 = t3_is_0 ? 10'd0 : product_t3[8] ? {2'b11, t3_complement} : {2'b00, product_t3[7:0]};
    wire [9:0] adder2_src2 = t4_is_0 ? 10'd0 : product_t4[8] ? {2'b11, t4_complement} : {2'b00, product_t4[7:0]};   

    wire [9:0] result1 = adder1_src1 + adder1_src2;
    wire [9:0] result2 = adder2_src1 + adder2_src2;

    wire result1_overflow = result1[9] ^ result1[8];
    wire result2_overflow = result2[9] ^ result2[8];

    // wire [9:0] adder3_rs1 = result1_overflow ? {result1[9], result1[9], }

    wire [9:0] result3 = result1 + result2;
    

    wire result3_overflow = result3[9] ^ result3[8];

    wire overflow = result1_overflow | result2_overflow | result3_overflow;
    // assert (overflow) $fatal("expression overflow!");

    assign inner_product = result3_overflow ? 8'hff : result3[9] ? (~result3[7:0] + 1) : result3[7:0];
    assign inner_product_sign = result3[9];

endmodule


// module bicubic_vector_mult_tb();

//     reg [3:0] weight_1_tb;
//     reg [8:0] pixel_1_tb;
//     reg [3:0] weight_2_tb;
//     reg [8:0] pixel_2_tb;
//     reg [3:0] weight_3_tb;
//     reg [8:0] pixel_3_tb;
//     reg [3:0] weight_4_tb;
//     reg [8:0] pixel_4_tb;

//     wire [7:0] inner_product_tb;
//     wire inner_product_sign_tb;


//     bicubic_vector_mult u_bicubic_vector_mult(
//         .weight_1 (  weight_1_tb),
//         .pixel_1  (   pixel_1_tb),
//         .weight_2 (  weight_2_tb),
//         .pixel_2  (   pixel_2_tb),
//         .weight_3 (  weight_3_tb),
//         .pixel_3  (   pixel_3_tb),
//         .weight_4 (  weight_4_tb),
//         .pixel_4  (   pixel_4_tb),

//         .inner_product (inner_product_tb),
//         .inner_product_sign (inner_product_sign_tb)
//     );


//     initial begin
//         weight_1_tb = 4'd0;
//         pixel_1_tb = 9'd0;
//         weight_2_tb = 4'd0;
//         pixel_2_tb = 9'd0;
//         weight_3_tb = 4'd0;
//         pixel_3_tb = 9'd0;
//         weight_4_tb = 4'd0;
//         pixel_4_tb = 9'd0;

//         #5 
//         pixel_1_tb = 9'd255;
//         pixel_2_tb = 9'd255;
//         pixel_3_tb = 9'd255;
//         pixel_4_tb = 9'd248;
//         weight_1_tb = 4'd1;


//     // localparam S_U2_1 = {1'b1,3'd3};  // -9      B
//     // localparam S_U2_2 = 4'd6;         // 111     6
//     // localparam S_U2_3 = 4'd4;         // 29      4
//     // localparam S_U2_4 = {1'b1, 3'd1}; // -3      9
//         #5 
//         weight_1_tb = {1'b1,3'd3};  // -9      B
//         weight_2_tb = 4'd6;         // 111     6
//         weight_3_tb = 4'd4;         // 29      4
//         weight_4_tb = {1'b1, 3'd1}; // -3      9       

//         // #5 
//         // weight_1_tb = {1'b1, 3'd1};
//         // weight_2_tb = {1'b1, 3'd1};
//         // weight_3_tb = {1'b1, 3'd1};
//         // weight_4_tb = {1'b1, 3'd1};
        

//         #5 $finish;

//     end

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, bicubic_vector_mult_tb);
//     end



// endmodule


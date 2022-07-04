
module bicubic_vector_mult_config #
(
    parameter INTER_PRODUCT_WIDTH = 24,
    parameter PRODUCT_WIDTH = 32
)
(

`ifdef STAGE2_MULT_IN_ONE_CYCLE
    
`elsif STAGE2_MULT_IN_TWO_CYCLE
    input wire clk,
    input wire ena,
`elsif STAGE2_MULT_IN_THREE_CYCLE
    input wire clk,
    input wire ena,
`endif
    input wire [2:0] weight_1,
    input wire [INTER_PRODUCT_WIDTH - 1:0] pixel_1,
    input wire [2:0] weight_2,
    input wire [INTER_PRODUCT_WIDTH - 1:0] pixel_2,
    input wire [2:0] weight_3,
    input wire [INTER_PRODUCT_WIDTH - 1:0] pixel_3,
    input wire [2:0] weight_4,
    input wire [INTER_PRODUCT_WIDTH - 1:0] pixel_4,

    output wire [PRODUCT_WIDTH - 1:0] inner_product
);

    // Instantiate each of the four multiplication units
    wire [PRODUCT_WIDTH - 1:0] product_t1, product_t2, product_t3, product_t4;

    bicubic_mult_config u_bicubic_mult_1(
    `ifdef STAGE2_MULT_IN_ONE_CYCLE
    
    `elsif STAGE2_MULT_IN_TWO_CYCLE
        .clk(clk),
        .ena(ena),
    `elsif STAGE2_MULT_IN_THREE_CYCLE
        .clk(clk),
        .ena(ena),
    `endif

        .weight       (weight_1),
        .pixel        (pixel_1[PRODUCT_WIDTH -8 - 1:0]),
        .product      (product_t1)
    );

    bicubic_mult_config u_bicubic_mult_2(
    `ifdef STAGE2_MULT_IN_ONE_CYCLE
    
    `elsif STAGE2_MULT_IN_TWO_CYCLE
        .clk(clk),
        .ena(ena),
    `elsif STAGE2_MULT_IN_THREE_CYCLE
        .clk(clk),
        .ena(ena),
    `endif

        .weight       (weight_2),
        .pixel        (pixel_2[PRODUCT_WIDTH -8 - 1:0]),
        .product      (product_t2)
    );

    bicubic_mult_config u_bicubic_mult_3(
    `ifdef STAGE2_MULT_IN_ONE_CYCLE
    
    `elsif STAGE2_MULT_IN_TWO_CYCLE
        .clk(clk),
        .ena(ena),
    `elsif STAGE2_MULT_IN_THREE_CYCLE
        .clk(clk),
        .ena(ena),
    `endif


        .weight       (weight_3 ),
        .pixel        (pixel_3[PRODUCT_WIDTH -8 - 1:0]),
        .product      (product_t3)
    );

    bicubic_mult_config u_bicubic_mult_4(
    `ifdef STAGE2_MULT_IN_ONE_CYCLE
    
    `elsif STAGE2_MULT_IN_TWO_CYCLE
        .clk(clk),
        .ena(ena),
    `elsif STAGE2_MULT_IN_THREE_CYCLE
        .clk(clk),
        .ena(ena),
    `endif


        .weight       (weight_4),
        .pixel        (pixel_4[PRODUCT_WIDTH -8 - 1:0]),
        .product      (product_t4)
    );


    // Use three adders to get the final multiplication result
    wire [PRODUCT_WIDTH-1:0] adder1_src1 = product_t1;
    wire [PRODUCT_WIDTH-1:0] adder1_src2 = product_t2;

    wire [PRODUCT_WIDTH-1:0] adder2_src1 = product_t3;
    wire [PRODUCT_WIDTH-1:0] adder2_src2 = product_t4;   

    wire [PRODUCT_WIDTH-1:0] result1 = adder1_src1 + adder1_src2;
    wire [PRODUCT_WIDTH-1:0] result2 = adder2_src1 + adder2_src2;

    wire [PRODUCT_WIDTH-1:0] result3 = result1 + result2;

    assign inner_product = result3;

endmodule

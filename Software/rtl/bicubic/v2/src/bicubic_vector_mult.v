
module bicubic_vector_mult#
(
    parameter INTER_PRODUCT_WIDTH = 24
)
(
    input wire [2:0] weight_1,
    input wire [8:0] pixel_1,
    input wire [2:0] weight_2,
    input wire [8:0] pixel_2,
    input wire [2:0] weight_3,
    input wire [8:0] pixel_3,
    input wire [2:0] weight_4,
    input wire [8:0] pixel_4,

    output wire [INTER_PRODUCT_WIDTH - 1:0] inner_product
);

    // Instantiate each of the four multiplication units
    wire [INTER_PRODUCT_WIDTH - 1:0] product_t1, product_t2, product_t3, product_t4;
    bicubic_mult #(.INTER_PRODUCT_WIDTH(INTER_PRODUCT_WIDTH)) u_bicubic_mult_1(
        .weight       (weight_1  ),
        .pixel        (pixel_1   ),
        .product      (product_t1)
    );
    bicubic_mult #(.INTER_PRODUCT_WIDTH(INTER_PRODUCT_WIDTH)) u_bicubic_mult_2(
        .weight       (weight_2  ),
        .pixel        (pixel_2   ),
        .product      (product_t2)
    );
    bicubic_mult #(.INTER_PRODUCT_WIDTH(INTER_PRODUCT_WIDTH)) u_bicubic_mult_3(
        .weight       (weight_3  ),
        .pixel        (pixel_3   ),
        .product      (product_t3)
    );
    bicubic_mult #(.INTER_PRODUCT_WIDTH(INTER_PRODUCT_WIDTH)) u_bicubic_mult_4(
        .weight       (weight_4  ),
        .pixel        (pixel_4   ),
        .product      (product_t4)
    );


    // Use three adders to get the final multiplication result
    wire [INTER_PRODUCT_WIDTH-1:0] adder1_src1 = product_t1;
    wire [INTER_PRODUCT_WIDTH-1:0] adder1_src2 = product_t2;

    wire [INTER_PRODUCT_WIDTH-1:0] adder2_src1 = product_t3;
    wire [INTER_PRODUCT_WIDTH-1:0] adder2_src2 = product_t4;   

    wire [INTER_PRODUCT_WIDTH-1:0] result1 = adder1_src1 + adder1_src2;
    wire [INTER_PRODUCT_WIDTH-1:0] result2 = adder2_src1 + adder2_src2;

    wire [INTER_PRODUCT_WIDTH-1:0] result3 = result1 + result2;

    assign inner_product = result3;

endmodule

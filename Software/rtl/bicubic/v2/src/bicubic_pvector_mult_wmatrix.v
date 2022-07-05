
module bicubic_pvector_mult_wmatrix #
(
    parameter INTER_PRODUCT_WIDTH = 24,
    parameter PRODUCT_WIDTH = 32
)
(

    input wire clk,
    input wire ena,
    input wire [2:0] w1_1,
    input wire [2:0] w1_2,
    input wire [2:0] w1_3,
    input wire [2:0] w1_4,
    input wire [2:0] w2_1,
    input wire [2:0] w2_2,
    input wire [2:0] w2_3,
    input wire [2:0] w2_4,
    input wire [2:0] w3_1,
    input wire [2:0] w3_2,
    input wire [2:0] w3_3,
    input wire [2:0] w3_4,
    input wire [2:0] w4_1,
    input wire [2:0] w4_2,
    input wire [2:0] w4_3,
    input wire [2:0] w4_4,


    input wire [INTER_PRODUCT_WIDTH - 1:0] p1,
    input wire [INTER_PRODUCT_WIDTH - 1:0] p2,
    input wire [INTER_PRODUCT_WIDTH - 1:0] p3,
    input wire [INTER_PRODUCT_WIDTH - 1:0] p4,

    output wire [PRODUCT_WIDTH - 1:0] inner_product1,
    output wire [PRODUCT_WIDTH - 1:0] inner_product2,
    output wire [PRODUCT_WIDTH - 1:0] inner_product3,
    output wire [PRODUCT_WIDTH - 1:0] inner_product4
    
);

    bicubic_vector_mult_stage2 u_bicubic_vector_mult1(
        .clk     (clk ),
        .ena     (ena ),
        .weight_1(w1_1),
        .weight_2(w1_2),
        .weight_3(w1_3),
        .weight_4(w1_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product1)
    );

    bicubic_vector_mult_stage2 u_bicubic_vector_mult2(
        .clk     (clk ),
        .ena     (ena ),
        .weight_1(w2_1),
        .weight_2(w2_2),
        .weight_3(w2_3),
        .weight_4(w2_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product2)
    );

    bicubic_vector_mult_stage2 u_bicubic_vector_mult3(
        .clk     (clk ),
        .ena     (ena ),
        .weight_1(w3_1),
        .weight_2(w3_2),
        .weight_3(w3_3),
        .weight_4(w3_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product3)
    );

    bicubic_vector_mult_stage2 u_bicubic_vector_mult4(
        .clk     (clk ),
        .ena     (ena ),
        .weight_1(w4_1),
        .weight_2(w4_2),
        .weight_3(w4_3),
        .weight_4(w4_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product4)
    );


endmodule


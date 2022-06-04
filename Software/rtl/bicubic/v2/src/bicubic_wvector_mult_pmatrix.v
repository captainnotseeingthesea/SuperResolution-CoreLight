
module bicubic_wvector_mult_pmatrix #
(
    parameter PRODUCT_WIDTH = 32
)
(
    input wire [3:0] w1,
    input wire [3:0] w2,
    input wire [3:0] w3,
    input wire [3:0] w4,

    input wire [PRODUCT_WIDTH - 1:0] p1_1,
    input wire [PRODUCT_WIDTH - 1:0] p1_2,
    input wire [PRODUCT_WIDTH - 1:0] p1_3,
    input wire [PRODUCT_WIDTH - 1:0] p1_4,
    input wire [PRODUCT_WIDTH - 1:0] p2_1,
    input wire [PRODUCT_WIDTH - 1:0] p2_2,
    input wire [PRODUCT_WIDTH - 1:0] p2_3,
    input wire [PRODUCT_WIDTH - 1:0] p2_4,
    input wire [PRODUCT_WIDTH - 1:0] p3_1,
    input wire [PRODUCT_WIDTH - 1:0] p3_2,
    input wire [PRODUCT_WIDTH - 1:0] p3_3,
    input wire [PRODUCT_WIDTH - 1:0] p3_4,
    input wire [PRODUCT_WIDTH - 1:0] p4_1,
    input wire [PRODUCT_WIDTH - 1:0] p4_2,
    input wire [PRODUCT_WIDTH - 1:0] p4_3,
    input wire [PRODUCT_WIDTH - 1:0] p4_4,

    output wire [PRODUCT_WIDTH - 2:0] inner_product1,
    output wire [PRODUCT_WIDTH - 2:0] inner_product2,
    output wire [PRODUCT_WIDTH - 2:0] inner_product3,
    output wire [PRODUCT_WIDTH - 2:0] inner_product4,

    output wire inner_product_sign1,
    output wire inner_product_sign2,
    output wire inner_product_sign3,
    output wire inner_product_sign4  
    
);


    bicubic_vector_mult u_bicubic_vector_mult1(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p1_1),
        .pixel_2(p1_2),
        .pixel_3(p1_3),
        .pixel_4(p1_4),

        .inner_product(inner_product1),
        .inner_product_sign(inner_product_sign1)
    );

    bicubic_vector_mult u_bicubic_vector_mult2(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p2_1),
        .pixel_2(p2_2),
        .pixel_3(p2_3),
        .pixel_4(p2_4),

        .inner_product(inner_product2),
        .inner_product_sign(inner_product_sign2)
    );
    bicubic_vector_mult u_bicubic_vector_mult3(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p3_1),
        .pixel_2(p3_2),
        .pixel_3(p3_3),
        .pixel_4(p3_4),

        .inner_product(inner_product3),
        .inner_product_sign(inner_product_sign3)
    );
    bicubic_vector_mult u_bicubic_vector_mult4(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p4_1),
        .pixel_2(p4_2),
        .pixel_3(p4_3),
        .pixel_4(p4_4),

        .inner_product(inner_product4),
        .inner_product_sign(inner_product_sign4)
    );


endmodule



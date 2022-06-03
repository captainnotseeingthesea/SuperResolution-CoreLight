
module bicubic_pvector_mult_wmatrix(
    input wire [3:0] w1_1,
    input wire [3:0] w1_2,
    input wire [3:0] w1_3,
    input wire [3:0] w1_4,
    input wire [3:0] w2_1,
    input wire [3:0] w2_2,
    input wire [3:0] w2_3,
    input wire [3:0] w2_4,
    input wire [3:0] w3_1,
    input wire [3:0] w3_2,
    input wire [3:0] w3_3,
    input wire [3:0] w3_4,
    input wire [3:0] w4_1,
    input wire [3:0] w4_2,
    input wire [3:0] w4_3,
    input wire [3:0] w4_4,


    input wire [8:0] p1,
    input wire [8:0] p2,
    input wire [8:0] p3,
    input wire [8:0] p4,

    output wire [7:0] inner_product1,
    output wire [7:0] inner_product2,
    output wire [7:0] inner_product3,
    output wire [7:0] inner_product4,

    output wire inner_product_sign1,
    output wire inner_product_sign2,
    output wire inner_product_sign3,
    output wire inner_product_sign4  
    
);

    bicubic_vector_mult u_bicubic_vector_mult1(
        .weight_1(w1_1),
        .weight_2(w1_2),
        .weight_3(w1_3),
        .weight_4(w1_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product1),
        .inner_product_sign(inner_product_sign1)
    );

    bicubic_vector_mult u_bicubic_vector_mult2(
        .weight_1(w2_1),
        .weight_2(w2_2),
        .weight_3(w2_3),
        .weight_4(w2_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product2),
        .inner_product_sign(inner_product_sign2)
    );

    bicubic_vector_mult u_bicubic_vector_mult3(
        .weight_1(w3_1),
        .weight_2(w3_2),
        .weight_3(w3_3),
        .weight_4(w3_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product3),
        .inner_product_sign(inner_product_sign3)
    );

    bicubic_vector_mult u_bicubic_vector_mult4(
        .weight_1(w4_1),
        .weight_2(w4_2),
        .weight_3(w4_3),
        .weight_4(w4_4),

        .pixel_1(p1),
        .pixel_2(p2),
        .pixel_3(p3),
        .pixel_4(p4),

        .inner_product(inner_product4),
        .inner_product_sign(inner_product_sign4)
    );


endmodule


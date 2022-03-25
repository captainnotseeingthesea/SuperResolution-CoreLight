
`include "bicubic_vector_mult.v"
module bicubic_vector_mult_matrix(
    input wire [3:0] w1,
    input wire [3:0] w2,
    input wire [3:0] w3,
    input wire [3:0] w4,

    input wire [8:0] p_u1,
    input wire [8:0] p_u2,
    input wire [8:0] p_u3,
    input wire [8:0] p_u4,
    input wire [8:0] p_u5,
    input wire [8:0] p_u6,
    input wire [8:0] p_u7,
    input wire [8:0] p_u8,
    input wire [8:0] p_u9,
    input wire [8:0] p_u10,
    input wire [8:0] p_u11,
    input wire [8:0] p_u12,
    input wire [8:0] p_u13,
    input wire [8:0] p_u14,
    input wire [8:0] p_u15,
    input wire [8:0] p_u16,

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
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p_u1),
        .pixel_2(p_u5),
        .pixel_3(p_u9),
        .pixel_4(p_u13),

        .inner_product(inner_product1),
        .inner_product_sign(inner_product_sign1)
    );

    bicubic_vector_mult u_bicubic_vector_mult2(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p_u2),
        .pixel_2(p_u6),
        .pixel_3(p_u10),
        .pixel_4(p_u14),

        .inner_product(inner_product2),
        .inner_product_sign(inner_product_sign2)
    );
    bicubic_vector_mult u_bicubic_vector_mult3(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p_u3),
        .pixel_2(p_u7),
        .pixel_3(p_u11),
        .pixel_4(p_u15),

        .inner_product(inner_product3),
        .inner_product_sign(inner_product_sign3)
    );
    bicubic_vector_mult u_bicubic_vector_mult4(
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),

        .pixel_1(p_u4),
        .pixel_2(p_u8),
        .pixel_3(p_u12),
        .pixel_4(p_u16),

        .inner_product(inner_product4),
        .inner_product_sign(inner_product_sign4)
    );


endmodule


// module bicubic_vector_mult_matrix_tb();

//     reg[3:0] w1_tb;
//     reg[3:0] w2_tb;
//     reg[3:0] w3_tb;
//     reg[3:0] w4_tb;

//     reg[8:0] p_u1_tb;
//     reg[8:0] p_u2_tb;
//     reg[8:0] p_u3_tb;
//     reg[8:0] p_u4_tb;
//     reg[8:0] p_u5_tb;
//     reg[8:0] p_u6_tb;
//     reg[8:0] p_u7_tb;
//     reg[8:0] p_u8_tb;
//     reg[8:0] p_u9_tb;
//     reg[8:0] p_u10_tb;
//     reg[8:0] p_u11_tb;
//     reg[8:0] p_u12_tb;
//     reg[8:0] p_u13_tb;
//     reg[8:0] p_u14_tb;
//     reg[8:0] p_u15_tb;
//     reg[8:0] p_u16_tb;

//     wire [7:0] inner_product1_tb;
//     wire [7:0] inner_product2_tb;
//     wire [7:0] inner_product3_tb;
//     wire [7:0] inner_product4_tb;

//     wire inner_product_sign1_tb;
//     wire inner_product_sign2_tb;
//     wire inner_product_sign3_tb;
//     wire inner_product_sign4_tb;


//     initial begin
//         // all set to mult 3
//         w1_tb = 4'd1;
//         w2_tb = 4'd1;
//         w3_tb = 4'd1;
//         w4_tb = 4'd1;

//         p_u1_tb = 9'd128;
//         p_u2_tb = 9'd128;
//         p_u3_tb = 9'd128;
//         p_u4_tb = 9'd128;
//         p_u5_tb = 9'd128;
//         p_u6_tb = 9'd128;
//         p_u7_tb = 9'd128;
//         p_u8_tb = 9'd128;
//         p_u9_tb = 9'd128;
//         p_u10_tb = 9'd128;
//         p_u11_tb = 9'd128;
//         p_u12_tb = 9'd128;
//         p_u13_tb = 9'd128;
//         p_u14_tb = 9'd128;
//         p_u15_tb = 9'd128;
//         p_u16_tb = 9'd128;
    
//         #10
//         $finish;

//     end
//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, bicubic_vector_mult_matrix_tb);
//     end




//     bicubic_vector_mult_matrix u_bicubic_mult_matrix_tb(
//         .w1(w1_tb),
//         .w2(w2_tb),
//         .w3(w3_tb),
//         .w4(w4_tb),

//         .p_u1(p_u1_tb),
//         .p_u2(p_u2_tb),
//         .p_u3(p_u3_tb),
//         .p_u4(p_u4_tb),
//         .p_u5(p_u5_tb),
//         .p_u6(p_u6_tb),
//         .p_u7(p_u7_tb),
//         .p_u8(p_u8_tb),
//         .p_u9(p_u9_tb),
//         .p_u10(p_u10_tb),
//         .p_u11(p_u11_tb),
//         .p_u12(p_u12_tb),
//         .p_u13(p_u13_tb),
//         .p_u14(p_u14_tb),
//         .p_u15(p_u15_tb),
//         .p_u16(p_u16_tb),

//         .inner_product1(inner_product1_tb),
//         .inner_product2(inner_product2_tb),
//         .inner_product3(inner_product3_tb),
//         .inner_product4(inner_product4_tb),

//         .inner_product_sign1(inner_product_sign1_tb),
//         .inner_product_sign2(inner_product_sign2_tb),
//         .inner_product_sign3(inner_product_sign3_tb),
//         .inner_product_sign4(inner_product_sign4_tb)  
    
//     );

// endmodule


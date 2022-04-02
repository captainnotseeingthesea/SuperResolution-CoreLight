`define GEN_IN_ONE
`include "bicubic_pvector_mult_wmatrix.v"
`include "bicubic_wvector_mult_pmatrix.v"

module bicubic_upsample_1(
    input wire clk,
    input wire rst_n,
    input wire bf_req_valid,
    output wire bcci_req_ready,
    input wire [CHANNEL_WIDTH-1:0] p1,
    input wire [CHANNEL_WIDTH-1:0] p2,
    input wire [CHANNEL_WIDTH-1:0] p3,
    input wire [CHANNEL_WIDTH-1:0] p4,
    input wire [CHANNEL_WIDTH-1:0] p5,
    input wire [CHANNEL_WIDTH-1:0] p6,
    input wire [CHANNEL_WIDTH-1:0] p7,
    input wire [CHANNEL_WIDTH-1:0] p8,
    input wire [CHANNEL_WIDTH-1:0] p9,
    input wire [CHANNEL_WIDTH-1:0] p10,
    input wire [CHANNEL_WIDTH-1:0] p11,
    input wire [CHANNEL_WIDTH-1:0] p12,
    input wire [CHANNEL_WIDTH-1:0] p13,
    input wire [CHANNEL_WIDTH-1:0] p14,
    input wire [CHANNEL_WIDTH-1:0] p15,
    input wire [CHANNEL_WIDTH-1:0] p16,


    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data1,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data2,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data3,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data4,

    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data5,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data6,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data7,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data8,

    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data9,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data10,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data11,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data12,

    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data13,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data14,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data15,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data16,

    output wire bcci_rsp_valid,
    input wire bf_rsp_ready
);

    wire bf_req_hsked = bf_req_valid & bcci_req_ready;
    wire bcci_rsp_hsked = bcci_rsp_valid & bf_rsp_ready;

    assign bcci_req_ready = 1'b1;
    assign bcci_rsp_valid = bf_req_valid; 

    localparam CHANNEL_WIDTH = 8;
    localparam WEIGHT_WIDTH = 4;

    localparam S_U1_1 = 4'd0;         // 0       0
    localparam S_U1_2 = 4'd7;         // 128     7
    localparam S_U1_3 = 4'd0;         // 0       0
    localparam S_U1_4 = 4'd0;         // 0       0
 
    localparam S_U2_1 = {1'b1,3'd3};  // -9      B
    localparam S_U2_2 = 4'd6;         // 111     6
    localparam S_U2_3 = 4'd4;         // 29      4
    localparam S_U2_4 = {1'b1, 3'd1}; // -3      9
 
    localparam S_U3_1 = {1'b1, 3'd2}; // -8      A
    localparam S_U3_2 = 4'd5;         // 72      5
    localparam S_U3_3 = 4'd5;         // 72      5
    localparam S_U3_4 = {1'b1, 3'd2}; // -8      A

    localparam S_U4_1 = {1'b1, 3'd1};  // -3     9
    localparam S_U4_2 = 4'd4;          // 29     4
    localparam S_U4_3 = 4'd6;          // 111    6
    localparam S_U4_4 = {1'b1, 3'd3};  // -9     B

    wire [WEIGHT_WIDTH-1:0] w1_a, w2_a, w3_a, w4_a;
    wire [WEIGHT_WIDTH-1:0] w1_b, w2_b, w3_b, w4_b;
    wire [WEIGHT_WIDTH-1:0] w1_c, w2_c, w3_c, w4_c;
    wire [WEIGHT_WIDTH-1:0] w1_d, w2_d, w3_d, w4_d;
    wire [CHANNEL_WIDTH:0] p1_1, p1_2, p1_3, p1_4;
    wire [CHANNEL_WIDTH:0] p2_1, p2_2, p2_3, p2_4;
    wire [CHANNEL_WIDTH:0] p3_1, p3_2, p3_3, p3_4;
    wire [CHANNEL_WIDTH:0] p4_1, p4_2, p4_3, p4_4;  
    wire [CHANNEL_WIDTH:0] product1_t_a, product2_t_a, product3_t_a, product4_t_a;
    wire [CHANNEL_WIDTH:0] product1_t_b, product2_t_b, product3_t_b, product4_t_b;
    wire [CHANNEL_WIDTH:0] product1_t_c, product2_t_c, product3_t_c, product4_t_c;
    wire [CHANNEL_WIDTH:0] product1_t_d, product2_t_d, product3_t_d, product4_t_d;

    bicubic_wvector_mult_pmatrix u_bicubic_wvector_mult_pmatrix_a(
        .w1(w1_a),
        .w2(w2_a),
        .w3(w3_a),
        .w4(w4_a),

        .p1_1(p1_1),
        .p1_2(p1_2),
        .p1_3(p1_3),
        .p1_4(p1_4),
        .p2_1(p2_1),
        .p2_2(p2_2),
        .p2_3(p2_3),
        .p2_4(p2_4),
        .p3_1(p3_1),
        .p3_2(p3_2),
        .p3_3(p3_3),
        .p3_4(p3_4),
        .p4_1(p4_1),
        .p4_2(p4_2),
        .p4_3(p4_3),
        .p4_4(p4_4),

        .inner_product1(product1_t_a[7:0]),
        .inner_product2(product2_t_a[7:0]),
        .inner_product3(product3_t_a[7:0]),
        .inner_product4(product4_t_a[7:0]),

        .inner_product_sign1(product1_t_a[8]),
        .inner_product_sign2(product2_t_a[8]),
        .inner_product_sign3(product3_t_a[8]),
        .inner_product_sign4(product4_t_a[8]) 
    );  

    bicubic_wvector_mult_pmatrix u_bicubic_wvector_mult_pmatrix_b(
        .w1(w1_b),
        .w2(w2_b),
        .w3(w3_b),
        .w4(w4_b),

        .p1_1(p1_1),
        .p1_2(p1_2),
        .p1_3(p1_3),
        .p1_4(p1_4),
        .p2_1(p2_1),
        .p2_2(p2_2),
        .p2_3(p2_3),
        .p2_4(p2_4),
        .p3_1(p3_1),
        .p3_2(p3_2),
        .p3_3(p3_3),
        .p3_4(p3_4),
        .p4_1(p4_1),
        .p4_2(p4_2),
        .p4_3(p4_3),
        .p4_4(p4_4),

        .inner_product1(product1_t_b[7:0]),
        .inner_product2(product2_t_b[7:0]),
        .inner_product3(product3_t_b[7:0]),
        .inner_product4(product4_t_b[7:0]),

        .inner_product_sign1(product1_t_b[8]),
        .inner_product_sign2(product2_t_b[8]),
        .inner_product_sign3(product3_t_b[8]),
        .inner_product_sign4(product4_t_b[8]) 
    );  

    bicubic_wvector_mult_pmatrix u_bicubic_wvector_mult_pmatrix_c(
        .w1(w1_c),
        .w2(w2_c),
        .w3(w3_c),
        .w4(w4_c),

        .p1_1(p1_1),
        .p1_2(p1_2),
        .p1_3(p1_3),
        .p1_4(p1_4),
        .p2_1(p2_1),
        .p2_2(p2_2),
        .p2_3(p2_3),
        .p2_4(p2_4),
        .p3_1(p3_1),
        .p3_2(p3_2),
        .p3_3(p3_3),
        .p3_4(p3_4),
        .p4_1(p4_1),
        .p4_2(p4_2),
        .p4_3(p4_3),
        .p4_4(p4_4),

        .inner_product1(product1_t_c[7:0]),
        .inner_product2(product2_t_c[7:0]),
        .inner_product3(product3_t_c[7:0]),
        .inner_product4(product4_t_c[7:0]),

        .inner_product_sign1(product1_t_c[8]),
        .inner_product_sign2(product2_t_c[8]),
        .inner_product_sign3(product3_t_c[8]),
        .inner_product_sign4(product4_t_c[8]) 
    );  

    bicubic_wvector_mult_pmatrix u_bicubic_wvector_mult_pmatrix_d(
        .w1(w1_d),
        .w2(w2_d),
        .w3(w3_d),
        .w4(w4_d),

        .p1_1(p1_1),
        .p1_2(p1_2),
        .p1_3(p1_3),
        .p1_4(p1_4),
        .p2_1(p2_1),
        .p2_2(p2_2),
        .p2_3(p2_3),
        .p2_4(p2_4),
        .p3_1(p3_1),
        .p3_2(p3_2),
        .p3_3(p3_3),
        .p3_4(p3_4),
        .p4_1(p4_1),
        .p4_2(p4_2),
        .p4_3(p4_3),
        .p4_4(p4_4),

        .inner_product1(product1_t_d[7:0]),
        .inner_product2(product2_t_d[7:0]),
        .inner_product3(product3_t_d[7:0]),
        .inner_product4(product4_t_d[7:0]),

        .inner_product_sign1(product1_t_d[8]),
        .inner_product_sign2(product2_t_d[8]),
        .inner_product_sign3(product3_t_d[8]),
        .inner_product_sign4(product4_t_d[8]) 
    );  

    assign w1_a = S_U1_1;
    assign w2_a = S_U1_2;
    assign w3_a = S_U1_3;
    assign w4_a = S_U1_4;

    assign w1_b = S_U2_1;
    assign w2_b = S_U2_2;
    assign w3_b = S_U2_3;
    assign w4_b = S_U2_4;

    assign w1_c = S_U3_1;
    assign w2_c = S_U3_2;
    assign w3_c = S_U3_3;
    assign w4_c = S_U3_4;

    assign w1_d = S_U4_1;
    assign w2_d = S_U4_2;
    assign w3_d = S_U4_3;
    assign w4_d = S_U4_4;


    assign p1_1 = {1'b0, p1};
    assign p1_2 = {1'b0, p5};   
    assign p1_3 = {1'b0, p9};
    assign p1_4 = {1'b0, p13};    

    assign p2_1 = {1'b0, p2};
    assign p2_2 = {1'b0, p6};   
    assign p2_3 = {1'b0, p10};
    assign p2_4 = {1'b0, p14}; 

    assign p3_1 = {1'b0, p3};
    assign p3_2 = {1'b0, p7};   
    assign p3_3 = {1'b0, p11};
    assign p3_4 = {1'b0, p15}; 

    assign p4_1 = {1'b0, p4};
    assign p4_2 = {1'b0, p8};   
    assign p4_3 = {1'b0, p12};
    assign p4_4 = {1'b0, p16}; 


    wire [WEIGHT_WIDTH-1:0] w1_1, w1_2, w1_3, w1_4;
    wire [WEIGHT_WIDTH-1:0] w2_1, w2_2, w2_3, w2_4;
    wire [WEIGHT_WIDTH-1:0] w3_1, w3_2, w3_3, w3_4;
    wire [WEIGHT_WIDTH-1:0] w4_1, w4_2, w4_3, w4_4;
    wire [CHANNEL_WIDTH:0] p1_a, p2_a, p3_a, p4_a;
    wire [CHANNEL_WIDTH:0] p1_b, p2_b, p3_b, p4_b;
    wire [CHANNEL_WIDTH:0] p1_c, p2_c, p3_c, p4_c;
    wire [CHANNEL_WIDTH:0] p1_d, p2_d, p3_d, p4_d;

    wire [CHANNEL_WIDTH:0] product1_a, product2_a, product3_a, product4_a;
    wire [CHANNEL_WIDTH:0] product1_b, product2_b, product3_b, product4_b; 
    wire [CHANNEL_WIDTH:0] product1_c, product2_c, product3_c, product4_c;
    wire [CHANNEL_WIDTH:0] product1_d, product2_d, product3_d, product4_d; 

    bicubic_pvector_mult_wmatrix u_bicubic_pverctor_mult_wmatrix_a(
        .w1_1(w1_1),
        .w1_2(w1_2),
        .w1_3(w1_3),
        .w1_4(w1_4),
        .w2_1(w2_1),
        .w2_2(w2_2),
        .w2_3(w2_3),
        .w2_4(w2_4),
        .w3_1(w3_1),
        .w3_2(w3_2),
        .w3_3(w3_3),
        .w3_4(w3_4),
        .w4_1(w4_1),
        .w4_2(w4_2),
        .w4_3(w4_3),
        .w4_4(w4_4),

        .p1(p1_a),
        .p2(p2_a),
        .p3(p3_a),
        .p4(p4_a),

        .inner_product1(product1_a[7:0]),
        .inner_product2(product2_a[7:0]),
        .inner_product3(product3_a[7:0]),
        .inner_product4(product4_a[7:0]),

        .inner_product_sign1(product1_a[8]),
        .inner_product_sign2(product2_a[8]),
        .inner_product_sign3(product3_a[8]),
        .inner_product_sign4(product4_a[8])  
    );

    bicubic_pvector_mult_wmatrix u_bicubic_pverctor_mult_wmatrix_b(
        .w1_1(w1_1),
        .w1_2(w1_2),
        .w1_3(w1_3),
        .w1_4(w1_4),
        .w2_1(w2_1),
        .w2_2(w2_2),
        .w2_3(w2_3),
        .w2_4(w2_4),
        .w3_1(w3_1),
        .w3_2(w3_2),
        .w3_3(w3_3),
        .w3_4(w3_4),
        .w4_1(w4_1),
        .w4_2(w4_2),
        .w4_3(w4_3),
        .w4_4(w4_4),

        .p1(p1_b),
        .p2(p2_b),
        .p3(p3_b),
        .p4(p4_b),

        .inner_product1(product1_b[7:0]),
        .inner_product2(product2_b[7:0]),
        .inner_product3(product3_b[7:0]),
        .inner_product4(product4_b[7:0]),

        .inner_product_sign1(product1_b[8]),
        .inner_product_sign2(product2_b[8]),
        .inner_product_sign3(product3_b[8]),
        .inner_product_sign4(product4_b[8])  
    );

    bicubic_pvector_mult_wmatrix u_bicubic_pverctor_mult_wmatrix_c(
        .w1_1(w1_1),
        .w1_2(w1_2),
        .w1_3(w1_3),
        .w1_4(w1_4),
        .w2_1(w2_1),
        .w2_2(w2_2),
        .w2_3(w2_3),
        .w2_4(w2_4),
        .w3_1(w3_1),
        .w3_2(w3_2),
        .w3_3(w3_3),
        .w3_4(w3_4),
        .w4_1(w4_1),
        .w4_2(w4_2),
        .w4_3(w4_3),
        .w4_4(w4_4),

        .p1(p1_c),
        .p2(p2_c),
        .p3(p3_c),
        .p4(p4_c),

        .inner_product1(product1_c[7:0]),
        .inner_product2(product2_c[7:0]),
        .inner_product3(product3_c[7:0]),
        .inner_product4(product4_c[7:0]),

        .inner_product_sign1(product1_c[8]),
        .inner_product_sign2(product2_c[8]),
        .inner_product_sign3(product3_c[8]),
        .inner_product_sign4(product4_c[8])  
    );

    bicubic_pvector_mult_wmatrix u_bicubic_pverctor_mult_wmatrix_d(
        .w1_1(w1_1),
        .w1_2(w1_2),
        .w1_3(w1_3),
        .w1_4(w1_4),
        .w2_1(w2_1),
        .w2_2(w2_2),
        .w2_3(w2_3),
        .w2_4(w2_4),
        .w3_1(w3_1),
        .w3_2(w3_2),
        .w3_3(w3_3),
        .w3_4(w3_4),
        .w4_1(w4_1),
        .w4_2(w4_2),
        .w4_3(w4_3),
        .w4_4(w4_4),

        .p1(p1_d),
        .p2(p2_d),
        .p3(p3_d),
        .p4(p4_d),

        .inner_product1(product1_d[7:0]),
        .inner_product2(product2_d[7:0]),
        .inner_product3(product3_d[7:0]),
        .inner_product4(product4_d[7:0]),

        .inner_product_sign1(product1_d[8]),
        .inner_product_sign2(product2_d[8]),
        .inner_product_sign3(product3_d[8]),
        .inner_product_sign4(product4_d[8])  
    );

    assign w1_1 = S_U1_1;
    assign w1_2 = S_U1_2;
    assign w1_3 = S_U1_3;
    assign w1_4 = S_U1_4;    

    assign w2_1 = S_U2_1;
    assign w2_2 = S_U2_2;
    assign w2_3 = S_U2_3;
    assign w2_4 = S_U2_4;  

    assign w3_1 = S_U3_1;
    assign w3_2 = S_U3_2;
    assign w3_3 = S_U3_3;
    assign w3_4 = S_U3_4;  

    assign w4_1 = S_U4_1;
    assign w4_2 = S_U4_2;
    assign w4_3 = S_U4_3;
    assign w4_4 = S_U4_4;  

    assign p1_a = product1_t_a;
    assign p2_a = product2_t_a;
    assign p3_a = product3_t_a;
    assign p4_a = product4_t_a;

    assign p1_b = product1_t_b;
    assign p2_b = product2_t_b;
    assign p3_b = product3_t_b;
    assign p4_b = product4_t_b;

    assign p1_c = product1_t_c;
    assign p2_c = product2_t_c;
    assign p3_c = product3_t_c;
    assign p4_c = product4_t_c;

    assign p1_d = product1_t_d;
    assign p2_d = product2_t_d;
    assign p3_d = product3_t_d;
    assign p4_d = product4_t_d;

    assign bcci_rsp_data1 = product1_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data2 = product2_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data3 = product3_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data4 = product4_a[CHANNEL_WIDTH-1:0];

    assign bcci_rsp_data5 = product1_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data6 = product2_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data7 = product3_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data8 = product4_b[CHANNEL_WIDTH-1:0];

    assign bcci_rsp_data9 = product1_c[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data10 = product2_c[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data11 = product3_c[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data12 = product4_c[CHANNEL_WIDTH-1:0];

    assign bcci_rsp_data13 = product1_d[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data14 = product2_d[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data15 = product3_d[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data16 = product4_d[CHANNEL_WIDTH-1:0];


endmodule

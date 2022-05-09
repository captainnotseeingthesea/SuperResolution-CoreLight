// `include "define.v"
`include "bicubic_pvector_mult_wmatrix.v"
`include "bicubic_wvector_mult_pmatrix.v"


module bicubic_upsample_2(
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

    output wire bcci_rsp_valid,
    input wire bf_rsp_ready
);

    wire bf_req_hsked = bf_req_valid & bcci_req_ready;
    wire bcci_rsp_hsked = bcci_rsp_valid & bf_rsp_ready;

    localparam FSM_WIDTH = 1;
    localparam STATE_S1 = 1'd0;
    localparam STATE_S2 = 1'd1;  

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;
    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_S1;

    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;

    assign bcci_req_ready = cur_is_s1 & bf_rsp_ready;
    assign bcci_rsp_valid = bf_req_valid;    

    wire state_s1_exit_ena = cur_is_s1 & bf_req_hsked & bcci_rsp_hsked;
    wire state_s2_exit_ena = cur_is_s2 & bcci_rsp_hsked;    

    wire state_ena =  state_s1_exit_ena
                    | state_s2_exit_ena;

    assign nxt_state = ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                    | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt);

    dfflr #(.DW(FSM_WIDTH)) u_upsample_fsm(
        .lden(state_ena),
        .dnxt(nxt_state),
        .qout(cur_state),
        .clk(clk),
        .rst_n(rst_n)
    );

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
    wire [CHANNEL_WIDTH:0] p1_1, p1_2, p1_3, p1_4;
    wire [CHANNEL_WIDTH:0] p2_1, p2_2, p2_3, p2_4;
    wire [CHANNEL_WIDTH:0] p3_1, p3_2, p3_3, p3_4;
    wire [CHANNEL_WIDTH:0] p4_1, p4_2, p4_3, p4_4;  
    wire [CHANNEL_WIDTH:0] product1_t_a, product2_t_a, product3_t_a, product4_t_a;
    wire [CHANNEL_WIDTH:0] product1_t_b, product2_t_b, product3_t_b, product4_t_b;
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

    assign w1_a = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_1)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U3_1);

    assign w2_a = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_2)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U3_2);
    
    assign w3_a = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_3)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U3_3);

    assign w4_a = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_4)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U3_4);

    assign w1_b = ({WEIGHT_WIDTH{cur_is_s1}} & S_U2_1)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U4_1);

    assign w2_b = ({WEIGHT_WIDTH{cur_is_s1}} & S_U2_2)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U4_2);
    
    assign w3_b = ({WEIGHT_WIDTH{cur_is_s1}} & S_U2_3)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U4_3);

    assign w4_b = ({WEIGHT_WIDTH{cur_is_s1}} & S_U2_4)
                | ({WEIGHT_WIDTH{cur_is_s2}} & S_U4_4);

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

    wire [CHANNEL_WIDTH:0] product1_a, product2_a, product3_a, product4_a;
    wire [CHANNEL_WIDTH:0] product1_b, product2_b, product3_b, product4_b; 

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

    assign bcci_rsp_data1 = product1_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data2 = product2_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data3 = product3_a[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data4 = product4_a[CHANNEL_WIDTH-1:0];

    assign bcci_rsp_data5 = product1_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data6 = product2_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data7 = product3_b[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data8 = product4_b[CHANNEL_WIDTH-1:0];




endmodule


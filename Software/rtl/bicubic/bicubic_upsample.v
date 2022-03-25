`include "bicubic_vector_mult.v"
module bicubic_upsample  (
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

    output wire bcci_rsp_valid,
    input wire bf_rsp_ready

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


    wire [WEIGHT_WIDTH-1:0] w1_1, w1_2, w1_3, w1_4;
    wire [WEIGHT_WIDTH-1:0] w2_1, w2_2, w2_3, w2_4;
    wire [WEIGHT_WIDTH-1:0] w3_1, w3_2, w3_3, w3_4;
    wire [WEIGHT_WIDTH-1:0] w4_1, w4_2, w4_3, w4_4;
    wire [CHANNEL_WIDTH:0] p1_1, p1_2, p1_3, p1_4;
    wire [CHANNEL_WIDTH:0] p2_1, p2_2, p2_3, p2_4;
    wire [CHANNEL_WIDTH:0] p3_1, p3_2, p3_3, p3_4;
    wire [CHANNEL_WIDTH:0] p4_1, p4_2, p4_3, p4_4;  

    wire [CHANNEL_WIDTH:0] nxt_product1, nxt_product2, nxt_product3, nxt_product4;
    wire [CHANNEL_WIDTH:0] cur_product1, cur_product2, cur_product3, cur_product4;


    bicubic_vector_mult u_bicubic_vector_mult1(
        .weight_1           (w1_1               ),
        .weight_2           (w1_2               ),
        .weight_3           (w1_3               ),
        .weight_4           (w1_4               ),

        .pixel_1            (p1_1               ),
        .pixel_2            (p1_2               ),
        .pixel_3            (p1_3               ),
        .pixel_4            (p1_4               ),

        .inner_product      (nxt_product1[7:0] ),
        .inner_product_sign (nxt_product1[8]   )
    );

    bicubic_vector_mult u_bicubic_vector_mult2(
        .weight_1          (w2_1               ),
        .weight_2          (w2_2               ),
        .weight_3          (w2_3               ),
        .weight_4          (w2_4               ),
 
        .pixel_1           (p2_1               ),
        .pixel_2           (p2_2               ),
        .pixel_3           (p2_3               ),
        .pixel_4           (p2_4               ),

        .inner_product     (nxt_product2[7:0] ),
        .inner_product_sign(nxt_product2[8]   )
    );
    bicubic_vector_mult u_bicubic_vector_mult3(
        .weight_1          (w3_1               ),
        .weight_2          (w3_2               ),
        .weight_3          (w3_3               ),
        .weight_4          (w3_4               ),

        .pixel_1           (p3_1               ),
        .pixel_2           (p3_2               ),
        .pixel_3           (p3_3               ),
        .pixel_4           (p3_4               ),

        .inner_product     (nxt_product3[7:0] ),
        .inner_product_sign(nxt_product3[8]   )
    );
    bicubic_vector_mult u_bicubic_vector_mult4(
        .weight_1          (w4_1               ),
        .weight_2          (w4_2               ),
        .weight_3          (w4_3               ),
        .weight_4          (w4_4               ),

        .pixel_1           (p4_1               ),
        .pixel_2           (p4_2               ),
        .pixel_3           (p4_3               ),
        .pixel_4           (p4_4               ),

        .inner_product     (nxt_product4[7:0] ),
        .inner_product_sign(nxt_product4[8]   )
    );

    wire product_dff_ena;

    dffl #(.DW(CHANNEL_WIDTH+1)) u_product1_dff(
        .lden(product_dff_ena),
        .dnxt(nxt_product1),
        .qout(cur_product1),
        .clk(clk)
    );

    dffl #(.DW(CHANNEL_WIDTH+1)) u_product2_dff(
        .lden(product_dff_ena),
        .dnxt(nxt_product2),
        .qout(cur_product2),
        .clk(clk)
    );

    dffl #(.DW(CHANNEL_WIDTH+1)) u_product3_dff(
        .lden(product_dff_ena),
        .dnxt(nxt_product3),
        .qout(cur_product3),
        .clk(clk)
    );
    dffl #(.DW(CHANNEL_WIDTH+1)) u_product4_dff(
        .lden(product_dff_ena),
        .dnxt(nxt_product4),
        .qout(cur_product4),
        .clk(clk)
    );

    wire bf_req_hsked = bf_req_valid & bcci_req_ready;
    wire bcci_rsp_hsked = bcci_rsp_valid & bf_rsp_ready;


    localparam FSM_WIDTH = 4;
    localparam STATE_IDLE = 4'd0;
    localparam STATE_S1 = 4'd1;
    localparam STATE_S2 = 4'd2;
    localparam STATE_S3 = 4'd3;
    localparam STATE_S4 = 4'd4;
    localparam STATE_S5 = 4'd5;
    localparam STATE_S6 = 4'd6;
    localparam STATE_S7 = 4'd7;
    localparam STATE_S8 = 4'd8;

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;

    wire [FSM_WIDTH-1:0] state_idle_nxt = STATE_S1;
    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_S3;
    wire [FSM_WIDTH-1:0] state_s3_nxt = STATE_S4;
    wire [FSM_WIDTH-1:0] state_s4_nxt = STATE_S5;
    wire [FSM_WIDTH-1:0] state_s5_nxt = STATE_S6;
    wire [FSM_WIDTH-1:0] state_s6_nxt = STATE_S7;
    wire [FSM_WIDTH-1:0] state_s7_nxt = STATE_S8;
    wire [FSM_WIDTH-1:0] state_s8_nxt = STATE_IDLE;

    wire cur_is_idle = (cur_state == STATE_IDLE) ? 1'b1 : 1'b0;
    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;
    wire cur_is_s3 = (cur_state == STATE_S3) ? 1'b1 : 1'b0;
    wire cur_is_s4 = (cur_state == STATE_S4) ? 1'b1 : 1'b0;
    wire cur_is_s5 = (cur_state == STATE_S5) ? 1'b1 : 1'b0;
    wire cur_is_s6 = (cur_state == STATE_S6) ? 1'b1 : 1'b0;
    wire cur_is_s7 = (cur_state == STATE_S7) ? 1'b1 : 1'b0;
    wire cur_is_s8 = (cur_state == STATE_S8) ? 1'b1 : 1'b0;

    assign bcci_req_ready = cur_is_idle;
    assign bcci_rsp_valid = cur_is_s2 | cur_is_s4
                          | cur_is_s6 | cur_is_s8;

    wire state_idle_exit_ena = bf_req_hsked;
    wire state_s1_exit_ena = cur_is_s1;
    wire state_s2_exit_ena = cur_is_s2 & bcci_rsp_hsked;
    wire state_s3_exit_ena = cur_is_s3;
    wire state_s4_exit_ena = cur_is_s4 & bcci_rsp_hsked;
    wire state_s5_exit_ena = cur_is_s5;
    wire state_s6_exit_ena = cur_is_s6 & bcci_rsp_hsked;
    wire state_s7_exit_ena = cur_is_s7;
    wire state_s8_exit_ena = cur_is_s8 & bcci_rsp_hsked;

    wire state_ena = state_idle_exit_ena
                    | state_s1_exit_ena
                    | state_s2_exit_ena
                    | state_s3_exit_ena
                    | state_s4_exit_ena
                    | state_s5_exit_ena
                    | state_s6_exit_ena
                    | state_s7_exit_ena
                    | state_s8_exit_ena;
    
    assign nxt_state = ({FSM_WIDTH{state_idle_exit_ena}} & state_idle_nxt)
                    | ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                    | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt)
                    | ({FSM_WIDTH{state_s3_exit_ena}} & state_s3_nxt)
                    | ({FSM_WIDTH{state_s4_exit_ena}} & state_s4_nxt)
                    | ({FSM_WIDTH{state_s5_exit_ena}} & state_s5_nxt)
                    | ({FSM_WIDTH{state_s6_exit_ena}} & state_s6_nxt)
                    | ({FSM_WIDTH{state_s7_exit_ena}} & state_s7_nxt)
                    | ({FSM_WIDTH{state_s8_exit_ena}} & state_s8_nxt);
    
    dfflr #(.DW(FSM_WIDTH)) u_upsample_fsm(
        .lden(state_ena),
        .dnxt(nxt_state),
        .qout(cur_state),
        .clk(clk),
        .rst_n(rst_n)
    );


    assign product_dff_ena = state_s1_exit_ena | state_s3_exit_ena 
                           | state_s5_exit_ena | state_s7_exit_ena;

    wire cur_is_gen_temp_matrix = cur_is_s1 | cur_is_s3 | cur_is_s5 | cur_is_s7;
    wire cur_is_gen_result = cur_is_s2 | cur_is_s4 | cur_is_s6 | cur_is_s8;

    assign w1_1 =  ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_1)
                | ({WEIGHT_WIDTH{cur_is_s3}} & S_U2_1)
                | ({WEIGHT_WIDTH{cur_is_s5}} & S_U3_1)
                | ({WEIGHT_WIDTH{cur_is_s7}} & S_U4_1)
                | ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U1_1);

    assign w1_2 =  ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_2)
                | ({WEIGHT_WIDTH{cur_is_s3}} & S_U2_2)
                | ({WEIGHT_WIDTH{cur_is_s5}} & S_U3_2)
                | ({WEIGHT_WIDTH{cur_is_s7}} & S_U4_2)
                | ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U1_2);

    assign w1_3 =  ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_3)
                | ({WEIGHT_WIDTH{cur_is_s3}} & S_U2_3)
                | ({WEIGHT_WIDTH{cur_is_s5}} & S_U3_3)
                | ({WEIGHT_WIDTH{cur_is_s7}} & S_U4_3)
                | ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U1_3);

    assign w1_4 =  ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_4)
                | ({WEIGHT_WIDTH{cur_is_s3}} & S_U2_4)
                | ({WEIGHT_WIDTH{cur_is_s5}} & S_U3_4)
                | ({WEIGHT_WIDTH{cur_is_s7}} & S_U4_4)
                | ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U1_4);
    
    assign w2_1 = cur_is_gen_temp_matrix ? w1_1 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U2_1);
    assign w2_2 = cur_is_gen_temp_matrix ? w1_2 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U2_2);
    assign w2_3 = cur_is_gen_temp_matrix ? w1_3 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U2_3);
    assign w2_4 = cur_is_gen_temp_matrix ? w1_4 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U2_4);

    assign w3_1 = cur_is_gen_temp_matrix ? w1_1 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U3_1);
    assign w3_2 = cur_is_gen_temp_matrix ? w1_2 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U3_2);
    assign w3_3 = cur_is_gen_temp_matrix ? w1_3 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U3_3);
    assign w3_4 = cur_is_gen_temp_matrix ? w1_4 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U3_4);

    assign w4_1 = cur_is_gen_temp_matrix ? w1_1 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U4_1);
    assign w4_2 = cur_is_gen_temp_matrix ? w1_2 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U4_2);
    assign w4_3 = cur_is_gen_temp_matrix ? w1_3 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U4_3);
    assign w4_4 = cur_is_gen_temp_matrix ? w1_4 : ({WEIGHT_WIDTH{cur_is_gen_result}} & S_U4_4); 




    assign p1_1 = cur_is_gen_temp_matrix ? {1'b0, p1} : cur_is_gen_result ? cur_product1 : {CHANNEL_WIDTH{1'b0}};
    assign p1_2 = cur_is_gen_temp_matrix ? {1'b0, p5} : cur_is_gen_result ? cur_product2 : {CHANNEL_WIDTH{1'b0}};
    assign p1_3 = cur_is_gen_temp_matrix ? {1'b0, p9} : cur_is_gen_result ? cur_product3 : {CHANNEL_WIDTH{1'b0}};  
    assign p1_4 = cur_is_gen_temp_matrix ? {1'b0, p13} : cur_is_gen_result ? cur_product4 : {CHANNEL_WIDTH{1'b0}};  

    assign p2_1 = cur_is_gen_temp_matrix ? {1'b0, p2} : cur_is_gen_result ? cur_product1 : {CHANNEL_WIDTH{1'b0}};
    assign p2_2 = cur_is_gen_temp_matrix ? {1'b0, p6} : cur_is_gen_result ? cur_product2 : {CHANNEL_WIDTH{1'b0}};    
    assign p2_3 = cur_is_gen_temp_matrix ? {1'b0, p10} : cur_is_gen_result ? cur_product3 : {CHANNEL_WIDTH{1'b0}};  
    assign p2_4 = cur_is_gen_temp_matrix ? {1'b0, p14} : cur_is_gen_result ? cur_product4 : {CHANNEL_WIDTH{1'b0}};  

    assign p3_1 = cur_is_gen_temp_matrix ? {1'b0, p3} : cur_is_gen_result ? cur_product1 : {CHANNEL_WIDTH{1'b0}};
    assign p3_2 = cur_is_gen_temp_matrix ? {1'b0, p7} : cur_is_gen_result ? cur_product2 : {CHANNEL_WIDTH{1'b0}};    
    assign p3_3 = cur_is_gen_temp_matrix ? {1'b0, p11} : cur_is_gen_result ? cur_product3 : {CHANNEL_WIDTH{1'b0}};  
    assign p3_4 = cur_is_gen_temp_matrix ? {1'b0, p15} : cur_is_gen_result ? cur_product4 : {CHANNEL_WIDTH{1'b0}};  

    assign p4_1 = cur_is_gen_temp_matrix ? {1'b0, p4} : cur_is_gen_result ? cur_product1 : {CHANNEL_WIDTH{1'b0}};
    assign p4_2 = cur_is_gen_temp_matrix ? {1'b0, p8} : cur_is_gen_result ? cur_product2 : {CHANNEL_WIDTH{1'b0}};    
    assign p4_3 = cur_is_gen_temp_matrix ? {1'b0, p12} : cur_is_gen_result ? cur_product3 : {CHANNEL_WIDTH{1'b0}};  
    assign p4_4 = cur_is_gen_temp_matrix ? {1'b0, p16} : cur_is_gen_result ? cur_product4 : {CHANNEL_WIDTH{1'b0}}; 

    assign bcci_rsp_data1 = cur_product1[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data2 = cur_product2[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data3 = cur_product3[CHANNEL_WIDTH-1:0];
    assign bcci_rsp_data4 = cur_product4[CHANNEL_WIDTH-1:0];  




endmodule

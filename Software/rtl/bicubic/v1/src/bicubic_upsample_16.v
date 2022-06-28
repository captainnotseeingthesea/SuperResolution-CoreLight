// `include "define.v"
// `include "bicubic_vector_mult.v"
module bicubic_upsample_16
#(parameter CHANNEL_WIDTH = 8)
(
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

    output wire bcci_rsp_valid,
    input wire bf_rsp_ready  


);


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

    wire [CHANNEL_WIDTH:0] product1_t, product2_t, product3_t, product4_t;

    wire [WEIGHT_WIDTH-1:0] w1_t, w2_t, w3_t, w4_t;

    bicubic_vector_mult u_bicubic_vector_mult1(
        .weight_1           (w1_1               ),
        .weight_2           (w1_2               ),
        .weight_3           (w1_3               ),
        .weight_4           (w1_4               ),

        .pixel_1            (p1_1               ),
        .pixel_2            (p1_2               ),
        .pixel_3            (p1_3               ),
        .pixel_4            (p1_4               ),

        .inner_product      (product1_t[7:0] ),
        .inner_product_sign (product1_t[8]   )
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

        .inner_product     (product2_t[7:0] ),
        .inner_product_sign(product2_t[8]   )
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

        .inner_product     (product3_t[7:0] ),
        .inner_product_sign(product3_t[8]   )
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

        .inner_product     (product4_t[7:0] ),
        .inner_product_sign(product4_t[8]   )
    );

    bicubic_vector_mult u_bicubic_vector_multt(
        .weight_1          (w1_t               ),
        .weight_2          (w2_t               ),
        .weight_3          (w3_t               ),
        .weight_4          (w4_t               ),

        .pixel_1           (product1_t         ),
        .pixel_2           (product2_t         ),
        .pixel_3           (product3_t         ),
        .pixel_4           (product4_t         ),

        .inner_product     (bcci_rsp_data1 ),
        .inner_product_sign(   )
    );


    wire bf_req_hsked = bf_req_valid & bcci_req_ready;
    wire bcci_rsp_hsked = bcci_rsp_valid & bf_rsp_ready;

    localparam FSM_WIDTH = 4;
    localparam STATE_S1 = 4'd0;
    localparam STATE_S2 = 4'd1;
    localparam STATE_S3 = 4'd2;
    localparam STATE_S4 = 4'd3;
    localparam STATE_S5 = 4'd4;
    localparam STATE_S6 = 4'd5;
    localparam STATE_S7 = 4'd6;
    localparam STATE_S8 = 4'd7;
    localparam STATE_S9 = 4'd8;
    localparam STATE_S10 = 4'd9;
    localparam STATE_S11 = 4'd10;
    localparam STATE_S12 = 4'd11;
    localparam STATE_S13 = 4'd12;
    localparam STATE_S14 = 4'd13;
    localparam STATE_S15 = 4'd14;
    localparam STATE_S16 = 4'd15;  

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;

    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_S3;
    wire [FSM_WIDTH-1:0] state_s3_nxt = STATE_S4;
    wire [FSM_WIDTH-1:0] state_s4_nxt = STATE_S5;
    wire [FSM_WIDTH-1:0] state_s5_nxt = STATE_S6;
    wire [FSM_WIDTH-1:0] state_s6_nxt = STATE_S7;
    wire [FSM_WIDTH-1:0] state_s7_nxt = STATE_S8;
    wire [FSM_WIDTH-1:0] state_s8_nxt = STATE_S9;
    wire [FSM_WIDTH-1:0] state_s9_nxt = STATE_S10;
    wire [FSM_WIDTH-1:0] state_s10_nxt = STATE_S11;
    wire [FSM_WIDTH-1:0] state_s11_nxt = STATE_S12;
    wire [FSM_WIDTH-1:0] state_s12_nxt = STATE_S13;
    wire [FSM_WIDTH-1:0] state_s13_nxt = STATE_S14;
    wire [FSM_WIDTH-1:0] state_s14_nxt = STATE_S15;
    wire [FSM_WIDTH-1:0] state_s15_nxt = STATE_S16;
    wire [FSM_WIDTH-1:0] state_s16_nxt = STATE_S1;

    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;
    wire cur_is_s3 = (cur_state == STATE_S3) ? 1'b1 : 1'b0;
    wire cur_is_s4 = (cur_state == STATE_S4) ? 1'b1 : 1'b0;
    wire cur_is_s5 = (cur_state == STATE_S5) ? 1'b1 : 1'b0;
    wire cur_is_s6 = (cur_state == STATE_S6) ? 1'b1 : 1'b0;
    wire cur_is_s7 = (cur_state == STATE_S7) ? 1'b1 : 1'b0;
    wire cur_is_s8 = (cur_state == STATE_S8) ? 1'b1 : 1'b0;
    wire cur_is_s9 = (cur_state == STATE_S9) ? 1'b1 : 1'b0;
    wire cur_is_s10 = (cur_state == STATE_S10) ? 1'b1 : 1'b0;
    wire cur_is_s11 = (cur_state == STATE_S11) ? 1'b1 : 1'b0;
    wire cur_is_s12 = (cur_state == STATE_S12) ? 1'b1 : 1'b0;
    wire cur_is_s13 = (cur_state == STATE_S13) ? 1'b1 : 1'b0;
    wire cur_is_s14 = (cur_state == STATE_S14) ? 1'b1 : 1'b0;
    wire cur_is_s15 = (cur_state == STATE_S15) ? 1'b1 : 1'b0;
    wire cur_is_s16 = (cur_state == STATE_S16) ? 1'b1 : 1'b0;

    assign bcci_req_ready = cur_is_s1 & bf_rsp_ready;
    assign bcci_rsp_valid = bf_req_valid;  

    wire state_s1_exit_ena = cur_is_s1 & bf_req_hsked & bcci_rsp_hsked;
    wire state_s2_exit_ena = cur_is_s2 & bcci_rsp_hsked;
    wire state_s3_exit_ena = cur_is_s3 & bcci_rsp_hsked;
    wire state_s4_exit_ena = cur_is_s4 & bcci_rsp_hsked;
    wire state_s5_exit_ena = cur_is_s5 & bcci_rsp_hsked;
    wire state_s6_exit_ena = cur_is_s6 & bcci_rsp_hsked;
    wire state_s7_exit_ena = cur_is_s7 & bcci_rsp_hsked;
    wire state_s8_exit_ena = cur_is_s8 & bcci_rsp_hsked;
    wire state_s9_exit_ena = cur_is_s9 & bcci_rsp_hsked;
    wire state_s10_exit_ena = cur_is_s10 & bcci_rsp_hsked;
    wire state_s11_exit_ena = cur_is_s11 & bcci_rsp_hsked;
    wire state_s12_exit_ena = cur_is_s12 & bcci_rsp_hsked;
    wire state_s13_exit_ena = cur_is_s13 & bcci_rsp_hsked;
    wire state_s14_exit_ena = cur_is_s14 & bcci_rsp_hsked;
    wire state_s15_exit_ena = cur_is_s15 & bcci_rsp_hsked;
    wire state_s16_exit_ena = cur_is_s16 & bcci_rsp_hsked;


    wire state_ena =  state_s1_exit_ena
                    | state_s2_exit_ena
                    | state_s3_exit_ena
                    | state_s4_exit_ena
                    | state_s5_exit_ena
                    | state_s6_exit_ena
                    | state_s7_exit_ena
                    | state_s8_exit_ena
                    | state_s9_exit_ena
                    | state_s10_exit_ena
                    | state_s11_exit_ena
                    | state_s12_exit_ena
                    | state_s13_exit_ena
                    | state_s14_exit_ena
                    | state_s15_exit_ena
                    | state_s16_exit_ena;

    assign nxt_state = ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                    | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt)
                    | ({FSM_WIDTH{state_s3_exit_ena}} & state_s3_nxt)
                    | ({FSM_WIDTH{state_s4_exit_ena}} & state_s4_nxt)
                    | ({FSM_WIDTH{state_s5_exit_ena}} & state_s5_nxt)
                    | ({FSM_WIDTH{state_s6_exit_ena}} & state_s6_nxt)
                    | ({FSM_WIDTH{state_s7_exit_ena}} & state_s7_nxt)
                    | ({FSM_WIDTH{state_s8_exit_ena}} & state_s8_nxt)
                    | ({FSM_WIDTH{state_s9_exit_ena}} & state_s9_nxt)
                    | ({FSM_WIDTH{state_s10_exit_ena}} & state_s10_nxt)
                    | ({FSM_WIDTH{state_s11_exit_ena}} & state_s11_nxt)
                    | ({FSM_WIDTH{state_s12_exit_ena}} & state_s12_nxt)
                    | ({FSM_WIDTH{state_s13_exit_ena}} & state_s13_nxt)
                    | ({FSM_WIDTH{state_s14_exit_ena}} & state_s14_nxt)
                    | ({FSM_WIDTH{state_s15_exit_ena}} & state_s15_nxt)
                    | ({FSM_WIDTH{state_s16_exit_ena}} & state_s16_nxt);
    
    dfflr #(.DW(FSM_WIDTH)) u_upsample_fsm(
        .lden(state_ena),
        .dnxt(nxt_state),
        .qout(cur_state),
        .clk(clk),
        .rst_n(rst_n)
    );

    wire cur_is_row1 = cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s4;
    wire cur_is_row2 = cur_is_s5 | cur_is_s6 | cur_is_s7 | cur_is_s8;
    wire cur_is_row3 = cur_is_s9 | cur_is_s10 | cur_is_s11 | cur_is_s12;
    wire cur_is_row4 = cur_is_s13 | cur_is_s14 | cur_is_s15 | cur_is_s16;

    assign w1_1 = ({WEIGHT_WIDTH{cur_is_row1}} & S_U1_1)
                | ({WEIGHT_WIDTH{cur_is_row2}} & S_U2_1)
                | ({WEIGHT_WIDTH{cur_is_row3}} & S_U3_1)
                | ({WEIGHT_WIDTH{cur_is_row4}} & S_U4_1);

    assign w1_2 = ({WEIGHT_WIDTH{cur_is_row1}} & S_U1_2)
                | ({WEIGHT_WIDTH{cur_is_row2}} & S_U2_2)
                | ({WEIGHT_WIDTH{cur_is_row3}} & S_U3_2)
                | ({WEIGHT_WIDTH{cur_is_row4}} & S_U4_2);  

    assign w1_3 = ({WEIGHT_WIDTH{cur_is_row1}} & S_U1_3)
                | ({WEIGHT_WIDTH{cur_is_row2}} & S_U2_3)
                | ({WEIGHT_WIDTH{cur_is_row3}} & S_U3_3)
                | ({WEIGHT_WIDTH{cur_is_row4}} & S_U4_3); 
            
    assign w1_4 = ({WEIGHT_WIDTH{cur_is_row1}} & S_U1_4)
                | ({WEIGHT_WIDTH{cur_is_row2}} & S_U2_4)
                | ({WEIGHT_WIDTH{cur_is_row3}} & S_U3_4)
                | ({WEIGHT_WIDTH{cur_is_row4}} & S_U4_4); 

    assign w2_1 = w1_1;
    assign w2_2 = w1_2;
    assign w2_3 = w1_3;
    assign w2_4 = w1_4;

    assign w3_1 = w1_1;
    assign w3_2 = w1_2;
    assign w3_3 = w1_3;
    assign w3_4 = w1_4;

    assign w4_1 = w1_1;
    assign w4_2 = w1_2;
    assign w4_3 = w1_3;
    assign w4_4 = w1_4;

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

    wire cur_is_col1 = cur_is_s1 | cur_is_s5 | cur_is_s9 | cur_is_s13;
    wire cur_is_col2 = cur_is_s2 | cur_is_s6 | cur_is_s10 | cur_is_s14;
    wire cur_is_col3 = cur_is_s3 | cur_is_s7 | cur_is_s11 | cur_is_s15;
    wire cur_is_col4 = cur_is_s4 | cur_is_s8 | cur_is_s12 | cur_is_s16;   


    assign w1_t = ({WEIGHT_WIDTH{cur_is_col1}} & S_U1_1)
                | ({WEIGHT_WIDTH{cur_is_col2}} & S_U2_1)
                | ({WEIGHT_WIDTH{cur_is_col3}} & S_U3_1)
                | ({WEIGHT_WIDTH{cur_is_col4}} & S_U4_1);

    assign w2_t = ({WEIGHT_WIDTH{cur_is_col1}} & S_U1_2)
                | ({WEIGHT_WIDTH{cur_is_col2}} & S_U2_2)
                | ({WEIGHT_WIDTH{cur_is_col3}} & S_U3_2)
                | ({WEIGHT_WIDTH{cur_is_col4}} & S_U4_2);

    assign w3_t = ({WEIGHT_WIDTH{cur_is_col1}} & S_U1_3)
                | ({WEIGHT_WIDTH{cur_is_col2}} & S_U2_3)
                | ({WEIGHT_WIDTH{cur_is_col3}} & S_U3_3)
                | ({WEIGHT_WIDTH{cur_is_col4}} & S_U4_3);

    assign w4_t = ({WEIGHT_WIDTH{cur_is_col1}} & S_U1_4)
                | ({WEIGHT_WIDTH{cur_is_col2}} & S_U2_4)
                | ({WEIGHT_WIDTH{cur_is_col3}} & S_U3_4)
                | ({WEIGHT_WIDTH{cur_is_col4}} & S_U4_4);

endmodule

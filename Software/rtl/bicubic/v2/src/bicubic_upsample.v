 `include "../../../../../new/define.v"
module bicubic_upsample #
(
    parameter CHANNEL_WIDTH = 8,
    parameter INTER_PRODUCT_WIDTH = 24,
    parameter PRODUCT_WIDTH = 32,
    parameter BLOCK_SIZE = 960,
    parameter SRC_IMG_HEIGHT = 540
)

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
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data2,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data3,
    output wire [CHANNEL_WIDTH-1:0] bcci_rsp_data4,

    output wire bcci_rsp_valid,
    input wire bf_rsp_ready

);


    wire bf_req_hsked = bf_req_valid & bcci_req_ready;     // buffer to upsample module handshake signal 
    wire bcci_rsp_hsked = bcci_rsp_valid & bf_rsp_ready;   // upsample to access_control handshake signal

    localparam WIDTH = BLOCK_SIZE;          // the width of (sub)figure
    localparam WIDTH_LEN = $clog2(WIDTH)+1;


    // the column counter to count the current colomn in progress
    wire [WIDTH_LEN-1:0] cur_col_cnt, nxt_col_cnt;
    wire col_meet_the_end = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    assign nxt_col_cnt = (~col_meet_the_end) ? cur_col_cnt+1 : {(WIDTH_LEN){1'b0}};
    wire col_cnt_ena = bcci_rsp_hsked;   // colomn counter enables every time handshaked
    dfflr #(.DW(WIDTH_LEN)) u_col_cnt(.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));


    localparam HEIGHT = SRC_IMG_HEIGHT;
    localparam DES_HEIGHT_LEN = $clog2(HEIGHT*4)+1;
    
    // the row counter to count the current row in progress
    wire [DES_HEIGHT_LEN-1:0] cur_row_cnt, nxt_row_cnt;
    wire cur_row_cnt_is_1 = (cur_row_cnt == 1) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_2 = (cur_row_cnt == HEIGHT*4-3) ? 1'b1 : 1'b0;
    wire row_meet_the_end = (cur_row_cnt == HEIGHT*4-1) ? 1'b1 : 1'b0;
    assign nxt_row_cnt = cur_row_cnt + 1;
    wire row_cnt_ena;
    dfflr #(.DW(DES_HEIGHT_LEN)) u_row_cnt(.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));



    // use the FSM to control the weight configuration
    localparam FSM_WIDTH = 2;
    localparam STATE_S1 = 2'd0;
    localparam STATE_S2 = 2'd1;
    localparam STATE_S3 = 2'd2;
    localparam STATE_S4 = 2'd3;

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;

    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_S3;
    wire [FSM_WIDTH-1:0] state_s3_nxt = STATE_S4;
    wire [FSM_WIDTH-1:0] state_s4_nxt = STATE_S1;

    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;
    wire cur_is_s3 = (cur_state == STATE_S3) ? 1'b1 : 1'b0;
    wire cur_is_s4 = (cur_state == STATE_S4) ? 1'b1 : 1'b0;

    assign bcci_req_ready = bf_rsp_ready;

    // every time the last pixel handshaked of current row then FSM go to next state 
    wire state_s1_exit_ena = cur_is_s1 & col_meet_the_end & bcci_rsp_hsked;
    wire state_s2_exit_ena = cur_is_s2 & col_meet_the_end & bcci_rsp_hsked;    
    wire state_s3_exit_ena = cur_is_s3 & col_meet_the_end & bcci_rsp_hsked; 
    wire state_s4_exit_ena = cur_is_s4 & col_meet_the_end & bcci_rsp_hsked; 

    wire state_ena =  state_s1_exit_ena
                    | state_s2_exit_ena
                    | state_s3_exit_ena
                    | state_s4_exit_ena;

    // every time the FSM enables the row counter enables
    assign row_cnt_ena = state_ena;

    assign nxt_state = ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                    | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt)
                    | ({FSM_WIDTH{state_s3_exit_ena}} & state_s3_nxt)
                    | ({FSM_WIDTH{state_s4_exit_ena}} & state_s4_nxt);

    dfflr #(.DW(FSM_WIDTH)) u_upsample_fsm(
        .lden(state_ena),
        .dnxt(nxt_state),
        .qout(cur_state),
        .clk(clk),
        .rst_n(rst_n)
    );


    localparam WEIGHT_WIDTH = 3;

    // u(5/8):
    localparam S_U1_1 = {3'd1};    // -135
    localparam S_U1_2 = {3'd5};    //  873
    localparam S_U1_3 = {3'd6};    // 1535
    localparam S_U1_4 = {3'd3};    // -225

    // u(7/8):
    localparam S_U2_1 = {3'd0};    //  -21
    localparam S_U2_2 = {3'd4};    //  235
    localparam S_U2_3 = {3'd7};    // 1981
    localparam S_U2_4 = {3'd2};    // -147

    // u(1/8):
    localparam S_U3_1 = {3'd2};    // -147
    localparam S_U3_2 = {3'd7};    // 1981
    localparam S_U3_3 = {3'd4};    //  235
    localparam S_U3_4 = {3'd0};    //  -21

    // u(3/8):
    localparam S_U4_1 = {3'd3};    //  -225
    localparam S_U4_2 = {3'd6};    //  1535
    localparam S_U4_3 = {3'd5};    //  873
    localparam S_U4_4 = {3'd1};    // -135
 

    wire [WEIGHT_WIDTH-1:0] w1, w2, w3, w4;

    wire [CHANNEL_WIDTH:0] p1_1, p1_2, p1_3, p1_4;
    wire [CHANNEL_WIDTH:0] p2_1, p2_2, p2_3, p2_4;
    wire [CHANNEL_WIDTH:0] p3_1, p3_2, p3_3, p3_4;
    wire [CHANNEL_WIDTH:0] p4_1, p4_2, p4_3, p4_4;  

    wire [INTER_PRODUCT_WIDTH - 1:0] cur_product1, cur_product2, cur_product3, cur_product4;

    wire reg_ena;

    bicubic_wvector_mult_pmatrix u_bicubic_wvector_mult_pmatrix(
        .clk(clk),
        .ena(reg_ena),
        .w1(w1),
        .w2(w2),
        .w3(w3),
        .w4(w4),

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

        .inner_product1(cur_product1),
        .inner_product2(cur_product2),
        .inner_product3(cur_product3),
        .inner_product4(cur_product4)
    );

    assign w1 = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_1)
              | ({WEIGHT_WIDTH{cur_is_s2}} & S_U2_1)
              | ({WEIGHT_WIDTH{cur_is_s3}} & S_U3_1)
              | ({WEIGHT_WIDTH{cur_is_s4}} & S_U4_1);

    assign w2 = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_2)
              | ({WEIGHT_WIDTH{cur_is_s2}} & S_U2_2)
              | ({WEIGHT_WIDTH{cur_is_s3}} & S_U3_2)
              | ({WEIGHT_WIDTH{cur_is_s4}} & S_U4_2);

    assign w3 = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_3)
              | ({WEIGHT_WIDTH{cur_is_s2}} & S_U2_3)
              | ({WEIGHT_WIDTH{cur_is_s3}} & S_U3_3)
              | ({WEIGHT_WIDTH{cur_is_s4}} & S_U4_3);

    assign w4 = ({WEIGHT_WIDTH{cur_is_s1}} & S_U1_4)
              | ({WEIGHT_WIDTH{cur_is_s2}} & S_U2_4)
              | ({WEIGHT_WIDTH{cur_is_s3}} & S_U3_4)
              | ({WEIGHT_WIDTH{cur_is_s4}} & S_U4_4);    

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


    localparam PIPELINE_WIDTH = INTER_PRODUCT_WIDTH*4;
    wire [PIPELINE_WIDTH-1:0] cur_pipeline_data, nxt_pipeline_data;
    assign reg_ena = (~bcci_rsp_valid) ? 1'b1 : bcci_rsp_hsked;

    wire bcci_rsp_valid_t1, bcci_rsp_valid_t2, bcci_rsp_valid_t3, bcci_rsp_valid_t4, bcci_rsp_valid_t5, bcci_rsp_data6;
    wire [5:0] cur_bcci_rsp_valid, nxt_bcci_rsp_valid;
    assign nxt_bcci_rsp_valid = {
        bcci_rsp_valid_t5, 
        bcci_rsp_valid_t4, 
        bcci_rsp_valid_t3,       
        bcci_rsp_valid_t2, 
        bcci_rsp_valid_t1,
        bf_req_valid
    };
    assign {
        bcci_rsp_valid_t6,
        bcci_rsp_valid_t5,
        bcci_rsp_valid_t4,
        bcci_rsp_valid_t3,
        bcci_rsp_valid_t2,
        bcci_rsp_valid_t1
    } = cur_bcci_rsp_valid;


    // pipeline regs
    dfflr #(.DW(6)) u_pipeline_valid_reg (.lden(reg_ena), .dnxt(nxt_bcci_rsp_valid), .qout(cur_bcci_rsp_valid), .clk(clk), .rst_n(rst_n));

    `ifdef MULT_IN_TWO_CYCLE
        assign bcci_rsp_valid = bcci_rsp_valid_t2;
    `elsif MULT_IN_THREE_CYCLE
        assign bcci_rsp_valid = bcci_rsp_valid_t3;
    `elsif MULT_IN_FOUR_CYCLE
        assign bcci_rsp_valid = bcci_rsp_valid_t4;
    `elsif MULT_IN_FIVE_CYCLE
        assign bcci_rsp_valid = bcci_rsp_valid_t5;
    `elsif MULT_IN_SIX_CYCLE
        assign bcci_rsp_valid = bcci_rsp_valid_t6;
    `endif

    wire [WEIGHT_WIDTH-1:0] w1_1, w1_2, w1_3, w1_4;
    wire [WEIGHT_WIDTH-1:0] w2_1, w2_2, w2_3, w2_4;
    wire [WEIGHT_WIDTH-1:0] w3_1, w3_2, w3_3, w3_4;
    wire [WEIGHT_WIDTH-1:0] w4_1, w4_2, w4_3, w4_4;

    wire [PRODUCT_WIDTH - 1:0] product1, product2, product3, product4;

    bicubic_pvector_mult_wmatrix u_bicubic_pverctor_mult_wmatrix (
        .clk(clk),
        .ena(reg_ena),
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

        .p1(cur_product1),
        .p2(cur_product2),
        .p3(cur_product3),
        .p4(cur_product4),

        .inner_product1(product1),
        .inner_product2(product2),
        .inner_product3(product3),
        .inner_product4(product4)
    );

    assign w1_1 = S_U3_1;
    assign w1_2 = S_U3_2;
    assign w1_3 = S_U3_3;
    assign w1_4 = S_U3_4;    

    assign w2_1 = S_U4_1;
    assign w2_2 = S_U4_2;
    assign w2_3 = S_U4_3;
    assign w2_4 = S_U4_4;  

    assign w3_1 = S_U1_1;
    assign w3_2 = S_U1_2;
    assign w3_3 = S_U1_3;
    assign w3_4 = S_U1_4;  

    assign w4_1 = S_U2_1;
    assign w4_2 = S_U2_2;
    assign w4_3 = S_U2_3;
    assign w4_4 = S_U2_4;  

    assign bcci_rsp_data1 = product1[PRODUCT_WIDTH - 1] ? {CHANNEL_WIDTH{1'b0}} : product1[PRODUCT_WIDTH - 2 : 22] > 255 ? 255 : product1[CHANNEL_WIDTH + 21 : 22];
    assign bcci_rsp_data2 = product2[PRODUCT_WIDTH - 1] ? {CHANNEL_WIDTH{1'b0}} : product2[PRODUCT_WIDTH - 2 : 22] > 255 ? 255 : product2[CHANNEL_WIDTH + 21 : 22];
    assign bcci_rsp_data3 = product3[PRODUCT_WIDTH - 1] ? {CHANNEL_WIDTH{1'b0}} : product3[PRODUCT_WIDTH - 2 : 22] > 255 ? 255 : product3[CHANNEL_WIDTH + 21 : 22];
    assign bcci_rsp_data4 = product4[PRODUCT_WIDTH - 1] ? {CHANNEL_WIDTH{1'b0}} : product4[PRODUCT_WIDTH - 2 : 22] > 255 ? 255 : product4[CHANNEL_WIDTH + 21 : 22];


    
endmodule


// `include "../tb/define.v"
module buffer_sram #(
    parameter BUFFER_WIDTH=24,
    parameter BLOCK_SIZE=960
) (
    input wire clk,
    input wire rst_n,

// for simulations
`ifndef SIM_WITHOUT_AXI
    output wire axi_ready,
    input wire [23:0] axi_data,
    input wire axi_valid,
`endif

    output wire bf_req_valid,
    input wire bcci_req_ready,

    output wire [BUFFER_WIDTH-1:0] out_p1,
    output wire [BUFFER_WIDTH-1:0] out_p2,
    output wire [BUFFER_WIDTH-1:0] out_p3,
    output wire [BUFFER_WIDTH-1:0] out_p4,
    output wire [BUFFER_WIDTH-1:0] out_p5,
    output wire [BUFFER_WIDTH-1:0] out_p6,
    output wire [BUFFER_WIDTH-1:0] out_p7,
    output wire [BUFFER_WIDTH-1:0] out_p8,
    output wire [BUFFER_WIDTH-1:0] out_p9,
    output wire [BUFFER_WIDTH-1:0] out_p10,
    output wire [BUFFER_WIDTH-1:0] out_p11,
    output wire [BUFFER_WIDTH-1:0] out_p12,
    output wire [BUFFER_WIDTH-1:0] out_p13,
    output wire [BUFFER_WIDTH-1:0] out_p14,
    output wire [BUFFER_WIDTH-1:0] out_p15,
    output wire [BUFFER_WIDTH-1:0] out_p16,


// for simulations
`ifdef SIM_WITHOUT_AXI

    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4, 

`endif



    input wire bcci_2_bf_hsked

);

    localparam WIDTH = BLOCK_SIZE;
    localparam HEIGHT = `SRC_IMG_HEIGHT;
    
// only valid when degree of parallelism is 1 for simulation
`ifdef SIM_WITHOUT_AXI
    wire axi_ready;
    wire [23:0] axi_data;
    wire axi_valid; 
    bicubic_read_bmp u_bicubic_read_bmp(
        .clk(clk), 
        .rst_n(rst_n),
        .ready(axi_ready),
        .data(axi_data),
        .valid(axi_valid)
    );
`endif

    wire axi_hsked = axi_ready & axi_valid;            // input pixel handshaked signal
    wire bf_req_hsked = bf_req_valid & bcci_req_ready; // output pixel handahsked signal



    // the counter used for initialization, the output valid when the initial four rows are completed
    localparam INIT_CNT_WIDTH = $clog2((WIDTH)*4+1);
    wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    wire init_finished = (cur_init_cnt == WIDTH*4) ? 1'b1 : 1'b0;
    assign nxt_init_cnt = cur_init_cnt + 1;
    wire init_cnt_ena = init_finished ? 1'b0 : axi_valid;
    dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));


    // determine which ram block to initialize
    wire cur_init_ram1 = (cur_init_cnt<WIDTH) ? 1'b1 : 1'b0;
    wire cur_init_ram2 = ((cur_init_cnt<WIDTH*2) & (cur_init_cnt>=WIDTH*1)) ? 1'b1 : 1'b0;
    wire cur_init_ram3 = ((cur_init_cnt<WIDTH*3) & (cur_init_cnt>=WIDTH*2)) ? 1'b1 : 1'b0;
    wire cur_init_ram4 = ((cur_init_cnt<WIDTH*4) & (cur_init_cnt>=WIDTH*3)) ? 1'b1 : 1'b0;  


    localparam ADDR_WIDTH = $clog2(WIDTH+1);


    // four of the five block rams are used for calculations and the extra one is used to receive inputs of the next row
    wire cs_n1, cs_n2, cs_n3, cs_n4, cs_n5;
    wire wr_en1, wr_en2, wr_en3, wr_en4, wr_en5; 
    wire [ADDR_WIDTH-1:0] addr1, addr2, addr3, addr4, addr5;
    wire [BUFFER_WIDTH-1:0] data_out1, data_out2, data_out3, data_out4, data_out5;
 



    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_sram1 
          (.clk(clk), .addr(addr1), .cs_n(cs_n1), .wr_en(wr_en1), .data_in(axi_data), .data_out(data_out1)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_sram2 
          (.clk(clk), .addr(addr2), .cs_n(cs_n2), .wr_en(wr_en2), .data_in(axi_data), .data_out(data_out2)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_sram3 
          (.clk(clk), .addr(addr3), .cs_n(cs_n3), .wr_en(wr_en3), .data_in(axi_data), .data_out(data_out3)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_sram4 
          (.clk(clk), .addr(addr4), .cs_n(cs_n4), .wr_en(wr_en4), .data_in(axi_data), .data_out(data_out4)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_sram5 
          (.clk(clk), .addr(addr5), .cs_n(cs_n5), .wr_en(wr_en5), .data_in(axi_data), .data_out(data_out5)); 




    // FSM to control the output sequence
    // S0 is for initialization, S1 -> S5 for calculation
    localparam FSM_WIDTH = 3;
    localparam STATE_S0 = 3'd0;
    localparam STATE_S1 = 3'd1;
    localparam STATE_S2 = 3'd2;
    localparam STATE_S3 = 3'd3;
    localparam STATE_S4 = 3'd4;
    localparam STATE_S5 = 3'd5;

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;
    wire [FSM_WIDTH-1:0] state_s0_nxt = STATE_S1;
    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_S3;
    wire [FSM_WIDTH-1:0] state_s3_nxt = STATE_S4;
    wire [FSM_WIDTH-1:0] state_s4_nxt = STATE_S5;
    wire [FSM_WIDTH-1:0] state_s5_nxt = STATE_S1;

    wire cur_is_s0 = (cur_state == STATE_S0) ? 1'b1 : 1'b0; 
    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;
    wire cur_is_s3 = (cur_state == STATE_S3) ? 1'b1 : 1'b0;
    wire cur_is_s4 = (cur_state == STATE_S4) ? 1'b1 : 1'b0;
    wire cur_is_s5 = (cur_state == STATE_S5) ? 1'b1 : 1'b0;

    wire state_s0_exit_ena;
    wire state_s1_exit_ena;
    wire state_s2_exit_ena;
    wire state_s3_exit_ena;
    wire state_s4_exit_ena;
    wire state_s5_exit_ena;

    assign nxt_state = ({FSM_WIDTH{state_s0_exit_ena}} & state_s0_nxt)
                     | ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                     | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt)
                     | ({FSM_WIDTH{state_s3_exit_ena}} & state_s3_nxt)
                     | ({FSM_WIDTH{state_s4_exit_ena}} & state_s4_nxt)
                     | ({FSM_WIDTH{state_s5_exit_ena}} & state_s5_nxt);

    wire state_ena;

    dfflr #(.DW(FSM_WIDTH)) u_cs_fsm(.lden(state_ena), .dnxt(nxt_state), .qout(cur_state), .clk(clk), .rst_n(rst_n));    



    // configure the cs signal of rams
    assign {cs_n1, cs_n2, cs_n3, cs_n4, cs_n5} = ({5{cur_is_s0}} & 5'b00001)
                                               | ({5{cur_is_s1}} & 5'b00000)
                                               | ({5{cur_is_s2}} & 5'b00000)
                                               | ({5{cur_is_s3}} & 5'b00000)
                                               | ({5{cur_is_s4}} & 5'b00000)
                                               | ({5{cur_is_s5}} & 5'b00000);




    // column counter to configure request signal
    localparam COL_CNT_WIDTH = $clog2(WIDTH+10)+1;
    wire [COL_CNT_WIDTH-1:0] cur_col_cnt, nxt_col_cnt;

    wire cur_col_cnt_below_3 = (cur_col_cnt < 3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_4 = (cur_col_cnt < 4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_5 = (cur_col_cnt < 5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_6 = (cur_col_cnt < 6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_7 = (cur_col_cnt < 7) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_8 = (cur_col_cnt < 8) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_9 = (cur_col_cnt < 9) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_10 = (cur_col_cnt < 10) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_11 = (cur_col_cnt < 11) ? 1'b1 : 1'b0;

    wire cur_col_cnt_over_5 = (cur_col_cnt > 5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_over_6 = (cur_col_cnt > 6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_over_7 = (cur_col_cnt > 7) ? 1'b1 : 1'b0;
    wire cur_col_cnt_over_8 = (cur_col_cnt > 8) ? 1'b1 : 1'b0;
    wire cur_col_cnt_over_9 = (cur_col_cnt > 9) ? 1'b1 : 1'b0;
    wire cur_col_cnt_over_10 = (cur_col_cnt > 10) ? 1'b1 : 1'b0;

    wire cur_col_cnt_is_0 = (cur_col_cnt == 0) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_1 = (cur_col_cnt == 1) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_6 = (cur_col_cnt == 6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_7 = (cur_col_cnt == 7) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_8 = (cur_col_cnt == 8) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_9 = (cur_col_cnt == 9) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_10 = (cur_col_cnt == 10) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_11 = (cur_col_cnt == 11) ? 1'b1 : 1'b0;

    wire cur_col_cnt_is_width = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_2 = (cur_col_cnt == WIDTH+2) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_3 = (cur_col_cnt == WIDTH+3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_4 = (cur_col_cnt == WIDTH+4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_5 = (cur_col_cnt == WIDTH+5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_6 = (cur_col_cnt == WIDTH+6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_7 = (cur_col_cnt == WIDTH+7) ? 1'b1 : 1'b0;    
    wire cur_col_cnt_is_width_plus_8 = (cur_col_cnt == WIDTH+8) ? 1'b1 : 1'b0;    
    wire cur_col_cnt_is_width_plus_9 = (cur_col_cnt == WIDTH+9) ? 1'b1 : 1'b0;    
    wire cur_col_cnt_is_width_plus_10 = (cur_col_cnt == WIDTH+10) ? 1'b1 : 1'b0;    

    wire cur_col_cnt_below_width_plus_3 = (cur_col_cnt < WIDTH+3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_4 = (cur_col_cnt < WIDTH+4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_5 = (cur_col_cnt < WIDTH+5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_6 = (cur_col_cnt < WIDTH+6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_7 = (cur_col_cnt < WIDTH+7) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_8 = (cur_col_cnt < WIDTH+8) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_9 = (cur_col_cnt < WIDTH+9) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_10 = (cur_col_cnt < WIDTH+10) ? 1'b1 : 1'b0;

    wire col_cnt_ena;
    dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));




    // row counters to determine the row sequence of output data
    localparam ROW_CNT_WIDTH = $clog2(HEIGHT*4+1)+1;
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt, nxt_row_cnt;
    wire cur_row_cnt_is_0 = (cur_row_cnt == 0) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_1 = (cur_row_cnt == 1) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_2 = (cur_row_cnt == 2) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_3 = (cur_row_cnt == 3) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_4 = (cur_row_cnt == 4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_5 = (cur_row_cnt == 5) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_9 = (cur_row_cnt == 9) ? 1'b1 : 1'b0;
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt_minus_6 = cur_row_cnt - 6;

    wire cur_row_cnt_over_7 = (cur_row_cnt > 7) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_8 = (cur_row_cnt > 8) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_9 = (cur_row_cnt > 9) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_4x_plus_6 = (cur_row_cnt_minus_6[1:0] == 2'b11) ? 1'b1 : 1'b0;

    wire cur_row_cnt_below_last_10 = (cur_row_cnt + 11 < HEIGHT*4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_last_10 = (cur_row_cnt + 10 > HEIGHT*4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_last_9 = (cur_row_cnt + 9 > HEIGHT*4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_last_8 = (cur_row_cnt + 8 > HEIGHT*4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_over_last_7 = (cur_row_cnt + 7 > HEIGHT*4) ? 1'b1 : 1'b0;

    wire cur_row_cnt_is_last_7 = (cur_row_cnt == HEIGHT*4-7) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_6 = (cur_row_cnt == HEIGHT*4-6) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_5 = (cur_row_cnt == HEIGHT*4-5) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_4 = (cur_row_cnt == HEIGHT*4-4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_3 = (cur_row_cnt == HEIGHT*4-3) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_2 = (cur_row_cnt == HEIGHT*4-2) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_1 = (cur_row_cnt == HEIGHT*4-1) ? 1'b1 : 1'b0;


    // the write address configure
    wire [ADDR_WIDTH-1:0] cur_waddr, nxt_waddr;
    wire cur_wr_end = (~init_finished) ? (cur_waddr == WIDTH-1) : (cur_waddr == WIDTH);  // the input of next row is end
    assign nxt_waddr = (~cur_wr_end) ? cur_waddr+1 : 0;
    wire waddr_ena = cur_is_s0 ? axi_hsked : cur_wr_end ? state_ena : axi_hsked;
    dfflr #(.DW(ADDR_WIDTH)) u_waddr_reg(.lden(waddr_ena), .dnxt(nxt_waddr), .qout(cur_waddr), .clk(clk), .rst_n(rst_n));  



    // row counter configure
    assign nxt_row_cnt = cur_row_cnt + 1;
`ifdef MULT_IN_TWO_CYCLE
    wire row_cnt_ena = (~cur_row_cnt_over_8) ? cur_col_cnt_is_width_plus_6 & bcci_2_bf_hsked : (~cur_row_cnt_is_4x_plus_6) ? cur_col_cnt_is_width_plus_6 & bcci_2_bf_hsked : cur_col_cnt_is_width_plus_6 & bcci_2_bf_hsked & (cur_wr_end | cur_row_cnt_over_last_10);
`elsif MULT_IN_THREE_CYCLE
    wire row_cnt_ena = (~cur_row_cnt_over_8) ? cur_col_cnt_is_width_plus_7 & bcci_2_bf_hsked : (~cur_row_cnt_is_4x_plus_6) ? cur_col_cnt_is_width_plus_7 & bcci_2_bf_hsked : cur_col_cnt_is_width_plus_7 & bcci_2_bf_hsked & (cur_wr_end | cur_row_cnt_over_last_10);
`elsif MULT_IN_FOUR_CYCLE
    wire row_cnt_ena = (~cur_row_cnt_over_8) ? cur_col_cnt_is_width_plus_8 & bcci_2_bf_hsked : (~cur_row_cnt_is_4x_plus_6) ? cur_col_cnt_is_width_plus_8 & bcci_2_bf_hsked : cur_col_cnt_is_width_plus_8 & bcci_2_bf_hsked & (cur_wr_end | cur_row_cnt_over_last_10);
`elsif MULT_IN_FIVE_CYCLE
    wire row_cnt_ena = (~cur_row_cnt_over_8) ? cur_col_cnt_is_width_plus_9 & bcci_2_bf_hsked : (~cur_row_cnt_is_4x_plus_6) ? cur_col_cnt_is_width_plus_9 & bcci_2_bf_hsked : cur_col_cnt_is_width_plus_9 & bcci_2_bf_hsked & (cur_wr_end | cur_row_cnt_over_last_10);
`elsif MULT_IN_SIX_CYCLE
    wire row_cnt_ena = (~cur_row_cnt_over_8) ? cur_col_cnt_is_width_plus_10 & bcci_2_bf_hsked : (~cur_row_cnt_is_4x_plus_6) ? cur_col_cnt_is_width_plus_10 & bcci_2_bf_hsked : cur_col_cnt_is_width_plus_10 & bcci_2_bf_hsked & (cur_wr_end | cur_row_cnt_over_last_10);
`endif

    dfflr #(.DW(ROW_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));



    // next column counter 
`ifdef MULT_IN_TWO_CYCLE
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_6 ? 0 : (cur_col_cnt_is_0 & state_ena & cur_row_cnt_over_9) ? 0 :cur_col_cnt + 1;
`elsif MULT_IN_THREE_CYCLE
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_7 ? 0 : (cur_col_cnt_is_0 & state_ena & cur_row_cnt_over_9) ? 0 :cur_col_cnt + 1;
`elsif MULT_IN_FOUR_CYCLE
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_8 ? 0 : (cur_col_cnt_is_0 & state_ena & cur_row_cnt_over_9) ? 0 :cur_col_cnt + 1;
`elsif MULT_IN_FIVE_CYCLE
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_9 ? 0 : (cur_col_cnt_is_0 & state_ena & cur_row_cnt_over_9) ? 0 :cur_col_cnt + 1;
`elsif MULT_IN_SIX_CYCLE
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_10 ? 0 : (cur_col_cnt_is_0 & state_ena & cur_row_cnt_over_9) ? 0 :cur_col_cnt + 1;
`endif
  

    // read ram addr, four block rams shared the same address
    wire [ADDR_WIDTH-1:0] cur_raddr, nxt_raddr;
    assign nxt_raddr = ((cur_raddr < WIDTH-1) & (~cur_col_cnt_below_3)) ? cur_raddr+1 
                     : ((cur_raddr == WIDTH-1) & (cur_col_cnt_below_width_plus_4)) ? cur_raddr : 0;
    wire cur_rd_end = (cur_raddr == WIDTH-1) ? 1'b1 : 1'b0;
    wire raddr_ena;
    dfflr #(.DW(ADDR_WIDTH)) u_raddr_reg(.lden(raddr_ena), .dnxt(nxt_raddr), .qout(cur_raddr), .clk(clk), .rst_n(rst_n));    


    // delayed the init_finished signal to meet timing requirments 
    wire init_finished_delayed;
    dfflr #(.DW(1)) u_init_delayed_reg (.lden(1'b1), .dnxt(init_finished), .qout(init_finished_delayed), .clk(clk), .rst_n(rst_n));



    // special handling when the column counter is 0
    wire col_cnt_0_fetched, nxt_col_cnt0_fetched;
    wire col_cnt_0_fetched_ena = (cur_col_cnt_is_0 & bcci_2_bf_hsked & cur_row_cnt_over_8 & cur_row_cnt_is_4x_plus_6) | cur_col_cnt_is_1;
    assign nxt_col_cnt0_fetched = bcci_2_bf_hsked ? 1'b1 : 1'b0;
    dfflr #(.DW(1)) u_col_cnt_0_fetched_reg (.lden(col_cnt_0_fetched_ena), .dnxt(nxt_col_cnt0_fetched), .qout(col_cnt_0_fetched), .clk(clk), .rst_n(rst_n));



    // special handling when column counter is 0
    wire col_cnt0_ena_normal = (cur_col_cnt_is_0 & cur_row_cnt_over_8) ? 
                                ((~cur_row_cnt_is_4x_plus_6) & bcci_2_bf_hsked) | (cur_row_cnt_is_4x_plus_6 & bcci_2_bf_hsked & (cur_row_cnt_over_last_10)) : bcci_2_bf_hsked; 

    wire col_cnt0_ena_abnormal = cur_col_cnt_is_0 & cur_row_cnt_over_8 & cur_row_cnt_is_4x_plus_6 & cur_wr_end & col_cnt_0_fetched; 


    // column conter increase enable signal
`ifdef MULT_IN_TWO_CYCLE
    assign col_cnt_ena = init_finished & (   (cur_col_cnt_is_0 & ((~init_finished_delayed) |  (col_cnt0_ena_abnormal | col_cnt0_ena_normal))) // when col_cnt is 0
                                           | ((~cur_col_cnt_is_0) & cur_col_cnt_below_7)                                                      // when col_cnt is (0, 7)
                                           | (cur_col_cnt_below_width_plus_6 & cur_col_cnt_over_6 & bcci_2_bf_hsked)                          // when col_cnt is (7, width+6)
                                           | (cur_col_cnt_is_width_plus_6 & bcci_2_bf_hsked)                                                  // when col_cnt is width+5
                                        );

`elsif MULT_IN_THREE_CYCLE
    assign col_cnt_ena = init_finished & (   (cur_col_cnt_is_0 & ((~init_finished_delayed) |  (col_cnt0_ena_abnormal | col_cnt0_ena_normal))) // when col_cnt is 0
                                           | ((~cur_col_cnt_is_0) & cur_col_cnt_below_8)                                                      // when col_cnt is (0, 8)
                                           | (cur_col_cnt_below_width_plus_7 & cur_col_cnt_over_7 & bcci_2_bf_hsked)                          // when col_cnt is (8, width+7)
                                           | (cur_col_cnt_is_width_plus_7 & bcci_2_bf_hsked)                                                  // when col_cnt is width+7
                                        );
`elsif MULT_IN_FOUR_CYCLE
    assign col_cnt_ena = init_finished & (   (cur_col_cnt_is_0 & ((~init_finished_delayed) |  (col_cnt0_ena_abnormal | col_cnt0_ena_normal))) // when col_cnt is 0
                                           | ((~cur_col_cnt_is_0) & cur_col_cnt_below_9)                                                      // when col_cnt is (0, 9)
                                           | (cur_col_cnt_below_width_plus_8 & cur_col_cnt_over_8 & bcci_2_bf_hsked)                          // when col_cnt is (9, width+8)
                                           | (cur_col_cnt_is_width_plus_8 & bcci_2_bf_hsked)                                                  // when col_cnt is width+8
                                        );
`elsif MULT_IN_FIVE_CYCLE
    assign col_cnt_ena = init_finished & (   (cur_col_cnt_is_0 & ((~init_finished_delayed) |  (col_cnt0_ena_abnormal | col_cnt0_ena_normal))) // when col_cnt is 0
                                           | ((~cur_col_cnt_is_0) & cur_col_cnt_below_10)                                                      // when col_cnt is (0, 10)
                                           | (cur_col_cnt_below_width_plus_9 & cur_col_cnt_over_9 & bcci_2_bf_hsked)                          // when col_cnt is (10, width+9)
                                           | (cur_col_cnt_is_width_plus_9 & bcci_2_bf_hsked)                                                  // when col_cnt is width+9
                                        );         
`elsif MULT_IN_SIX_CYCLE
    assign col_cnt_ena = init_finished & (   (cur_col_cnt_is_0 & ((~init_finished_delayed) |  (col_cnt0_ena_abnormal | col_cnt0_ena_normal))) // when col_cnt is 0
                                           | ((~cur_col_cnt_is_0) & cur_col_cnt_below_11)                                                      // when col_cnt is (0, 11)
                                           | (cur_col_cnt_below_width_plus_10 & cur_col_cnt_over_10 & bcci_2_bf_hsked)                          // when col_cnt is (11, width+10)
                                           | (cur_col_cnt_is_width_plus_10 & bcci_2_bf_hsked)                                                  // when col_cnt is width+10
                                        ); 
`endif


    wire end_of_data;

    // shift signal 
`ifdef MULT_IN_TWO_CYCLE
    wire shift_ena = (init_finished & (~end_of_data)) ? cur_col_cnt_is_0 ? (~state_ena) | (~init_finished_delayed) : ((cur_col_cnt_below_width_plus_6 & bcci_2_bf_hsked) | cur_col_cnt_below_7) : 1'b0;
`elsif MULT_IN_THREE_CYCLE
    wire shift_ena = (init_finished & (~end_of_data)) ? cur_col_cnt_is_0 ? (~state_ena) | (~init_finished_delayed) : ((cur_col_cnt_below_width_plus_7 & bcci_2_bf_hsked) | cur_col_cnt_below_8) : 1'b0;
`elsif MULT_IN_FOUR_CYCLE
    wire shift_ena = (init_finished & (~end_of_data)) ? cur_col_cnt_is_0 ? (~state_ena) | (~init_finished_delayed) : ((cur_col_cnt_below_width_plus_8 & bcci_2_bf_hsked) | cur_col_cnt_below_9) : 1'b0;
`elsif MULT_IN_FIVE_CYCLE
    wire shift_ena = (init_finished & (~end_of_data)) ? cur_col_cnt_is_0 ? (~state_ena) | (~init_finished_delayed) : ((cur_col_cnt_below_width_plus_9 & bcci_2_bf_hsked) | cur_col_cnt_below_10) : 1'b0;
`elsif MULT_IN_SIX_CYCLE
    wire shift_ena = (init_finished & (~end_of_data)) ? cur_col_cnt_is_0 ? (~state_ena) | (~init_finished_delayed) : ((cur_col_cnt_below_width_plus_10 & bcci_2_bf_hsked) | cur_col_cnt_below_11) : 1'b0;
`endif


    // every time the register shifts then the read address adds
    assign raddr_ena = init_finished ? shift_ena : 1'b0;


    // FSM exit signal
`ifdef MULT_IN_TWO_CYCLE
    wire state_exit_normal = cur_row_cnt_is_4x_plus_6 & cur_col_cnt_is_width_plus_6 & bcci_2_bf_hsked & (~cur_row_cnt_is_last_7);
`elsif MULT_IN_THREE_CYCLE
    wire state_exit_normal = cur_row_cnt_is_4x_plus_6 & cur_col_cnt_is_width_plus_7 & bcci_2_bf_hsked & (~cur_row_cnt_is_last_7);
`elsif MULT_IN_FOUR_CYCLE
    wire state_exit_normal = cur_row_cnt_is_4x_plus_6 & cur_col_cnt_is_width_plus_8 & bcci_2_bf_hsked & (~cur_row_cnt_is_last_7);
`elsif MULT_IN_FIVE_CYCLE
    wire state_exit_normal = cur_row_cnt_is_4x_plus_6 & cur_col_cnt_is_width_plus_9 & bcci_2_bf_hsked & (~cur_row_cnt_is_last_7);
`elsif MULT_IN_SIX_CYCLE
    wire state_exit_normal = cur_row_cnt_is_4x_plus_6 & cur_col_cnt_is_width_plus_10 & bcci_2_bf_hsked & (~cur_row_cnt_is_last_7);
`endif

    assign state_s0_exit_ena = (cur_is_s0 & init_finished) ? 1'b1 : 1'b0;
    assign state_s1_exit_ena = (cur_is_s1 & cur_wr_end & state_exit_normal) ? ((~cur_row_cnt_is_last_3) & cur_row_cnt_over_9) | cur_row_cnt_is_9 : 1'b0;
    assign state_s2_exit_ena = (cur_is_s2 & cur_wr_end & state_exit_normal) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s3_exit_ena = (cur_is_s3 & cur_wr_end & state_exit_normal) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s4_exit_ena = (cur_is_s4 & cur_wr_end & state_exit_normal) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s5_exit_ena = (cur_is_s5 & cur_wr_end & state_exit_normal) ? (~cur_row_cnt_is_last_3) : 1'b0;

    assign state_ena = state_s0_exit_ena | state_s1_exit_ena 
                     | state_s2_exit_ena | state_s3_exit_ena
                     | state_s4_exit_ena | state_s5_exit_ena;



    wire [BUFFER_WIDTH-1:0] line_out1, line_out2, line_out3, line_out4;
    wire [BUFFER_WIDTH-1:0] ram_out1, ram_out2, ram_out3, ram_out4;

    // reshape the ram out sequence for boundary fill in the row direction
    assign line_out1 = (cur_row_cnt_is_last_3 | cur_row_cnt_is_last_4 | cur_row_cnt_is_last_5 | cur_row_cnt_is_last_6) ? ram_out2 
                     : (cur_row_cnt_is_last_1 | cur_row_cnt_is_last_2) ? ram_out3

                     : ram_out1;

    assign line_out2 = (cur_row_cnt_is_last_3 | cur_row_cnt_is_last_4 | cur_row_cnt_is_last_5 | cur_row_cnt_is_last_6) ? ram_out3 
                     : (cur_row_cnt_is_last_1 | cur_row_cnt_is_last_2) ? ram_out4

                     : (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out1 
                     : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out1 : ram_out2;

    assign line_out3 = (cur_row_cnt_is_last_3 | cur_row_cnt_is_last_4 | cur_row_cnt_is_last_5 | cur_row_cnt_is_last_6) ? ram_out4
                     : (cur_row_cnt_is_last_1 | cur_row_cnt_is_last_2) ? ram_out4

                     : (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out1 
                     : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out2 : ram_out3;

    assign line_out4 = (cur_row_cnt_is_last_3 | cur_row_cnt_is_last_4 | cur_row_cnt_is_last_5 | cur_row_cnt_is_last_6) ? ram_out4
                     : (cur_row_cnt_is_last_1 | cur_row_cnt_is_last_2) ? ram_out4

                     : (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out2 
                     : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out3 : ram_out4;



    // output pixels
    dffl #(.DW(BUFFER_WIDTH)) u_dffl1(.lden(shift_ena), .dnxt(out_p2), .qout(out_p1), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl2(.lden(shift_ena), .dnxt(out_p3), .qout(out_p2), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl3(.lden(shift_ena), .dnxt(out_p4), .qout(out_p3), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl4(.lden(shift_ena), .dnxt(line_out1), .qout(out_p4), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl5(.lden(shift_ena), .dnxt(out_p6), .qout(out_p5), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl6(.lden(shift_ena), .dnxt(out_p7), .qout(out_p6), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl7(.lden(shift_ena), .dnxt(out_p8), .qout(out_p7), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl8(.lden(shift_ena), .dnxt(line_out2), .qout(out_p8), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl9(.lden(shift_ena), .dnxt(out_p10), .qout(out_p9), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl10(.lden(shift_ena), .dnxt(out_p11), .qout(out_p10), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl11(.lden(shift_ena), .dnxt(out_p12), .qout(out_p11), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl12(.lden(shift_ena), .dnxt(line_out3), .qout(out_p12), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl13(.lden(shift_ena), .dnxt(out_p14), .qout(out_p13), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl14(.lden(shift_ena), .dnxt(out_p15), .qout(out_p14), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl15(.lden(shift_ena), .dnxt(out_p16), .qout(out_p15), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl16(.lden(shift_ena), .dnxt(line_out4), .qout(out_p16), .clk(clk));


    // configure the wr_en signal of rams
    assign {wr_en1, wr_en2, wr_en3, wr_en4, wr_en5} =
          ({5{cur_is_s0 & cur_init_ram1 & axi_hsked}} & 5'b10000)
        | ({5{cur_is_s0 & cur_init_ram2 & axi_hsked}} & 5'b01000)
        | ({5{cur_is_s0 & cur_init_ram3 & axi_hsked}} & 5'b00100)
        | ({5{cur_is_s0 & cur_init_ram4 & axi_hsked}} & 5'b00010)
        | ({5{cur_is_s1 & axi_hsked}} & {4'b0000, 1'b1})
        | ({5{cur_is_s2 & axi_hsked}} & {1'b1, 4'b0000})
        | ({5{cur_is_s3 & axi_hsked}} & {1'b0, 1'b1, 3'b000})
        | ({5{cur_is_s4 & axi_hsked}} & {2'b00, 1'b1, 2'b00})
        | ({5{cur_is_s5 & axi_hsked}} & {3'b000, 1'b1, 1'b0});



    // configure the address of each block ram (write addr or read addr ?)
    assign addr1 = (cur_is_s0 | (cur_is_s2 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s3 | cur_is_s4 | cur_is_s5) ? (shift_ena ? nxt_raddr : cur_raddr) : {ADDR_WIDTH{1'b0}};

    assign addr2 = (cur_is_s0 | (cur_is_s3 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s4 | cur_is_s5) ? (shift_ena ? nxt_raddr : cur_raddr) : {ADDR_WIDTH{1'b0}};

    assign addr3 = (cur_is_s0 | (cur_is_s4 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s5) ? (shift_ena ? nxt_raddr : cur_raddr)  : {ADDR_WIDTH{1'b0}};
                   
    assign addr4 = (cur_is_s0 | (cur_is_s5 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s4) ? (shift_ena ? nxt_raddr : cur_raddr)  : {ADDR_WIDTH{1'b0}};

    assign addr5 = (cur_is_s1 & (~cur_wr_end)) ? cur_waddr :
                   (cur_is_s2 | cur_is_s3 | cur_is_s4 | cur_is_s5) ? (shift_ena ? nxt_raddr : cur_raddr)  : {ADDR_WIDTH{1'b0}};



    // reshape the block ram direct out sequence
    assign ram_out1 = cur_is_s0 ? {BUFFER_WIDTH{1'b0}} :
                      cur_is_s1 ? data_out1 :
                      cur_is_s2 ? data_out2 :
                      cur_is_s3 ? data_out3 :
                      cur_is_s4 ? data_out4 :
                      cur_is_s5 ? data_out5 : {BUFFER_WIDTH{1'b0}};

    assign ram_out2 = cur_is_s0 ? {BUFFER_WIDTH{1'b0}} :
                      cur_is_s1 ? data_out2 :
                      cur_is_s2 ? data_out3 :
                      cur_is_s3 ? data_out4 :
                      cur_is_s4 ? data_out5 :
                      cur_is_s5 ? data_out1 : {BUFFER_WIDTH{1'b0}}; 

    assign ram_out3 = cur_is_s0 ? {BUFFER_WIDTH{1'b0}} :
                      cur_is_s1 ? data_out3 :
                      cur_is_s2 ? data_out4 :
                      cur_is_s3 ? data_out5 :
                      cur_is_s4 ? data_out1 :
                      cur_is_s5 ? data_out2 : {BUFFER_WIDTH{1'b0}}; 

    assign ram_out4 = cur_is_s0 ? {BUFFER_WIDTH{1'b0}} :
                      cur_is_s1 ? data_out4 :
                      cur_is_s2 ? data_out5 :
                      cur_is_s3 ? data_out1 :
                      cur_is_s4 ? data_out2 :
                      cur_is_s5 ? data_out3 : {BUFFER_WIDTH{1'b0}}; 



    // valid signal to the output side
    assign bf_req_valid = init_finished ? ((cur_col_cnt_below_width_plus_6) & (~cur_col_cnt_below_5) & (~end_of_data)) : 1'b0;


    // ready signal to the input side
    assign axi_ready = (~init_finished) 
                     | ((cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s4 | cur_is_s5) & ( ~cur_wr_end));


    // signal indicates that the data of this figure is end 
    wire end_ena = (cur_row_cnt_is_last_1 & row_cnt_ena) ? 1'b1 : 1'b0;
    dfflr #(.DW(1)) u_data_end_reg (.lden(end_ena), .dnxt(1'b1), .qout(end_of_data), .clk(clk), .rst_n(rst_n));




// simulatiuon codes
`ifdef SIM_WITHOUT_AXI
    localparam OUT_BUFFER_WIDTH = BUFFER_WIDTH*4;

    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
    reg [32:0] result_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            result_cnt <= 0;
        end
        else begin
            `ifdef MULT_IN_TWO_CYCLE
                if(bcci_2_bf_hsked) begin
                    if(cur_col_cnt_is_7) begin
                        $display("%x", out1[BUFFER_WIDTH*2-1:0]);
                    end
                    else if(cur_col_cnt_is_0) begin
                        $display("%x", out1[BUFFER_WIDTH*4-1:BUFFER_WIDTH*2]);
                    end
                    else begin
                        $display("%x", out1);
                    end
                    result_cnt <= result_cnt + 1;
                end

            `elsif MULT_IN_THREE_CYCLE
                if(bcci_2_bf_hsked) begin
                    if(cur_col_cnt_is_8) begin
                        $display("%x", out1[BUFFER_WIDTH*2-1:0]);
                    end
                    else if(cur_col_cnt_is_0) begin
                        $display("%x", out1[BUFFER_WIDTH*4-1:BUFFER_WIDTH*2]);
                    end
                    else begin
                        $display("%x", out1);
                    end
                    result_cnt <= result_cnt + 1;
                end

            `elsif MULT_IN_FOUR_CYCLE
                if(bcci_2_bf_hsked) begin
                    if(cur_col_cnt_is_9) begin
                        $display("%x", out1[BUFFER_WIDTH*2-1:0]);
                    end
                    else if(cur_col_cnt_is_0) begin
                        $display("%x", out1[BUFFER_WIDTH*4-1:BUFFER_WIDTH*2]);
                    end
                    else begin
                        $display("%x", out1);
                    end
                    result_cnt <= result_cnt + 1;
                end
            `elsif MULT_IN_FIVE_CYCLE
                if(bcci_2_bf_hsked) begin
                    if(cur_col_cnt_is_10) begin
                        $display("%x", out1[BUFFER_WIDTH*2-1:0]);
                    end
                    else if(cur_col_cnt_is_0) begin
                        $display("%x", out1[BUFFER_WIDTH*4-1:BUFFER_WIDTH*2]);
                    end
                    else begin
                        $display("%x", out1);
                    end
                    result_cnt <= result_cnt + 1;
                end
            `elsif MULT_IN_SIX_CYCLE
                if(bcci_2_bf_hsked) begin
                    if(cur_col_cnt_is_11) begin
                        $display("%x", out1[BUFFER_WIDTH*2-1:0]);
                    end
                    else if(cur_col_cnt_is_0) begin
                        $display("%x", out1[BUFFER_WIDTH*4-1:BUFFER_WIDTH*2]);
                    end
                    else begin
                        $display("%x", out1);
                    end
                    result_cnt <= result_cnt + 1;
                end
            `endif
        end
    end

`endif



endmodule

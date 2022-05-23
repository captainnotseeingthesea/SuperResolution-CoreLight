
module buffer_sram #(
    parameter BUFFER_WIDTH=24
) (
    input wire clk,
    input wire rst_n,

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



`ifdef SIM_WITHOUT_AXI

    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4, 

`endif



    input wire bcci_2_bf_hsked

);

    localparam WIDTH = `SRC_IMG_WIDTH;
    localparam HEIGHT = `SRC_IMG_HEIGHT;
    
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

    wire axi_hsked = axi_ready & axi_valid;
    wire bf_req_hsked = bf_req_valid & bcci_req_ready;

    localparam INIT_CNT_WIDTH = $clog2((WIDTH)*4);
    wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    wire init_finished = (cur_init_cnt == WIDTH*4) ? 1'b1 : 1'b0;
    assign nxt_init_cnt = cur_init_cnt + 1;
    wire init_cnt_ena = init_finished ? 1'b0 : axi_valid;
    dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));

    wire cur_init_ram1 = (cur_init_cnt<WIDTH) ? 1'b1 : 1'b0;
    wire cur_init_ram2 = ((cur_init_cnt<WIDTH*2) & (cur_init_cnt>=WIDTH*1)) ? 1'b1 : 1'b0;
    wire cur_init_ram3 = ((cur_init_cnt<WIDTH*3) & (cur_init_cnt>=WIDTH*2)) ? 1'b1 : 1'b0;
    wire cur_init_ram4 = ((cur_init_cnt<WIDTH*4) & (cur_init_cnt>=WIDTH*3)) ? 1'b1 : 1'b0;  


    wire cs_n1, cs_n2, cs_n3, cs_n4, cs_n5;
    wire wr_en1, wr_en2, wr_en3, wr_en4, wr_en5; 
    wire [$clog2(WIDTH)-1:0] addr1, addr2, addr3, addr4, addr5;
    wire [BUFFER_WIDTH-1:0] data_out1, data_out2, data_out3, data_out4, data_out5;
 

    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH)) u_sram1 
          (.clk(clk), .addr(addr1), .cs_n(cs_n1), .wr_en(wr_en1), .data_in(axi_data), .data_out(data_out1)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH)) u_sram2 
          (.clk(clk), .addr(addr2), .cs_n(cs_n2), .wr_en(wr_en2), .data_in(axi_data), .data_out(data_out2)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH)) u_sram3 
          (.clk(clk), .addr(addr3), .cs_n(cs_n3), .wr_en(wr_en3), .data_in(axi_data), .data_out(data_out3)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH)) u_sram4 
          (.clk(clk), .addr(addr4), .cs_n(cs_n4), .wr_en(wr_en4), .data_in(axi_data), .data_out(data_out4)); 
    sram #(.DATA_WIDTH(BUFFER_WIDTH), .DEPTH(WIDTH)) u_sram5 
          (.clk(clk), .addr(addr5), .cs_n(cs_n5), .wr_en(wr_en5), .data_in(axi_data), .data_out(data_out5)); 



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


    assign {cs_n1, cs_n2, cs_n3, cs_n4, cs_n5} = ({5{cur_is_s0}} & 5'b00001)
                                               | ({5{cur_is_s1}} & 5'b00000)
                                               | ({5{cur_is_s2}} & 5'b00000)
                                               | ({5{cur_is_s3}} & 5'b00000)
                                               | ({5{cur_is_s4}} & 5'b00000)
                                               | ({5{cur_is_s5}} & 5'b00000);

    localparam COL_CNT_WIDTH = $clog2(WIDTH+6);
    wire [COL_CNT_WIDTH-1:0] cur_col_cnt, nxt_col_cnt;
    wire cur_col_cnt_below_2 = (cur_col_cnt < 2) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_3 = (cur_col_cnt < 3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_4 = (cur_col_cnt < 4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_5 = (cur_col_cnt < 5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_6 = (cur_col_cnt < 6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width = (cur_col_cnt < WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_0 = (cur_col_cnt == 0) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_5 = (cur_col_cnt == 5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_6 = (cur_col_cnt == 6) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_2 = (cur_col_cnt == WIDTH+2) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_3 = (cur_col_cnt == WIDTH+3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_4 = (cur_col_cnt == WIDTH+4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_5 = (cur_col_cnt == WIDTH+5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_6 = (cur_col_cnt == WIDTH+6) ? 1'b1 : 1'b0;

    wire cur_col_cnt_below_width_plus_3 = (cur_col_cnt < WIDTH+3) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_4 = (cur_col_cnt < WIDTH+4) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_5 = (cur_col_cnt < WIDTH+5) ? 1'b1 : 1'b0;
    wire cur_col_cnt_below_width_plus_6 = (cur_col_cnt < WIDTH+6) ? 1'b1 : 1'b0;

    assign nxt_col_cnt = cur_col_cnt_is_width_plus_5 ? 0 : cur_col_cnt + 1;

    wire col_cnt_ena;

    dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));




    localparam ROW_CNT_WIDTH = $clog2(HEIGHT*4);
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt, nxt_row_cnt;
    wire cur_row_cnt_is_0 = (cur_row_cnt == 0) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_1 = (cur_row_cnt == 1) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_2 = (cur_row_cnt == 2) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_3 = (cur_row_cnt == 3) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_4 = (cur_row_cnt == 4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_5 = (cur_row_cnt == 5) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_9 = (cur_row_cnt == 9) ? 1'b1 : 1'b0;
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt_minus_6 = cur_row_cnt - 6;

    wire cur_row_cnt_over_9 = (cur_row_cnt > 9) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_4x_plus_6 = (cur_row_cnt_minus_6[1:0] == 2'b11) ? 1'b1 : 1'b0;

    wire cur_row_cnt_below_last_10 = (cur_row_cnt + 11 < HEIGHT*4) ? 1'b1 : 1'b0;

    wire cur_row_cnt_is_last_7 = (cur_row_cnt == HEIGHT*4-7) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_6 = (cur_row_cnt == HEIGHT*4-6) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_5 = (cur_row_cnt == HEIGHT*4-5) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_4 = (cur_row_cnt == HEIGHT*4-4) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_3 = (cur_row_cnt == HEIGHT*4-3) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_2 = (cur_row_cnt == HEIGHT*4-2) ? 1'b1 : 1'b0;
    wire cur_row_cnt_is_last_1 = (cur_row_cnt == HEIGHT*4-1) ? 1'b1 : 1'b0;

    assign nxt_row_cnt = cur_row_cnt + 1;
    wire row_cnt_ena = cur_col_cnt_is_width_plus_5;
    dfflr #(.DW(ROW_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));



    wire [$clog2(WIDTH)-1:0] cur_waddr, nxt_waddr;
    wire cur_wr_end = (~init_finished) ? (cur_waddr == WIDTH-1) : (cur_waddr == WIDTH);
    assign nxt_waddr = (~cur_wr_end) ? cur_waddr+1 : 0;

    wire waddr_ena = cur_is_s0 ? axi_hsked : cur_wr_end ? state_ena : axi_hsked;
    dfflr #(.DW($clog2(WIDTH))) u_waddr_reg(.lden(waddr_ena), .dnxt(nxt_waddr), .qout(cur_waddr), .clk(clk), .rst_n(rst_n));    


    wire [$clog2(WIDTH)-1:0] cur_raddr, nxt_raddr;

    assign nxt_raddr = ((cur_raddr < WIDTH-1) & (~cur_col_cnt_below_2)) ? cur_raddr+1 
                     : ((cur_raddr == WIDTH-1) & (cur_col_cnt_below_width_plus_4)) ? cur_raddr : 0;
    wire cur_rd_end = (cur_raddr == WIDTH-1) ? 1'b1 : 1'b0;
    wire raddr_ena;
    dfflr #(.DW($clog2(WIDTH))) u_raddr_reg(.lden(raddr_ena), .dnxt(nxt_raddr), .qout(cur_raddr), .clk(clk), .rst_n(rst_n));    



    // localparam CNT_WIDTH = 1;
    // wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    // wire cur_cnt_is_1 = (cur_cnt == 1'd1) ? 1'b1 : 1'b0;
    // assign nxt_cnt = cur_cnt_is_1 ? 1'd1 : 1'd0;
    // wire cnt_ena = init_finished & cur_col_cnt_below_width & bcci_2_bf_hsked;
    // dfflr #(.DW(CNT_WIDTH)) u_cnt3_dff (.lden(cnt_ena), .dnxt(nxt_cnt), .qout(cur_cnt), .clk(clk), .rst_n(rst_n));

    assign col_cnt_ena = init_finished & (cur_col_cnt_below_width_plus_5 | (cur_col_cnt_is_width_plus_5 & row_cnt_ena));


    assign state_s0_exit_ena = (cur_is_s0 & init_finished) ? 1'b1 : 1'b0;
    // assign state_s1_exit_ena = (cur_is_s1 & cur_wr_end & cur_rd_end & cur_row_cnt_is_9) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s1_exit_ena = (cur_is_s1 & cur_wr_end & cur_rd_end & cur_row_cnt_is_4x_plus_6) ? ((~cur_row_cnt_is_last_3) & cur_row_cnt_over_9) | cur_row_cnt_is_9 : 1'b0;
    assign state_s2_exit_ena = (cur_is_s2 & cur_wr_end & cur_rd_end & cur_row_cnt_is_4x_plus_6) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s3_exit_ena = (cur_is_s3 & cur_wr_end & cur_rd_end & cur_row_cnt_is_4x_plus_6) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s4_exit_ena = (cur_is_s4 & cur_wr_end & cur_rd_end & cur_row_cnt_is_4x_plus_6) ? (~cur_row_cnt_is_last_3) : 1'b0;
    assign state_s5_exit_ena = (cur_is_s5 & cur_wr_end & cur_rd_end & cur_row_cnt_is_4x_plus_6) ? (~cur_row_cnt_is_last_3) : 1'b0;

    assign state_ena = state_s0_exit_ena | state_s1_exit_ena 
                     | state_s2_exit_ena | state_s3_exit_ena
                     | state_s4_exit_ena | state_s5_exit_ena;


    wire shift_ena = (init_finished & (~end_of_data)) ? (cur_col_cnt_below_width_plus_5 | cur_col_cnt_below_6) : 1'b0;

    assign raddr_ena = init_finished ? shift_ena : 1'b0;


    wire [BUFFER_WIDTH-1:0] line_out1, line_out2, line_out3, line_out4;
    wire [BUFFER_WIDTH-1:0] ram_out1, ram_out2, ram_out3, ram_out4;

    // assign line_out1 = ram_out1;

    // assign line_out2 = (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out1 
    //                  : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out1 : ram_out2;

    // assign line_out3 = (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out1 
    //                  : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out2 : ram_out3;

    // assign line_out4 = (cur_row_cnt_is_0 | cur_row_cnt_is_1) ? ram_out2 
    //                  : (cur_row_cnt_is_2 | cur_row_cnt_is_3 | cur_row_cnt_is_4 | cur_row_cnt_is_5) ? ram_out3 : ram_out4;


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

    assign {wr_en1, wr_en2, wr_en3, wr_en4, wr_en5} =
          ({5{cur_is_s0 & cur_init_ram1 & axi_hsked}} & 5'b10000)
        | ({5{cur_is_s0 & cur_init_ram2 & axi_hsked}} & 5'b01000)
        | ({5{cur_is_s0 & cur_init_ram3 & axi_hsked}} & 5'b00100)
        | ({5{cur_is_s0 & cur_init_ram4 & axi_hsked}} & 5'b00010)
        | ({5{cur_is_s1 & axi_hsked}} & {4'b0000, cur_row_cnt_below_last_10})
        | ({5{cur_is_s2 & axi_hsked}} & {cur_row_cnt_below_last_10, 4'b0000})
        | ({5{cur_is_s3 & axi_hsked}} & {1'b0, cur_row_cnt_below_last_10, 3'b000})
        | ({5{cur_is_s4 & axi_hsked}} & {2'b00, cur_row_cnt_below_last_10, 2'b00})
        | ({5{cur_is_s5 & axi_hsked}} & {3'b000, cur_row_cnt_below_last_10, 1'b0});



    assign addr1 = (cur_is_s0 | (cur_is_s2 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s3 | cur_is_s4 | cur_is_s5) ? cur_raddr : {$clog2(WIDTH){1'b0}};

    assign addr2 = (cur_is_s0 | (cur_is_s3 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s4 | cur_is_s5) ? cur_raddr : {$clog2(WIDTH){1'b0}};

    assign addr3 = (cur_is_s0 | (cur_is_s4 & (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s5) ? cur_raddr : {$clog2(WIDTH){1'b0}};
                   
    assign addr4 = (cur_is_s0 | (cur_is_s5& (~cur_wr_end))) ? cur_waddr :
                   (cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s4) ? cur_raddr : {$clog2(WIDTH){1'b0}};

    assign addr5 = (cur_is_s1 & (~cur_wr_end)) ? cur_waddr :
                   (cur_is_s2 | cur_is_s3 | cur_is_s4 | cur_is_s5) ? cur_raddr : {$clog2(WIDTH){1'b0}};



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

    wire end_of_data;


    assign bf_req_valid = init_finished ? ((cur_col_cnt_below_width_plus_6) & (~cur_col_cnt_below_5) & (~end_of_data)) : 1'b0;

    // wire nxt_bf_req_valid = init_finished ? ((cur_col_cnt_below_width_plus_4) & (~cur_col_cnt_below_5) & (~end_of_data)) : 1'b0;
    // wire reg_ena = shift_ena;
    // dfflr #(.DW(1)) u_pipeline_valid_reg (.lden(reg_ena), .dnxt(nxt_bf_req_valid), .qout(bf_req_valid), .clk(clk), .rst_n(rst_n));


    assign axi_ready = (~init_finished) 
                     | ((cur_is_s1 | cur_is_s2 | cur_is_s3 | cur_is_s4 | cur_is_s5) & ( ~cur_wr_end) & cur_row_cnt_below_last_10);






    wire end_ena = (cur_row_cnt_is_last_1 & row_cnt_ena) ? 1'b1 : 1'b0;
    dfflr #(.DW(1)) u_data_end_reg (.lden(end_ena), .dnxt(1'b1), .qout(end_of_data), .clk(clk), .rst_n(rst_n));





`ifdef SIM_WITHOUT_AXI
    localparam OUT_BUFFER_WIDTH = BUFFER_WIDTH*4;

    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
    reg [32:0] result_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            result_cnt <= 0;
        end
        else begin
            if(bcci_2_bf_hsked) begin
                if(cur_col_cnt_is_6) begin
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
        end
    end

`endif



endmodule

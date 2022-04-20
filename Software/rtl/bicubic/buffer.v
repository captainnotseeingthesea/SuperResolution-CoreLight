// `include "define.v"
`include "bicubic_read_bmp.v"
`ifndef DFFS
    `include "dffs.v"
`endif
`ifndef LINE_BUFFER
    `include "line_buffer.v"
`endif
// `include "sram.v"


`define BUFFER 
module buffer #(
    parameter BUFFER_WIDTH=24
) (
    input wire clk,
    input wire rst_n,
    
// read data into the buffer
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
`ifdef GEN_IN_SIXTEEN
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
`elsif GEN_IN_EIGHT
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4,   
`elsif GEN_IN_FOUR
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4, 
`elsif GEN_IN_TWO
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4, 
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data5,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data6,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data7,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data8, 
`elsif GEN_IN_ONE
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4, 
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data5,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data6,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data7,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data8, 
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data9,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data10,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data11,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data12, 
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data13,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data14,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data15,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data16, 
`endif
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


`ifdef GEN_IN_SIXTEEN
    localparam CNT_WIDTH = 4;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_15 = (cur_cnt == 4'd15) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_15 ? 4'd0 : cur_cnt + 1;

`elsif GEN_IN_EIGHT
    localparam CNT_WIDTH = 3;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_7 = (cur_cnt == 3'd7) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_7 ? 3'd0 : cur_cnt + 1;

`elsif GEN_IN_FOUR
    localparam CNT_WIDTH = 2;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_3 = (cur_cnt == 2'd3) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_3 ? 2'd0 : cur_cnt + 1;

`elsif GEN_IN_TWO
    localparam CNT_WIDTH = 1;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_1 = (cur_cnt == 1'd1) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_1 ? 1'd0 : cur_cnt + 1;

`elsif GEN_IN_ONE
    localparam CNT_WIDTH = 1;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    assign nxt_cnt = 1'd0;

`endif
    wire cnt_ena;

    dfflr #(.DW(CNT_WIDTH)) u_cnt3_dff (.lden(cnt_ena), .dnxt(nxt_cnt), .qout(cur_cnt), .clk(clk), .rst_n(rst_n));


    localparam INIT_CNT_WIDTH = $clog2((WIDTH+3)*3+4);
    wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    wire init_finished = (cur_init_cnt == (WIDTH+3)*3+4) ? 1'b1 : 1'b0;
    assign nxt_init_cnt = cur_init_cnt + 1;
    wire init_cnt_ena = init_finished ? 1'b0 : axi_valid;
    dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));



    localparam COL_CNT_WIDTH = $clog2(WIDTH+3);
    wire [COL_CNT_WIDTH-1:0] cur_col_cnt, nxt_col_cnt;
    wire cur_col_cnt_below_width = (cur_col_cnt < WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_2 = (cur_col_cnt == WIDTH+2) ? 1'b1 : 1'b0;
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_2 ? 0 : cur_col_cnt + 1;

`ifdef GEN_IN_SIXTEEN
    wire col_cnt_ena = (cur_cnt_is_15 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_EIGHT
    wire col_cnt_ena = (cur_cnt_is_7 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_FOUR
    wire col_cnt_ena = (cur_cnt_is_3 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_TWO
    wire col_cnt_ena = (cur_cnt_is_1 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_ONE
    wire col_cnt_ena = axi_valid & init_finished;
`endif

    dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));


    localparam ROW_CNT_WIDTH = $clog2(HEIGHT+3);
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt, nxt_row_cnt;
    wire cur_is_last_row = (cur_row_cnt == HEIGHT-1) ? 1'b1 : 1'b0;
    assign nxt_row_cnt = cur_row_cnt + 1;
    wire row_cnt_ena = cur_col_cnt_is_width_plus_2 & axi_valid;
    dfflr #(.DW(COL_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));


    wire end_of_upsample_ena = cur_is_last_row & cur_col_cnt_is_width;

    wire end_of_upsample;

    dfflr #(1) u_end_dff (.lden(end_of_upsample_ena), .dnxt(1'b1), .qout(end_of_upsample), .clk(clk), .rst_n(rst_n));


`ifdef GEN_IN_SIXTEEN
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_15 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_EIGHT
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_7 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_FOUR
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_3 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_TWO
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_1 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`elsif GEN_IN_ONE
    wire shift_ena = (~init_finished & axi_valid) | (1'b1 & axi_valid) | (~cur_col_cnt_below_width & axi_valid);
`endif


    wire cur_cnt_ena_lock, nxt_cnt_ena_lock;
`ifdef GEN_IN_SIXTEEN
    assign nxt_cnt_ena_lock = (cur_cnt_is_15 & (~axi_valid)) ? 1'b1 : 1'b0;
    wire lock_ena = shift_ena | (cur_cnt_is_15 & (~axi_valid));
`elsif GEN_IN_EIGHT
    assign nxt_cnt_ena_lock = (cur_cnt_is_7 & (~axi_valid)) ? 1'b1 : 1'b0;
    wire lock_ena = shift_ena | (cur_cnt_is_7 & (~axi_valid));
`elsif GEN_IN_FOUR
    assign nxt_cnt_ena_lock = (cur_cnt_is_3 & (~axi_valid)) ? 1'b1 : 1'b0;
    wire lock_ena = shift_ena | (cur_cnt_is_3 & (~axi_valid));
`elsif GEN_IN_TWO
    assign nxt_cnt_ena_lock = (cur_cnt_is_1 & (~axi_valid)) ? 1'b1 : 1'b0;
    wire lock_ena = shift_ena | (cur_cnt_is_1 & (~axi_valid));
`elsif GEN_IN_ONE
    assign nxt_cnt_ena_lock = (~axi_valid) ? 1'b1 : 1'b0;
    wire lock_ena = shift_ena | (~axi_valid);
`endif
    dfflr #(.DW(1)) u_lock_dff (.lden(lock_ena), .dnxt(nxt_cnt_ena_lock), .qout(cur_cnt_ena_lock), .clk(clk), .rst_n(rst_n));

`ifdef GEN_IN_SIXTEEN
    assign cnt_ena = init_finished & cur_col_cnt_below_width & ((~cur_cnt_is_15) | (cur_cnt_is_15 & axi_valid));
`elsif GEN_IN_EIGHT
    assign cnt_ena = init_finished & cur_col_cnt_below_width & ((~cur_cnt_is_7) | (cur_cnt_is_7 & axi_valid));
`elsif GEN_IN_FOUR
    assign cnt_ena = init_finished & cur_col_cnt_below_width & ((~cur_cnt_is_3) | (cur_cnt_is_3 & axi_valid));
`elsif GEN_IN_TWO
    assign cnt_ena = init_finished & cur_col_cnt_below_width & ((~cur_cnt_is_1) | (cur_cnt_is_1 & axi_valid));
`elsif GEN_IN_ONE
    assign cnt_ena = init_finished & cur_col_cnt_below_width & axi_valid;
`endif

    assign bf_req_valid = init_finished ? (cur_col_cnt_below_width & (~cur_cnt_ena_lock) & (~end_of_upsample)) : 1'b0;

`ifdef GEN_IN_SIXTEEN
    assign axi_ready = (~init_finished) | (cur_cnt_is_15) | (~cur_col_cnt_below_width);
`elsif GEN_IN_EIGHT
    assign axi_ready = (~init_finished) | (cur_cnt_is_7) | (~cur_col_cnt_below_width);
`elsif GEN_IN_FOUR
    assign axi_ready = (~init_finished) | (cur_cnt_is_3) | (~cur_col_cnt_below_width);
`elsif GEN_IN_TWO
    assign axi_ready = (~init_finished) | (cur_cnt_is_1) | (~cur_col_cnt_below_width);
`elsif GEN_IN_ONE
    assign axi_ready = (~init_finished) |  1'b1 | (~cur_col_cnt_below_width);
`endif


    wire [BUFFER_WIDTH-1:0] out_bf1;
    wire [BUFFER_WIDTH-1:0] out_bf2;
    wire [BUFFER_WIDTH-1:0] out_bf3;

    line_buffer #(.DEPTH(WIDTH-1),.DW(24)) u_line_buffer1(.shift_en(shift_ena), .bf_nxt(out_p5), .bf_out(out_bf1), .clk(clk));
    line_buffer #(.DEPTH(WIDTH-1),.DW(24)) u_line_buffer2(.shift_en(shift_ena), .bf_nxt(out_p9), .bf_out(out_bf2), .clk(clk));
    line_buffer #(.DEPTH(WIDTH-1),.DW(24)) u_line_buffer3(.shift_en(shift_ena), .bf_nxt(out_p13), .bf_out(out_bf3), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl1(.lden(shift_ena), .dnxt(out_p2), .qout(out_p1), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl2(.lden(shift_ena), .dnxt(out_p3), .qout(out_p2), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl3(.lden(shift_ena), .dnxt(out_p4), .qout(out_p3), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl4(.lden(shift_ena), .dnxt(out_bf1), .qout(out_p4), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl5(.lden(shift_ena), .dnxt(out_p6), .qout(out_p5), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl6(.lden(shift_ena), .dnxt(out_p7), .qout(out_p6), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl7(.lden(shift_ena), .dnxt(out_p8), .qout(out_p7), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl8(.lden(shift_ena), .dnxt(out_bf2), .qout(out_p8), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl9(.lden(shift_ena), .dnxt(out_p10), .qout(out_p9), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl10(.lden(shift_ena), .dnxt(out_p11), .qout(out_p10), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl11(.lden(shift_ena), .dnxt(out_p12), .qout(out_p11), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl12(.lden(shift_ena), .dnxt(out_bf3), .qout(out_p12), .clk(clk));

    dffl #(.DW(BUFFER_WIDTH)) u_dffl13(.lden(shift_ena), .dnxt(out_p14), .qout(out_p13), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl14(.lden(shift_ena), .dnxt(out_p15), .qout(out_p14), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl15(.lden(shift_ena), .dnxt(out_p16), .qout(out_p15), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl16(.lden(shift_ena), .dnxt(axi_data), .qout(out_p16), .clk(clk));


`ifdef SIM_WITHOUT_AXI
    localparam OUT_BUFFER_WIDTH = BUFFER_WIDTH*4;


`ifdef GEN_IN_SIXTEEN

    wire [BUFFER_WIDTH-1:0] data1, data2, data3;

    wire u_dffl1_ena = (cur_cnt==0) | (cur_cnt==4) | (cur_cnt==8) | (cur_cnt==12) ? 1'b1: 1'b0;
    wire u_dffl2_ena = (cur_cnt==1) | (cur_cnt==5) | (cur_cnt==9) | (cur_cnt==13) ? 1'b1: 1'b0;
    wire u_dffl3_ena = (cur_cnt==2) | (cur_cnt==6) | (cur_cnt==10) | (cur_cnt==14) ? 1'b1: 1'b0;

    dffl #(.DW(BUFFER_WIDTH)) u_dffl1_for_16 (.lden(u_dffl1_ena), .dnxt(bcci_rsp_data1), .qout(data1), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl2_for_16 (.lden(u_dffl2_ena), .dnxt(bcci_rsp_data1), .qout(data2), .clk(clk));
    dffl #(.DW(BUFFER_WIDTH)) u_dffl3_for_16 (.lden(u_dffl3_ena), .dnxt(bcci_rsp_data1), .qout(data3), .clk(clk));

    wire [OUT_BUFFER_WIDTH-1:0] out1 = {data1, data2, data3, bcci_rsp_data1};

`elsif GEN_IN_EIGHT
    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
`elsif GEN_IN_FOUR
    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
`elsif GEN_IN_TWO
    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
    wire [OUT_BUFFER_WIDTH-1:0] out2 = {bcci_rsp_data5, bcci_rsp_data6, bcci_rsp_data7, bcci_rsp_data8};
`elsif GEN_IN_ONE
    wire [OUT_BUFFER_WIDTH-1:0] out1 = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};
    wire [OUT_BUFFER_WIDTH-1:0] out2 = {bcci_rsp_data5, bcci_rsp_data6, bcci_rsp_data7, bcci_rsp_data8};
    wire [OUT_BUFFER_WIDTH-1:0] out3 = {bcci_rsp_data9, bcci_rsp_data10, bcci_rsp_data11, bcci_rsp_data12};
    wire [OUT_BUFFER_WIDTH-1:0] out4 = {bcci_rsp_data13, bcci_rsp_data14, bcci_rsp_data15, bcci_rsp_data16};

`endif

    reg [9:0] result_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            result_cnt <= 0;
        end
        else begin
            if(bcci_2_bf_hsked) begin
                result_cnt <= result_cnt + 1;
                `ifdef GEN_IN_SIXTEEN
                    if(cur_cnt[1:0] == 2'b11) begin
                        $display("%x", out1);  
                    end
                `elsif GEN_IN_EIGHT
                    $display("%x", out1);
                `elsif GEN_IN_FOUR
                    $display("%x", out1);
                `elsif GEN_IN_TWO
                    $display("%x", out1);
                    $display("%x", out2);
                `elsif GEN_IN_ONE
                    $display("%x", out1);
                    $display("%x", out2);
                    $display("%x", out3);   
                    $display("%x", out4);
                `endif
            end
        end
    end


`endif




endmodule

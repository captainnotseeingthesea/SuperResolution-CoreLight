`include "define.v"
`include "bicubic_read_bmp.v"
`ifndef DFFS
    `include "dffs.v"
`endif
`ifndef LINE_BUFFER
    `include "line_buffer.v"
`endif
`include "sram.v"


`define BUFFER 
module buffer #(
    parameter BUFFER_WIDTH=24
) (
    input wire clk,
    input wire rst_n,

    // // input wire [BUFFER_WIDTH-1:0] axi_rsp_data,
    // input wire 

    // output wire [BUFFER_WIDTH*4-1:0] axi_req_data,
    // output 


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



    output wire bf_rsp_ready,
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
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data5,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data6,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data7,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data8,
`elsif GEN_IN_ONE
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


    input wire bcci_rsp_valid
    
);

    // localparam WIDTH = 960;
    // localparam HEIGHT = 540;

    localparam WIDTH = 11;
    localparam HEIGHT = 6;

    wire ready = 1'b1;
    wire ram_valid;

    wire bf_2_bcci_hsked = bf_req_valid & bcci_req_ready; 
    wire bcci_2_bf_hsked = bcci_rsp_valid & bf_rsp_ready;
    wire ram_2_ddr_hsked = ram_valid & ready;
    
    assign bf_rsp_ready = 1'b1;


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
`ifdef GEN_IN_SIXTEEN
    localparam CNT_WIDTH = 4;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_15 = (cur_cnt == 4'd15) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_15 ? 4'd0 : cur_cnt + 1;

`elsif GEN_IN_EIGHT
    localparam CNT_WIDTH = 2;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_3 = (cur_cnt == 2'd3) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_3 ? 2'd0 : cur_cnt + 1;

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

`else
    localparam CNT_WIDTH = 2;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_3 = (cur_cnt == 2'd3) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_3 ? 2'd0 : cur_cnt + 1;
`endif
    wire cnt_ena = bcci_2_bf_hsked;

    dfflr #(.DW(CNT_WIDTH)) u_cnt3_dff (.lden(cnt_ena), .dnxt(nxt_cnt), .qout(cur_cnt), .clk(clk), .rst_n(rst_n));


    localparam INIT_CNT_WIDTH = 12;
    wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    wire init_finished = (cur_init_cnt == (WIDTH+3)*3+5) ? 1'b1 : 1'b0;
    assign nxt_init_cnt = cur_init_cnt + 1;
    wire init_cnt_ena = init_finished ? 1'b0 : 1'b1;
    dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));



    localparam COL_CNT_WIDTH = 10;
    wire [COL_CNT_WIDTH-1:0] cur_col_cnt, nxt_col_cnt;
    wire cur_col_cnt_below_width = (cur_col_cnt < WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_2 = (cur_col_cnt == WIDTH+2) ? 1'b1 : 1'b0;
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_2 ? 10'd0 : cur_col_cnt + 1;

`ifdef GEN_IN_SIXTEEN
    wire col_cnt_ena = (cur_cnt_is_15 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
`elsif GEN_IN_EIGHT
    wire col_cnt_ena = (cur_cnt_is_3 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
`elsif GEN_IN_FOUR
    wire col_cnt_ena = (cur_cnt_is_3 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
`elsif GEN_IN_TWO
    wire col_cnt_ena = (cur_cnt_is_1 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
`elsif GEN_IN_ONE
    wire col_cnt_ena = bcci_2_bf_hsked  | (~cur_col_cnt_below_width);
`else
    wire col_cnt_ena = (cur_cnt_is_3 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
`endif

    dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));


    localparam ROW_CNT_WIDTH = 10;
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt, nxt_row_cnt;
    wire cur_is_last_row = (cur_row_cnt == HEIGHT-1) ? 1'b1 : 1'b0;
    assign nxt_row_cnt = cur_row_cnt + 1;
    wire row_cnt_ena = cur_col_cnt_is_width_plus_2;
    dfflr #(.DW(COL_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));


    wire end_of_upsample = cur_is_last_row & cur_col_cnt_is_width;

    assign bf_req_valid = init_finished ? cur_col_cnt_below_width : 1'b0;


`ifdef GEN_IN_SIXTEEN
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_15 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);
`elsif GEN_IN_EIGHT
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_3 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);
`elsif GEN_IN_FOUR
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_3 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);
`elsif GEN_IN_TWO
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_1 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);
`elsif GEN_IN_ONE
    wire shift_ena = (~init_finished & axi_valid) |  bcci_2_bf_hsked | (~cur_col_cnt_below_width);
`else
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_3 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);
`endif

    assign axi_ready = shift_ena;

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

    // wire [BUFFER_WIDTH*4-1:0] axi_req_data;
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





`ifdef GEN_IN_SIXTEEN


    localparam ADDR_WIDTH = $clog2(WIDTH*4);
    localparam ROW_WIDTH = $clog2(HEIGHT);

    wire [ADDR_WIDTH-1:0] cur_rd_addr;
    wire read_line_end = (cur_rd_addr==(WIDTH*4)-1) ? 1'b1 : 1'b0;
    wire [ADDR_WIDTH-1:0] nxt_rd_addr;

    wire rd_addr_ena;
    dfflr #(.DW(ADDR_WIDTH)) u_rd_addr_dff (.lden(rd_addr_ena), .dnxt(nxt_rd_addr), .qout(cur_rd_addr), .rst_n(rst_n), .clk(clk));

    wire [1:0] cur_rd_line, nxt_rd_line;
    assign nxt_rd_line = (cur_rd_line == 2'd3) ? 2'd0 : cur_rd_line + 1;
    wire rd_line_ena = ram_2_ddr_hsked & read_line_end;
    dfflr #(.DW(2)) u_rd_line_dff (.lden(rd_line_ena), .dnxt(nxt_rd_line), .qout(cur_rd_line), .rst_n(rst_n), .clk(clk));   
    wire cur_rd_line0 = (cur_rd_line == 2'd0) ? 1'b1 : 1'b0;
    wire cur_rd_line1 = (cur_rd_line == 2'd1) ? 1'b1 : 1'b0;
    wire cur_rd_line2 = (cur_rd_line == 2'd2) ? 1'b1 : 1'b0;
    wire cur_rd_line3 = (cur_rd_line == 2'd3) ? 1'b1 : 1'b0;   


    wire [ROW_WIDTH-1:0] cur_rd_row_cnt;
    wire [ROW_WIDTH-1:0] nxt_rd_row_cnt = cur_rd_row_cnt + 1;
    wire rd_row_cnt_ena = cur_rd_line3 & rd_line_ena;
    dfflr #(.DW(ROW_WIDTH)) u_rd_row_dff (.lden(rd_row_cnt_ena), .dnxt(nxt_rd_row_cnt), .qout(cur_rd_row_cnt), .rst_n(rst_n), .clk(clk));   
    wire rd_last_row = (cur_rd_row_cnt == HEIGHT-1) ? 1'b1 : 1'b0;



    wire [1:0] cur_wr_line, nxt_wr_line;
    wire cur_wr_line0 = (cur_wr_line == 2'd0) ? 1'b1 : 1'b0;
    wire cur_wr_line1 = (cur_wr_line == 2'd1) ? 1'b1 : 1'b0;
    wire cur_wr_line2 = (cur_wr_line == 2'd2) ? 1'b1 : 1'b0;
    wire cur_wr_line3 = (cur_wr_line == 2'd3) ? 1'b1 : 1'b0;  


    wire [1:0] cur_wr_offset, nxt_wr_offset;
    wire cur_wr_offset3 = (cur_wr_offset == 2'd3) ? 1'b1 : 1'b0;
    assign nxt_wr_offset = cur_wr_offset3 ? 2'd0 : cur_wr_offset + 1;
    wire wr_offset_ena = bcci_2_bf_hsked ? 1'b1 : 1'b0;
    dfflr #(.DW(2)) u_wr_offset_dff (.lden(wr_offset_ena), .dnxt(nxt_wr_offset), .qout(cur_wr_offset), .rst_n(rst_n), .clk(clk));      


    wire write_line_end = cur_wr_line3 & cur_wr_offset3;

    wire wr_line_ena = (cur_wr_offset3 & bcci_2_bf_hsked) ? 1'b1 : 1'b0;
    assign nxt_wr_line = write_line_end ? 2'd0 : cur_wr_line + 1;
    dfflr #(.DW(2)) u_wr_line_dff (.lden(wr_line_ena), .dnxt(nxt_wr_line), .qout(cur_wr_line), .rst_n(rst_n), .clk(clk));  



    wire [ADDR_WIDTH-3:0] cur_wr_ptr, nxt_wr_ptr;
    assign nxt_wr_ptr = (cur_wr_ptr == WIDTH-1) ? 0 : cur_wr_ptr + 1; 
    wire wr_ptr_ena = (cur_wr_line3 & cur_wr_offset3 & bcci_2_bf_hsked) ? 1'b1 : 1'b0;
    dfflr #(.DW(ADDR_WIDTH-2)) u_wr_ptr_dff (.lden(wr_ptr_ena), .dnxt(nxt_wr_ptr), .qout(cur_wr_ptr), .rst_n(rst_n), .clk(clk));

    wire wr_ptr_end = (cur_wr_ptr == WIDTH-1) ? 1'b1 :1'b0;    

    wire wr_first_line_finished = wr_ptr_ena & wr_ptr_end;
 
    
    wire [ADDR_WIDTH-1:0] cur_wr_addr = (cur_wr_ptr<<2) + cur_wr_offset;




    wire [1:0] cur_wr_rd_ctrl;
    wire [1:0] nxt_wr_rd_ctrl = ~cur_wr_rd_ctrl;
    wire wr_rd_ctrl_ena;
    dfflrs #(.DW(1)) u_wr_rd_ctrl0 (.lden(wr_rd_ctrl_ena), .dnxt(nxt_wr_rd_ctrl[0]), .qout(cur_wr_rd_ctrl[0]), .clk(clk), .rst_n(rst_n));
    dfflr #(.DW(1)) u_wr_rd_ctrl1 (.lden(wr_rd_ctrl_ena), .dnxt(nxt_wr_rd_ctrl[1]), .qout(cur_wr_rd_ctrl[1]), .clk(clk), .rst_n(rst_n));
    wire wr_low_ram = (cur_wr_rd_ctrl == 2'b01) ? 1'b1 : 1'b0;
    wire rd_low_ram = ~wr_low_ram ? 1'b1 : 1'b0;



    wire [3:0] rd_cs_n = ({4{cur_rd_line0}} & 4'b1110)
                       | ({4{cur_rd_line1}} & 4'b1101)
                       | ({4{cur_rd_line2}} & 4'b1011)
                       | ({4{cur_rd_line3}} & 4'b0111);

    wire [3:0] wr_cs_n = ({4{cur_wr_line0}} & 4'b1110)
                       | ({4{cur_wr_line1}} & 4'b1101)
                       | ({4{cur_wr_line2}} & 4'b1011)
                       | ({4{cur_wr_line3}} & 4'b0111);


    wire wr_only;
    wire wr_only_ena = (wr_only & wr_first_line_finished) ? 1'b1 : 1'b0;
    dfflrs #(.DW(1)) u_wr_only_reg(.lden(wr_only_ena), .dnxt(~wr_only), .qout(wr_only), .clk(clk), .rst_n(rst_n));

    wire rd_only;
    wire rd_only_ena;
    dfflr #(.DW(1)) u_rd_only_reg(.lden(rd_only_ena), .dnxt(~rd_only), .qout(rd_only), .clk(clk), .rst_n(rst_n));

    wire wr_and_rd = ((~wr_only) & (~rd_only)) ? 1'b1 : 1'b0;


    assign wr_rd_ctrl_ena = (cur_wr_line3 & write_line_end & wr_ptr_end & wr_only)
                         | (cur_wr_line3 & write_line_end & wr_ptr_end & (~ram_valid));

    wire [7:0] cs_wr_only_t = bcci_rsp_valid ? (wr_low_ram ? {4'b1111, wr_cs_n} : {wr_cs_n, 4'b1111}) : 8'b1111_1111;
    wire [7:0] cs_t = wr_low_ram ? {rd_cs_n, wr_cs_n} : {wr_cs_n, rd_cs_n}; 
    wire [7:0] cs_rd_only_t = rd_low_ram ? {4'b1111, rd_cs_n} : {rd_cs_n, 4'b1111};
    wire [7:0] cs_n = ({8{wr_only}}   & cs_wr_only_t)
                    | ({8{wr_and_rd}} & cs_t)
                    | ({8{rd_only}}   & cs_rd_only_t);

    wire ram0_cs_n, ram1_cs_n, ram2_cs_n, ram3_cs_n;
    wire ram4_cs_n, ram5_cs_n, ram6_cs_n, ram7_cs_n;
    assign {
        ram7_cs_n,
        ram6_cs_n,
        ram5_cs_n,
        ram4_cs_n,
        ram3_cs_n,
        ram2_cs_n,
        ram1_cs_n,
        ram0_cs_n
    } = cs_n;

    wire [7:0] cs_n_delayed;
    dfflr #(.DW(8)) u_cs_n_delay_reg(.lden(1'b1), .dnxt(cs_n), .qout(cs_n_delayed), .clk(clk), .rst_n(rst_n));


    wire ram7_cs_n_delayed  = cs_n_delayed[7];
    wire ram6_cs_n_delayed  = cs_n_delayed[6];
    wire ram5_cs_n_delayed  = cs_n_delayed[5];
    wire ram4_cs_n_delayed  = cs_n_delayed[4];
    wire ram3_cs_n_delayed  = cs_n_delayed[3];
    wire ram2_cs_n_delayed  = cs_n_delayed[2];
    wire ram1_cs_n_delayed  = cs_n_delayed[1];
    wire ram0_cs_n_delayed  = cs_n_delayed[0];



    wire ram0_wr_en = cur_wr_rd_ctrl[0];
    wire ram1_wr_en = cur_wr_rd_ctrl[0];
    wire ram2_wr_en = cur_wr_rd_ctrl[0];
    wire ram3_wr_en = cur_wr_rd_ctrl[0]; 
    wire ram4_wr_en = cur_wr_rd_ctrl[1];
    wire ram5_wr_en = cur_wr_rd_ctrl[1];
    wire ram6_wr_en = cur_wr_rd_ctrl[1];
    wire ram7_wr_en = cur_wr_rd_ctrl[1];

    wire [ADDR_WIDTH-1:0] ram0_addr = ram0_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram1_addr = ram1_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram2_addr = ram2_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram3_addr = ram3_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram4_addr = ram4_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram5_addr = ram5_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram6_addr = ram6_wr_en ? cur_wr_addr : cur_rd_addr;
    wire [ADDR_WIDTH-1:0] ram7_addr = ram7_wr_en ? cur_wr_addr : cur_rd_addr;

    wire [BUFFER_WIDTH-1:0] data_in = bcci_rsp_data1;
    wire [BUFFER_WIDTH-1:0] ram0_out, ram1_out, ram2_out, ram3_out;
    wire [BUFFER_WIDTH-1:0] ram4_out, ram5_out, ram6_out, ram7_out;

    wire [BUFFER_WIDTH-1:0] rd_data_t1 = (~ram0_cs_n_delayed) ? ram0_out
                                     : (~ram1_cs_n_delayed) ? ram1_out
                                     : (~ram2_cs_n_delayed) ? ram2_out
                                     : (~ram3_cs_n_delayed) ? ram3_out : {BUFFER_WIDTH{1'b0}};

    wire [BUFFER_WIDTH-1:0] rd_data_t2 = (~ram4_cs_n_delayed) ? ram4_out
                                     : (~ram5_cs_n_delayed) ? ram5_out
                                     : (~ram6_cs_n_delayed) ? ram6_out
                                     : (~ram7_cs_n_delayed) ? ram7_out : {BUFFER_WIDTH{1'b0}};  





    wire read_end = cur_rd_line3 & read_line_end & ram_2_ddr_hsked;

    localparam FSM_WIDTH = 3;
    localparam [FSM_WIDTH-1:0] STATE_S0 = 3'd0;
    localparam [FSM_WIDTH-1:0] STATE_S1 = 3'd1;
    localparam [FSM_WIDTH-1:0] STATE_S2 = 3'd2;
    localparam [FSM_WIDTH-1:0] STATE_READ = 3'd3;
    localparam [FSM_WIDTH-1:0] STATE_READ_LAST = 3'd4;

    wire [FSM_WIDTH-1:0] cur_state, nxt_state;
    wire [FSM_WIDTH-1:0] state_s0_nxt = STATE_S1;
    wire [FSM_WIDTH-1:0] state_s1_nxt = STATE_S2;
    wire [FSM_WIDTH-1:0] state_s2_nxt = STATE_READ;
    wire [FSM_WIDTH-1:0] state_read_nxt = STATE_READ_LAST;
    wire [FSM_WIDTH-1:0] state_read_last_nxt = STATE_S0;

    wire cur_is_s0 = (cur_state == STATE_S0) ? 1'b1 : 1'b0;
    wire cur_is_s1 = (cur_state == STATE_S1) ? 1'b1 : 1'b0;
    wire cur_is_s2 = (cur_state == STATE_S2) ? 1'b1 : 1'b0;
    wire cur_is_read = (cur_state == STATE_READ) ? 1'b1 : 1'b0;
    wire cur_is_read_last = (cur_state == STATE_READ_LAST) ? 1'b1 : 1'b0;

    wire state_s0_exit_ena = (cur_is_s0 & wr_rd_ctrl_ena) ? 1'b1 : 1'b0; 
    wire state_s1_exit_ena = cur_is_s1;
    wire state_s2_exit_ena = cur_is_s2;
    wire state_read_exit_ena = (cur_is_read & read_end) ? 1'b1 : 1'b0;
    wire state_read_last_exit_ena = (cur_is_read_last & ram_2_ddr_hsked) ? 1'b1 : 1'b0;
    wire state_ena = state_s0_exit_ena | state_s1_exit_ena | state_s2_exit_ena | state_read_exit_ena | state_read_last_exit_ena;

    assign nxt_state = ({FSM_WIDTH{state_s0_exit_ena}} & state_s0_nxt)
                     | ({FSM_WIDTH{state_s1_exit_ena}} & state_s1_nxt)
                     | ({FSM_WIDTH{state_s2_exit_ena}} & state_s2_nxt)
                     | ({FSM_WIDTH{state_read_exit_ena}} & state_read_nxt)
                     | ({FSM_WIDTH{state_read_last_exit_ena}} & state_read_last_nxt);

                    

    dfflr #(.DW(FSM_WIDTH)) u_ram_read_fsm (.lden(state_ena), .dnxt(nxt_state), .qout(cur_state), .clk(clk), .rst_n(rst_n));

    assign rd_addr_ena = (state_s1_exit_ena | state_s2_exit_ena | ram_2_ddr_hsked) ? 1'b1 : 1'b0;
    assign nxt_rd_addr = (cur_is_s1 | (cur_rd_addr == WIDTH*4-1)) ? 0 : cur_rd_addr + 1;


    assign rd_only_ena = (rd_last_row & (~rd_only) & (~cur_is_read_last)) ? 1'b1 : 1'b0;

    wire nxt_ram_valid = state_read_last_exit_ena ? 1'b0 : state_s2_exit_ena? 1'b1 : 1'b0;
    wire ram_valid_ena = (state_s2_exit_ena | state_read_last_exit_ena) ? 1'b1 : 1'b0;
    dfflr #(.DW(1)) u_ram_valid_dff (.lden(ram_valid_ena), .dnxt(nxt_ram_valid), .qout(ram_valid), .clk(clk), .rst_n(rst_n));

  //   dfflr #(.DW(1)) u_ram_valid_dely_dff (.lden(1'b1), .dnxt(nxt_ram_valid), .qout(ram_valid), .clk(clk), .rst_n(rst_n));

    wire [BUFFER_WIDTH-1:0] ram_out = rd_low_ram ? rd_data_t1 : rd_data_t2;


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
        end
        else begin
            if(ram_2_ddr_hsked) begin
                $display("%x", ram_out);
            end
        end
    end

    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram0 (
        .clk(clk),
        .addr(ram0_addr),
        .cs_n(ram0_cs_n),
        .wr_en(ram0_wr_en),
        .data_in(data_in),
        .data_out(ram0_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram1 (
        .clk(clk),
        .addr(ram1_addr),
        .cs_n(ram1_cs_n),
        .wr_en(ram1_wr_en),
        .data_in(data_in),
        .data_out(ram1_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram2 (
        .clk(clk),
        .addr(ram2_addr),
        .cs_n(ram2_cs_n),
        .wr_en(ram2_wr_en),
        .data_in(data_in),
        .data_out(ram2_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram3 (
        .clk(clk),
        .addr(ram3_addr),
        .cs_n(ram3_cs_n),
        .wr_en(ram3_wr_en),
        .data_in(data_in),
        .data_out(ram3_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram4 (
        .clk(clk),
        .addr(ram4_addr),
        .cs_n(ram4_cs_n),
        .wr_en(ram4_wr_en),
        .data_in(data_in),
        .data_out(ram4_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram5 (
        .clk(clk),
        .addr(ram5_addr),
        .cs_n(ram5_cs_n),
        .wr_en(ram5_wr_en),
        .data_in(data_in),
        .data_out(ram5_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram6 (
        .clk(clk),
        .addr(ram6_addr),
        .cs_n(ram6_cs_n),
        .wr_en(ram6_wr_en),
        .data_in(data_in),
        .data_out(ram6_out) 
    );
    sram #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .DEPTH(WIDTH*4)
    ) u_sram7 (
        .clk(clk),
        .addr(ram7_addr),
        .cs_n(ram7_cs_n),
        .wr_en(ram7_wr_en),
        .data_in(data_in),
        .data_out(ram7_out) 
    );


`elsif GEN_IN_EIGHT

`elsif GEN_IN_FOUR

`elsif GEN_IN_TWO

`elsif GEN_IN_ONE

`endif




    // reg [9:0] result_cnt;
    // always @(posedge clk or negedge rst_n) begin
    //     if(~rst_n)begin
    //         result_cnt <= 0;
    //     end
    //     else begin
    //         if(bcci_2_bf_hsked) begin
    //             result_cnt <= result_cnt + 1;
    //             `ifdef GEN_IN_SIXTEEN
    //                 if(cur_cnt[1:0] == 2'b11) begin
    //                     $display("%x", out1);  
    //                 end
    //             `elsif GEN_IN_EIGHT
    //                 $display("%x", out1);
    //             `elsif GEN_IN_FOUR
    //                 $display("%x", out1);
    //             `elsif GEN_IN_TWO
    //                 $display("%x", out1);
    //                 $display("%x", out2);
    //             `elsif GEN_IN_ONE
    //                 $display("%x", out1);
    //                 $display("%x", out2);
    //                 $display("%x", out3);   
    //                 $display("%x", out4);
    //             `endif
    //         end
    //     end
    // end


endmodule
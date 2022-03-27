`include "bicubic_read_bmp.v"
`ifndef DFFS
    `include "dffs.v"
`endif
`ifndef LINE_BUFFER
    `include "line_buffer.v"
`endif

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
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data1,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data2,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data3,
    input wire [BUFFER_WIDTH-1:0] bcci_rsp_data4,
    input wire bcci_rsp_valid

    
);

    localparam WIDTH = 960;
    localparam HEIGHT = 540;


    wire bf_2_bcci_hsked = bf_req_valid & bcci_req_ready; 
    wire bcci_2_bf_hsked = bcci_rsp_valid & bf_rsp_ready;
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




    localparam CNT_WIDTH = 2;
    wire [CNT_WIDTH-1:0] cur_cnt, nxt_cnt;
    wire cur_cnt_is_3 = (cur_cnt == 2'd3) ? 1'b1 : 1'b0;
    assign nxt_cnt = cur_cnt_is_3 ? 2'd0 : cur_cnt + 1;
    wire cnt_ena = bcci_2_bf_hsked;

    dfflr #(.DW(CNT_WIDTH)) u_cnt3_dff (.lden(cnt_ena), .dnxt(nxt_cnt), .qout(cur_cnt), .clk(clk), .rst_n(rst_n));


    localparam INIT_CNT_WIDTH = 12;
    // wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    // wire cur_is_47 = (cur_init_cnt == 12'd47) ? 1'b1 : 1'b0; // (11+3)*3 + 5
    // assign nxt_init_cnt = cur_init_cnt + 1;
    // wire init_cnt_ena = cur_is_47 ? 1'b0 : 1'b1;
    // dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));


    wire [INIT_CNT_WIDTH-1:0] cur_init_cnt, nxt_init_cnt;
    wire init_finished = (cur_init_cnt == (WIDTH+3)*3+5) ? 1'b1 : 1'b0;
    assign nxt_init_cnt = cur_init_cnt + 1;
    wire init_cnt_ena = init_finished ? 1'b0 : 1'b1;
    dfflr #(.DW(INIT_CNT_WIDTH)) u_init_dff (.lden(init_cnt_ena), .dnxt(nxt_init_cnt), .qout(cur_init_cnt), .clk(clk), .rst_n(rst_n));



    localparam COL_CNT_WIDTH = 10;
    wire [COL_CNT_WIDTH-1:0] cur_col_cnt, nxt_col_cnt;
    // wire cur_col_cnt_below_11 = (cur_col_cnt < 10'd11) ? 1'b1 : 1'b0;
    // wire cur_col_cnt_is_11 = (cur_col_cnt == 10'd11) ? 1'b1 : 1'b0;
    // wire cur_col_cnt_is_13 = (cur_col_cnt == 10'd13) ? 1'b1 : 1'b0;
    // assign nxt_col_cnt = cur_col_cnt_is_13 ? 10'd0 : cur_col_cnt + 1;
    // wire col_cnt_ena = (cur_cnt_is_3 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_11);
    // dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));

    wire cur_col_cnt_below_width = (cur_col_cnt < WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width = (cur_col_cnt == WIDTH) ? 1'b1 : 1'b0;
    wire cur_col_cnt_is_width_plus_2 = (cur_col_cnt == WIDTH+2) ? 1'b1 : 1'b0;
    assign nxt_col_cnt = cur_col_cnt_is_width_plus_2 ? 10'd0 : cur_col_cnt + 1;
    wire col_cnt_ena = (cur_cnt_is_3 & bcci_2_bf_hsked)  | (~cur_col_cnt_below_width);
    dfflr #(.DW(COL_CNT_WIDTH)) u_col_dff (.lden(col_cnt_ena), .dnxt(nxt_col_cnt), .qout(cur_col_cnt), .clk(clk), .rst_n(rst_n));


    localparam ROW_CNT_WIDTH = 10;
    wire [ROW_CNT_WIDTH-1:0] cur_row_cnt, nxt_row_cnt;
    // wire cur_is_last_row = (cur_row_cnt == 10'd5) ? 1'b1 : 1'b0;
    // assign nxt_row_cnt = cur_row_cnt + 1;
    // wire row_cnt_ena = cur_col_cnt_is_13;
    // dfflr #(.DW(COL_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));

    wire cur_is_last_row = (cur_row_cnt == HEIGHT-1) ? 1'b1 : 1'b0;
    assign nxt_row_cnt = cur_row_cnt + 1;
    wire row_cnt_ena = cur_col_cnt_is_width_plus_2;
    dfflr #(.DW(COL_CNT_WIDTH)) u_row_cnt (.lden(row_cnt_ena), .dnxt(nxt_row_cnt), .qout(cur_row_cnt), .clk(clk), .rst_n(rst_n));



    // wire end_of_upsample = cur_is_last_row & cur_col_cnt_is_11;
    wire end_of_upsample = cur_is_last_row & cur_col_cnt_is_width;


    // assign bf_req_valid = cur_is_47 ? cur_col_cnt_below_11 : 1'b0;
    assign bf_req_valid = init_finished ? cur_col_cnt_below_width : 1'b0;

    // wire shift_ena = (~cur_is_47 & axi_valid) | (cur_cnt_is_3 & bcci_2_bf_hsked) | (~cur_col_cnt_below_11);
    wire shift_ena = (~init_finished & axi_valid) | (cur_cnt_is_3 & bcci_2_bf_hsked) | (~cur_col_cnt_below_width);

    assign axi_ready = shift_ena;



    wire [BUFFER_WIDTH-1:0] out_bf1;
    wire [BUFFER_WIDTH-1:0] out_bf2;
    wire [BUFFER_WIDTH-1:0] out_bf3;
    
    // line_buffer #(.DEPTH(11-1),.DW(24)) u_line_buffer1(.shift_en(shift_ena), .bf_nxt(out_p5), .bf_out(out_bf1), .clk(clk));
    // line_buffer #(.DEPTH(11-1),.DW(24)) u_line_buffer2(.shift_en(shift_ena), .bf_nxt(out_p9), .bf_out(out_bf2), .clk(clk));
    // line_buffer #(.DEPTH(11-1),.DW(24)) u_line_buffer3(.shift_en(shift_ena), .bf_nxt(out_p13), .bf_out(out_bf3), .clk(clk));

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
    wire [OUT_BUFFER_WIDTH-1:0] nxt_out = {bcci_rsp_data1, bcci_rsp_data2, bcci_rsp_data3, bcci_rsp_data4};





    reg [9:0] result_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            result_cnt <= 0;
        end
        else begin
            if(bcci_2_bf_hsked) begin
                result_cnt <= result_cnt + 1;
                // $display("cnt %d %x", result_cnt, nxt_out);
                $display("%x", nxt_out);

                // $display("%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x",
                // bcci_rsp_data1[23:16], bcci_rsp_data1[15:8],bcci_rsp_data1[7:0], 
                // bcci_rsp_data2[23:16], bcci_rsp_data2[15:8],bcci_rsp_data2[7:0],
                // bcci_rsp_data3[23:16], bcci_rsp_data3[15:8],bcci_rsp_data3[7:0],
                // bcci_rsp_data4[23:16], bcci_rsp_data4[15:8],bcci_rsp_data4[7:0],);

                // $display("0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x,0x%x",
                // bcci_rsp_data1[23:16], bcci_rsp_data1[15:8],bcci_rsp_data1[7:0], 
                // bcci_rsp_data2[23:16], bcci_rsp_data2[15:8],bcci_rsp_data2[7:0],
                // bcci_rsp_data3[23:16], bcci_rsp_data3[15:8],bcci_rsp_data3[7:0],
                // bcci_rsp_data4[23:16], bcci_rsp_data4[15:8],bcci_rsp_data4[7:0],);
                
            end
        end
    end


endmodule
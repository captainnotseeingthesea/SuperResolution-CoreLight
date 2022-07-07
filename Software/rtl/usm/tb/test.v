`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/24 10:44:22
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)

module test(

    );
    // reg en;
    // reg in;
    // wire out;
    // wire io;
    // reg clk;
    // reg rst_n;
    // initial begin
    //     clk = 0;
    //     rst_n = 0;
    //     en = 0;
    //     in = 1;
    //     #20 rst_n = 1;
    //     #10 in = 0;
    //     #10 en = 1;
    //     #10 in = 1;
    //     #10 force io = 0;
    //     #10 force io = 1;
    //     #10 release io;

    //     $finish();
    // end
    // always #5 clk = ~clk;
    // sub_module sub(
    //     .en(en),
    //     .io(io),
    //     .in(in),
    //     .out(out),
    //     .clk(clk),
    //     .rst_n(rst_n)
    // );

    // reg [10:0] num;
    // wire [5:0] log2_num;
    // initial begin
    //     num = 10;
    //     #20 num = 5;
    //     #10 num = 2;
    //     #10 num = 30;
    //     #10 num = 100;
    //     #10 num = 50;
    //     #10 num = 70;
    //     #10 num = 300;
    // end
    // assign log2_num = `log2(num);

                            /* UnsignedAdderTree Test */
    // parameter LENGTH = 3;
    // parameter DATA_WIDTH = 8;
    // parameter OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);
    // reg [LENGTH * DATA_WIDTH-1:0] in_addends;
    // wire [OUT_WIDTH-1:0] out_sum;

    // integer i;
    // initial begin
    //     for(i = 0; i < LENGTH; i = i + 1) begin
    //         in_addends[DATA_WIDTH * i +: DATA_WIDTH] = 100 + i;
    //     end

    //     #100
    //     for(i = 0; i < LENGTH; i = i + 1) begin
    //         in_addends[DATA_WIDTH * i +: DATA_WIDTH] = 100 - i;
            
    //     end
    // end 

    // UnsignedAdderTree #(
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .LENGTH(LENGTH)
    // )
    // test_u(
    //     .in_addends(in_addends),
    //     .out_sum(out_sum)
    // );

                            /* vector_cov test */

    // parameter LENGTH = 10; // length of the input pixel vector
    // parameter COV_SIZE = 3; // size of the convolution kernel
    // parameter CH_WIDTH = 8; // channel width
    // parameter WEIGHT_WIDTH = 8; // weight width
    // localparam INNER_MUL_WIDTH = CH_WIDTH + WEIGHT_WIDTH; // width of the inner multiplication value
    // localparam OUTPUT_LENGTH = LENGTH - COV_SIZE + 1; // length of the output vector

    // reg [CH_WIDTH * LENGTH - 1 : 0] pixel_vector;
    // reg [WEIGHT_WIDTH * COV_SIZE - 1: 0] weight_vector;
    // wire [OUTPUT_LENGTH * (INNER_MUL_WIDTH + $clog2(COV_SIZE)) - 1 : 0] partial_sum;

    // integer i;
    // initial begin
    //     for(i = 0; i < LENGTH; i = i + 1) begin
    //         pixel_vector[CH_WIDTH * i +: CH_WIDTH] = i;
    //     end
    //     for(i = 0; i < COV_SIZE; i = i + 1) begin
    //         weight_vector[WEIGHT_WIDTH * i +: WEIGHT_WIDTH] = i + 1;
    //     end
    // end

    // vector_cov #(
    //     .LENGTH(LENGTH),
    //     .COV_SIZE(COV_SIZE),
    //     .CH_WIDTH(CH_WIDTH),
    //     .WEIGHT_WIDTH(WEIGHT_WIDTH)
    // )
    // test_u(
    //     .pixel_vector(pixel_vector),
    //     .weight_vector(weight_vector),
    //     .partial_sum(partial_sum)
    // );


                                /* usm test */
    parameter AXIS_DATA_WIDTH = 96; // data width of axis input stream
    parameter COUNT_WIDTH = 32;
    parameter AXIS_STRB_WIDTH = 12; // strb width of axis input stream
    parameter COV_SIZE = 3; // convolution kernel size
    parameter CH_WIDTH = 8; // pixel channel width
    parameter WEIGHT_WIDTH = 8; // width of gaussian blur kernel weight
    parameter DST_IMAGE_WIDTH = 3840; // destination image width
    parameter DST_IMAGE_HEIGHT = 100; // destination image height
    parameter COUNT = 100;

    localparam HEIGHT = DST_IMAGE_HEIGHT;
    localparam WIDTH  = DST_IMAGE_WIDTH;

    localparam OFFSET = 54;
    localparam TOTAL_SIZE = HEIGHT * WIDTH *3 + OFFSET;
    localparam SIZE = (HEIGHT) * (WIDTH) ;
    localparam RESULT_SIZE = HEIGHT*WIDTH*3 + OFFSET;

    wire                       s_axis_tvalid;
    reg                       s_axis_tid;
    wire[AXIS_DATA_WIDTH-1:0] s_axis_tdata;
    reg [AXIS_STRB_WIDTH-1:0] s_axis_tkeep;
    reg [AXIS_STRB_WIDTH-1:0] s_axis_tstrb;
    wire                      s_axis_tlast;
    reg                       s_axis_tdest;
    reg                       s_axis_user;

    reg                       m_axis_tready;

    wire                      s_axis_tready;

    wire                       m_axis_tvalid;
    wire                       m_axis_tid;
    wire [AXIS_DATA_WIDTH-1:0] m_axis_tdata;
    wire [AXIS_STRB_WIDTH-1:0] m_axis_tkeep;
    wire [AXIS_STRB_WIDTH-1:0] m_axis_tstrb;
    wire                       m_axis_tlast;
    wire                       m_axis_tdest;
    wire                       m_axis_user;

    reg clk;
    reg rst_n;

    reg [COUNT_WIDTH - 1 : 0] count;
    reg [20 : 0] output_count;

    reg [7:0] bmp_data [TOTAL_SIZE:0];
    reg [23:0] shaped_data [SIZE-1:0];
    reg [AXIS_DATA_WIDTH - 1:0] result_data [RESULT_SIZE-1:0];

    wire output_handshake = m_axis_tvalid & m_axis_tready;

    integer shaped_index = 0;
    integer com = 0;
    integer bmp_file_id, icode, index = 0;
    integer output_file_id, display_id;

    integer img_width, img_height, img_start_index, img_size;
    integer ii, i, j;

    initial begin
        for (ii = 0; ii < SIZE; ii = ii+1) begin
            shaped_data[ii] = 0;
        end
        bmp_file_id = $fopen("0.bmp", "rb");
        // bmp_file_id = $fopen("2.bmp", "rb");
        icode = $fread(bmp_data, bmp_file_id);

        img_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
        img_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
        img_start_index = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
        img_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
        $fclose(bmp_file_id);
        for (i = 0; i < img_height; i = i + 1) begin
            for(j = 0; j < img_width; j = j + 1) begin
                // if it is odd of width, then use (width+1), the extra bits are set to 00 0000
                index = i * (img_width) * 3 + j * 3 + img_start_index;
                shaped_data[shaped_index] = {bmp_data[index+2], bmp_data[index+1], bmp_data[index+0]};
                shaped_index = shaped_index + 1;
            end
        end
    end

    wire bmp_hsked = s_axis_tready & s_axis_tvalid;
    reg [31:0] ptr;
    reg [AXIS_DATA_WIDTH - 1:0] data_reg;
    reg valid_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ptr <= 32'd0;
            data_reg <= {AXIS_DATA_WIDTH{1'b0}};
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <=  1'b1;
            if(bmp_hsked) begin
                ptr <=  ptr + (AXIS_DATA_WIDTH / 24);
                data_reg <=  {shaped_data[ptr + (AXIS_DATA_WIDTH / 24) + 3], shaped_data[ptr + (AXIS_DATA_WIDTH / 24) + 2], shaped_data[ptr + (AXIS_DATA_WIDTH / 24) + 1], shaped_data[ptr + (AXIS_DATA_WIDTH / 24) + 0]};
            end
            else begin
                data_reg <=  {shaped_data[ptr + 3], shaped_data[ptr + 2], shaped_data[ptr + 1], shaped_data[ptr + 0]};
            end
        end
    end    
    assign s_axis_tvalid = valid_reg;
    assign s_axis_tdata = data_reg;

    // genvar i;
    // generate
    //     for(i = 0; i < AXIS_DATA_WIDTH / COUNT_WIDTH; i = i + 1) begin : init_axis_data
    //         always @(*) begin
    //             s_axis_tdata[i * COUNT_WIDTH +: COUNT_WIDTH] = count;
    //         end
    //     end
    // endgenerate

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #10 rst_n = 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            m_axis_tready <= 1'b0;
            s_axis_tid <= 1'b0;
            s_axis_tkeep <= {AXIS_STRB_WIDTH{1'b0}};
            s_axis_tstrb <= {AXIS_STRB_WIDTH{1'b0}};
            s_axis_tdest <= 1'b0;
            s_axis_user <= 1'b0;
        end
        else begin
            m_axis_tready <= 1'b1;
            s_axis_tid <= 1'b0;
            s_axis_tkeep <= {AXIS_STRB_WIDTH{1'b1}};
            s_axis_tstrb <= {AXIS_STRB_WIDTH{1'b1}};
            s_axis_tdest <= 1'b0;
            s_axis_user <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            output_count <= 0;
        end
        else if(output_handshake) begin
            output_count <= output_count + 1;
            $display("%x", m_axis_tdata);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            count <= {COUNT_WIDTH{1'b0}};
        end
        else begin
            if(bmp_hsked) begin
                if(count == (DST_IMAGE_WIDTH / (AXIS_DATA_WIDTH / 24)) - 1) begin
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end
            end
        end
    end

    always begin
        #100;
        if (output_count == SIZE / 4)  begin
            #1;
            $finish;
        end
    end

    assign s_axis_tlast = bmp_hsked & count == (DST_IMAGE_WIDTH / (AXIS_DATA_WIDTH / 24)) - 1 ? 1'b1 : 1'b0;

    // always @(*) begin
    //     s_axis_tlast = (count == 99) & handshake;
    // end
    
    always #2 clk = ~clk;

    usm #(
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .AXIS_STRB_WIDTH(AXIS_STRB_WIDTH),
        .COV_SIZE(COV_SIZE),
        .CH_WIDTH(CH_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DST_IMAGE_WIDTH(DST_IMAGE_WIDTH),
        .DST_IMAGE_HEIGHT(DST_IMAGE_HEIGHT)
    )
    test_usm
    (
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tid(s_axis_tid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tstrb(s_axis_tstrb),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tdest(s_axis_tdest),
        .s_axis_user(s_axis_user),

        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tid(m_axis_tid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(m_axis_tkeep),
        .m_axis_tstrb(m_axis_tstrb),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tdest(m_axis_tdest),
        .m_axis_user(m_axis_user),

        .clk(clk),
        .rst_n(rst_n)
    );
endmodule

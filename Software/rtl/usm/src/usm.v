`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/26 18:28:53
// Design Name: 
// Module Name: usm
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


module usm #(
    parameter AXIS_DATA_WIDTH = 192, // data width of axis input stream
    parameter AXIS_STRB_WIDTH = 24, // strb width of axis input stream
    parameter COV_SIZE = 3, // convolution kernel size
    parameter CH_WIDTH = 8, // pixel channel width
    parameter WEIGHT_WIDTH = 8, // width of gaussian blur kernel weight
    parameter DST_IMAGE_WIDTH = 3840, // destination image width
    parameter DST_IMAGE_HEIGHT = 2160 // destination image height
    )
    (
        /* Interface as AXI-Stream slave, in */
        input                       s_axis_tvalid,
        output                      s_axis_tready,
        input                       s_axis_tid,
        input [AXIS_DATA_WIDTH-1:0] s_axis_tdata,
        input [AXIS_STRB_WIDTH-1:0] s_axis_tkeep,
        input [AXIS_STRB_WIDTH-1:0] s_axis_tstrb,
        input                       s_axis_tlast,
        input                       s_axis_tdest,
        input                       s_axis_user,

        /* Interface as AXI-Stream master, out */
        output reg                   m_axis_tvalid,
        input                        m_axis_tready,
        output                       m_axis_tid,
        output [AXIS_DATA_WIDTH-1:0] m_axis_tdata,
        output [AXIS_STRB_WIDTH-1:0] m_axis_tkeep,
        output [AXIS_STRB_WIDTH-1:0] m_axis_tstrb,
        output reg                   m_axis_tlast,
        output                       m_axis_tdest,
        output                       m_axis_user,

        input clk,
	    input rst_n
    );

    localparam INPUT_PIXEL_NUM = AXIS_DATA_WIDTH / CH_WIDTH / 3;
    localparam AXISOUT_STRB_WIDTH = AXIS_DATA_WIDTH / 8;
    localparam EDGE_WIDTH = (COV_SIZE - 1) / 2;
    localparam INPUT_BUFFER_SIZE = 2 * INPUT_PIXEL_NUM + EDGE_WIDTH;
    localparam COUNT_WIDTH = $clog2(INPUT_BUFFER_SIZE);
    localparam DATA_WIDTH = CH_WIDTH * 3;
    localparam EXPAND_PRECISION = 11;
    localparam PARTIAL_SUM_ELE_WIDTH = (WEIGHT_WIDTH + CH_WIDTH + $clog2(COV_SIZE));
    localparam BRAM_ELE_WIDTH = (CH_WIDTH + EXPAND_PRECISION + 2) * 3;
    localparam BRAM_DATA_WIDTH = BRAM_ELE_WIDTH * INPUT_PIXEL_NUM;
    localparam LINE_COUNT_WIDTH = $clog2(DST_IMAGE_HEIGHT);

    localparam IDLE = 2'b00, NORMAL = 2'b01, LAST = 2'b10, LAST_EDGE = 2'b11;
    localparam FSM_WIDTH = 2;
    localparam USM_IDLE = 2'b00, USM_START = 2'b01, USM_NORMAL = 2'b10, USM_LAST = 2'b11;
    localparam FSM_USM_WIDTH = 2;

    function [BRAM_ELE_WIDTH / 3 - 1 : 0] negative_data;
        input [PARTIAL_SUM_ELE_WIDTH - 1 : 0] data;
        begin
            negative_data = {{(BRAM_ELE_WIDTH / 3 - PARTIAL_SUM_ELE_WIDTH){1'b1}}, ~data + 1'b1};
        end
    endfunction

    reg [DATA_WIDTH - 1 : 0] input_buffer [INPUT_BUFFER_SIZE - 1 : 0]; // input data to the input buffer
    wire [$clog2(INPUT_BUFFER_SIZE) - 1 : 0] input_buffer_idle_index [INPUT_PIXEL_NUM + EDGE_WIDTH - 1 : 0]; // index of idle element in the input buffer
    wire [$clog2(INPUT_BUFFER_SIZE) - 1 : 0] input_buffer_busy_index [INPUT_PIXEL_NUM + 2 * EDGE_WIDTH - 1 : 0]; // index of busy element in the input buffer
    reg [DATA_WIDTH - 1 : 0] last_edge [EDGE_WIDTH - 1 : 0]; // buffer contain the data of the last edge
    wire [COUNT_WIDTH - 1 : 0] count; // number of elements in the input buffer
    wire [COUNT_WIDTH - 1 : 0] input_stride; // stride of the input pixels
    wire [COUNT_WIDTH - 1 : 0] output_stride; // stride of the output pixels
    
    wire [COUNT_WIDTH - 1 : 0] idle_pos; // the position of the first idle space
    wire [COUNT_WIDTH - 1 : 0] nxt_idle_pos; // the next position of the first idle space
    wire [COUNT_WIDTH - 1 : 0] start_pos; // the position of the first element in the input buffer
    wire [COUNT_WIDTH - 1 : 0] nxt_start_pos; // the next position of the first element in the input buffer
    wire idle_pos_ena; // enable change to next idle position
    wire start_pos_ena; // enable change to next start position

    wire input_valid = s_axis_tready & s_axis_tvalid; // signal to indicate the valid input data
    wire input_valid_late;
    wire end_line = s_axis_tlast & input_valid; // the end flag the line
    wire cov_done = count >= (INPUT_PIXEL_NUM + 2 * EDGE_WIDTH); // flag to signal a convolutionary operation done
    wire cov_done_late;

    // AXIS output signal
    wire output_data_valid;
    assign  m_axis_tid = s_axis_tid;
    assign  m_axis_tdest = s_axis_tdest;
    assign  m_axis_tkeep = {AXISOUT_STRB_WIDTH{1'b1}};
    assign  m_axis_tstrb = {AXISOUT_STRB_WIDTH{1'b1}};
    assign  m_axis_user = s_axis_user;

    wire [(INPUT_PIXEL_NUM + 2 * EDGE_WIDTH) * CH_WIDTH - 1 : 0] pixel_vector [2 : 0];
    wire [WEIGHT_WIDTH * COV_SIZE - 1 : 0] weight_vector [COV_SIZE - 1 : 0];
    wire [INPUT_PIXEL_NUM * (PARTIAL_SUM_ELE_WIDTH) - 1 : 0] partial_sum [COV_SIZE - 1 : 0][2 : 0];
    wire [INPUT_PIXEL_NUM * (PARTIAL_SUM_ELE_WIDTH) - 1 : 0] partial_sum_late [COV_SIZE - 1 : 0][2 : 0];
    wire [INPUT_PIXEL_NUM * (BRAM_ELE_WIDTH / 3) - 1 : 0] negative_partial_sum_late [COV_SIZE - 1 : 0][2 : 0];

    wire  [AXIS_DATA_WIDTH - 1 : 0] input_data_late;

    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM) - 1 : 0] addra[COV_SIZE : 0]; // addr to write the bram bank
    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM) - 1 : 0] addrb; // addr to write the bram bank

    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM) - 1 : 0] next_addra[COV_SIZE : 0]; // next addr to access the bram bank
    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM) - 1 : 0] next_addrb = (addrb == (DST_IMAGE_WIDTH / INPUT_PIXEL_NUM - 1) ? {($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM)){1'b0}} : addrb + 1); // next addr to access the bram bank
    
    wire [BRAM_DATA_WIDTH - 1 : 0] bram_ina [COV_SIZE : 0]; // data input to port a of bram banks
    reg  [BRAM_DATA_WIDTH - 1 : 0] bram_inb [COV_SIZE : 0]; // data input to port b of the bram banks
    wire [BRAM_DATA_WIDTH - 1 : 0] bram_outa [COV_SIZE : 0]; // data output of the bram banks
    reg  [BRAM_DATA_WIDTH - 1 : 0] bram_data_a [COV_SIZE : 0]; // data of port a of bram banks
    wire [BRAM_DATA_WIDTH - 1 : 0] bram_outb [COV_SIZE : 0]; // data output of the bram banks
    reg  [BRAM_DATA_WIDTH - 1 : 0] bram_data_b [COV_SIZE : 0]; // data of port b of bram banks

    reg  [BRAM_DATA_WIDTH - 1 : 0] partial_sum_in_0 [COV_SIZE - 1 : 0]; // negative partial sum 0 input to port b of the bram banks
    reg  [BRAM_DATA_WIDTH - 1 : 0] partial_sum_in_1 [COV_SIZE - 1: 0]; // negative partial sum 1 input to port b of the bram banks

    wire [COV_SIZE: 0] ena; // prot a enable vector to select corresponding bram banks
    wire [COV_SIZE: 0] enb; // port b enable vector to select corresponding bram banks
    wire [COV_SIZE: 0] rea; // rea vector to select corresponding bram banks
    reg  [COV_SIZE: 0] reb; // reb vector to select corresponding bram banks
    wire [COV_SIZE: 0] wea; // wea vector to select corresponding bram banks
    reg  [COV_SIZE: 0] web; // web vector to select corresponding bram banks

    reg [DST_IMAGE_WIDTH / INPUT_PIXEL_NUM - 1 : 0] dirty_flag [COV_SIZE : 0]; // flag to indicate whether the data in the bram is usefull (1 : usefull)
    reg [COV_SIZE : 0] dirty_clear; // flag to clear the dirty flag (a line -> a bit)
    wire [COV_SIZE : 0] outline_ready; // flag to indicate which line is ready to output
    reg  [COV_SIZE : 0] next_outline_ready;
    wire outline_ready_ena; // enable to change the outline state
    reg outline_ready_set; // enable to set the outline ready state
    reg outline_ready_clear; // enable to clear the outline ready state
    wire no_outline; // flag to indicate whether there is idle space to buffer the output line
    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM + 1) - 1 : 0] output_count; // the number of elements of a line output to the axis
    wire [$clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM + 1) - 1 : 0] next_output_count = (outline_ready_clear) ? {($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM + 1)){1'b0}} : output_count + 1;
    wire output_count_ena;

    wire [FSM_WIDTH - 1 : 0] line_state;
    wire [FSM_WIDTH - 1 : 0] next_line_state;
    wire [FSM_WIDTH - 1 : 0] state_idle_nxt = NORMAL;
    wire [FSM_WIDTH - 1 : 0] state_normal_nxt = end_line ? LAST : NORMAL;
    wire [FSM_WIDTH - 1 : 0] state_last_nxt = LAST_EDGE;
    wire [FSM_WIDTH - 1 : 0] state_last_edge_nxt = input_valid ? NORMAL : IDLE;

    wire line_is_idle = (line_state == IDLE) ? 1'b1 : 1'b0;
    wire line_is_normal = (line_state == NORMAL) ? 1'b1 : 1'b0;
    wire line_is_last = (line_state == LAST) ? 1'b1 : 1'b0;
    wire line_is_last_edge = (line_state == LAST_EDGE) ? 1'b1 : 1'b0;

    wire state_idle_exit_ena = line_is_idle & input_valid;
    wire state_normal_exit_ena = line_is_normal & end_line;
    wire state_last_exit_ena = line_is_last_late;
    wire state_last_edge_exit_ena = line_is_last_edge_late;

    wire line_state_ena = state_idle_exit_ena
                        | state_normal_exit_ena
                        | state_last_exit_ena
                        | state_last_edge_exit_ena;
    
    assign next_line_state = ({FSM_WIDTH{state_idle_exit_ena}} & state_idle_nxt)
                        | ({FSM_WIDTH{state_normal_exit_ena}} & state_normal_nxt)
                        | ({FSM_WIDTH{state_last_exit_ena}} & state_last_nxt)
                        | ({FSM_WIDTH{state_last_edge_exit_ena}} & state_last_edge_nxt);

    dfflr #(.DW(FSM_WIDTH)) line_cov_fsm(
        .lden(line_state_ena),
        .dnxt(next_line_state),
        .qout(line_state),
        .clk(clk),
        .rst_n(rst_n)
    );

    dffr #(.DW(AXIS_DATA_WIDTH)) input_data_dffr(
        .dnxt(s_axis_tdata),
        .qout(input_data_late),
        .clk(clk),
        .rst_n(rst_n)
    );

    dffr #(.DW(1)) input_valid_dffr(
        .dnxt(input_valid),
        .qout(input_valid_late),
        .clk(clk),
        .rst_n(rst_n)
    );

    dffr #(.DW(1)) cov_done_dffr(
        .dnxt(cov_done),
        .qout(cov_done_late),
        .clk(clk),
        .rst_n(rst_n)
    );

    dffr #(.DW(1)) line_is_last_dffr(
        .dnxt(line_is_last),
        .qout(line_is_last_late),
        .clk(clk),
        .rst_n(rst_n)
    );

    dffr #(.DW(1)) line_is_last_edge_dffr(
        .dnxt(line_is_last_edge),
        .qout(line_is_last_edge_late),
        .clk(clk),
        .rst_n(rst_n)
    );

    assign input_stride = ({COUNT_WIDTH{line_is_idle}} & (INPUT_PIXEL_NUM + EDGE_WIDTH))
    | ({COUNT_WIDTH{line_is_normal}} & (INPUT_PIXEL_NUM))
    | ({COUNT_WIDTH{line_is_last}} & (EDGE_WIDTH))
    | ({COUNT_WIDTH{line_is_last_edge & input_valid}} & (INPUT_PIXEL_NUM + EDGE_WIDTH));

    assign output_stride = ({COUNT_WIDTH{line_is_normal | line_is_last}} & (INPUT_PIXEL_NUM))
    | ({COUNT_WIDTH{line_is_last_edge}} & (INPUT_PIXEL_NUM + 2 * EDGE_WIDTH));

    assign nxt_idle_pos = (idle_pos + input_stride >= INPUT_BUFFER_SIZE) ? (idle_pos + input_stride - INPUT_BUFFER_SIZE) : (idle_pos + input_stride);
    assign nxt_start_pos = (start_pos + output_stride >= INPUT_BUFFER_SIZE) ? (start_pos + output_stride - INPUT_BUFFER_SIZE) : (start_pos + output_stride);
    assign idle_pos_ena = input_valid | line_is_last_late;
    assign start_pos_ena = cov_done;

    assign count = (idle_pos == start_pos) ? ((line_is_idle | line_is_last_edge) ? {COUNT_WIDTH{1'b0}} : INPUT_BUFFER_SIZE) : ((idle_pos > start_pos) ? (idle_pos - start_pos) : (INPUT_BUFFER_SIZE - start_pos + idle_pos));

    dfflr #(.DW(COUNT_WIDTH)) dfflr_idle_pos(
        .lden(idle_pos_ena),
        .dnxt(nxt_idle_pos),
        .qout(idle_pos),
        .clk(clk),
        .rst_n(rst_n)
    );

    dfflr #(.DW(COUNT_WIDTH)) dfflr_start_pos(
        .lden(start_pos_ena),
        .dnxt(nxt_start_pos),
        .qout(start_pos),
        .clk(clk),
        .rst_n(rst_n)
    );

    always @(posedge clk or negedge rst_n) begin : init_input_buffer
        integer i;
        if(~rst_n) begin
            for(i = 0; i < INPUT_BUFFER_SIZE; i = i + 1) begin
                input_buffer[i] <= {DATA_WIDTH{1'b0}};
            end
            for(i = 0; i < EDGE_WIDTH; i = i + 1) begin
                last_edge[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else begin
            if(input_valid) begin
                if(line_is_idle | line_is_last_edge) begin
                    for(i = 0; i < EDGE_WIDTH; i = i + 1) begin
                        input_buffer[input_buffer_idle_index[i]] <= s_axis_tdata[(i + 1) * DATA_WIDTH +: DATA_WIDTH];
                    end
                    for(i = 0; i < INPUT_PIXEL_NUM; i = i + 1) begin
                        input_buffer[input_buffer_idle_index[i + EDGE_WIDTH]] <= s_axis_tdata[i * DATA_WIDTH +: DATA_WIDTH];
                    end
                end
                else begin
                    for(i = 0; i < INPUT_PIXEL_NUM; i = i + 1) begin
                        input_buffer[input_buffer_idle_index[i]] <= s_axis_tdata[i * DATA_WIDTH +: DATA_WIDTH];
                    end
                end
                for(i = 0; i < EDGE_WIDTH; i = i + 1) begin
                    last_edge[i] <= s_axis_tdata[(INPUT_PIXEL_NUM - i - 2) * DATA_WIDTH +: DATA_WIDTH];
                end
            end
            if(line_is_last_late) begin
                for(i = 0; i < EDGE_WIDTH; i = i + 1) begin
                    input_buffer[input_buffer_idle_index[i]] <= last_edge[i];
                end
            end
        end
    end
    genvar i, j, k;
    generate
        for(i = 0; i < INPUT_PIXEL_NUM + EDGE_WIDTH; i = i + 1) begin : gen_input_idle_index
            assign input_buffer_idle_index[i] = (idle_pos + i) >= INPUT_BUFFER_SIZE ? idle_pos + i - INPUT_BUFFER_SIZE : idle_pos + i;
        end
        for(i = 0; i < INPUT_PIXEL_NUM + 2 * EDGE_WIDTH; i = i + 1) begin : gen_input_busy_index
            assign input_buffer_busy_index[i] = (start_pos + i) >= INPUT_BUFFER_SIZE ? start_pos + i - INPUT_BUFFER_SIZE : start_pos + i;
        end
    endgenerate

    assign weight_vector[0][0 +: WEIGHT_WIDTH] = 225;
    assign weight_vector[0][WEIGHT_WIDTH +: WEIGHT_WIDTH] = 228;
    assign weight_vector[0][2 * WEIGHT_WIDTH +: WEIGHT_WIDTH] = 225;
    assign weight_vector[1][0 +: WEIGHT_WIDTH] = 228;
    assign weight_vector[1][WEIGHT_WIDTH +: WEIGHT_WIDTH] = 231;
    assign weight_vector[1][2 * WEIGHT_WIDTH +: WEIGHT_WIDTH] = 228;
    assign weight_vector[2][0 +: WEIGHT_WIDTH] = 225;
    assign weight_vector[2][WEIGHT_WIDTH +: WEIGHT_WIDTH] = 228;
    assign weight_vector[2][2 * WEIGHT_WIDTH +: WEIGHT_WIDTH] = 225;
    generate
        for (i = 0; i < INPUT_PIXEL_NUM + 2 * EDGE_WIDTH; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                assign pixel_vector[j][i * CH_WIDTH +: CH_WIDTH] = input_buffer[input_buffer_busy_index[i]][j * CH_WIDTH +: CH_WIDTH];
            end
        end

        for(i = 0; i < COV_SIZE; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                vector_cov #(
                    .LENGTH(2 * EDGE_WIDTH + INPUT_PIXEL_NUM),
                    .COV_SIZE(COV_SIZE),
                    .CH_WIDTH(CH_WIDTH),
                    .WEIGHT_WIDTH(WEIGHT_WIDTH)
                )
                test_u(
                    .pixel_vector(pixel_vector[j]),
                    .weight_vector(weight_vector[i]),
                    .partial_sum(partial_sum[i][j])
                );
                dffr #(.DW(INPUT_PIXEL_NUM * (PARTIAL_SUM_ELE_WIDTH))) cov_data_dffr(
                    .dnxt(partial_sum[i][j]),
                    .qout(partial_sum_late[i][j]),
                    .clk(clk),
                    .rst_n(rst_n)
                );
            end
        end
    endgenerate

    generate
        for(i = 0; i < COV_SIZE; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                for(k = 0; k < INPUT_PIXEL_NUM; k = k + 1) begin
                    assign negative_partial_sum_late[i][j][k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_data(partial_sum_late[i][j][k * PARTIAL_SUM_ELE_WIDTH +: PARTIAL_SUM_ELE_WIDTH]);
                end
            end
        end
    endgenerate

    generate
        // Init #(COV_SIZE + 1) output line buffer
        for(i = 0; i < COV_SIZE + 1; i = i + 1) begin:init_outline
                bram_subbank_dual_port #(
                    .DEPTH(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM),
                    .DATA_WIDTH(BRAM_DATA_WIDTH),
                    .ADDR_WIDTH($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM))
                )
                bram(
                    .clka(clk),
                    .clkb(clk),
                    .dina(bram_ina[i]),
                    .dinb(bram_inb[i]),
                    .addra(addra[i]),
                    .addrb(addrb),
                    .ena(ena[i]),
                    .enb(enb[i]),
                    .wea(wea[i]),
                    .web(web[i]),
                    .douta(bram_outa[i]),
                    .doutb(bram_outb[i])
                );
                always @(posedge clk or negedge rst_n) begin
                    if(~rst_n | dirty_clear[i]) begin
                        dirty_flag[i] <= {{DST_IMAGE_WIDTH / INPUT_PIXEL_NUM}{1'b0}};
                    end
                    else begin
                        if(wea[i])
                            dirty_flag[i][addra[i]] <= 1'b1;
                        else if(web[i])
                            dirty_flag[i][addrb] <= 1'b1;
                    end
                end
                dfflr #(.DW($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM))) dfflr_addra(
                    .lden(addra_ena[i]),
                    .dnxt(next_addra[i]),
                    .qout(addra[i]),
                    .clk(clk),
                    .rst_n(rst_n)
                );
                assign next_addra[i] = (addra[i] == (DST_IMAGE_WIDTH / INPUT_PIXEL_NUM - 1) ? {($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM)){1'b0}} : addra[i] + 1);
        end
    endgenerate

    wire [FSM_USM_WIDTH - 1 : 0] usm_state;
    wire [FSM_USM_WIDTH - 1 : 0] next_usm_state;
    wire usm_is_idle = (usm_state == USM_IDLE) ? 1'b1 : 1'b0;
    wire usm_is_start = (usm_state == USM_START) ? 1'b1 : 1'b0;
    wire usm_is_normal = (usm_state == USM_NORMAL) ? 1'b1 : 1'b0;
    wire usm_is_last = (usm_state == USM_LAST) ? 1'b1 : 1'b0;

    wire [LINE_COUNT_WIDTH - 1 : 0] line_count; // the number of input lines
    wire [LINE_COUNT_WIDTH - 1 : 0] next_line_count = line_count + 1;
    wire line_count_ena = line_is_last_edge_late & line_is_last_edge;
    wire [LINE_COUNT_WIDTH - 1 : 0] start_output_line = (line_count > EDGE_WIDTH) ? line_count - EDGE_WIDTH : {LINE_COUNT_WIDTH{1'b0}};
    wire [LINE_COUNT_WIDTH - 1 : 0] last_output_line = (line_count < DST_IMAGE_HEIGHT - EDGE_WIDTH) ? line_count + EDGE_WIDTH : DST_IMAGE_HEIGHT - 1;
    wire [LINE_COUNT_WIDTH - 1 : 0] output_line_num; // number of lines output to the M_AXIS
    wire [LINE_COUNT_WIDTH - 1 : 0] busy_line = last_output_line + 1 - output_line_num;
    wire [LINE_COUNT_WIDTH - 1 : 0] next_output_line_num = output_line_num + 1;
    wire output_line_num_ena = m_axis_tlast;
    reg  [COV_SIZE : 0] addra_ena;
    wire addrb_ena = cov_done_late;
    wire [$clog2(EDGE_WIDTH + 1) - 1 : 0] edge_distance; // distance to the edge
    wire usm_end = output_line_num == DST_IMAGE_HEIGHT;
    wire usm_state_idle_exit_ena   = usm_is_idle & input_valid;
    wire usm_state_start_exit_ena  = usm_is_start & (line_count > EDGE_WIDTH);
    wire usm_state_normal_exit_ena = usm_is_normal & (line_count > DST_IMAGE_HEIGHT - EDGE_WIDTH - 2);
    wire usm_state_last_exit_ena   = usm_is_last & usm_end;

    wire [FSM_USM_WIDTH - 1 : 0] usm_state_idle_nxt = USM_START;
    wire [FSM_USM_WIDTH - 1 : 0] usm_state_start_edge_nxt = USM_NORMAL;
    wire [FSM_USM_WIDTH - 1 : 0] usm_state_normal_nxt = usm_state_normal_exit_ena ? USM_LAST : USM_NORMAL;
    wire [FSM_USM_WIDTH - 1 : 0] usm_state_last_nxt = USM_IDLE;

    wire [$clog2(COV_SIZE + 1) - 1 : 0] start_outline_index = start_output_line % (COV_SIZE + 1);
    wire [$clog2(COV_SIZE + 1) - 1 : 0] outline_index_vector [COV_SIZE: 0];
    wire ready_outline_index_ena = m_axis_tlast;
    wire usm_rstn = ~usm_is_idle & rst_n;
    wire [$clog2(COV_SIZE + 1) - 1 : 0] ready_outline_index; // indicate which line to to output to the AXIS
    wire [$clog2(COV_SIZE + 1) - 1 : 0] next_ready_outline_index = (ready_outline_index == COV_SIZE) ? {($clog2(COV_SIZE + 1)){1'b0}} : ready_outline_index + 1;
    wire usm_state_ena = usm_state_idle_exit_ena  
                        | usm_state_start_exit_ena 
                        | usm_state_normal_exit_ena
                        | usm_state_last_exit_ena;

    assign no_outline = busy_line > COV_SIZE + 1;
    assign s_axis_tready = ~(line_is_last | line_is_last_edge | input_valid_late | no_outline | line_count == DST_IMAGE_HEIGHT);

    assign next_usm_state = ({FSM_USM_WIDTH{usm_state_idle_exit_ena}}   & usm_state_idle_nxt)
                        | ({FSM_USM_WIDTH{usm_state_start_exit_ena}}  & usm_state_start_edge_nxt)
                        | ({FSM_USM_WIDTH{usm_state_normal_exit_ena}} & usm_state_normal_nxt)
                        | ({FSM_USM_WIDTH{usm_state_last_exit_ena}}   & usm_state_last_nxt);

    dfflr #(.DW(FSM_USM_WIDTH)) usm_fsm(
        .lden(usm_state_ena),
        .dnxt(next_usm_state),
        .qout(usm_state),
        .clk(clk),
        .rst_n(rst_n)
    );

    dfflr #(.DW($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM))) dfflr_addrb(
        .lden(addrb_ena),
        .dnxt(next_addrb),
        .qout(addrb),
        .clk(clk),
        .rst_n(rst_n)
    );

    dfflr #(.DW(LINE_COUNT_WIDTH)) dfflr_line_count(
        .lden(line_count_ena),
        .dnxt(next_line_count),
        .qout(line_count),
        .clk(clk),
        .rst_n(usm_rstn)
    );

    dfflr #(.DW(LINE_COUNT_WIDTH)) dfflr_output_line_num(
        .lden(output_line_num_ena),
        .dnxt(next_output_line_num),
        .qout(output_line_num),
        .clk(clk),
        .rst_n(usm_rstn)
    );

    dfflr #(.DW($clog2(COV_SIZE + 1))) dfflr_ready_outline_index(
        .lden(ready_outline_index_ena),
        .dnxt(next_ready_outline_index),
        .qout(ready_outline_index),
        .clk(clk),
        .rst_n(usm_rstn)
    );

    dfflr #(COV_SIZE + 1) dfflr_outline_ready(
        .lden(outline_ready_ena),
        .dnxt(next_outline_ready),
        .qout(outline_ready),
        .clk(clk),
        .rst_n(rst_n)
    );

    dfflr #($clog2(DST_IMAGE_WIDTH / INPUT_PIXEL_NUM + 1)) dfflr_output_count(
        .lden(output_count_ena),
        .dnxt(next_output_count),
        .qout(output_count),
        .clk(clk),
        .rst_n(rst_n)
    );

    assign edge_distance = usm_is_start ? line_count : (usm_is_last ? DST_IMAGE_HEIGHT - line_count - 1 : line_count);
    assign outline_ready_ena = outline_ready_set | outline_ready_clear;
    assign output_count_ena = addra_ena[ready_outline_index] & outline_ready[ready_outline_index] | outline_ready_clear;

    generate
        for(i = 0; i < COV_SIZE + 1; i = i + 1) begin
            for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
                for(k = 0; k < 3; k = k + 1) begin
                    wire [(BRAM_ELE_WIDTH / 3) - 1 : 0] double_ch_data = input_data_late[j * DATA_WIDTH + k * CH_WIDTH +: CH_WIDTH] << (1 + EXPAND_PRECISION);
                    assign bram_ina[i][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = double_ch_data + bram_data_a[i][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                end
            end
            assign wea[i] = (line_count % (COV_SIZE + 1)) == i ? input_valid_late : 1'b0;
            assign rea[i] = (line_count % (COV_SIZE + 1)) == i ? input_valid : (i == ready_outline_index & outline_ready[i]) ? 1'b1 : 1'b0;
            assign ena[i] = wea[i] | rea[i];
            assign enb[i] = web[i] | reb[i];
            assign outline_index_vector[i] = (start_outline_index + i) > COV_SIZE ? start_outline_index + i - COV_SIZE - 1 : start_outline_index + i;
        end
    endgenerate

    always @(*) begin : outline_control
        integer i;
        outline_ready_set = 1'b0;
        outline_ready_clear = 1'b0;
        for(i = 0; i < COV_SIZE + 1; i = i + 1)begin
            bram_data_a[i] = dirty_flag[i][addra[i]] == 1'b0 ? {BRAM_DATA_WIDTH{1'b0}} : bram_outa[i];
            bram_data_b[i] = dirty_flag[i][addrb] == 1'b0 ? {BRAM_DATA_WIDTH{1'b0}} : bram_outb[i];
            dirty_clear[i] = 1'b0;
            next_outline_ready[i] = outline_ready[i];
            addra_ena[i] = (line_count % (COV_SIZE + 1)) == i ? input_valid_late : (i == ready_outline_index & outline_ready[i]) ?  m_axis_tready & (output_count < DST_IMAGE_WIDTH / INPUT_PIXEL_NUM) : 1'b0;
        end

        if(m_axis_tlast) begin
            next_outline_ready[ready_outline_index] = 1'b0;
            outline_ready_clear = 1'b1;
        end

        if(line_count_ena) begin
            if (usm_is_start & edge_distance == EDGE_WIDTH) begin
                next_outline_ready[start_outline_index] = 1'b1;
                outline_ready_set = 1'b1;
                dirty_clear[start_outline_index] = 1'b1;
            end
            else if(usm_is_normal | (usm_is_last & edge_distance != 0)) begin
                next_outline_ready[start_outline_index] = 1'b1;
                outline_ready_set = 1'b1;
                dirty_clear[start_outline_index] = 1'b1;
            end
            else if(usm_is_last) begin
                for(i = 0; i < EDGE_WIDTH + 1; i = i + 1) begin
                    next_outline_ready[outline_index_vector[i]] = 1'b1;
                    dirty_clear[outline_index_vector[i]] = 1'b1;
                    outline_ready_set = 1'b1;
                end
            end
        end
    end

    always @(*) begin : usm_control
        integer i, j, k;
        for(i = 0; i < COV_SIZE + 1; i = i + 1) begin
            bram_inb[i] = {(BRAM_DATA_WIDTH - 1){1'b0}};
            partial_sum_in_0[i] = {(BRAM_DATA_WIDTH - 1){1'b0}};
            partial_sum_in_1[i] = {(BRAM_DATA_WIDTH - 1){1'b0}};
            web[i] = 1'b0;
            reb[i] = 1'b0;
        end
        
        for(i = 0; i < COV_SIZE; i = i + 1) begin
            for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
                for(k = 0; k < 3; k = k + 1) begin
                    if(usm_is_start & edge_distance == 0 & i < EDGE_WIDTH + 1) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                    else if(usm_is_start & i < (EDGE_WIDTH - edge_distance + 1)) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH - edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                        partial_sum_in_1[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH + edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];

                    end
                    else if(usm_is_start & i < (EDGE_WIDTH + edge_distance + 1)) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH + edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                    else if(usm_is_normal) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                    else if(usm_is_last & (edge_distance == 0)) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                    else if(usm_is_last & i < (edge_distance << 1)) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                    else if(usm_is_last & i < (EDGE_WIDTH + edge_distance + 1)) begin
                        partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                        partial_sum_in_1[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i + (edge_distance << 1) - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                    end
                end
            end
        end

        for(i = 0; i < COV_SIZE; i = i + 1) begin
            for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
                for(k = 0; k < 3; k = k + 1) begin
                    bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = partial_sum_in_0[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + partial_sum_in_1[i][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
                end
            end
        end

        for(i = 0; i < COV_SIZE; i = i + 1) begin
            if(usm_is_start & edge_distance == 0 & i < (EDGE_WIDTH + 1)) begin
                web[i] = cov_done_late;
                reb[i] = cov_done;
            end
            else if(usm_is_start & i < (EDGE_WIDTH + edge_distance + 1)) begin
                web[outline_index_vector[i]] = cov_done_late;
                reb[outline_index_vector[i]] = cov_done;
            end
            else if(usm_is_normal) begin
                web[outline_index_vector[i]] = cov_done_late;
                reb[outline_index_vector[i]] = cov_done;
            end
            else if(usm_is_last & (edge_distance == 0) & i < (EDGE_WIDTH + 1)) begin
                web[outline_index_vector[i]] = cov_done_late;
                reb[outline_index_vector[i]] = cov_done;
            end
            else if(usm_is_last & i < (EDGE_WIDTH + edge_distance + 1)) begin
                web[outline_index_vector[i]] = cov_done_late;
                reb[outline_index_vector[i]] = cov_done;
            end
        end
        
        // if(usm_is_start & edge_distance == 0) begin
        //     for(i = 0; i < EDGE_WIDTH + 1; i = i + 1) begin
        //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
        //             for(k = 0; k < 3; k = k + 1) begin
        //                 bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] +  bram_data_b[i][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //             end
        //         end
        //         web[i] = cov_done_late;
        //         reb[i] = cov_done;
        //     end
        // end
        // else if(usm_is_start) begin
        //     for(i = 0; i < COV_SIZE; i = i + 1) begin
        //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1)begin
        //             for(k = 0; k < 3; k = k + 1)begin
        //                 if(i < EDGE_WIDTH - edge_distance + 1) begin
        //                     bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH - edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + negative_partial_sum_late[EDGE_WIDTH + edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //                 end
        //                 else if(i < EDGE_WIDTH + edge_distance + 1) begin
        //                     bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[EDGE_WIDTH + edge_distance - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //                 end
        //             end
        //         end
        //     end

        //     for(i = 0; i < COV_SIZE; i= i + 1) begin
        //         if(i < EDGE_WIDTH + edge_distance + 1) begin
        //             web[outline_index_vector[i]] = cov_done_late;
        //             reb[outline_index_vector[i]] = cov_done;
        //         end
        //     end
        // end
        // else if(usm_is_normal) begin
        //     for(i = 0; i < COV_SIZE; i = i + 1) begin
        //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
        //             for(k = 0; k < 3; k = k + 1) begin
        //                 bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - 1 - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] +  bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //             end
        //         end
        //     end

        //     for(i = 0; i < COV_SIZE; i= i + 1) begin
        //         web[outline_index_vector[i]] = cov_done_late;
        //         reb[outline_index_vector[i]] = cov_done;
        //     end
        // end
        // else if(usm_is_last & (edge_distance == 0)) begin
        //     for(i = 0; i < EDGE_WIDTH + 1; i = i + 1) begin
        //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
        //             for(k = 0; k < 3; k = k + 1) begin
        //                 bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - 1 - i][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] +  bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //             end
        //         end
        //         web[outline_index_vector[i]] = cov_done_late;
        //         reb[outline_index_vector[i]] = cov_done;
        //     end
        // end
        // else if(usm_is_last) begin
        //     for(i = 0; i < COV_SIZE; i = i + 1) begin
        //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1)begin
        //             for(k = 0; k < 3; k = k + 1)begin
        //                 if(i < (edge_distance << 1)) begin
        //                     bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //                 end
        //                 else if(i < EDGE_WIDTH + edge_distance + 1) begin
        //                     bram_inb[outline_index_vector[i]][(j * BRAM_ELE_WIDTH) + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] = negative_partial_sum_late[COV_SIZE - i - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + negative_partial_sum_late[COV_SIZE - i + (edge_distance << 1) - 1][k][j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] + bram_data_b[outline_index_vector[i]][j * BRAM_ELE_WIDTH + k * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)];
        //                 end
        //             end
        //         end
        //     end

        //     for(i = 0; i < COV_SIZE; i= i + 1) begin
        //         if(i < EDGE_WIDTH + edge_distance + 1) begin
        //             web[outline_index_vector[i]] = cov_done_late;
        //             reb[outline_index_vector[i]] = cov_done;
        //         end
        //     end
        // end
    end

    // Axis output logic
    assign output_data_valid = rea[ready_outline_index] & outline_ready[ready_outline_index] & (output_count < DST_IMAGE_WIDTH / INPUT_PIXEL_NUM);
    wire downflow [INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    wire overflow [INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    wire int_flag [INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    wire [(CH_WIDTH + 1) * 3 * INPUT_PIXEL_NUM - 1 : 0] output_data;
    generate
        for(i = 0; i < INPUT_PIXEL_NUM; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                assign output_data[i * (CH_WIDTH + 1) * 3 + j * (CH_WIDTH + 1) +: (CH_WIDTH + 1)] = (bram_outa[ready_outline_index][(i * BRAM_ELE_WIDTH) + j * (BRAM_ELE_WIDTH / 3) +: (BRAM_ELE_WIDTH / 3)] >> EXPAND_PRECISION) + {{(CH_WIDTH){1'b0}}, ~int_flag[i][j]};
                assign overflow[i][j] = output_data[i * (CH_WIDTH + 1) * 3 + j * (CH_WIDTH + 1) +: (CH_WIDTH + 1)] > 255;
                assign m_axis_tdata[i * DATA_WIDTH + j * CH_WIDTH +: CH_WIDTH] = (downflow[i][j] ? {CH_WIDTH{1'b0}} : overflow[i][j] ? 255 : output_data[i * (CH_WIDTH + 1) * 3 + j * (CH_WIDTH + 1) +: CH_WIDTH]) & {CH_WIDTH{m_axis_tvalid}};
                assign downflow[i][j] = bram_outa[ready_outline_index][(i * BRAM_ELE_WIDTH) + (j + 1) * (BRAM_ELE_WIDTH / 3) - 1];
                assign int_flag[i][j] = bram_outa[ready_outline_index][(i * BRAM_ELE_WIDTH) + j * (BRAM_ELE_WIDTH / 3) +: EXPAND_PRECISION] == {EXPAND_PRECISION{1'b0}};
            end
        end
    endgenerate
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            m_axis_tvalid <= 1'b0;
        end
        else if (~m_axis_tvalid | m_axis_tready) begin
            m_axis_tvalid <= output_data_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            m_axis_tlast <= 1'b0;
        end
        else if(m_axis_tready) begin
            m_axis_tlast <= (output_count == DST_IMAGE_WIDTH / INPUT_PIXEL_NUM - 1);
        end
        else begin
            m_axis_tlast <= 1'b0;
        end
    end

    /* signal used to debug */
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_ina   [COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_outa  [COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_data_a[COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_inb   [COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_outb  [COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [CH_WIDTH + EXPAND_PRECISION + 1 : 0] debug_bram_data_b[COV_SIZE : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];
    // wire [PARTIAL_SUM_ELE_WIDTH - 1 : 0] debug_partial_sum_late [COV_SIZE - 1 : 0][INPUT_PIXEL_NUM - 1 : 0][2 : 0];


    // generate
    //     for(i = 0; i < COV_SIZE + 1; i = i + 1) begin
    //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
    //             for(k = 0; k < 3; k = k + 1) begin
    //                 assign debug_bram_ina   [i][j][k] = bram_ina   [i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //                 assign debug_bram_outa  [i][j][k] = bram_outa  [i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //                 assign debug_bram_data_a[i][j][k] = bram_data_a[i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //                 assign debug_bram_inb   [i][j][k] = bram_inb   [i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //                 assign debug_bram_outb  [i][j][k] = bram_outb  [i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //                 assign debug_bram_data_b[i][j][k] = bram_data_b[i][j * BRAM_ELE_WIDTH + k * (CH_WIDTH + EXPAND_PRECISION + 2) +: (CH_WIDTH + EXPAND_PRECISION + 2)];
    //             end
    //         end
    //     end
    //     for(i = 0; i < COV_SIZE; i = i + 1) begin
    //         for(j = 0; j < INPUT_PIXEL_NUM; j = j + 1) begin
    //             for(k = 0; k < 3; k = k + 1) begin
    //                 assign debug_partial_sum_late[i][j][k] = partial_sum_late[i][k][j * PARTIAL_SUM_ELE_WIDTH +: PARTIAL_SUM_ELE_WIDTH];
    //             end
    //         end
    //     end
    // endgenerate

endmodule

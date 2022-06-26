/*************************************************

 Copyright: NUDT_CoreLight

 File name: stream_transformer.v

 Author: NUDT_CoreLight

 Date: 2021-06-26


 Description:

 The original output has some null bytes in the stream, but
 xilinx vdma does not support null bytes between tlas, so we
 have to do a transformation on the output stream.
 **************************************************/

module stream_transformer # (
        parameter AXISOUT_DATA_WIDTH = 32,
        parameter DST_IMG_WIDTH = 960
) (
    /*AUTOARG*/
   // Outputs
   ac_m_axis_tready, m_axis_tvalid, m_axis_tid, m_axis_tdata,
   m_axis_tkeep, m_axis_tstrb, m_axis_tlast, m_axis_tdest,
   m_axis_tuser,
   // Inputs
   clk, rst_n, ac_m_axis_tvalid, ac_m_axis_tid, ac_m_axis_tdata,
   ac_m_axis_tkeep, ac_m_axis_tstrb, ac_m_axis_tlast, ac_m_axis_tdest,
   ac_m_axis_tuser, m_axis_tready
   );

	localparam AXISOUT_STRB_WIDTH = AXISOUT_DATA_WIDTH/8;
    localparam N_FIFO = AXISOUT_STRB_WIDTH/3;
    localparam FIFO_DEPTH = 2;

    input clk;
    input rst_n;

    // Interface with access control
	input                          ac_m_axis_tvalid;	
	output                         ac_m_axis_tready;
	input                          ac_m_axis_tid;
	input [AXISOUT_DATA_WIDTH-1:0] ac_m_axis_tdata;
	input [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tkeep;
	input [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb;
	input                          ac_m_axis_tlast;
	input                          ac_m_axis_tdest;
	input                          ac_m_axis_tuser;


    // Interface with output
	output                          m_axis_tvalid;	
	input                           m_axis_tready;
	output                          m_axis_tid;
	output [AXISOUT_DATA_WIDTH-1:0] m_axis_tdata;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tkeep;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tstrb;
	output                          m_axis_tlast;
	output                          m_axis_tdest;
	output                          m_axis_tuser;




    /*AUTOWIRE*/


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [AXISOUT_DATA_WIDTH-1:0] m_axis_tdata;
    reg			m_axis_tlast;
    reg			m_axis_tuser;
    // End of automatics


    /* Transform input data into a LSB packed form */
    reg [N_FIFO-1:0] valid_pixel;
    reg [$clog2(N_FIFO)-1:0] pos[AXISOUT_STRB_WIDTH-1:0];
    reg [AXISOUT_DATA_WIDTH-1:0] intermediate_ac_data;
    
    always@(*) begin: VALID_PIXEL
        integer i;
        for(i = 0; i < N_FIFO; i=i+1) begin
           valid_pixel[i] = ac_m_axis_tkeep[i*3];
        end
    end

    genvar j;
    generate
        for(j = 0; j < N_FIFO; j=j+1) begin: FORMER_VALID_CNT
            integer idx;
            always@(*) begin
                pos[j] = 0;
                for(idx = 0; idx < j; idx=idx+1) begin
                    pos[j] = pos[j] + valid_pixel[idx];
                end  
            end
        end
    endgenerate

    // Reconstruct data according to pos
    reg [N_FIFO-1:0] intermediate_valid_pixel;
    generate
        for(j = 0; j < N_FIFO; j=j+1) begin: RECONSTRUCT
            integer i;
            always@(*) begin
                intermediate_ac_data[j*24+:24] = 24'b0;
                intermediate_valid_pixel[j] = 1'b0;
                for(i = 0; i < N_FIFO; i=i+1) begin
                    if(pos[i] == j) begin
                        intermediate_ac_data[j*24+:24] = ac_m_axis_tdata[i*24+:24];
                        intermediate_valid_pixel[j] = 1'b1;
                    end
                end
            end
        end
    endgenerate


    /* We us fifos to store valid data bytes in a transfer, ignore null bytes*/
    reg [$clog2(N_FIFO)-1:0] write_pos;
    reg [$clog2(N_FIFO)-1:0] write_num;
    always@(*) begin: WRT_NUM
        integer i;
        write_num = 0;
        for(i = 0; i < N_FIFO; i=i+1) begin
            write_num = write_num + intermediate_valid_pixel[i];
        end
    end

    always@(posedge clk or negedge rst_n) begin: WRT_CNT
        if(~rst_n)
            write_pos <= {$clog2(N_FIFO){1'b1}};
        else if(ac_m_axis_tvalid & ac_m_axis_tready)
            write_pos <= (write_pos + write_num) % N_FIFO;
    end


    reg [AXISOUT_DATA_WIDTH-1:0] fifo_idata;
    reg [N_FIFO-1:0] fifo_wrtmask;

    generate
        for(j = 0; j < N_FIFO; j=j+1) begin: FIFOIN_DATA
            integer i;
            always@(*) begin
                fifo_idata[j*24+:24] = 24'b0;
                fifo_wrtmask[j] = 1'b0;
                for(i = 0; i < N_FIFO; i=i+1) begin
                    if(intermediate_valid_pixel[i] && (i+write_pos)%N_FIFO == j) begin
                        fifo_idata[j*24+:24] = intermediate_ac_data[i*24+:24];
                        fifo_wrtmask[j] = 1'b1;
                    end
                end
            end
        end
    endgenerate

    wire [N_FIFO-1:0] fifo_empty;
    wire [N_FIFO-1:0] fifo_full;
    wire fifo_wrt;
    wire fifo_rd;
    wire [23:0] fifo_odata[N_FIFO-1:0];
    wire fifo_wready;

    assign fifo_wrt = ac_m_axis_tvalid;
    assign fifo_wready = (|fifo_full);

    assign ac_m_axis_tready = fifo_wready;

    // If fifo is not empty, and there is no transfer or the tranfer will complete, read from fifo.
    assign fifo_rd = ~(|fifo_empty) & (~m_axis_tvalid | m_axis_tready);
	reg [N_FIFO-1:0] fifo_rd_r;
    reg [$clog2(DST_IMG_WIDTH)-1:0] fifo_rd_cnt;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			fifo_rd_r <= 1'b0;
		else if(~ac_m_axis_tvalid | ac_m_axis_tready) begin
			fifo_rd_r <= fifo_rd;
            m_axis_tlast <= (fifo_rd_cnt == DST_IMG_WIDTH - N_FIFO)?1'b1:1'b0;
		end
	end

    always@(posedge clk or negedge rst_n) begin: FIFORD_CNT
        if(~rst_n)
	        fifo_rd_cnt <= {$clog2(DST_IMG_WIDTH){1'b0}};
        else if(fifo_rd)
            fifo_rd_cnt <= (fifo_rd_cnt + N_FIFO) % DST_IMG_WIDTH;
    end

    generate
        for(j = 0; j < N_FIFO; j++) begin: TRANSFORMER_FIFO
            fifo #(
	           .FIFO_DEPTH			(FIFO_DEPTH),
	           .FIFO_WIDTH			(24))
            ofifo(
		        // Outputs
		        .fifo_odata		(fifo_odata[j]),
		        .fifo_empty		(fifo_empty[j]),
		        .fifo_full		(fifo_full[j]),
		        // Inputs
		        .clk			(clk),
		        .rst_n		(rst_n),
		        .fifo_rd		(fifo_rd),
		        .fifo_wrt		(fifo_wrt&fifo_wrtmask[j]&fifo_wready),
		        .fifo_idata		(fifo_idata[j*24+:24]));
        end
    endgenerate

    assign m_axis_tvalid = fifo_rd_r;
    assign m_axis_tid    = ac_m_axis_tid;
    assign m_axis_user   = ac_m_axis_tuser;
    assign m_axis_tdest  = ac_m_axis_tdest;
    assign m_axis_tkeep  = {AXISOUT_STRB_WIDTH{1'b1}};
    assign m_axis_tstrb  = {AXISOUT_STRB_WIDTH{1'b1}};

    always@(*) begin: OUTPUT_DATA
        integer i;
        for(i = 0; i < N_FIFO; i=i+1) begin
            m_axis_tdata[i*24+:24] = fifo_odata[i];
        end
    end

endmodule

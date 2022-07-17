/*************************************************

 Copyright: NUDT_CoreLight

 File name: stream_in.v

 Author: NUDT_CoreLight

 Date: 2021-04-05


 Description:

 Accept the input data via AXI-Stream and bypass the data
 to Up-Sampling.

 **************************************************/
module stream_in # (
		parameter AXISIN_DATA_WIDTH = 32,
		parameter UPSP_RDDATA_WIDTH = 32,
		parameter SRC_IMG_WIDTH     = 1920,
		parameter SRC_IMG_HEIGHT    = 1080,
		parameter CRF_DATA_WIDTH    = 32,
		parameter N_PARALLEL	    = 2
	) (/*AUTOARG*/
   // Outputs
   ac_upsp_rvalid, ac_upsp_rdata, s_axis_tready,
   // Inputs
   upsp_ac_rready, UPSTART, UPEND, s_axis_aclk, s_axis_arstn,
   s_axis_tvalid, s_axis_tid, s_axis_tdata, s_axis_tstrb,
   s_axis_tkeep, s_axis_tlast, s_axis_tdest, s_axis_tuser
   );

	localparam AXISIN_STRB_WIDTH    = AXISIN_DATA_WIDTH/8;
	localparam SRC_IMG_HEIGHT_LB2   = $clog2(SRC_IMG_HEIGHT);
	localparam SRC_IMG_WIDTH_LB2    = $clog2(SRC_IMG_WIDTH);
	
	// Interface for upsp read
	input  [N_PARALLEL-1:0]		   upsp_ac_rready;
	output [N_PARALLEL-1:0]        ac_upsp_rvalid;
	output [UPSP_RDDATA_WIDTH-1:0] ac_upsp_rdata;


	// Use UPSTART to indicate the start of a stream
	input UPSTART;
	// Use UPEND to indicate Up-Sampling module has done its work
	input UPEND;


    // Interface as a AXI-Stream slave
	input s_axis_aclk;
    input s_axis_arstn;
	
	input s_axis_tvalid;	
	output s_axis_tready;

	input                         s_axis_tid;
	input [AXISIN_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tkeep;
	input                         s_axis_tlast;
	input                         s_axis_tdest;
	input                         s_axis_tuser;



	/*AUTOWIRE*/


	/*AUTOREG*/


	wire clk = s_axis_aclk;
	wire rst_n = s_axis_arstn;
	wire one_row_hsked = s_axis_tvalid & s_axis_tready & s_axis_tlast;

	// Because VDMA in xilinx will send a tlast signal for every row. So we need to track it.
	reg [SRC_IMG_HEIGHT_LB2-1:0] input_row_cnt;
	always@(posedge clk or negedge rst_n) begin: INROW_CNT
		if(~rst_n)
			input_row_cnt <= {SRC_IMG_HEIGHT_LB2{1'b0}};
		else if(one_row_hsked)
			input_row_cnt <= input_row_cnt + 1;
		else if(UPEND)
			input_row_cnt <= {SRC_IMG_HEIGHT_LB2{1'b0}};
	end

	// Track whether a whole image has been transmitted or not
	reg frame_done;
	always@(posedge clk or negedge rst_n) begin
		// If UPSTART didn't be set, frame_done will be asserted, not data will
		// be transmitted.
		if(~rst_n)
			frame_done <= 1'b1;
		// VDMA sends the last data
		else if(one_row_hsked && input_row_cnt == SRC_IMG_HEIGHT - 1)
			frame_done <= 1'b1;
		// Up-Sampling finished the operation, which means no further data needed
		else if(input_row_cnt == SRC_IMG_HEIGHT)
			frame_done <= 1'b1;
		// reset when next stream begins.
		else if(frame_done & UPSTART)
			frame_done <= 1'b0;
	end


	// Send input stream to one upsp processing element, or multiple elements
	// when the data is in boundary
	localparam BLOCK_SIZE = (SRC_IMG_WIDTH/N_PARALLEL);
	reg [SRC_IMG_WIDTH_LB2:0] cur_row_pos;
	always @(posedge clk or negedge rst_n) begin: ROW_POS
		if(~rst_n)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			cur_row_pos <= {(1+(SRC_IMG_WIDTH_LB2)){1'b0}};
			// End of automatics
		else if(~frame_done) begin
			if(s_axis_tvalid & s_axis_tready) begin
				if(cur_row_pos == SRC_IMG_WIDTH - 1)
					cur_row_pos <= {(1+(SRC_IMG_WIDTH_LB2)){1'b0}};
				else
					cur_row_pos <= cur_row_pos + 1;
			end
		end else
			cur_row_pos <= {(1+(SRC_IMG_WIDTH_LB2)){1'b0}};
	end

	// If not frame_done, generate tready signals depending on upsp ready.
	// The tready for output will be asserted if all elements requiring the data are ready
	wire [N_PARALLEL-1:0] tready;
	wire all_ready = ~(|(ac_upsp_rvalid^tready)) & (|tready);
	assign s_axis_tready  = all_ready & ~frame_done;
	assign ac_upsp_rdata  = s_axis_tdata;

	wire [N_PARALLEL-1:0] in_range;

	genvar j;
	generate
		for(j = 0; j < N_PARALLEL; j=j+1) begin: MULTI_ELE
			localparam START = (j == 0)?0:j*BLOCK_SIZE;
			localparam END = (j == 0)?((N_PARALLEL==1)?(START + BLOCK_SIZE -1):(START + BLOCK_SIZE -1 + 3))
								    :(j<N_PARALLEL-1)?START + BLOCK_SIZE -1 + 3
									:START + BLOCK_SIZE -1;

			assign in_range[j] = (cur_row_pos >= START) && (cur_row_pos <= END);
			assign ac_upsp_rvalid[j] = in_range[j] & s_axis_tvalid;
			assign tready[j] = in_range[j] & upsp_ac_rready[j];
		end
	endgenerate




// Additional code for easy debugging
`ifndef DISABLE_DEBUG_CODE

	// Track if only the lower 3B are valid data in data bus.
	reg AXIS_ONLY_3LSB_ARE_VALID;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			AXIS_ONLY_3LSB_ARE_VALID <= 1'b0;
		else if(s_axis_tvalid ) begin
			if(s_axis_tstrb & s_axis_tkeep != 'b0111)
				AXIS_ONLY_3LSB_ARE_VALID <= 1'b1;
		end else if(frame_done & UPSTART)
			AXIS_ONLY_3LSB_ARE_VALID <= 1'b0;
	end

`endif


// SVA for the design features
`ifndef DISABLE_SV_ASSERTION

	property valid_stream_in;
		@(posedge clk) disable iff(~rst_n)
		s_axis_tvalid |-> ~frame_done;
	endproperty

	assert property(valid_stream_in) else begin 
		$display("stream_in: tvalid is asserted when frame_done is asserted\n");
		// $finish;
	end

`endif

endmodule

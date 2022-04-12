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
		parameter AXIS_DATA_WIDTH = 32,
		parameter UPSP_DATA_WIDTH = 32
	) (/*AUTOARG*/
   // Outputs
   ac_upsp_rvalid, ac_upsp_rdata, s_axis_tready,
   // Inputs
   upsp_ac_rd, UPSTR, UPENDR, s_axis_aclk, s_axis_arstn,
   s_axis_tvalid, s_axis_tid, s_axis_tdata, s_axis_tstrb,
   s_axis_tkeep, s_axis_tlast, s_axis_tdest, s_axis_user
   );

	localparam AXIS_STRB_WIDTH = AXIS_DATA_WIDTH/8;
	
	// Interface for upsp read
	input                        upsp_ac_rd;
	output                       ac_upsp_rvalid;
	output [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;


	// Use UPSTR[0] to indicate the start of a stream
	input UPSTR;
	// Use UPENDR[0] to indicate Up-Sampling module has done its work
	input UPENDR;


    // Interface as a AXI-Stream slave
	input s_axis_aclk;
    input s_axis_arstn;
	
	input s_axis_tvalid;	
	output s_axis_tready;

	input                       s_axis_tid;
	input [AXIS_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tkeep;
	input                       s_axis_tlast;
	input                       s_axis_tdest;
	input                       s_axis_user;



	/*AUTOWIRE*/


	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	reg		ac_upsp_rvalid;
	// End of automatics


	wire clk = s_axis_aclk;
	wire rst_n = s_axis_arstn;

	// Track whether a whole image has been transmitted or not
	reg frame_done;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			frame_done <= 1'b0;
		// DMA sends the last data
		else if(s_axis_tvalid & s_axis_tready & s_axis_tlast)
			frame_done <= 1'b1;
		// Up-Sampling finished the operation, which means no further data needed
		else if(UPENDR)
			frame_done <= 1'b1;
		// reset when next stream begins
		else if(frame_done & UPSTR)
			frame_done <= 1'b0;
	end

	/* Input width of AXI-Stream is 4B, but only LSB 3B are useful.
	 These 3B will be sent to Up-Sampling module.
	*/
	assign s_axis_tready = upsp_ac_rd & ~frame_done;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_upsp_rdata <= {UPSP_DATA_WIDTH{1'b0}};
			ac_upsp_rvalid <= 1'h0;
			// End of automatics
		end else if(s_axis_tvalid & s_axis_tready & ~frame_done) begin
			ac_upsp_rvalid <= 1'b1;
			ac_upsp_rdata  <= s_axis_tdata[UPSP_DATA_WIDTH-1:0];
		end else
			ac_upsp_rvalid <= 1'b0;
	end



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
		end else if(frame_done & UPSTR)
			AXIS_ONLY_3LSB_ARE_VALID <= 1'b0;
	end

`endif


// SVA for the design features
`ifndef DISABLE_SV_ASSERTION

	property valid_stream_in;
		@(posedge clk) disable iff(~rst_n)
		s_axis_tvalid |-> ~frame_done;
	endproperty

	property valid_upsp_read;
		@(posedge clk) disable iff(~rst_n)
		upsp_ac_rd |-> ~frame_done;
	endproperty


	assert property(valid_stream_in);
	assert property(valid_upsp_read);

`endif

endmodule

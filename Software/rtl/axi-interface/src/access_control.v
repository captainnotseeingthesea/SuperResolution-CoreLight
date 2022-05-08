/*************************************************

 Copyright: NUDT_CoreLight

 File name: access_control.v

 Author: NUDT_CoreLight

 Date: 2021-03-27


 Description:

 Access control, contains stream_in to serve read requests from 
 Up-Sampling and transforms Up-Sampling write requests into AXI4 
 requests to DDR in PS side as the AXI4 master.
 R and AR channels 
 **************************************************/

module access_control # (
		// AXI-Stream
		parameter AXIS_DATA_WIDTH = 32,

		parameter CRF_DATA_WIDTH = 32,
		parameter CRF_ADDR_WIDTH = 32,
		parameter UPSP_DATA_WIDTH = 32,

		parameter SRC_IMG_WIDTH  = 1920,
		parameter SRC_IMG_HEIGHT = 1080,
		parameter DST_IMG_WIDTH  = 4096,
		parameter DST_IMG_HEIGHT = 2160
	) (/*AUTOARG*/
   // Outputs
   ac_crf_wrt, ac_crf_wdata, ac_crf_waddr, ac_upsp_rvalid,
   ac_upsp_rdata, ac_upsp_wready, s_axis_tready, m_axis_tvalid,
   m_axis_tid, m_axis_tdata, m_axis_tkeep, m_axis_tstrb, m_axis_tlast,
   m_axis_tdest, m_axis_user,
   // Inputs
   clk, rst_n, crf_ac_UPSTART, crf_ac_UPEND, crf_ac_wbusy,
   upsp_ac_rready, upsp_ac_wvalid, upsp_ac_wdata, s_axis_tvalid,
   s_axis_tid, s_axis_tdata, s_axis_tstrb, s_axis_tkeep, s_axis_tlast,
   s_axis_tdest, s_axis_user, m_axis_tready
   );

	localparam AXIS_STRB_WIDTH    = AXIS_DATA_WIDTH/8;
	localparam IMG_CNT_WIDTH      = $clog2(DST_IMG_WIDTH*DST_IMG_HEIGHT);
	localparam DST_IMG_HEIGHT_LB2 = $clog2(DST_IMG_HEIGHT);

	input clk;
	input rst_n;

	// Interface with config register file
	output                      ac_crf_wrt;
	output [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	output [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	input                       crf_ac_UPSTART;
	input                       crf_ac_UPEND  ;
	input                       crf_ac_wbusy;


	// Interface with upsp
	input                        upsp_ac_rready;
	output                       ac_upsp_rvalid;
	output [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	output                       ac_upsp_wready;
	input                        upsp_ac_wvalid;
	input  [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;



	// Interface as AXI-Stream slave
	// input s_axis_aclk;
    // input s_axis_arstn;
	input                       s_axis_tvalid;	
	output                      s_axis_tready;
	input                       s_axis_tid;
	input [AXIS_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tkeep;
	input                       s_axis_tlast;
	input                       s_axis_tdest;
	input                       s_axis_user;



	// Interface as AXI-Stream master
	// input s_axis_aclk;
    // input s_axis_arstn;
	output                       m_axis_tvalid;	
	input                        m_axis_tready;
	output                       m_axis_tid;
	output [AXIS_DATA_WIDTH-1:0] m_axis_tdata;
	output [AXIS_STRB_WIDTH-1:0] m_axis_tkeep;
	output [AXIS_STRB_WIDTH-1:0] m_axis_tstrb;
	output                       m_axis_tlast;
	output                       m_axis_tdest;
	output                       m_axis_user;


	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	reg [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	reg		ac_crf_wrt;
	reg		m_axis_tlast;
	reg		m_axis_tvalid;
	// End of automatics




	// Rename config registers and output UPSTART and UPEND
	wire UPSTART = crf_ac_UPSTART;
	wire UPEND   = crf_ac_UPEND;

	// Whether a upsampling is been processing or not
	reg processing;
	always@(posedge clk or negedge rst_n) begin: PROCESSING
		if(~rst_n)
			processing <= 1'b0;
		else if(UPSTART & ~UPEND & ~processing)
			processing <= 1'b1;
		else if(~UPSTART & UPEND & processing)
			processing <= 1'b0;
	end

	// After finish upsampling, clear UPSTART and write UPEND.
	wire last_one_sent;
	wire write_done = m_axis_tvalid & m_axis_tready & m_axis_tlast & last_one_sent;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_crf_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			ac_crf_wdata <= {CRF_DATA_WIDTH{1'b0}};
			ac_crf_wrt <= 1'h0;
			// End of automatics
		end else if(processing & write_done & UPSTART) begin
			ac_crf_wrt <= 1'b1;
			ac_crf_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			ac_crf_wdata <= {{(CRF_DATA_WIDTH-2){1'b0}}, UPEND, 1'b0};
		end else if(processing & ~UPSTART & ~UPEND) begin
			ac_crf_wrt <= 1'b1;
			ac_crf_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			ac_crf_wdata <= {{(CRF_DATA_WIDTH-2){1'b0}}, 1'b1, UPSTART};
		end else
			ac_crf_wrt <= 1'b0;
	end


	// Stream in to handle input axi-stream
	stream_in #(/*AUTOINSTPARAM*/
		    // Parameters
		    .AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH),
		    .UPSP_DATA_WIDTH	(UPSP_DATA_WIDTH),
		    .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT))
	AAA_stream_in(
			  .s_axis_aclk	(clk),
			  .s_axis_arstn	(rst_n),
			  /*AUTOINST*/
		      // Outputs
		      .ac_upsp_rvalid	(ac_upsp_rvalid),
		      .ac_upsp_rdata	(ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]),
		      .s_axis_tready	(s_axis_tready),
		      // Inputs
		      .upsp_ac_rready	(upsp_ac_rready),
		      .UPSTART		(UPSTART),
		      .UPEND		(UPEND),
		      .s_axis_tvalid	(s_axis_tvalid),
		      .s_axis_tid	(s_axis_tid),
		      .s_axis_tdata	(s_axis_tdata[AXIS_DATA_WIDTH-1:0]),
		      .s_axis_tstrb	(s_axis_tstrb[AXIS_STRB_WIDTH-1:0]),
		      .s_axis_tkeep	(s_axis_tkeep[AXIS_STRB_WIDTH-1:0]),
		      .s_axis_tlast	(s_axis_tlast),
		      .s_axis_tdest	(s_axis_tdest),
		      .s_axis_user	(s_axis_user));





	/* We use two ping-pong buffers to hold the data from Up-Sampling.
	*/

	localparam DST_IMG_WIDTH_LB2 = $clog2(DST_IMG_WIDTH);
	assign m_axis_tid   = 1'b0;
	assign m_axis_tdest = 1'b0;
	assign m_axis_user  = 1'b0;
	assign m_axis_tkeep	= {AXIS_STRB_WIDTH{1'b1}};
	assign m_axis_tstrb = {AXIS_STRB_WIDTH{1'b1}};
	
	
	// Corresponding buffers are under written, already valid or empty
	reg [1:0] outbuf_writing;
	reg [1:0] outbuf_valid;
	reg upsp_bufsel;
	reg ac_bufsel;


	// If there is at least one non-valid buffer, upsp can write.
	assign ac_upsp_wready = ~(&outbuf_valid);

	reg [IMG_CNT_WIDTH-1:0] upsp_wrtcnt;
	reg [IMG_CNT_WIDTH-1:0] ac_rdcnt;



	// Get access control read position
	reg [DST_IMG_WIDTH_LB2-1:0]  ac_rdnum_inrow;
	reg [DST_IMG_HEIGHT_LB2-1:0] ac_rdnum_incol;
	always@(*) begin//TODO: More efficient
		ac_rdnum_inrow = ac_rdcnt % DST_IMG_WIDTH;
	end

	wire outbuf_clear = 
			   ac_rdnum_inrow == (DST_IMG_WIDTH-1)
			   && ac_rdnum_incol[1:0] == 2'b11 
			   && m_axis_tvalid & m_axis_tready;


	// Get the number of written data in the first buffer's first line
	reg [DST_IMG_WIDTH_LB2-1:0] upsp_wrtnum_inrowfir;
	reg [DST_IMG_WIDTH_LB2-1:0] upsp_wrtnum_inrowbase;
	reg [DST_IMG_WIDTH_LB2-1+2:0] upsp_wrtcnt_4line;

	// Determine whether the data is ready for transfer or not
	wire already_written = outbuf_writing[upsp_bufsel] &&
						   (ac_rdnum_inrow < upsp_wrtnum_inrowfir);


	wire outbuf0_we = ~upsp_bufsel & upsp_ac_wvalid & ac_upsp_wready;
	wire outbuf1_we =  upsp_bufsel & upsp_ac_wvalid & ac_upsp_wready;
	wire [DST_IMG_WIDTH_LB2-1:0] outbuf_waddr = upsp_wrtnum_inrowbase + upsp_wrtcnt[1:0];

	wire outbuf_re  = ((|outbuf_valid) | already_written) & ((~m_axis_tvalid) | m_axis_tready);
	wire outbuf0_re = ~ac_bufsel & outbuf_re;
	wire outbuf1_re =  ac_bufsel & outbuf_re;

	wire [AXIS_DATA_WIDTH-1:0] outbuf0_dout, outbuf1_dout;

	reg [1:0] outbuf_re_r;
	assign m_axis_tdata =   ({AXIS_DATA_WIDTH{outbuf_re_r[0]}} & outbuf0_dout)
						  | ({AXIS_DATA_WIDTH{outbuf_re_r[1]}} & outbuf1_dout);

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			outbuf_re_r <= 2'b0;
		else
			outbuf_re_r <= {outbuf1_re, outbuf0_re};
	end

	/*axis_outbuf AUTO_TEMPLATE(
	      // Outputs
	      .rdout		(outbuf@_dout),
	      // Inputs
	      .clk			(clk),
	      .rst_n		(rst_n),
	      .raddr		(ac_rdnum_inrow),
	      .rcs			(ac_rdnum_incol[1:0]),
	      .re			(outbuf@_re),
	      .wdin			(upsp_ac_wdata),
	      .waddr		(outbuf_waddr),
	      .wcs			(upsp_wrtcnt[3:2]),
	      .we			(outbuf@_we),
	)*/

	axis_outbuf #(
		  // Parameters
		  .DATA_WIDTH	(AXIS_DATA_WIDTH),
		  .DEPTH		(DST_IMG_WIDTH),
		  .ADDR_WIDTH	(DST_IMG_WIDTH_LB2))
	outbuf0(/*AUTOINST*/
		// Outputs
		.rdout			(outbuf0_dout),		 // Templated
		// Inputs
		.clk			(clk),			 // Templated
		.rst_n			(rst_n),		 // Templated
		.raddr			(ac_rdnum_inrow),	 // Templated
		.rcs			(ac_rdnum_incol[1:0]),	 // Templated
		.re			(outbuf0_re),		 // Templated
		.wdin			(upsp_ac_wdata),	 // Templated
		.waddr			(outbuf_waddr),		 // Templated
		.wcs			(upsp_wrtcnt[3:2]),	 // Templated
		.we			(outbuf0_we));		 // Templated

	axis_outbuf #(
		  // Parameters
		  .DATA_WIDTH	(AXIS_DATA_WIDTH),
		  .DEPTH		(DST_IMG_WIDTH),
		  .ADDR_WIDTH	(DST_IMG_WIDTH_LB2))
	outbuf1(/*AUTOINST*/
		// Outputs
		.rdout			(outbuf1_dout),		 // Templated
		// Inputs
		.clk			(clk),			 // Templated
		.rst_n			(rst_n),		 // Templated
		.raddr			(ac_rdnum_inrow),	 // Templated
		.rcs			(ac_rdnum_incol[1:0]),	 // Templated
		.re			(outbuf1_re),		 // Templated
		.wdin			(upsp_ac_wdata),	 // Templated
		.waddr			(outbuf_waddr),		 // Templated
		.wcs			(upsp_wrtcnt[3:2]),	 // Templated
		.we			(outbuf1_we));		 // Templated


	always@(posedge clk or negedge rst_n) begin: UPSP_WRITE
		if(~rst_n) begin
			outbuf_valid <= 2'h0;
			outbuf_writing <= 2'h0;
			upsp_bufsel <= 1'h0;
			upsp_wrtcnt <= {IMG_CNT_WIDTH{1'b0}};
			upsp_wrtnum_inrowfir <= {DST_IMG_WIDTH_LB2{1'b0}};
			upsp_wrtnum_inrowbase <= {DST_IMG_WIDTH_LB2{1'b0}};
			upsp_wrtcnt_4line <= {(IMG_CNT_WIDTH-1+2){1'b0}};
		end else if(write_done) begin
			outbuf_valid <= 2'h0;
			outbuf_writing <= 2'h0;
			upsp_bufsel <= 1'h0;
			upsp_wrtcnt <= {IMG_CNT_WIDTH{1'b0}};
			upsp_wrtnum_inrowfir <= {DST_IMG_WIDTH_LB2{1'b0}};
			upsp_wrtnum_inrowbase <= {DST_IMG_WIDTH_LB2{1'b0}};
			upsp_wrtcnt_4line <= {(IMG_CNT_WIDTH-1+2){1'b0}};
		end else begin
			if(upsp_ac_wvalid & ac_upsp_wready) begin
				if(~outbuf_writing[upsp_bufsel]) outbuf_writing[upsp_bufsel] <= 1'b1;
				if(outbuf_writing[~upsp_bufsel]) outbuf_writing[~upsp_bufsel] <= 1'b0;

				upsp_wrtcnt <= upsp_wrtcnt + 1;
				upsp_wrtcnt_4line <= upsp_wrtcnt_4line + 1;
				// After writing 4 lines, set outbuf valid
				if(upsp_wrtcnt_4line == 4 * DST_IMG_WIDTH-1) begin
					upsp_bufsel <= ~upsp_bufsel;
					outbuf_valid[upsp_bufsel] <= 1'b1;
					upsp_wrtcnt_4line <= {(IMG_CNT_WIDTH-1+2){1'b0}};
				end
				
				if(upsp_wrtcnt[3:2] == 2'b00) begin
					upsp_wrtnum_inrowfir <= upsp_wrtnum_inrowfir + 1;
					if(upsp_wrtnum_inrowfir == DST_IMG_WIDTH - 1) upsp_wrtnum_inrowfir <= {DST_IMG_WIDTH_LB2{1'b0}};
				end

				if(upsp_wrtcnt[3:0] == 4'hf)
					upsp_wrtnum_inrowbase <= upsp_wrtnum_inrowfir;

			end

			// After transfering 4 lines, clear outbuf valid
			if(outbuf_clear)
				outbuf_valid[ac_bufsel] <= 1'b0;
		end
	end
	

	// Transfer data if possible
	wire last_of_row = (ac_rdnum_inrow == DST_IMG_WIDTH - 1);
	assign last_one_sent = (ac_rdnum_incol == DST_IMG_HEIGHT);

	always@(posedge clk or negedge rst_n) begin: AC_BUFSEL
		if(~rst_n) begin
			ac_bufsel <= 1'b0;
		end else if(write_done)
			ac_bufsel <= 1'b0;
		else if(outbuf_clear)
			ac_bufsel <= ~ac_bufsel;
	end

	always@(posedge clk or negedge rst_n) begin: AIXS_TRANS
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_rdcnt <= {IMG_CNT_WIDTH{1'b0}};
			ac_rdnum_incol <= {DST_IMG_HEIGHT_LB2{1'b0}};
			m_axis_tlast <= 1'h0;
			m_axis_tvalid <= 1'h0;
			// End of automatics

		// If there is a valid outbuf, or the could-writeen data are already
		// inside the buffer, get data and send
		end else if((|outbuf_valid) | already_written) begin
			if(m_axis_tvalid) begin
				if(m_axis_tready) begin
					
					ac_rdcnt <= ac_rdcnt + 1;
					if(last_of_row) begin
						ac_rdnum_incol <= ac_rdnum_incol + 1;
						// if(ac_rdnum_incol == 2'b11) ac_rdnum_incol <= 0;
					end

					m_axis_tlast <= last_of_row;
				end
			end else begin
				m_axis_tvalid <= 1'b1;

				ac_rdcnt <= ac_rdcnt + 1;
				if(last_of_row) begin
					ac_rdnum_incol <= ac_rdnum_incol + 1;
					// if(ac_rdnum_incol == 2'b11) ac_rdnum_incol <= 0;
				end
				
				m_axis_tlast  <= last_of_row;
			end

		end else if(m_axis_tvalid) begin
			if(m_axis_tready) begin
				m_axis_tvalid <= 1'b0;
				if(m_axis_tlast && last_one_sent) begin
					ac_rdcnt <= {IMG_CNT_WIDTH{1'b0}};
					ac_rdnum_incol <= {DST_IMG_HEIGHT_LB2{1'b0}};
					m_axis_tlast <= 1'b0;
				end
			end
		end else begin
			m_axis_tvalid <= 1'b0;
		end
	end


// Additional code for easy debugging
`ifndef DISABLE_DEBUG_CODE

	reg startup;
	always@(posedge clk or negedge rst_n) begin: START_UP
		if(~rst_n)
			startup <= 1'b0;
		else if(UPSTART & ~UPEND & ~startup & ~processing)
			startup <= 1'b1;
		else
			startup <= 1'b0;
	end

`endif


// SVA for the design features
`ifndef DISABLE_SV_ASSERTION

`endif

endmodule

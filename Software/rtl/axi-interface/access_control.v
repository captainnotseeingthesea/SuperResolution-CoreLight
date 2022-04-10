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
   ac_crf_wrt, ac_crf_wdata, ac_crf_waddr, UPSTR, UPENDR,
   ac_upsp_rvalid, ac_upsp_rdata, ac_upsp_wready, s_axis_tready,
   m_axis_tvalid, m_axis_tid, m_axis_tdata, m_axis_tkeep,
   m_axis_tstrb, m_axis_tlast, m_axis_tdest, m_axis_user,
   // Inputs
   clk, rst_n, crf_ac_UPSTR, crf_ac_UPENDR, crf_ac_UPSRCAR,
   crf_ac_UPDSTAR, crf_ac_wbusy, upsp_ac_rd, upsp_ac_wrt,
   upsp_ac_wdata, s_axis_tvalid, s_axis_tid, s_axis_tdata,
   s_axis_tstrb, s_axis_tkeep, s_axis_tlast, s_axis_tdest,
   s_axis_user, m_axis_tready
   );

	localparam AXIS_STRB_WIDTH = AXIS_DATA_WIDTH/8;
	localparam IMG_CNT_WIDTH   = $clog2(DST_IMG_WIDTH*DST_IMG_HEIGHT);

	input clk;
	input rst_n;

	// Interface with config register file
	output                      ac_crf_wrt;
	output [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	output [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	input  [CRF_DATA_WIDTH-1:0] crf_ac_UPSTR;
	input  [CRF_DATA_WIDTH-1:0] crf_ac_UPENDR;
	input  [CRF_DATA_WIDTH-1:0] crf_ac_UPSRCAR;
	input  [CRF_DATA_WIDTH-1:0] crf_ac_UPDSTAR;
	input                       crf_ac_wbusy;


	// Interface with upsp
	output [CRF_DATA_WIDTH-1:0]  UPSTR;
	output [CRF_DATA_WIDTH-1:0]  UPENDR;
	input                        upsp_ac_rd;
	output                       ac_upsp_rvalid;
	output [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	output                       ac_upsp_wready;
	input                        upsp_ac_wrt;
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
	reg [AXIS_DATA_WIDTH-1:0] m_axis_tdata;
	reg		m_axis_tid;
	reg		m_axis_tlast;
	reg		m_axis_tvalid;
	// End of automatics




	// Rename config registers and output UPSTR and UPENDR
	assign                    UPSTR   = crf_ac_UPSTR;
	assign                    UPENDR  = crf_ac_UPENDR;
	wire [CRF_DATA_WIDTH-1:0] UPSRCAR = crf_ac_UPSRCAR;
	wire [CRF_DATA_WIDTH-1:0] UPDSTAR = crf_ac_UPDSTAR;

	// Whether a upsampling is been processing or not
	reg processing;
	always@(posedge clk or negedge rst_n) begin: PROCESSING
		if(~rst_n)
			processing <= 1'b0;
		else if(UPSTR[0] & ~UPENDR[0] & ~processing)
			processing <= 1'b1;
		else if(~UPSTR[0] & UPENDR[0] & processing)
			processing <= 1'b0;
	end

	// After finish upsampling, clear UPSTR and write UPENDR.
	wire write_done = m_axis_tvalid & m_axis_tready & m_axis_tlast;
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_crf_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			ac_crf_wdata <= {CRF_DATA_WIDTH{1'b0}};
			ac_crf_wrt <= 1'h0;
			// End of automatics
		end else if(processing & write_done & UPSTR[0]) begin
			ac_crf_wrt <= 1'b1;
			ac_crf_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			ac_crf_wdata <= {{(CRF_DATA_WIDTH-1){1'b0}}, 1'b1};
		end else if(processing & write_done & ~UPSTR[0] & ~UPENDR[0]) begin
			ac_crf_wrt <= 1'b1;
			ac_crf_waddr <= {{(CRF_DATA_WIDTH-1){1'b0}}, 1'b1};
			ac_crf_wdata <= {{(CRF_DATA_WIDTH-1){1'b0}}, 1'b1};	
		end
	end


	// Stream in to handle input axi-stream
	stream_in #(/*AUTOINSTPARAM*/
		    // Parameters
		    .AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH),
		    .UPSP_DATA_WIDTH	(UPSP_DATA_WIDTH))
	AAA_stream_in(
			  .s_axis_aclk	(clk),
			  .s_axis_arstn	(rst_n),
			  .UPSTR		(UPSTR[0]),
			  .UPENDR		(UPENDR[0]),
			  /*AUTOINST*/
		      // Outputs
		      .ac_upsp_rvalid	(ac_upsp_rvalid),
		      .ac_upsp_rdata	(ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]),
		      .s_axis_tready	(s_axis_tready),
		      // Inputs
		      .upsp_ac_rd	(upsp_ac_rd),
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
	assign m_axis_tkeep	= {AXIS_STRB_WIDTH{1'b1}};
	assign m_axis_tstrb = {AXIS_STRB_WIDTH{1'b1}};
	assign m_axis_tdest = 1'b0;
	assign m_axis_user  = 1'b0;
	
	// Corresponding buffers are been writing or already valid(empty)
	reg [1:0] outbuf_writing;
	reg [1:0] outbuf_valid;
	reg upsp_bufsel;
	reg [AXIS_DATA_WIDTH-1:0] outbuf[0:1][0:3][0:DST_IMG_WIDTH-1];

	// If there is at least one non-valid buffer, upsp can write.
	assign ac_upsp_wready = ~(&outbuf_valid);

	reg [IMG_CNT_WIDTH-1:0] upsp_wrtcnt;
	reg [IMG_CNT_WIDTH-1:0] ac_rdcnt;
	wire outbuf_clear = 
			   ac_rdcnt[DST_IMG_WIDTH_LB2-1+2+1:0] == {1'b1, {(DST_IMG_WIDTH_LB2+2){1'b0}}}
			   && ac_rdcnt != 0 
			   && m_axis_tvalid & m_axis_tready;

	integer i, j, k;
	always @(posedge clk or negedge rst_n) begin: UPSP_WRITE
		if(~rst_n) begin
			outbuf_valid <= 2'h0;
			outbuf_writing <= 2'h0;
			upsp_bufsel <= 1'h0;
			upsp_wrtcnt <= {IMG_CNT_WIDTH{1'b0}};
			for(i = 0; i < 1; i++)
			for(j = 0; j < 3; j++)
			for(k = 0; k< DST_IMG_WIDTH; k++)
			outbuf[i][j][k] <= {AXIS_DATA_WIDTH{1'b0}};

		end else if(upsp_ac_wrt & ac_upsp_wready) begin
			if(~outbuf_writing[upsp_bufsel]) outbuf_writing[upsp_bufsel] <= 1'b1;
			if(outbuf_writing[~upsp_bufsel]) outbuf_writing[~upsp_bufsel] <= 1'b0;

			outbuf[upsp_bufsel][upsp_wrtcnt[3:2]][upsp_wrtcnt[1:0]] <= upsp_ac_wdata;
			upsp_wrtcnt <= upsp_wrtcnt + 1;

			// After writing 4 lines, set outbuf valid
			if(upsp_wrtcnt[DST_IMG_WIDTH_LB2-1+2:0] == {(DST_IMG_WIDTH_LB2+2){1'b1}}) begin
				upsp_bufsel <= ~upsp_bufsel;
				outbuf_valid[upsp_bufsel] <= 1'b1;
			end
		
		// After transfering 4 lines, clear outbuf valid
		end else if(outbuf_clear)
			outbuf_valid[~upsp_bufsel] <= 1'b0;
	end


	// Get the pixel number in a row to determine whether the data is ready 
	// for transfer or not
	reg [DST_IMG_WIDTH_LB2-1:0] upsp_wrtnum_inrow;
	reg [DST_IMG_WIDTH_LB2-1:0] ac_rdnum_inrow;
	always @(*) begin
		ac_rdnum_inrow = ac_rdcnt[DST_IMG_WIDTH_LB2-1:0];
		if(upsp_wrtcnt[3:2] == 2'b00)
			upsp_wrtnum_inrow = {upsp_wrtcnt[DST_IMG_WIDTH_LB2-1+2:4],upsp_wrtcnt[1:0]};
		else
			upsp_wrtnum_inrow = {upsp_wrtcnt[DST_IMG_WIDTH_LB2-1+2:4],2'b11};
	end
	wire already_written = outbuf_writing[upsp_bufsel] &&
						   (ac_rdnum_inrow < upsp_wrtnum_inrow);



	// Hard wired signals for axi-stream
	assign m_axis_tkeep  = 1'b1;
	assign m_axis_tstrb  = 1'b1;
	assign m_axis_tdest  = 1'b0;
	assign m_axis_user   = 1'b0;

	reg m_axis_wrten;
	always @(posedge clk or negedge rst_n) begin: AXIS_WRTEN
		if(~rst_n)
			m_axis_wrten <= 1'b1;

		else if(~m_axis_wrten) begin
			if(write_done) m_axis_wrten <= 1'b1;

		end else if(m_axis_tvalid & m_axis_tready)
			m_axis_wrten <= 1'b0;
		else
			m_axis_wrten <= 1'b1;
	end
	
	// Transfer data if possible
	wire last_one = ac_rdcnt[DST_IMG_WIDTH_LB2-1+2:0] == {(DST_IMG_WIDTH_LB2+2){1'b1}};

	always @(posedge clk or negedge rst_n) begin: AIXS_TRANS
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_rdcnt <= {IMG_CNT_WIDTH{1'b0}};
			m_axis_tdata <= {AXIS_DATA_WIDTH{1'b0}};
			m_axis_tlast <= 1'h0;
			m_axis_tvalid <= 1'h0;
			// End of automatics

		// If there is a valid outbuf, get data from it and send
		end else if(|outbuf_valid) begin
			if(m_axis_tvalid) begin
				if(m_axis_tready) begin
					m_axis_tdata  <= outbuf[~upsp_bufsel][ac_rdcnt[DST_IMG_WIDTH_LB2+1:DST_IMG_WIDTH_LB2]][ac_rdcnt[DST_IMG_WIDTH_LB2-1:0]];
					ac_rdcnt <= ac_rdcnt + 1;
					if(outbuf_clear)
						m_axis_tvalid <= 1'b0;

					m_axis_tlast <= last_one;
				end
			end else begin
				m_axis_tvalid <= 1'b1;
				m_axis_tdata  <= outbuf[~upsp_bufsel][ac_rdcnt[DST_IMG_WIDTH_LB2+1:DST_IMG_WIDTH_LB2]][ac_rdcnt[DST_IMG_WIDTH_LB2-1:0]];
				m_axis_tlast  <= last_one;
			end

		// No valid buffer, upsp is writing. But we can still transfer data
		// already written
		end else if(already_written) begin
			m_axis_tvalid <= 1'b1;
			m_axis_tdata  <= outbuf[upsp_bufsel][ac_rdcnt[DST_IMG_WIDTH_LB2+1:DST_IMG_WIDTH_LB2]][ac_rdcnt[DST_IMG_WIDTH_LB2-1:0]];
			if(m_axis_tvalid & m_axis_tready || ~(|ac_rdcnt))
				ac_rdcnt <= ac_rdcnt + 1;
			
			m_axis_tlast <= last_one;

		end else if(write_done) begin
			m_axis_tvalid <= 1'b0;
			ac_rdcnt <= {IMG_CNT_WIDTH{1'b0}};

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
		else if(UPSTR[0] & ~UPENDR[0] & ~startup & ~processing)
			startup <= 1'b1;
		else
			startup <= 1'b0;
	end

	


`endif

// SVA for the design features
`ifndef DISABLE_SV_ASSERTION



`endif

endmodule

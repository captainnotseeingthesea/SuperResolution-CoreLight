/*************************************************

 Copyright: NUDT_CoreLight

 File name: access_control.v

 Author: NUDT_CoreLight

 Date: 2021-03-27


 Description:

 Access control, contains stream_in to serve read requests from 
 Up-Sampling and transforms Up-Sampling write requests into AXI-Stream
 requests to DDR in PS side as the AXI-Stream master.
 **************************************************/

module access_control # (
		// AXI-Stream
		parameter AXISIN_DATA_WIDTH = 32,
		parameter AXISOUT_DATA_WIDTH = 32,

		parameter CRF_DATA_WIDTH = 32,
		parameter CRF_ADDR_WIDTH = 32,
		parameter UPSP_RDDATA_WIDTH = 32,
		parameter UPSP_WRTDATA_WIDTH = 32,

		parameter SRC_IMG_WIDTH  = 1920,
		parameter SRC_IMG_HEIGHT = 1080,
		parameter DST_IMG_WIDTH  = 4096,
		parameter DST_IMG_HEIGHT = 2160,

		parameter OUT_FIFO_DEPTH = 128
	) (/*AUTOARG*/
   // Outputs
   ac_crf_wrt, ac_crf_wdata, ac_crf_waddr, ac_crf_processing,
   ac_crf_axisi_tvalid, ac_crf_axisi_tready, ac_crf_axiso_tvalid,
   ac_crf_axiso_tready, ac_upsp_rvalid, ac_upsp_rdata, ac_upsp_wready,
   s_axis_tready, m_axis_tvalid, m_axis_tid, m_axis_tdata,
   m_axis_tkeep, m_axis_tstrb, m_axis_tlast, m_axis_tdest,
   m_axis_user,
   // Inputs
   clk, rst_n, crf_ac_UPSTART, crf_ac_UPEND, crf_ac_wbusy,
   upsp_ac_rready, upsp_ac_wvalid, upsp_ac_wdata, s_axis_tvalid,
   s_axis_tid, s_axis_tdata, s_axis_tstrb, s_axis_tkeep, s_axis_tlast,
   s_axis_tdest, s_axis_user, m_axis_tready
   );

	localparam AXISIN_STRB_WIDTH  = AXISIN_DATA_WIDTH/8;
	localparam AXISOUT_STRB_WIDTH = AXISOUT_DATA_WIDTH/8;
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
	output                      ac_crf_processing;
	output                      ac_crf_axisi_tvalid;
	output                      ac_crf_axisi_tready;
	output                      ac_crf_axiso_tvalid;
	output                      ac_crf_axiso_tready;


	// Interface with upsp
	input                           upsp_ac_rready;
	output                          ac_upsp_rvalid;
	output [UPSP_RDDATA_WIDTH-1:0]  ac_upsp_rdata;
	output                          ac_upsp_wready;
	input                           upsp_ac_wvalid;
	input  [UPSP_WRTDATA_WIDTH-1:0] upsp_ac_wdata;



	// Interface as AXI-Stream slave
	// input s_axis_aclk;
    // input s_axis_arstn;
	input                       s_axis_tvalid;	
	output                      s_axis_tready;
	input                       s_axis_tid;
	input [AXISIN_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tkeep;
	input                       s_axis_tlast;
	input                       s_axis_tdest;
	input                       s_axis_user;



	// Interface as AXI-Stream master
	// input s_axis_aclk;
    // input s_axis_arstn;
	output                       m_axis_tvalid;	
	input                        m_axis_tready;
	output                       m_axis_tid;
	output [AXISOUT_DATA_WIDTH-1:0] m_axis_tdata;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tkeep;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tstrb;
	output                       m_axis_tlast;
	output                       m_axis_tdest;
	output                       m_axis_user;


	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	reg [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	reg		ac_crf_wrt;
	reg [AXISOUT_STRB_WIDTH-1:0] m_axis_tkeep;
	reg		m_axis_tlast;
	reg [AXISOUT_STRB_WIDTH-1:0] m_axis_tstrb;
	reg		m_axis_tvalid;
	// End of automatics




	// Rename config registers and output UPSTART and UPEND
	wire UPSTART = crf_ac_UPSTART;
	wire UPEND   = crf_ac_UPEND;


	// Whether a upsampling is under processing or not
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
	wire last_one_remain;
	wire write_done = m_axis_tvalid & m_axis_tready & m_axis_tlast & last_one_remain;
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


	// axi-s handshake signals to crf
	wire ac_crf_axisi_tvalid = s_axis_tvalid;
	wire ac_crf_axisi_tready = s_axis_tready;
	wire ac_crf_axiso_tvalid = m_axis_tvalid;
	wire ac_crf_axiso_tready = m_axis_tready;
	wire ac_crf_processing   = processing;


	// Stream in to handle input axi-stream
	stream_in #(/*AUTOINSTPARAM*/
		    // Parameters
		    .AXISIN_DATA_WIDTH	(AXISIN_DATA_WIDTH),
		    .UPSP_RDDATA_WIDTH	(UPSP_RDDATA_WIDTH),
		    .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT))
	AAA_stream_in(
			  .s_axis_aclk	(clk),
			  .s_axis_arstn	(rst_n),
			  /*AUTOINST*/
		      // Outputs
		      .ac_upsp_rvalid	(ac_upsp_rvalid),
		      .ac_upsp_rdata	(ac_upsp_rdata[UPSP_RDDATA_WIDTH-1:0]),
		      .s_axis_tready	(s_axis_tready),
		      // Inputs
		      .upsp_ac_rready	(upsp_ac_rready),
		      .UPSTART		(UPSTART),
		      .UPEND		(UPEND),
		      .s_axis_tvalid	(s_axis_tvalid),
		      .s_axis_tid	(s_axis_tid),
		      .s_axis_tdata	(s_axis_tdata[AXISIN_DATA_WIDTH-1:0]),
		      .s_axis_tstrb	(s_axis_tstrb[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tkeep	(s_axis_tkeep[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tlast	(s_axis_tlast),
		      .s_axis_tdest	(s_axis_tdest),
		      .s_axis_user	(s_axis_user));



	/* We use a fifo as output buffer to hold the data from Up-Sampling.
	*/
	localparam pixnum_per_upspwrt = AXISOUT_DATA_WIDTH/(3*8);
	localparam FIFO_COUNT_WIDTH = $clog2(OUT_FIFO_DEPTH);

	// fifo read/write count
	reg [FIFO_COUNT_WIDTH:0]  ofifo_rd_count, ofifo_wrt_count;
	// fifo read/write pointer
	wire [FIFO_COUNT_WIDTH-1:0] ofifo_rd_ptr  = ofifo_rd_count[FIFO_COUNT_WIDTH-1:0]; 
	wire [FIFO_COUNT_WIDTH-1:0] ofifo_wrt_ptr = ofifo_wrt_count[FIFO_COUNT_WIDTH-1:0];
	// Empty and full signals
	wire ofifo_ptrsame = (ofifo_rd_ptr == ofifo_wrt_ptr)?1'b1:1'b0;
	wire ofifo_empty = ofifo_ptrsame & (ofifo_rd_count[FIFO_COUNT_WIDTH] ^~ ofifo_wrt_count[FIFO_COUNT_WIDTH]);
	wire ofifo_full  = ofifo_ptrsame & (ofifo_rd_count[FIFO_COUNT_WIDTH] ^  ofifo_wrt_count[FIFO_COUNT_WIDTH]);

	// Up-Sampling can write if fifo is not full
	wire ofifo_wrt = upsp_ac_wvalid & ac_upsp_wready;
	assign ac_upsp_wready = ~ofifo_full;

	// If fifo is not empty, and there is no transfer or the tranfer will complete, read from fifo.
	wire ofifo_rd = ~ofifo_empty & (~m_axis_tvalid | m_axis_tready);

    /*bram_subbank AUTO_TEMPLATE(
        .dout(m_axis_tdata),
        .clk(clk),
		.din(upsp_ac_wdata),
		.raddr(ofifo_rd_ptr),
        .waddr(ofifo_wrt_ptr),
        .cs(ofifo_rd|ofifo_wrt),
        .re(ofifo_rd),
        .we(ofifo_wrt),
    )*/
    bram_subbank #(
		   .DEPTH		(OUT_FIFO_DEPTH),
		   .DATA_WIDTH		(UPSP_WRTDATA_WIDTH),
		   .ADDR_WIDTH		(FIFO_COUNT_WIDTH))
    ofifo(/*AUTOINST*/
	  // Outputs
	  .dout				(m_axis_tdata),		 // Templated
	  // Inputs
	  .clk				(clk),			 // Templated
	  .din				(upsp_ac_wdata),	 // Templated
	  .raddr			(ofifo_rd_ptr),		 // Templated
	  .waddr			(ofifo_wrt_ptr),	 // Templated
	  .cs				(ofifo_rd|ofifo_wrt),	 // Templated
	  .re				(ofifo_rd),		 // Templated
	  .we				(ofifo_wrt));		 // Templated

	// Fifo count management
	always @(posedge clk or negedge rst_n) begin: OFIFO_MANAGE
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ofifo_rd_count <= {(1+(FIFO_COUNT_WIDTH)){1'b0}};
			ofifo_wrt_count <= {(1+(FIFO_COUNT_WIDTH)){1'b0}};
			// End of automatics
		end else begin
			if(ofifo_wrt & ~ofifo_full)
				ofifo_wrt_count <= ofifo_wrt_count + 1;
			if(ofifo_rd & ~ofifo_empty)
				ofifo_rd_count  <= ofifo_rd_count + 1;
		end

	end

	// Up_Sampling write count and output stream tranfer count.
	reg [IMG_CNT_WIDTH-1:0] upsp_wrtcnt;
	reg [IMG_CNT_WIDTH-1:0] ac_sendcnt;
	assign last_one_remain = (ac_sendcnt  == DST_IMG_HEIGHT*DST_IMG_WIDTH - 4)?1'b1:1'b0;

	always @(posedge clk or negedge rst_n) begin: HSK_COUNT
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_sendcnt <= {IMG_CNT_WIDTH{1'b0}};
			upsp_wrtcnt <= {IMG_CNT_WIDTH{1'b0}};
			// End of automatics
		end else if(write_done) begin
			ac_sendcnt <= {IMG_CNT_WIDTH{1'b0}};
			upsp_wrtcnt <= {IMG_CNT_WIDTH{1'b0}};
		end else begin
			if(upsp_ac_wvalid & ac_upsp_wready)	begin
				if(|upsp_wrtcnt == 1'b0)
					upsp_wrtcnt <= 2;
				else
					upsp_wrtcnt <= upsp_wrtcnt + pixnum_per_upspwrt;
			end

			if(m_axis_tvalid & m_axis_tready) begin
				if(|ac_sendcnt == 1'b0)
					ac_sendcnt <= 2;
				else
					ac_sendcnt <= ac_sendcnt + pixnum_per_upspwrt;
			end
		end
	end

	// Output tranfer valid depends on ofifo_rd. tlast should be asserted for every row
	wire last_of_row_remain = ((ac_sendcnt % DST_IMG_WIDTH) >= DST_IMG_WIDTH - 4);
	always @(posedge clk or negedge rst_n) begin: M_TVALID
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			m_axis_tlast <= 1'h0;
			m_axis_tvalid <= 1'h0;
			// End of automatics
		end else if(~m_axis_tvalid) begin
			if(ofifo_rd) begin
				m_axis_tvalid <= 1'b1;
				m_axis_tlast  <= last_of_row_remain;
			end else
				m_axis_tlast  <= 1'b0;
		end else begin
			if(m_axis_tready) begin
				m_axis_tvalid <= ofifo_rd?1'b1:1'b0;
				m_axis_tlast  <= ofifo_rd?last_of_row_remain:1'b0;
			end
		end
	end

	// Ignore first two and last two pixels
	always@(*) begin
		if(ac_sendcnt == 0) begin
			m_axis_tstrb = {{(2*3){1'b0}},{(AXISOUT_STRB_WIDTH-2*3){1'b1}}};
			m_axis_tkeep = {{(2*3){1'b0}},{(AXISOUT_STRB_WIDTH-2*3){1'b1}}};
		end else if(ac_sendcnt >= DST_IMG_WIDTH * DST_IMG_HEIGHT - 4) begin
			m_axis_tstrb = {{(AXISOUT_STRB_WIDTH-2*3){1'b1}}, {(2*3){1'b0}}};
			m_axis_tkeep = {{(AXISOUT_STRB_WIDTH-2*3){1'b1}}, {(2*3){1'b0}}};
		end else begin
			m_axis_tstrb = {AXISOUT_STRB_WIDTH{1'b1}};
			m_axis_tkeep = {AXISOUT_STRB_WIDTH{1'b1}};
		end
	end
	
	// Hard-wired signals
	assign m_axis_tid   = 1'b0;
	assign m_axis_tdest = 1'b0;
	assign m_axis_user  = 1'b0;


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

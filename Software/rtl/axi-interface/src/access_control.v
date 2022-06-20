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

		parameter OUT_FIFO_DEPTH = 32,

		parameter N_PARALLEL	 = 1
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
   ac_crf_UPINHSKCNT, upsp_ac_rready, upsp_ac_wvalid, upsp_ac_wdata,
   s_axis_tvalid, s_axis_tid, s_axis_tdata, s_axis_tstrb,
   s_axis_tkeep, s_axis_tlast, s_axis_tdest, s_axis_user,
   m_axis_tready
   );

	localparam AXISIN_STRB_WIDTH  = AXISIN_DATA_WIDTH/8;
	localparam AXISOUT_STRB_WIDTH = AXISOUT_DATA_WIDTH/8;
	localparam IMG_CNT_WIDTH      = $clog2(DST_IMG_WIDTH*DST_IMG_HEIGHT);
	localparam DST_IMG_WIDTH_LB2  = $clog2(DST_IMG_WIDTH);

	input clk;
	input rst_n;

	// Interface with config register file
	output                      ac_crf_wrt;
	output [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	output [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	input                       crf_ac_UPSTART;
	input                       crf_ac_UPEND  ;
	input                       crf_ac_wbusy;
	input [CRF_DATA_WIDTH-1:0]  ac_crf_UPINHSKCNT;
	output                      ac_crf_processing;
	output                      ac_crf_axisi_tvalid;
	output                      ac_crf_axisi_tready;
	output                      ac_crf_axiso_tvalid;
	output                      ac_crf_axiso_tready;


	// Interface with N upsp modules
	input  [N_PARALLEL-1:0]					  upsp_ac_rready;
	output [N_PARALLEL-1:0]         		  ac_upsp_rvalid;
	output [UPSP_RDDATA_WIDTH-1:0]            ac_upsp_rdata;
	output [N_PARALLEL-1:0]                   ac_upsp_wready;
	input  [N_PARALLEL-1:0]                   upsp_ac_wvalid;
	input  [N_PARALLEL*UPSP_RDDATA_WIDTH-1:0] upsp_ac_wdata;



	// Interface as AXI-Stream slave
	// input s_axis_aclk;
    // input s_axis_arstn;
	input                         s_axis_tvalid;	
	output                        s_axis_tready;
	input                         s_axis_tid;
	input [AXISIN_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tkeep;
	input                         s_axis_tlast;
	input                         s_axis_tdest;
	input                         s_axis_user;



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
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		obuf_empty;		// From obuf of upsp_outbuf.v
	wire		obuf_wready;		// From obuf of upsp_outbuf.v
	// End of automatics

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
	wire [CRF_DATA_WIDTH-1:0] UPINHSKCNT = ac_crf_UPINHSKCNT;


	// Whether IP is under processing or not. This signal will be asserted 
	// from UPSTART been assserted to send interrupt.
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

	// Operating time window for Up-Sampling module.
	reg time_window;
	always@(posedge clk or negedge rst_n) begin: TIME_WIN
		if(~rst_n)
			time_window <= 1'b0;
		else if(UPSTART & ~UPEND & ~processing & ~time_window)
			time_window <= 1'b1;
		else if(processing & write_done & UPSTART)
			time_window <= 1'b0;
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
		    .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT),
		    .N_PARALLEL		(N_PARALLEL))
	AAA_stream_in(
			  .s_axis_aclk	(clk),
			  .s_axis_arstn	(rst_n),
			  /*AUTOINST*/
		      // Outputs
		      .ac_upsp_rvalid	(ac_upsp_rvalid[N_PARALLEL-1:0]),
		      .ac_upsp_rdata	(ac_upsp_rdata[UPSP_RDDATA_WIDTH-1:0]),
		      .s_axis_tready	(s_axis_tready),
		      // Inputs
		      .upsp_ac_rready	(upsp_ac_rready[N_PARALLEL-1:0]),
		      .UPSTART		(UPSTART),
		      .UPEND		(UPEND),
		      .UPINHSKCNT	(UPINHSKCNT[CRF_DATA_WIDTH-1:0]),
		      .s_axis_tvalid	(s_axis_tvalid),
		      .s_axis_tid	(s_axis_tid),
		      .s_axis_tdata	(s_axis_tdata[AXISIN_DATA_WIDTH-1:0]),
		      .s_axis_tstrb	(s_axis_tstrb[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tkeep	(s_axis_tkeep[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tlast	(s_axis_tlast),
		      .s_axis_tdest	(s_axis_tdest),
		      .s_axis_user	(s_axis_user));







	output [N_PARALLEL-1:0]                   ac_upsp_wready;
	input  [N_PARALLEL-1:0]                   upsp_ac_wvalid;
	input  [N_PARALLEL*UPSP_RDDATA_WIDTH-1:0] upsp_ac_wdata;

	// One outbuf per element
	wire [N_PARALLEL-1:0] obuf_wvalid;
	wire [N_PARALLEL-1:0] obuf_rd;
	wire [N_PARALLEL-1:0] obuf_rdmask;
	wire [N_PARALLEL-1:0] obuf_wready;
	wire [N_PARALLEL-1:0] obuf_empty;


	// Read buf total count.
	reg [IMG_CNT_WIDTH-1:0]      ac_rdbuf_cnt;
	wire [DST_IMG_WIDTH_LB2-1:0] ac_rdbuf_cnt_inrow;
	assign ac_rdbuf_cnt_inrow = (ac_rdbuf_cnt % DST_IMG_WIDTH);
	assign last_one_remain = (ac_rdbuf_cnt  == DST_IMG_HEIGHT*DST_IMG_WIDTH)?1'b1:1'b0;

	always @(posedge clk or negedge rst_n) begin: BUFRD_COUNT
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_rdbuf_cnt <= {IMG_CNT_WIDTH{1'b0}};
			// End of automatics
		end else if(write_done) begin
			ac_rdbuf_cnt <= {IMG_CNT_WIDTH{1'b0}};
		end else if(|obuf_rd) begin
			ac_rdbuf_cnt <= ac_rdbuf_cnt + 4*N_PARALLEL;
		end
	end

	// Output tranfer valid depends on obuf_rd. tlast should be asserted for every row
	wire last_of_row_remain = (ac_rdbuf_cnt_inrow == DST_IMG_WIDTH - 4*N_PARALLEL);

	always @(posedge clk or negedge rst_n) begin: M_TVALID
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			m_axis_tlast <= 1'h0;
			m_axis_tvalid <= 1'h0;
			// End of automatics
		end else if(~m_axis_tvalid) begin
			if(|obuf_rd) begin
				m_axis_tvalid <= 1'b1;
				m_axis_tlast  <= last_of_row_remain;
			end else
				m_axis_tlast  <= 1'b0;
		end else begin
			if(m_axis_tready) begin
				m_axis_tvalid <= |obuf_rd?1'b1:1'b0;
				m_axis_tlast  <= |obuf_rd?last_of_row_remain:1'b0;
			end
		end
	end


	// Hard-wired signals
	assign m_axis_tid   = 1'b0;
	assign m_axis_tdest = 1'b0;
	assign m_axis_user  = 1'b0;

	// Throw away some pixels between element
	assign m_axis_tkeep = {AXISOUT_STRB_WIDTH{1'b1}};
	assign m_axis_tstrb = {AXISOUT_STRB_WIDTH{1'b1}};


	genvar j;
	generate
		if(N_PARALLEL = 1) begin
			// If there is only one upsp element, its outbuf depth could be very small, since
			// we don't need to save data from other sources when transfer data from one source,
			// there is only one source.

			// When only one source, all its data are desired, so
			assign m_axis_tkeep = {AXISOUT_STRB_WIDTH{1'b1}};
			assign m_axis_tstrb = {AXISOUT_STRB_WIDTH{1'b1}};

			// Only in time-window can Up-Sampling write to fifo.
			assign obuf_wvalid = upsp_ac_wvalid & time_window;
			assign ac_upsp_wready = obuf_wready;

			// If fifo is not empty, and there is no transfer or the tranfer will complete, read from fifo.
			assign obuf_rd = ~obuf_empty & (~m_axis_tvalid | m_axis_tready) & time_window;

		    upsp_outbuf #(
				  .DATA_WIDTH		(AXISOUT_DATA_WIDTH),
				  .DEPTH		(OUT_FIFO_DEPTH),
				  .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
				  .DST_IMG_WIDTH	(DST_IMG_WIDTH))
			obuf(/*AUTOINST*/
			     // Outputs
			     .buf_wready		(obuf_wready),		 // Templated
			     .buf_rdata			(m_axis_tdata),		 // Templated
			     .buf_empty			(obuf_empty),		 // Templated
			     // Inputs
			     .clk			(clk),			 // Templated
			     .rst_n			(rst_n&(~write_done)),	 // Templated
			     .buf_wvalid		(obuf_wvalid),		 // Templated
			     .buf_wdata			(upsp_ac_wdata),	 // Templated
			     .buf_rd			(obuf_rd));		 // Templated

			
		end else begin
			// When there are multiple elements, we need to throw some data at boundary
			begin

				assign m_axis_tkeep = {AXISOUT_STRB_WIDTH{1'b1}};
				assign m_axis_tstrb = {AXISOUT_STRB_WIDTH{1'b1}};

			end

			for(j = 0; j < N_PARALLEL; j=j+1) begin

				if(j == 0) begin
					localparam OBUF_DEPTH = (DST_IMG_WIDTH/N_PARALLEL);

					assign obuf_wvalid[j] = upsp_ac_wvalid[j] & time_window;
					assign ac_upsp_wready[j] = obuf_wready[j];

					// If fifo is not empty, and there is no transfer or the tranfer will complete, and this
					// buf contains the desired data, read from fifo.
					assign obuf_rd[j] = obuf_rdmask[j] & ~obuf_empty[j] & (~m_axis_tvalid | m_axis_tready) & time_window;

		    		upsp_outbuf #(
						  .DATA_WIDTH		(AXISOUT_DATA_WIDTH),
						  .DEPTH		(OUT_FIFO_DEPTH),
						  .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
						  .DST_IMG_WIDTH	(DST_IMG_WIDTH))
					obuf(/*AUTOINST*/
					     // Outputs
					     .buf_wready		(obuf_wready[j]),		 // Templated
					     .buf_rdata			(m_axis_tdata),		 // Templated
					     .buf_empty			(obuf_empty[j]),		 // Templated
					     // Inputs
					     .clk			(clk),			 // Templated
					     .rst_n			(rst_n&(~write_done)),	 // Templated
					     .buf_wvalid		(obuf_wvalid[j]),		 // Templated
					     .buf_wdata			(upsp_ac_wdata[j*UPSP_RDDATA_WIDTH+UPSP_RDDATA_WIDTH-1:j*UPSP_RDDATA_WIDTH]),	 // Templated
					     .buf_rd			(obuf_rd[j]));		 // Templated



				end else if(j == N_PARALLEL-1) begin

				end else begin

				end

			end
		end
	endgenerate

	// Output buffer

	// Only in time-window can Up-Sampling write to fifo.
	wire obuf_wvalid = upsp_ac_wvalid & time_window;
	assign ac_upsp_wready = obuf_wready;

	// If fifo is not empty, and there is no transfer or the tranfer will complete, read from fifo.
	wire obuf_rd = ~obuf_empty & (~m_axis_tvalid | m_axis_tready) & time_window;


    /*upsp_outbuf AUTO_TEMPLATE(
	     .buf_wready		(obuf_wready),
	     .buf_rdata			(m_axis_tdata),
	     .buf_empty			(obuf_empty),
	     .clk				(clk),
	     .rst_n				(rst_n&(~write_done)),
	     .buf_wvalid		(obuf_wvalid),
	     .buf_wdata			(upsp_ac_wdata),
	     .buf_rd			(obuf_rd),
    )*/

    upsp_outbuf #(
		  .DATA_WIDTH		(AXISOUT_DATA_WIDTH),
		  .DEPTH		(OUT_FIFO_DEPTH),
		  .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
		  .DST_IMG_WIDTH	(DST_IMG_WIDTH))
	obuf(/*AUTOINST*/
	     // Outputs
	     .buf_wready		(obuf_wready),		 // Templated
	     .buf_rdata			(m_axis_tdata),		 // Templated
	     .buf_empty			(obuf_empty),		 // Templated
	     // Inputs
	     .clk			(clk),			 // Templated
	     .rst_n			(rst_n&(~write_done)),	 // Templated
	     .buf_wvalid		(obuf_wvalid),		 // Templated
	     .buf_wdata			(upsp_ac_wdata),	 // Templated
	     .buf_rd			(obuf_rd));		 // Templated







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

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
   ac_crf_axiso_tready, ac_crf_ac2usm_tvalid, ac_crf_ac2usm_tready,
   ac_crf_ac2usm_tlast, ac_upsp_rvalid, ac_upsp_rdata, ac_upsp_wready,
   ac_upsp_reset, s_axis_tready, ac_m_axis_tvalid, ac_m_axis_tid,
   ac_m_axis_tdata, ac_m_axis_tkeep, ac_m_axis_tstrb, ac_m_axis_tlast,
   ac_m_axis_tdest, ac_m_axis_tuser,
   // Inputs
   clk, rst_n, crf_ac_UPSTART, crf_ac_UPEND, crf_ac_wbusy,
   upsp_ac_rready, upsp_ac_wvalid, upsp_ac_wdata, s_axis_tvalid,
   s_axis_tid, s_axis_tdata, s_axis_tstrb, s_axis_tkeep, s_axis_tlast,
   s_axis_tdest, s_axis_tuser, ac_m_axis_tready,
   finnalout_m_axis_tvalid, finnalout_m_axis_tready,
   finnalout_m_axis_tlast
   );

	localparam AXISIN_STRB_WIDTH  = AXISIN_DATA_WIDTH/8;
	localparam AXISOUT_STRB_WIDTH = AXISOUT_DATA_WIDTH/8;
	localparam SRC_BASE_BSIZE     = SRC_IMG_WIDTH/N_PARALLEL;
	localparam DST_BASE_BSIZE     = SRC_BASE_BSIZE*4;
	localparam N_UPSP_WRT         = UPSP_WRTDATA_WIDTH/24;

	function integer start_of_rd;
		input integer i;
		integer pos, j;
		integer data_size;
		begin
			data_size = N_UPSP_WRT*N_PARALLEL;
			if(i == 0)
				start_of_rd = 0;
			else begin
				pos = 0;
				for(j = 0; j < i; j=j+1) begin
					pos = pos + (SRC_BASE_BSIZE+3)*4 - 1;
					pos = pos / data_size;
					pos = (pos+1) * data_size;
				end
				start_of_rd = pos;
			end
		end
	endfunction

	function integer end_of_rd;
		input integer i;
		integer pos;
		integer data_size;
		begin
			data_size = N_UPSP_WRT*N_PARALLEL;
			pos = start_of_rd(i);

			if(i < N_PARALLEL-1) begin
				pos = pos + (SRC_BASE_BSIZE+3)*4 - 1;
			end else begin
				pos = pos + SRC_BASE_BSIZE*4 - 1;
			end

			pos = pos / data_size;
			pos = pos * data_size;
			end_of_rd = pos;
		end
	endfunction

	localparam DST_GEN_WIDTH      = (N_PARALLEL==1)?DST_IMG_WIDTH
									:(end_of_rd(N_PARALLEL-1)+N_UPSP_WRT*N_PARALLEL);

	localparam IMG_CNT_WIDTH      = $clog2(DST_GEN_WIDTH*DST_IMG_HEIGHT+1);
	localparam DST_IMG_WIDTH_LB2  = $clog2(DST_GEN_WIDTH+1);
	localparam DST_IMG_HEIGHT_LB2  = $clog2(DST_IMG_HEIGHT+1);

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
	output                      ac_crf_ac2usm_tvalid;
	output                      ac_crf_ac2usm_tready;
	output                      ac_crf_ac2usm_tlast;

	// Interface with N upsp modules
	input  [N_PARALLEL-1:0]					   upsp_ac_rready;
	output [N_PARALLEL-1:0]         		   ac_upsp_rvalid;
	output [UPSP_RDDATA_WIDTH-1:0]             ac_upsp_rdata;
	output [N_PARALLEL-1:0]                    ac_upsp_wready;
	input  [N_PARALLEL-1:0]                    upsp_ac_wvalid;
	input  [N_PARALLEL*UPSP_WRTDATA_WIDTH-1:0] upsp_ac_wdata;
	output                                     ac_upsp_reset;



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
	input                         s_axis_tuser;



	// Interface as AXI-Stream master
	// input s_axis_aclk;
    // input s_axis_arstn;
	output                          ac_m_axis_tvalid;	
	input                           ac_m_axis_tready;
	output                          ac_m_axis_tid;
	output [AXISOUT_DATA_WIDTH-1:0] ac_m_axis_tdata;
	output [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tkeep;
	output [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb;
	output                          ac_m_axis_tlast;
	output                          ac_m_axis_tdest;
	output                          ac_m_axis_tuser;


	// Interface with out stream transformer
    input finnalout_m_axis_tvalid;
	input finnalout_m_axis_tready;
	input finnalout_m_axis_tlast ;


	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	reg [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	reg		ac_crf_wrt;
	reg		ac_m_axis_tlast;
	reg		ac_m_axis_tvalid;
	reg		ac_upsp_reset;
	// End of automatics
	reg [AXISOUT_DATA_WIDTH-1:0] ac_m_axis_tdata;

	genvar j;


	// Rename config registers and output UPSTART and UPEND
	wire UPSTART = crf_ac_UPSTART;
	wire UPEND   = crf_ac_UPEND;


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
	reg [DST_IMG_HEIGHT_LB2-1:0] out_line_count;
	wire last_one_remain = (out_line_count  == DST_IMG_HEIGHT - 1)?1'b1:1'b0;
	wire write_done = finnalout_m_axis_tvalid & finnalout_m_axis_tready & finnalout_m_axis_tlast & last_one_remain;
	
	always@(posedge clk or negedge rst_n) begin: UPSP_RESET
		if(~rst_n) 
			ac_upsp_reset <= 1'b0;
		else
			ac_upsp_reset <= write_done;
	end

	always@(posedge clk or negedge rst_n) begin: OLINE_COUNT
		if(~rst_n | write_done)
			out_line_count <= 1'b0;
		else if(finnalout_m_axis_tvalid & finnalout_m_axis_tready & finnalout_m_axis_tlast)
			out_line_count <= out_line_count + 1;
	end

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
	wire ac_crf_axiso_tvalid = finnalout_m_axis_tvalid;
	wire ac_crf_axiso_tready = finnalout_m_axis_tready;
	wire ac_crf_processing   = processing;
	wire ac_crf_ac2usm_tvalid = ac_m_axis_tvalid;
	wire ac_crf_ac2usm_tready = ac_m_axis_tready;
	wire ac_crf_ac2usm_tlast  = ac_m_axis_tlast;



	// Stream in to handle input axi-stream
	stream_in #(/*AUTOINSTPARAM*/
		    // Parameters
		    .AXISIN_DATA_WIDTH	(AXISIN_DATA_WIDTH),
		    .UPSP_RDDATA_WIDTH	(UPSP_RDDATA_WIDTH),
		    .SRC_IMG_WIDTH	(SRC_IMG_WIDTH),
		    .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT),
		    .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
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
		      .s_axis_tvalid	(s_axis_tvalid),
		      .s_axis_tid	(s_axis_tid),
		      .s_axis_tdata	(s_axis_tdata[AXISIN_DATA_WIDTH-1:0]),
		      .s_axis_tstrb	(s_axis_tstrb[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tkeep	(s_axis_tkeep[AXISIN_STRB_WIDTH-1:0]),
		      .s_axis_tlast	(s_axis_tlast),
		      .s_axis_tdest	(s_axis_tdest),
		      .s_axis_tuser	(s_axis_tuser));


	// One outbuf per element

	wire [N_PARALLEL-1:0] obuf_wvalid;
	wire [N_PARALLEL-1:0] obuf_rd;
	wire [N_PARALLEL-1:0] obuf_rdmask;
	wire [N_PARALLEL-1:0] obuf_wready;
	wire [N_PARALLEL-1:0] obuf_empty;
	wire [AXISOUT_DATA_WIDTH*N_PARALLEL-1:0] obuf_odata;


	// Read buf total count.
	reg [IMG_CNT_WIDTH-1:0]   ac_rdbuf_cnt;
	reg [DST_IMG_WIDTH_LB2:0] ac_rdbuf_cnt_inrow;
	// assign ac_rdbuf_cnt_inrow = (ac_rdbuf_cnt % DST_GEN_WIDTH);

	always @(posedge clk or negedge rst_n) begin: BUFRD_COUNT
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_rdbuf_cnt <= {IMG_CNT_WIDTH{1'b0}};
			ac_rdbuf_cnt_inrow <= {(1+(DST_IMG_WIDTH_LB2)){1'b0}};
			// End of automatics
		end else if(write_done) begin
			ac_rdbuf_cnt <= {IMG_CNT_WIDTH{1'b0}};
			ac_rdbuf_cnt_inrow <= {DST_IMG_WIDTH_LB2{1'b0}};
		end else if(|obuf_rd) begin
			ac_rdbuf_cnt <= ac_rdbuf_cnt + N_UPSP_WRT*N_PARALLEL;
			
			if(ac_rdbuf_cnt_inrow + N_UPSP_WRT*N_PARALLEL >= DST_GEN_WIDTH)
				ac_rdbuf_cnt_inrow <= ac_rdbuf_cnt_inrow + N_UPSP_WRT*N_PARALLEL - DST_GEN_WIDTH;
			else
				ac_rdbuf_cnt_inrow <= ac_rdbuf_cnt_inrow + N_UPSP_WRT*N_PARALLEL;
		end
	end

	// Output tranfer valid depends on obuf_rd. tlast should be asserted for every row
	wire last_of_row_remain = (ac_rdbuf_cnt_inrow == DST_GEN_WIDTH - N_UPSP_WRT*N_PARALLEL);

	always @(posedge clk or negedge rst_n) begin: M_TVALID
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_m_axis_tlast <= 1'h0;
			ac_m_axis_tvalid <= 1'h0;
			// End of automatics
		end else if(~ac_m_axis_tvalid) begin
			if(|obuf_rd) begin
				ac_m_axis_tvalid <= 1'b1;
				ac_m_axis_tlast  <= last_of_row_remain;
			end else
				ac_m_axis_tlast  <= 1'b0;
		end else begin
			if(ac_m_axis_tready) begin
				ac_m_axis_tvalid <= |obuf_rd?1'b1:1'b0;
				ac_m_axis_tlast  <= |obuf_rd?last_of_row_remain:1'b0;
			end
		end
	end


	// Hard-wired signals
	assign ac_m_axis_tid   = 1'b0;
	assign ac_m_axis_tdest = 1'b0;
	assign ac_m_axis_tuser  = 1'b0;


	generate
		if(N_PARALLEL == 1) begin: ONE_ELE
			// If there is only one upsp element, its outbuf depth could be very small, since
			// we don't need to save data from other sources when transfer data from one source,
			// there is only one source.

			// When only one source, all its data are desired, so
			wire [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tkeep_tmp = {AXISOUT_STRB_WIDTH{1'b1}};
			wire [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb_tmp = {AXISOUT_STRB_WIDTH{1'b1}};
			assign ac_m_axis_tkeep = ac_m_axis_tkeep_tmp;
			assign ac_m_axis_tstrb = ac_m_axis_tstrb_tmp;

			always@(*) begin: ONE_ELE_TDATA
				integer i;
				for(i = 0; i < AXISOUT_STRB_WIDTH/3; i=i+1) begin
					ac_m_axis_tdata[i*24+:24] = obuf_odata[((AXISOUT_STRB_WIDTH/3-i)*24-1)-:24];
				end
			end

			// Only in time-window can Up-Sampling write to fifo.
			assign obuf_wvalid = upsp_ac_wvalid & time_window;
			assign ac_upsp_wready = obuf_wready;

			// If fifo is not empty, and there is no transfer or the tranfer will complete, read from fifo.
			assign obuf_rd = ~obuf_empty & (~ac_m_axis_tvalid | ac_m_axis_tready) & time_window;

		    upsp_outbuf #(
				  .DATA_WIDTH		(AXISOUT_DATA_WIDTH),
				  .DEPTH		(OUT_FIFO_DEPTH),
				  .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
				  .DST_IMG_WIDTH	(DST_IMG_WIDTH))
			obuf(
			     // Outputs
			     .buf_wready		(obuf_wready),
			     .buf_rdata			(obuf_odata),
			     .buf_empty			(obuf_empty),
			     // Inputs
			     .clk			(clk),
			     .rst_n			(rst_n&(~write_done)),
			     .buf_wvalid		(obuf_wvalid),
			     .buf_wdata			(upsp_ac_wdata),
			     .buf_rd			(obuf_rd));

			
		end else begin:MULTI_ELE
			// When there are multiple elements, we need to throw some data at boundary
			reg [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tkeep_tmp;
			reg [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb_tmp;
			assign ac_m_axis_tkeep = ac_m_axis_tkeep_tmp;
			assign ac_m_axis_tstrb = ac_m_axis_tstrb_tmp;

			// Select output data from one of the buf
			reg  [N_PARALLEL-1:0] obuf_rd_r;
			always@(posedge clk or negedge rst_n) begin
				if(~rst_n)
					obuf_rd_r <= {N_PARALLEL{1'b0}};
				else if(~ac_m_axis_tvalid | ac_m_axis_tready) begin
						obuf_rd_r <= obuf_rd;
				end
			end

			reg [AXISOUT_DATA_WIDTH-1:0] axis_tdata_tmp;
			always@(*) begin: MULTIELE_TDATA
				integer i;
				axis_tdata_tmp = {AXISOUT_DATA_WIDTH{1'b0}};
				for(i = 0; i < N_PARALLEL; i=i+1) begin
					if(obuf_rd_r[i] == 1)
						axis_tdata_tmp = obuf_odata[i*AXISOUT_DATA_WIDTH+:AXISOUT_DATA_WIDTH];
				end
				for(i = 0; i < AXISOUT_STRB_WIDTH/3; i=i+1) begin
					ac_m_axis_tdata[i*24+:24] = axis_tdata_tmp[((AXISOUT_STRB_WIDTH/3-i)*24-1)-:24];
				end
			end
			

			reg [AXISOUT_STRB_WIDTH-1:0] keep[N_PARALLEL-1:0];
			reg [AXISOUT_STRB_WIDTH-1:0] strb[N_PARALLEL-1:0];

			for(j = 0; j < N_PARALLEL; j=j+1) begin:OBUF_PER_ELE
				
				localparam SRC_BSIZE = (j==N_PARALLEL-1)?SRC_BASE_BSIZE:SRC_BASE_BSIZE + 3;
				localparam DST_BSIZE = SRC_BSIZE * 4;
				// Start and End position of this block, when pixels are arranged as N_PARALLEL*N_UPSP_WRT
				// aligned.
				localparam START = start_of_rd(j);
				localparam END = end_of_rd(j);
				// If the last 6 pixels of a block-line only locate at the last transfer or not.
				localparam CORSS_BOUNDARY = ((START + DST_BSIZE - 6) >= END)?0:1;
				// The number of the last valid pixel in block-line.
				localparam N_LAST_VALID = (j == N_PARALLEL - 1)?(START + DST_BSIZE - 1 - END) + 1
										  :CORSS_BOUNDARY?(START + DST_BSIZE - 6 - 1 - (END - N_PARALLEL*N_UPSP_WRT)) + 1
										  :(START + DST_BSIZE - 6 - 1 - END) + 1;

				assign obuf_wvalid[j] = upsp_ac_wvalid[j] & time_window;
				assign ac_upsp_wready[j] = obuf_wready[j];

				// If fifo is not empty, and there is no transfer or the tranfer will complete, and this
				// buf contains the desired data, read from fifo.
				assign obuf_rdmask [j] = (ac_rdbuf_cnt_inrow >= START) && (ac_rdbuf_cnt_inrow <= END);
				assign obuf_rd[j] = obuf_rdmask[j] & ~obuf_empty[j] & (~ac_m_axis_tvalid | ac_m_axis_tready) & time_window;

		    	ac_outbuf #(
        			  .UPSP_WRTDATA_WIDTH (UPSP_WRTDATA_WIDTH),
        			  .DST_IMG_WIDTH      (DST_BSIZE),
        			  .DST_IMG_HEIGHT     (DST_IMG_HEIGHT),
        			  .N_PARALLEL	      (N_PARALLEL))
				obuf(
				     // Outputs
				     .buf_wready		(obuf_wready[j]),
				     .buf_rdata			(obuf_odata[j*AXISOUT_DATA_WIDTH+:AXISOUT_DATA_WIDTH]),
				     .buf_empty			(obuf_empty[j]),
				     // Inputs
				     .clk			(clk),
				     .rst_n			(rst_n&(~write_done)),
				     .buf_wvalid		(obuf_wvalid[j]),
				     .buf_wdata			(upsp_ac_wdata[j*UPSP_WRTDATA_WIDTH+:UPSP_WRTDATA_WIDTH]),
				     .buf_rd			(obuf_rd[j]));

				// Generate corresponding keep and strb signals
				if(j == 0) begin

					always@(posedge clk or negedge rst_n) begin
						if(~rst_n) begin
							keep[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
							strb[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
						end else if(~ac_m_axis_tvalid | ac_m_axis_tready) begin
							if(ac_rdbuf_cnt_inrow == END - N_PARALLEL*N_UPSP_WRT) begin
								keep[j] <= (CORSS_BOUNDARY)?{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}}
											:{AXISOUT_STRB_WIDTH{1'b1}};
								strb[j] <= (CORSS_BOUNDARY)?{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}}
											:{AXISOUT_STRB_WIDTH{1'b1}};
							end else if(ac_rdbuf_cnt_inrow == END) begin
								keep[j] <= (CORSS_BOUNDARY)?{AXISOUT_STRB_WIDTH{1'b0}}
											:{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
								strb[j] <= (CORSS_BOUNDARY)?{AXISOUT_STRB_WIDTH{1'b0}}
											:{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
							end else begin
								keep[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
								strb[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
							end
						end
					end

				end else if(j == N_PARALLEL - 1) begin

					always@(posedge clk or negedge rst_n) begin
						if(~rst_n) begin
							keep[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
							strb[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
						end else if(~ac_m_axis_tvalid | ac_m_axis_tready) begin
							if(ac_rdbuf_cnt_inrow == START) begin
								keep[j] <= {{(AXISOUT_STRB_WIDTH-18){1'b1}}, 18'b0};
								strb[j] <= {{(AXISOUT_STRB_WIDTH-18){1'b1}}, 18'b0};
							end else if(ac_rdbuf_cnt_inrow == END) begin
								keep[j] <= {{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
								strb[j] <= {{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
							end else begin
								keep[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
								strb[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
							end
						end
					end

				end else begin

					always@(posedge clk or negedge rst_n) begin
						if(~rst_n) begin
							keep[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
							strb[j] <= {AXISOUT_STRB_WIDTH{1'b0}};
						end else if(~ac_m_axis_tvalid | ac_m_axis_tready) begin
							if(ac_rdbuf_cnt_inrow == START) begin
								keep[j] <= {{(AXISOUT_STRB_WIDTH-18){1'b1}}, 18'b0};
								strb[j] <= {{(AXISOUT_STRB_WIDTH-18){1'b1}}, 18'b0};
							end else if(ac_rdbuf_cnt_inrow == END - N_PARALLEL*N_UPSP_WRT) begin
								keep[j] <= (CORSS_BOUNDARY)?{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}}
											:{AXISOUT_STRB_WIDTH{1'b1}};
								strb[j] <= (CORSS_BOUNDARY)?{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}}
											:{AXISOUT_STRB_WIDTH{1'b1}};
							end else if(ac_rdbuf_cnt_inrow == END) begin
								keep[j] <= (CORSS_BOUNDARY)?{AXISOUT_STRB_WIDTH{1'b0}}
											:{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
								strb[j] <= (CORSS_BOUNDARY)?{AXISOUT_STRB_WIDTH{1'b0}}
											:{{(AXISOUT_STRB_WIDTH-3*N_LAST_VALID){1'b0}}, {3*N_LAST_VALID{1'b1}}};
							end else begin
								keep[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
								strb[j] <= {AXISOUT_STRB_WIDTH{1'b1}};
							end
						end
					end

				end

			end

			always@(*) begin: MULTIELE_TKEEP
				integer i;
				ac_m_axis_tkeep_tmp = {AXISOUT_STRB_WIDTH{1'b1}};
				ac_m_axis_tstrb_tmp = {AXISOUT_STRB_WIDTH{1'b1}};
				for(i = 0; i < N_PARALLEL; i=i+1) begin
					if(obuf_rd_r[i] == 1'b1) begin
						ac_m_axis_tkeep_tmp = keep[i];
						ac_m_axis_tstrb_tmp = strb[i];
					end
				end
			end

		end
	endgenerate


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

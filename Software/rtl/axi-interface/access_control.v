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
		// AXI-Full
		parameter AXI_DATA_WIDTH = 32,
		parameter AXI_ADDR_WIDTH = 32,
		parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH/8,
		// AXI-Stream
		parameter AXIS_DATA_WIDTH = 32,
		parameter AXIS_STRB_WIDTH = AXIS_DATA_WIDTH/8,

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
   ac_upsp_rvalid, ac_upsp_rdata, m_axi_awvalid, m_axi_awid,
   m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst,
   m_axi_awlock, m_axi_awcache, m_axi_awprot, m_axi_awqos,
   m_axi_wvalid, m_axi_wid, m_axi_wdata, m_axi_wstrb, m_axi_wlast,
   m_axi_bready, m_axi_arvalid, m_axi_arid, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache,
   m_axi_arprot, m_axi_arqos, m_axi_rready, s_axis_tready,
   // Inputs
   clk, rst_n, crf_ac_UPSTR, crf_ac_UPENDR, crf_ac_UPSRCAR,
   crf_ac_UPDSTAR, crf_ac_wbusy, upsp_ac_rd, upsp_ac_wrt,
   upsp_ac_wdata, m_axi_awready, m_axi_wready, m_axi_bvalid,
   m_axi_bid, m_axi_bresp, m_axi_arready, m_axi_rvalid, m_axi_rid,
   m_axi_rdata, m_axi_rresp, m_axi_rlast, s_axis_tvalid, s_axis_tid,
   s_axis_tdata, s_axis_tstrb, s_axis_tkeep, s_axis_tlast,
   s_axis_tdest, s_axis_user
   );

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
	input                        upsp_ac_wrt;
	input  [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;


	// Interface as an AXI4-Full master
	// Common
	// input m_axi_aclk;
	// input m_rst_n;

	// Write address channel
	output                      m_axi_awvalid;
	input                       m_axi_awready;
	output                      m_axi_awid;
	output [AXI_ADDR_WIDTH-1:0] m_axi_awaddr;
	output [7:0]                m_axi_awlen;
	output [2:0]                m_axi_awsize;
	output [1:0]                m_axi_awburst;
	output [1:0]                m_axi_awlock;
	output [3:0]                m_axi_awcache;
	output [2:0]                m_axi_awprot;
	output [3:0]                m_axi_awqos;
//  output                      m_axi_awregion;
//  output                      m_axi_awuser;

	// Write data channel
	output                      m_axi_wvalid;
	input                       m_axi_wready;
	output                      m_axi_wid;
	output [AXI_DATA_WIDTH-1:0] m_axi_wdata;
	output [AXI_STRB_WIDTH-1:0] m_axi_wstrb;
	output                      m_axi_wlast;
//  output                      m_axi_wuser;

	// Write response channel
	input       m_axi_bvalid;
	output      m_axi_bready;
	input       m_axi_bid;
	input [1:0] m_axi_bresp;
//  input       m_axi_buser;

	// Read address channel
	output                      m_axi_arvalid;
	input                       m_axi_arready;
	output                      m_axi_arid;
	output [AXI_ADDR_WIDTH-1:0] m_axi_araddr;
	output [7:0]                m_axi_arlen;
	output [2:0]                m_axi_arsize;
	output [1:0]                m_axi_arburst;
	output [1:0]                m_axi_arlock;
	output [3:0]                m_axi_arcache;
	output [2:0]                m_axi_arprot;
	output [3:0]                m_axi_arqos;
//  output                      m_axi_arregion;
//  output                      m_axi_aruser;

	// Read data channel
	input                      m_axi_rvalid;
	output                     m_axi_rready;
	input                      m_axi_rid;
	input [AXI_DATA_WIDTH-1:0] m_axi_rdata;
	input [1:0]                m_axi_rresp;
	input                      m_axi_rlast;
//  input                      m_axi_ruser;


	// Interface for AXI-Stream slave
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


	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	reg [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	reg		ac_crf_wrt;
	reg		m_axi_awvalid;
	reg		m_axi_bready;
	reg [AXI_DATA_WIDTH-1:0] m_axi_wdata;
	reg		m_axi_wlast;
	reg		m_axi_wvalid;
	// End of automatics




	// Rename config registers and output UPSTR and UPENDR
	assign                    UPSTR   = crf_ac_UPSTR;
	assign                    UPENDR  = crf_ac_UPENDR;
	wire [CRF_DATA_WIDTH-1:0] UPSRCAR = crf_ac_UPSRCAR;
	wire [CRF_DATA_WIDTH-1:0] UPDSTAR = crf_ac_UPDSTAR;

	// A start impulse
	reg processing;
	always@(posedge clk or negedge rst_n) begin: PROCESSING
		if(~rst_n)
			processing <= 1'b0;
		else if(UPSTR[0] & ~UPENDR[0] & ~processing)
			processing <= 1'b1;
		else if(~UPSTR[0] & UPENDR[0] & processing)
			processing <= 1'b0;
	end

	reg startup;
	always@(posedge clk or negedge rst_n) begin: START_UP
		if(~rst_n)
			startup <= 1'b0;
		else if(UPSTR[0] & ~UPENDR[0] & ~startup & ~processing)
			startup <= 1'b1;
		else
			startup <= 1'b0;
	end


	// Stream in
	stream_in #(.AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
				.AXIS_STRB_WIDTH(AXIS_STRB_WIDTH),
				.UPSP_DATA_WIDTH(UPSP_DATA_WIDTH))
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






	// Some AXI signals will be hard wired
	localparam AXI_WRTBURST_LEN  = 3-1; //  transfers inside a transaction
	localparam AXI_WRTBURST_SIZE = 2;   // 2^2=4 bytes, 32 bits data

	// Write address channel
	assign m_axi_awid    = 1'b0;           // No multi-transaction
	assign m_axi_awlen   = AXI_WRTBURST_LEN;
	assign m_axi_awsize  = AXI_WRTBURST_SIZE;
	assign m_axi_awburst = 2'b01;          // Always use INCR type
	assign m_axi_awlock  = 2'b00;
	assign m_axi_awcache = 4'b0010;        //Normal Non-cacheable Non-bufferable memory
	assign m_axi_awprot  = 3'h0;           //
	assign m_axi_awqos   = 4'h0;

	// Write data channel
	assign m_axi_wid     = 1'b0;           // No multi-transaction
	assign m_axi_wstrb   = {AXI_STRB_WIDTH{1'b1}}; // Write all data

	// Read address and read signals all hard wired into zero
    assign m_axi_arvalid = 0;
    assign m_axi_arid    = 0;
    assign m_axi_araddr  = 0;
    assign m_axi_arlen   = 0;
    assign m_axi_arsize  = 0;
    assign m_axi_arburst = 0;
    assign m_axi_arlock  = 0;
    assign m_axi_arcache = 0;
    assign m_axi_arprot  = 0;
    assign m_axi_arqos   = 0;
    assign m_axi_rready  = 0;



	/*  Write buffers: Up-Sampling module writes into buffers, then AC
	 writes these data back to DDR. Using multiple buffers for non-blocking.
	 Because every template will compute 16 pixels as 4 4-pixel group,
	 and address increases only within a group, so we allocate one buffer
	 for each group. Every group will be sent to DDR as an independent
	 transaction.
	 */
	reg [24*4-1:0] wrtbuf[0:3];
	reg [3:0]      wrtbuf_valid;
	// ID indicates which buffer will be used by upsp, in a round-robin fashion.
	reg [1:0] upsp_wrtid;
	// Count indicates which pixel inside a 4-pixel buffer
	reg [1:0] upsp_wrtcount;

	// Up-Sampling module write buffer
	integer i;
	always@(posedge clk or negedge rst_n) begin: UPSP_WRITE_PROC
		if(~rst_n) begin
			upsp_wrtcount <= 2'h0;
			upsp_wrtid <= 2'h0;
			for(i = 0; i < 3; i++) begin
				wrtbuf[i] <= 96'b0;
			end
		end else if(upsp_ac_wrt) begin
			upsp_wrtcount <= upsp_wrtcount + 1;

			case(upsp_wrtcount)
				2'b00:   wrtbuf[upsp_wrtid][23:0 ] <= upsp_ac_wdata;
				2'b01:   wrtbuf[upsp_wrtid][47:24] <= upsp_ac_wdata;
				2'b10:   wrtbuf[upsp_wrtid][71:48] <= upsp_ac_wdata;
				default: wrtbuf[upsp_wrtid][95:72] <= upsp_ac_wdata;
			endcase

			// A whole buffer will be ready at next clock, advance the
			// upsp_wrtid to next
			if(upsp_wrtcount == 2'b11) begin
				upsp_wrtcount <= 2'b0;
				upsp_wrtid <= upsp_wrtid + 1;
				if(upsp_wrtid == 2'b11) upsp_wrtid <= 2'b0;
			end
		end
	end

	/*  AXI write address and write signals. When there is a valid 
	 buffer, issue an write transaction. The buffer size is 3*4=12 
	 bytes, an transaction with len=3 and size=32bit is suitable.
	 */
	wire wrtbuf_nonempty = | wrtbuf_valid;
	reg [1:0] ac_rdid;
	reg [1:0] ac_rdcount;

	// wrtbuf_valid: When upsp writes a whole buffer, set its valid bit.
	// When ac read a whole buffer, clear its valid bit.
	always@(posedge clk or negedge rst_n) begin: WRTBUF_VALID_PROC
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			wrtbuf_valid <= 4'h0;
			// End of automatics
		end else begin
			if(upsp_ac_wrt && upsp_wrtcount == 2'b11)
				wrtbuf_valid[upsp_wrtid] <= 1'b1;

			if(m_axi_wvalid & m_axi_wready && ac_rdcount == 2'b11)
				wrtbuf_valid[ac_rdid] <= 1'b0;
		end
	end

	// AC can issue a write transaction only when there is no pending write 
	// transaction
	reg ac_wrten;
	always@(posedge clk or negedge rst_n) begin: WAIT_IDLE_WRT
		if(~rst_n)
			ac_wrten <= 1'h1;
		else if(~ac_wrten) begin
			// Wait for the response of the pending write transaction
			if(m_axi_bvalid & m_axi_bready) ac_wrten <= 1'b1;
		// Deasserted when issue a transaction
		end else if(wrtbuf_nonempty & ~m_axi_awvalid & ac_wrten)
			ac_wrten <= 1'b0;
	end

	// awvalid will be asserted only for one clock, because we always
	// use the INCR burst type.
	always@(posedge clk or negedge rst_n) begin: AWREADY
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			m_axi_awvalid <= 1'h0;
			// End of automatics
		end else if(m_axi_awvalid) begin
			if(m_axi_awready) m_axi_awvalid <= 1'b0;
		end else if(wrtbuf_nonempty & ~m_axi_awvalid & ac_wrten)
			m_axi_awvalid <= 1'b1;
		else
			m_axi_awvalid <= 1'b0;
	end

	// The write address of burst steps across the target image.
	// Every time a write transaction initiated, advance the address.
	localparam KERNEL_ADDR_ROWSTEP = (UPSP_DATA_WIDTH/8) * 4;
	localparam KERNEL_ADDR_COLSTEP = 3*DST_IMG_WIDTH*(UPSP_DATA_WIDTH/8);
	localparam KERNEL_ADDR_MARGIN  = (UPSP_DATA_WIDTH/8) * 4;
	localparam KERNEL_ADDR_EDGE    = (DST_IMG_WIDTH-4)*(UPSP_DATA_WIDTH/8);
	localparam WRTBURST_ADDR_STEP  = DST_IMG_WIDTH*(UPSP_DATA_WIDTH/8);

	reg [AXI_ADDR_WIDTH-1:0] kernel_start_addr;
	reg [AXI_ADDR_WIDTH-1:0] wrtburst_start_addr;
	always@(posedge ac_wrten or negedge rst_n) begin: KADDR_PROC
		if(~rst_n) begin
			kernel_start_addr <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(startup)
			kernel_start_addr <= UPDSTAR;
		else if(m_axi_awvalid & m_axi_awready && ac_rdid == 2'b11) begin
			if(kernel_start_addr == KERNEL_ADDR_EDGE)
				kernel_start_addr <= kernel_start_addr + KERNEL_ADDR_MARGIN + KERNEL_ADDR_COLSTEP;
			else
				kernel_start_addr <= kernel_start_addr + KERNEL_ADDR_ROWSTEP;
		end
	end

	always@(posedge ac_wrten or negedge rst_n) begin: WADDR_PROC
		if(~rst_n) begin
			wrtburst_start_addr <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(m_axi_awvalid) begin
			if(m_axi_awready)
				wrtburst_start_addr <= wrtburst_start_addr + WRTBURST_ADDR_STEP;
		end else if(wrtbuf_nonempty & ~m_axi_awvalid & ac_wrten)
			wrtburst_start_addr <= kernel_start_addr;
	end

	assign m_axi_awaddr = wrtburst_start_addr;

	// wvalid: Send data as soon as there is a valid buffer.
	always@(posedge clk or negedge rst_n) begin: WVALID
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			ac_rdcount <= 2'h0;
			ac_rdid <= 2'h0;
			m_axi_wvalid <= 1'h0;
			// End of automatics
		end else if(m_axi_wvalid) begin
			if(m_axi_wready) begin
				ac_rdcount <= ac_rdcount + 1;
				if(ac_rdcount == 2'b11) begin
					m_axi_wvalid <= 1'b0;
					ac_rdcount  <= 2'b0;
					ac_rdid     <= ac_rdid + 1;
					if(ac_rdid == 2'b11) ac_rdid <= 2'b00;
				end
			end
		end else if(wrtbuf_nonempty & ~m_axi_wvalid & ac_wrten) begin
			m_axi_wvalid <= 1'b1;
			ac_rdcount  <= ac_rdcount + 1;
		end else begin
			m_axi_wvalid <= 1'b0;
			ac_rdcount  <= 2'b0;
		end
	end

	// wdata: Pick 4 bytes from buffer at the beginning of a new write
	// transaction or when a transfer succeed
	always@(posedge clk or negedge rst_n) begin: WDATA
		if(~rst_n) begin
			m_axi_wdata <= {AXI_DATA_WIDTH{1'b0}};
		end else if(
				wrtbuf_nonempty & ~m_axi_wvalid & ac_wrten |
				m_axi_wvalid & m_axi_wready
			) begin

			case(ac_rdcount)
				2'b00:   m_axi_wdata <= wrtbuf[ac_rdid][31:0] ;
				2'b01:   m_axi_wdata <= wrtbuf[ac_rdid][63:32];
				default: m_axi_wdata <= wrtbuf[ac_rdid][95:64];
			endcase

		end
	end

	// wlast: Assert for last write transfer
	always@(posedge clk or negedge rst_n) begin: WLAST
		if(~rst_n)
			m_axi_wlast <= 1'h0;
		else if(~m_axi_wlast) begin
			if(m_axi_wvalid & m_axi_wready && ac_rdcount == 2'b11)
				m_axi_wlast <= 1'b0;
		end
		else if(m_axi_wvalid & m_axi_wready && ac_rdcount == 2'b10)
			m_axi_wlast <= 1'b1;
		else
			m_axi_wlast <= 1'b0;
	end

	// bready: Assert bready for one cycle when bvalid is asserted
	always@(posedge clk or negedge rst_n) begin: BREADY
		if(~rst_n) begin
			m_axi_bready <= 1'h0;
		end else if(m_axi_bvalid & ~m_axi_bready)
			m_axi_bready <= 1'b1;
		else
			m_axi_bready <= 1'b0;
	end




// Additional code for easy debugging
`ifndef DISABLE_DEBUG_CODE



`endif

// SVA for the design features
`ifndef DISABLE_SV_ASSERTION

	property ps_write_empty_buffer;
		@(posedge clk) disable iff(~rst_n)
		upsp_ac_wrt |-> ~wrtbuf_valid[upsp_wrtid];
	endproperty

	property ac_read_valid_buffer;
		@(posedge clk) disable iff(~rst_n)
		m_axi_wvalid |-> wrtbuf_valid[ac_rdid];
	endproperty

	property ac_rdcount_lt_three;
		@(posedge clk) disable iff(~rst_n)
		ac_rdcount < 2'b11;
	endproperty

	property upsampling_start_correct;
		@(posedge clk) disable iff(~rst_n)
		startup |=>
		wrtbuf_valid == 3'b0 &&
		kernel_start_addr == UPDSTAR
		;
	endproperty

	assert property(ps_write_empty_buffer);
	assert property(ac_read_valid_buffer);
	assert property(ac_rdcount_lt_three);
	assert property(upsampling_start_correct);

`endif

endmodule

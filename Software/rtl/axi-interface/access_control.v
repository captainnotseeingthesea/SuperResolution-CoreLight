/*************************************************

 Copyright: NUDT_CoreLight

 File name: access_control.v

 Author: NUDT_CoreLight

 Date: 2021-03-27


 Description:

 Access control, receives read/write requests from PL side and
 transforms them into AXI4 requests to DDR in PS side.

 **************************************************/

module access_control # (
		parameter AXI_DATA_WIDTH = 32,
		parameter AXI_ADDR_WIDTH = 32,
		parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH/8,

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
		m_axi_arprot, m_axi_arqos, m_axi_rready,
		// Inputs
		crf_ac_UPSTR, crf_ac_UPENDR, crf_ac_UPSRCAR, crf_ac_UPDSTAR,
		crf_ac_wbusy, upsp_ac_rd, upsp_ac_wrt, upsp_ac_wdata, upsp_ac_start,
		m_axi_aclk, m_axi_rstn, m_axi_awready, m_axi_wready, m_axi_bvalid,
		m_axi_bid, m_axi_bresp, m_axi_arready, m_axi_rvalid, m_axi_rid,
		m_axi_rdata, m_axi_rresp, m_axi_rlast
	);

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
	output  [CRF_DATA_WIDTH-1:0]  UPSTR;
	output  [CRF_DATA_WIDTH-1:0]  UPENDR;
	input                         upsp_ac_rd;
	output                        ac_upsp_rvalid;
	output [UPSP_DATA_WIDTH-1:0]  ac_upsp_rdata;
	input                         upsp_ac_wrt;
	input   [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;
	input                         upsp_ac_start;

	// Interface as an AXI4-Full master
	// Common
	input m_axi_aclk;
	input m_axi_rstn;

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



	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	reg [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	reg     ac_crf_wrt;
	reg     ac_upsp_rvalid;
	reg [1:0]   m_axi_arburst;
	reg     m_axi_arvalid;
	reg     m_axi_awvalid;
	reg     m_axi_bready;
	reg     m_axi_rready;
	reg [AXI_DATA_WIDTH-1:0] m_axi_wdata;
	reg     m_axi_wlast;
	reg     m_axi_wvalid;
	// End of automatics



	wire clk;
	wire rst_n    = ~upsp_ac_start;
	wire axi_clk;
	wire axi_rstn = m_axi_rstn & ~upsp_ac_start;



	// Rename config registers and output UPSTR and UPENDR
	assign                    UPSTR   = crf_ac_UPSTR;
	assign                    UPENDR  = crf_ac_UPENDR;
	wire [CRF_DATA_WIDTH-1:0] UPSRCAR = crf_ac_UPSRCAR;
	wire [CRF_DATA_WIDTH-1:0] UPDSTAR = crf_ac_UPDSTAR;


	// Some AXI signals will be hard wired
	localparam AXI_WRTBURST_LEN  = 3-1; //  transfers inside a transaction
	localparam AXI_WRTBURST_SIZE = 2;   // 2^2=4 bytes, 32 bits data
	localparam AXI_RDBURST_LEN  = 16-1; // 16 transfers inside a transaction
	localparam AXI_RDBURST_SIZE = 2;   // 2^2=4 bytes, 32 bits data

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

	// Read address channel
	assign m_axi_arid    = 1'b0;           // No multi-transaction
	assign m_axi_arlen   = AXI_RDBURST_LEN;
	assign m_axi_arsize  = AXI_RDBURST_SIZE;
	assign m_axi_awburst = 2'b01;          // Always use INCR type
	assign m_axi_arlock  = 2'b00;
	assign m_axi_arcache = 4'b0010;        // Normal Non-cacheable Non-bufferable memory
	assign m_axi_arprot  = 3'h0;
	assign m_axi_arqos   = 4'h0;



	/*  Write buffers: Up-Sampling module writes into buffers, then AC
	 write these data back to DDR. Use multiple buffers for non-blocking.
	 Because every template will compute 16 pixels as 4 4-pixel group,
	 and address increases only within a group, so we allocate one buffer
	 for each group. Every group will be sent to DDR as an independent
	 transaction.
	 */
	reg [24*4-1:0] wrtbuf[0:2];
	reg [3:0]      wrtbuf_valid;
	// ID indicates which buffer will be used, in an round-robin fashion.
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

			// A whole buffer will be ready at next clock advance the
			// upsp_wrtid to next
			if(upsp_wrtcount == 2'b11) begin
				upsp_wrtcount <= 2'b0;
				upsp_wrtid <= upsp_wrtid + 1;
				if(upsp_wrtid == 2'b10) upsp_wrtid <= 2'b0;
			end
		end
	end

	/*  Control for AXI write address and write signals.
	 When there is a valid buffer data, issue an write transaction.
	 The buffer size is 3*4=12 bytes, an transaction with len=3
	 and size=32-bit is suitable.
	 */
	wire wrtbuf_nonempty = | wrtbuf_valid;
	reg [1:0] ac_rdid;
	reg [1:0] ac_rdcount;

	// wrtbuf_valid: When upsp writes a whole buffer, set its valid bit.
	// When ac read a whole buffer, clear its valid bit.
	always@(posedge axi_clk or negedge axi_rstn) begin: WRTBUF_VALID_PROC
		if(~axi_rstn) begin
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

	// If there is a pending write transaction, wait.
	reg ac_wrten;
	always@(posedge axi_clk or negedge axi_rstn) begin: WAIT_IDLE_WRT
		if(~axi_rstn)
			ac_wrten <= 1'h1;
		else if(~ac_wrten) begin
			// Wait for the response of the pending write transaction
			if(m_axi_bvalid & m_axi_bready & m_axi_bresp) ac_wrten <= 1'b1;
		end else if(wrtbuf_nonempty & ~m_axi_awvalid & ~ac_wrten)
			ac_wrten <= 1'b0;
	end

	// awvalid will be asserted only for one clock, because we always
	// use the INCR burst type.
	always@(posedge axi_clk or negedge axi_rstn) begin: AWREADY
		if(~axi_rstn) begin
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

	// The write addresses of bursts step across the target image.
	// Every time a write transaction initiated, advance the address.
	localparam KERNEL_ADDR_STEP = (UPSP_DATA_WIDTH/8) * 4;
	localparam WRTBURST_ADDR_STEP = DST_IMG_WIDTH*3;

	reg [AXI_ADDR_WIDTH-1:0] kernel_start_addr;
	reg [AXI_ADDR_WIDTH-1:0] wrtburst_start_addr;
	always@(posedge ac_wrten or negedge axi_rstn) begin: KADDR_PROC
		if(~axi_rstn) begin
			kernel_start_addr <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(upsp_ac_start)
			kernel_start_addr <= UPDSTAR;
		else if(m_axi_awvalid & m_axi_awready && ac_rdid == 2'b10) begin
			kernel_start_addr <= kernel_start_addr + KERNEL_ADDR_STEP;
		end
	end

	always@(posedge ac_wrten or negedge axi_rstn) begin: WADDR_PROC
		if(~axi_rstn) begin
			wrtburst_start_addr <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(m_axi_awvalid) begin
			if(m_axi_awready)
				wrtburst_start_addr <= wrtburst_start_addr + WRTBURST_ADDR_STEP;
		end else if(wrtbuf_nonempty & ~m_axi_awvalid & ac_wrten)
			wrtburst_start_addr <= kernel_start_addr;
	end

	assign m_axi_awaddr = wrtburst_start_addr;

	// wvalid: Send data as soon as there is a valid buffer.
	always@(posedge axi_clk or negedge axi_rstn) begin: WVALID
		if(~axi_rstn) begin
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
					if(ac_rdid == 2'b10) ac_rdid <= 2'b00;
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
	always@(posedge axi_clk or negedge axi_rstn) begin: WDATA
		if(~axi_rstn) begin
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

		end else if(m_axi_wvalid & m_axi_wready && ac_rdcount == 2'b11)
			m_axi_wdata <= {AXI_DATA_WIDTH{1'b0}};
	end

	// wlast: Assert for last write transfer
	always@(posedge axi_clk or negedge axi_rstn) begin: WLAST
		if(~axi_rstn) begin
			m_axi_wlast <= 1'h0;
		end else if(m_axi_wvalid & m_axi_wready && ac_rdcount == 2'b11)
			m_axi_wlast <= 1'b1;
		else
			m_axi_wlast <= 1'b0;
	end

	// bready: Assert bready for one cycle when bvalid is asserted
	always@(posedge axi_clk or negedge axi_rstn) begin: BREADY
		if(~axi_rstn) begin
			m_axi_bready <= 1'h0;
		end else if(m_axi_bvalid & ~m_axi_bready)
			m_axi_bready <= 1'b1;
		else
			m_axi_bready <= 1'b0;
	end



	/*  Read buffer: AccessControl read pixels from DDR and save them into
	 read buffer. If read buffer is not empty, Up-Sampling module can read
	 pixels. The size of read buffer is 128B, AccessControl writes 4B each
	 time, Up-Sampling module reads 3B each time.
	 */
	reg [7:0] rdbuf[0:127];
	// read/write count
	reg [7:0] rdbuf_rdcount, rdbuf_wrtcount;
	// read/write pointer
	wire [6:0] rdbuf_rdp  = rdbuf_rdcount[6:0];
	wire [6:0] rdbuf_wrtp = rdbuf_wrtcount[6:0];
	// Empty and full signals
	wire rdbuf_empty = (rdbuf_rdcount==rdbuf_wrtcount)?1'b1:1'b0;
	wire rdbuf_full  = (rdbuf_rdcount[7]!=rdbuf_wrtcount[7]) && (rdbuf_rdp == rdbuf_wrtp);

	// Read/Write enable and data
	wire rdbuf_ren = upsp_ac_rd;
	wire rdbuf_wen = m_axi_rvalid & m_axi_rready;
	wire [31:0] rdbuf_in = m_axi_rdata;
	reg  [23:0] rdbuf_out;

	// Read buffer acts like a synchronous fifo.
	always@(posedge axi_clk or negedge axi_rstn) begin: RDBUF_PROC
		if(~axi_rstn) begin
			rdbuf_out <= 24'h0;
			rdbuf_rdcount <= 8'h0;
			rdbuf_wrtcount <= 8'h0;
			for(i = 0; i < 128; i++) begin
				rdbuf[i] <= 8'b0;
			end
		end else if(upsp_ac_start) begin
			rdbuf_rdcount <= 8'h0;
			rdbuf_wrtcount <= 8'h0;
		end else if(rdbuf_ren & ~rdbuf_empty) begin
			rdbuf_rdcount <= rdbuf_rdcount + 3;
			rdbuf_out <= {rdbuf[rdbuf_rdp+2], rdbuf[rdbuf_rdp+1], rdbuf[rdbuf_rdp]};

		end else if(rdbuf_wen & ~rdbuf_full) begin
			rdbuf_wrtcount <= rdbuf_wrtcount + 4;
			{rdbuf[rdbuf_wrtp+3], rdbuf[rdbuf_wrtp+2], rdbuf[rdbuf_wrtp+1], rdbuf[rdbuf_wrtp]} <= rdbuf_in;
		end
	end

	assign ac_upsp_rdata = rdbuf_out;
	always@(posedge axi_clk or negedge axi_rstn) begin: RVALID
		if(~axi_rstn) begin
			ac_upsp_rvalid <= 1'h0;
		end else if(rdbuf_ren & ~rdbuf_empty)
			ac_upsp_rvalid <= 1'b1;
		else
			ac_upsp_rvalid <= 1'b0;
	end

	// Read address management
	localparam RDBURST_ADDR_STEP = (AXI_RDBURST_LEN + 1)*3;

	reg [AXI_ADDR_WIDTH-1:0] rdburst_start_addr;
	always@(posedge ac_wrten or negedge axi_rstn) begin: RADDR_PROC
		if(~axi_rstn) begin
			kernel_start_addr <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(upsp_ac_start)
			rdburst_start_addr <= UPSRCAR;
		else if(m_axi_arvalid & m_axi_arready)
			rdburst_start_addr <= rdburst_start_addr + RDBURST_ADDR_STEP;
	end
	assign m_axi_araddr = rdburst_start_addr;

	// Source pixel count management
	localparam TOTAL_SRCNUM  = SRC_IMG_HEIGHT*SRC_IMG_WIDTH*3;
	localparam SRC_READ_STEP = (AXI_RDBURST_LEN + 1)*4;

	reg [AXI_ADDR_WIDTH-1:0] srccount;
	always@(posedge ac_wrten or negedge axi_rstn) begin: SRC_COUNT_PROC
		if(~axi_rstn) begin
			srccount <= {AXI_ADDR_WIDTH{1'b0}};
		end else if(upsp_ac_start)
			srccount <= {AXI_ADDR_WIDTH{1'b0}};
		else if(m_axi_arvalid & m_axi_arready)
			srccount <= srccount + RDBURST_ADDR_STEP;
	end
	wire more_pixel = (srccount >= TOTAL_SRCNUM)?1'b0:1'b1;


	// arvalid: If there is at least a half empty space in read buffer and
	// some pixels still remain, issue a read transaction. The unsigned difference
	// of (rdbuf_wrtp - rdbuf_rdp) is always the number of occupied bytes.
	wire [7:0] rdbuf_remain = 8'd128 - (rdbuf_wrtp - rdbuf_rdp);

	wire rdbuf_revrdy = ~rdbuf_full & rdbuf_remain[6] | rdbuf_remain[7];

	reg axi_rden;
	always@(posedge axi_clk or negedge axi_rstn) begin: WAIT_IDLE_RD
		if(~axi_rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			axi_rden <= 1'h0;
		// End of automatics
		end else if(axi_rden) begin
			// Waiting for pending read transaction to finish
			if(m_axi_rvalid & m_axi_rready & m_axi_rlast)
				axi_rden <= 0;
		end else if(rdbuf_revrdy & more_pixel)
			axi_rden <= 1'b1;
		else
			axi_rden <= 1'b0;
	end

	// arvalid: Asserted only for one cycle
	always@(posedge axi_clk or negedge axi_rstn) begin: ARVALID
		if(~axi_rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			m_axi_arvalid <= 1'h0;
		// End of automatics
		end else if(m_axi_arvalid) begin
			// Wait for arready
			if(m_axi_arready) m_axi_arvalid <= 1'b1;
		end else if(axi_rden & ~m_axi_arvalid)
			m_axi_arvalid <= 1'b1;
		else
			m_axi_arvalid <= 1'b0;
	end

	// rready: Asserted until last read response
	always@(posedge axi_clk or negedge axi_rstn) begin: RREADY
		if(~axi_rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			m_axi_rready <= 1'h0;
		// End of automatics
		end else if(m_axi_rready) begin
			if(m_axi_rvalid & m_axi_rvalid & m_axi_rlast)
				m_axi_rready <= 1'b0;
		end else if(m_axi_rvalid)
			m_axi_rready <= 1'b0;
	end


`ifndef DISABLE_SV_ASSERTION
	property ps_write_empty_buffer;
		@(posedge axi_clk) disable iff(~axi_rstn);
		upsp_ac_wrt |-> ~wrtbuf_valid[upsp_wrtid];
	endproperty

	property ac_read_valid_buffer;
		@(posedge axi_clk) disable iff(~axi_rstn);
		m_axi_wvalid |-> wrtbuf_valid[ac_rdid];
	endproperty

	property upsp_wrtid_lt_three;
		@(posedge axi_clk) disable iff(~axi_rstn);
		upsp_wrtid < 2'b11;
	endproperty

	property ac_rdid_lt_three;
		@(posedge axi_clk) disable iff(~axi_rstn);
		ac_rdid < 2'b11;
	endproperty

	property ac_rdcount_lt_three;
		@(posedge axi_clk) disable iff(~axi_rstn);
		ac_rdcount < 2'b11;
	endproperty

	property upsampling_start_idle;
		@(posedge axi_clk) disable iff(~axi_rstn);
		upsp_ac_start |=>
		wrtbuf_valid == 3'b0 &&
		kernel_start_addr == UPDSTAR &&
		rdburst_start_addr == UPSRCAR &&
		srccount == 0 &&
		rdbuf_empty;
	endproperty

	always_comb begin
		assert (ps_write_empty_buffer);
		assert (ac_read_valid_buffer);
		assert (upsp_wrtid_lt_three);
		assert (ac_rdid_lt_three);
		assert (ac_rdcount_lt_three);
	end
	
	assert (upsampling_start_idle);
`endif

endmodule

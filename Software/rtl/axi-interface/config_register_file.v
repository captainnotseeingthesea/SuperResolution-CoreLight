/*************************************************

 Copyright: NUDT_CoreLight

 File name: config_register_file.v

 Author: NUDT_CoreLight

 Date: 2021-03-24


 Description:

 Configuration registers. Accessed by PS side via the AXI4-Lite
 interface, while simple write/busy mechanism for PL side.

 **************************************************/

module config_register_file # (
		parameter AXI_DATA_WIDTH = 32,
		parameter AXI_ADDR_WIDTH = 32,
		parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH/8,
		parameter CRF_DATA_WIDTH = 32,
		parameter CRF_ADDR_WIDTH = 32
	) (/*AUTOARG*/
		// Outputs
		s_axi_awready, s_axi_wready, s_axi_bvalid, s_axi_bresp,
		s_axi_arready, s_axi_rvalid, s_axi_rdata, s_axi_rresp,
		interrupt_updone, crf_ac_UPSTR, crf_ac_UPENDR, crf_ac_UPSRCAR,
		crf_ac_UPDSTAR, crf_ac_wbusy,
		// Inputs
		s_axi_aclk, s_axi_rstn, s_axi_awvalid, s_axi_awaddr, s_axi_awprot,
		s_axi_wvalid, s_axi_wdata, s_axi_wstrb, s_axi_bready,
		s_axi_arvalid, s_axi_araddr, s_axi_arprot, s_axi_rready,
		ac_crf_wrt, ac_crf_waddr, ac_crf_wdata
	);

	parameter RESP_OKAY = 2'b00;


	// Common
	input s_axi_aclk;
	input s_axi_rstn;

	// Write address channel
	input                      s_axi_awvalid;
	output                     s_axi_awready;
	input [AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
	input [2:0]                s_axi_awprot;

	// Write data channel
	input                      s_axi_wvalid;
	output                     s_axi_wready;
	input [AXI_DATA_WIDTH-1:0] s_axi_wdata;
	input [AXI_STRB_WIDTH-1:0] s_axi_wstrb;

	// Write response channel
	output                 s_axi_bvalid;
	input                  s_axi_bready;
	output                 s_axi_bresp;

	// Read address channel
	input                      s_axi_arvalid;
	output                     s_axi_arready;
	input [AXI_ADDR_WIDTH-1:0] s_axi_araddr;
	input [2:0]                s_axi_arprot;

	// Read data channel
	output                      s_axi_rvalid;
	input                       s_axi_rready;
	output [AXI_DATA_WIDTH-1:0] s_axi_rdata;
	output [1:0]                s_axi_rresp;

	// Output for interrupt
	output interrupt_updone;

	// Interface with PL side (access control)
	input                       ac_crf_wrt;
	input  [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;
	input  [CRF_DATA_WIDTH-1:0] ac_crf_wdata;
	output [CRF_DATA_WIDTH-1:0] crf_ac_UPSTR;
	output [CRF_DATA_WIDTH-1:0] crf_ac_UPENDR;
	output [CRF_DATA_WIDTH-1:0] crf_ac_UPSRCAR;
	output [CRF_DATA_WIDTH-1:0] crf_ac_UPDSTAR;
	output                      crf_ac_wbusy;

	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg     crf_ac_wbusy;
	reg     s_axi_arready;
	reg     s_axi_awready;
	reg     s_axi_bvalid;
	reg [AXI_DATA_WIDTH-1:0] s_axi_rdata;
	reg     s_axi_rvalid;
	reg     s_axi_wready;
	// End of automatics


	// Up-Sampling start and end register.
	reg [CRF_DATA_WIDTH-1:0] UPSTR;
	reg [CRF_DATA_WIDTH-1:0] UPENDR;
	// Source and destination address.
	reg [CRF_DATA_WIDTH-1:0] UPSRCAR;
	reg [CRF_DATA_WIDTH-1:0] UPDSTAR;


	// Below are logics for different channels
	wire clk  = s_axi_aclk;
	wire rstn = s_axi_rstn;

	// Directly output registers.
	assign crf_ac_UPDSTAR   = UPDSTAR;
	assign crf_ac_UPENDR    = UPENDR ;
	assign crf_ac_UPSRCAR   = UPSRCAR;
	assign crf_ac_UPSTR     = UPSTR  ;

	// Output the LSB of UPENR as an interrupt to PS.
	assign interrupt_updone = UPENDR[0];


	// Write address channel
	// Only one of write requests can be processed, PL side has a higher priority.
	// When processing PS write, set busy signal to PL side. Wait for both awvalid
	// and wvalid before setting awready to simplify write process.
	// If there is a pending response, wait until that response finishes.
	always@(posedge clk or negedge rstn) begin: AWREADY
		if(~rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			crf_ac_wbusy <= 1'h0;
			s_axi_awready <= 1'h0;
		// End of automatics
		end else if(ac_crf_wrt) begin
			s_axi_awready <= 1'b0;
			crf_ac_wbusy <= 1'b0;
		end else if(s_axi_awvalid & s_axi_wvalid & ~s_axi_bvalid & ~s_axi_awready
				& ~ac_crf_wrt) begin
			s_axi_awready <= 1'b1;
			crf_ac_wbusy <= 1'b1;
		end else begin
			crf_ac_wbusy <= 1'h0;
			s_axi_awready <= 1'h0;
		end
	end


	// Write data channel
	// When awvalid and awready are both 1s, the data will be write into register.
	// Only one of PS and PL can write at the same time.
	always@(posedge clk or negedge rstn) begin: WREADY
		if(~rstn)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_wready <= 1'h0;
		// End of automatics
		else if(s_axi_awvalid & s_axi_wvalid & ~s_axi_bvalid & s_axi_wready
				& ~ac_crf_wrt)
			s_axi_wready <= 1'b1;
		else
			s_axi_wready <= 1'h0;
	end

	// Write enable signals for PL side and PS side.
	// We simply ignore the write strobe, just writ all data received.
	wire ac_wren   = ac_crf_wrt & ~crf_ac_wbusy;
	wire axi_wren  = s_axi_awvalid & s_axi_awready & s_axi_wvalid & s_axi_wready;
	wire axi_waddr = s_axi_awaddr[CRF_ADDR_WIDTH-1:0];

	always@(posedge clk or negedge rstn) begin: WRITE_PROC
		if(~rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			UPDSTAR <= {CRF_DATA_WIDTH{1'b0}};
			UPENDR <= {CRF_DATA_WIDTH{1'b0}};
			UPSRCAR <= {CRF_DATA_WIDTH{1'b0}};
			UPSTR <= {CRF_DATA_WIDTH{1'b0}};
		// End of automatics
		end else if(ac_wren) begin
			case(ac_crf_waddr)
				0: UPSTR   <= ac_crf_wdata;
				1: UPENDR  <= ac_crf_wdata;
				2: UPSRCAR <= ac_crf_wdata;
				3: UPDSTAR <= ac_crf_wdata;
				default: begin
					UPSTR   <= UPSTR  ;
					UPENDR  <= UPENDR ;
					UPSRCAR <= UPSRCAR;
					UPDSTAR <= UPDSTAR;
				end
			endcase
		end else if(axi_wren) begin
			case(axi_waddr)
				0: UPSTR   <= s_axi_wdata;
				1: UPENDR  <= s_axi_wdata;
				2: UPSRCAR <= s_axi_wdata;
				3: UPDSTAR <= s_axi_wdata;
				default: begin
					UPSTR   <= UPSTR  ;
					UPENDR  <= UPENDR ;
					UPSRCAR <= UPSRCAR;
					UPDSTAR <= UPDSTAR;
				end
			endcase
		end
	end


	// Write response channel
	// Send a response after a successful write. The default value of bresp
	// is OKAY, just hard-wiring it.
	assign s_axi_bresp = RESP_OKAY;

	always@(posedge clk or negedge rstn) begin: BVALID
		if(~rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_bvalid <= 1'h0;
		// End of automatics

		end else if(s_axi_bvalid) begin
			// Wait for bready
			if(s_axi_bready) s_axi_bvalid <= 1'b0;
		end else if(axi_wren)
			s_axi_bvalid <= 1'b1;
		else
			s_axi_bvalid <= 1'b0;
	end


	// Read address channel
	// PS can read at any time, we simply ignore the coherence.
	always@(posedge clk or negedge rstn) begin: ARREADY
		if(~rstn)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_arready <= 1'h0;
		// End of automatics
		else if(s_axi_arvalid & ~s_axi_arready)
			s_axi_arready <= 1'b1;
		else
			s_axi_arready <= 1'b0;
	end


	// Read data channel
	wire   axi_read    = s_axi_arvalid & s_axi_arready;
	wire   axi_raddr   = s_axi_araddr[CRF_ADDR_WIDTH-1:0];
	assign s_axi_rresp = RESP_OKAY;

	always@(posedge clk or negedge rstn) begin: READ_PROC
		if(~rstn) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
			s_axi_rvalid <= 1'h0;
		// End of automatics

		end else if(s_axi_rvalid) begin
			// Wait for rready
			if(s_axi_rready) begin
				s_axi_rvalid <= 1'b0;
				s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
			end
		end else if(axi_read) begin
			s_axi_rvalid <= 1'b1;
			case(axi_raddr)
				0: s_axi_rdata <= UPSTR  ;
				1: s_axi_rdata <= UPENDR ;
				2: s_axi_rdata <= UPSRCAR;
				3: s_axi_rdata <= UPDSTAR;
				default: s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
			endcase
		end else begin
			s_axi_rvalid <= 1'b0;
			s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
		end
	end

endmodule
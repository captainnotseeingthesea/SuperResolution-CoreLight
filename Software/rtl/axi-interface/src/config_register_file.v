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
		parameter CRF_DATA_WIDTH = 32,
		parameter CRF_ADDR_WIDTH = 32
	) (/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bvalid, s_axi_bresp,
   s_axi_arready, s_axi_rvalid, s_axi_rdata, s_axi_rresp,
   interrupt_updone, crf_ac_UPSTART, crf_ac_UPEND, crf_ac_wbusy,
   // Inputs
   clk, rst_n, s_axi_awvalid, s_axi_awaddr, s_axi_awprot,
   s_axi_wvalid, s_axi_wdata, s_axi_wstrb, s_axi_bready,
   s_axi_arvalid, s_axi_araddr, s_axi_arprot, s_axi_rready,
   ac_crf_wrt, ac_crf_waddr, ac_crf_wdata, ac_crf_axisi_tvalid,
   ac_crf_axisi_tready, ac_crf_axiso_tvalid, ac_crf_axiso_tready,
   ac_crf_processing
   );

	localparam RESP_OKAY = 2'b00;
	localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;

	// Common
	input clk;
	input rst_n;

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
	output                      crf_ac_UPSTART;
	output                      crf_ac_UPEND;
	output                      crf_ac_wbusy;

	// Input and output axi-stream handshake signals
	input                       ac_crf_axisi_tvalid;
	input                       ac_crf_axisi_tready;
	input                       ac_crf_axiso_tvalid;
	input                       ac_crf_axiso_tready;
	input                       ac_crf_processing;



	/*AUTOWIRE*/

	/*AUTOREG*/
	// Beginning of automatic regs (for this module's undeclared outputs)
	reg		s_axi_arready;
	reg		s_axi_awready;
	reg		s_axi_bvalid;
	reg [AXI_DATA_WIDTH-1:0] s_axi_rdata;
	reg		s_axi_rvalid;
	reg		s_axi_wready;
	// End of automatics


	// Up-Sampling status register.
	reg [CRF_DATA_WIDTH-1:0] UPSTAT;

	// Directly output registers.
	assign crf_ac_UPSTART = UPSTAT[0];
	assign crf_ac_UPEND  = UPSTAT[1];

	// Output the LSB of UPENR as an interrupt to PS.
	assign interrupt_updone = UPSTAT[1];


/*************************** Performance monitoring registers ***************************/
	reg [CRF_DATA_WIDTH-1:0] UPINHSKCNT;
	reg [CRF_DATA_WIDTH-1:0] UPINNRDYCNT;
	reg [CRF_DATA_WIDTH-1:0] UPOUTHSKCNT;
	reg [CRF_DATA_WIDTH-1:0] UPOUTNRDYCNT;

	wire stream_i_hsked = ac_crf_axisi_tvalid & ac_crf_axisi_tready;
	wire stream_i_nrdy  = ac_crf_axisi_tvalid & ~ac_crf_axisi_tready;
	wire stream_o_hsked = ac_crf_axiso_tvalid & ac_crf_axiso_tready;
	wire stream_o_nrdy  = ac_crf_axiso_tvalid & ~ac_crf_axiso_tready;

	always@(posedge clk or negedge rst_n) begin: STREAMIN_HSKED
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			UPINHSKCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPINNRDYCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPOUTHSKCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPOUTNRDYCNT <= {CRF_DATA_WIDTH{1'b0}};
			// End of automatics
		end else if(ac_crf_processing) begin
			if(crf_ac_UPSTART & stream_i_hsked) UPINHSKCNT  <= UPINHSKCNT + 1;
			if(crf_ac_UPSTART & stream_i_nrdy)  UPINNRDYCNT <= UPINNRDYCNT + 1;
			if(crf_ac_UPSTART & stream_o_hsked) UPOUTHSKCNT <= UPOUTHSKCNT + 1;
			if(crf_ac_UPSTART & stream_o_nrdy) UPOUTNRDYCNT <= UPOUTNRDYCNT + 1;
		end else if(crf_ac_UPEND) begin
			UPINHSKCNT   <= UPINHSKCNT  ;
			UPINNRDYCNT  <= UPINNRDYCNT ;
			UPOUTHSKCNT  <= UPOUTHSKCNT ;
			UPOUTNRDYCNT <= UPOUTNRDYCNT;
		end else begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			UPINHSKCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPINNRDYCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPOUTHSKCNT <= {CRF_DATA_WIDTH{1'b0}};
			UPOUTNRDYCNT <= {CRF_DATA_WIDTH{1'b0}};
			// End of automatics
		end
	end


/*************************** Performance monitoring registers end ***************************/


	// Write address channel
	// If there is a pending response, wait until that response finishes.
	reg wrt_en;
	assign crf_ac_wbusy = ~wrt_en;
	always@(posedge clk or negedge rst_n) begin: WRT_EN
		if(~rst_n)
			wrt_en <= 1'b1;
		else if(~wrt_en) begin
			if(s_axi_bvalid & s_axi_bready) wrt_en <= 1'b1;
		end else if(wrt_en & s_axi_awvalid & s_axi_awready)
			wrt_en <= 1'b0;
		else
			wrt_en <= 1'b1;
	end

	always@(posedge clk or negedge rst_n) begin: AWREADY
		if(~rst_n)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_awready <= 1'h0;
			// End of automatics
		else if(wrt_en & s_axi_awvalid  & ~s_axi_awready)
			s_axi_awready <= 1'b1;
		else
			s_axi_awready <= 1'h0;
	end

	reg [CRF_ADDR_WIDTH-1:0] axi_waddr;
	always@(posedge clk or negedge rst_n) begin: WADDR
		if(~rst_n)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			axi_waddr <= {CRF_ADDR_WIDTH{1'b0}};
			// End of automatics
		else if(s_axi_awvalid & s_axi_awready)
			axi_waddr <= s_axi_awaddr[CRF_ADDR_WIDTH-1:0];
	end

	// Write data channel
	// Only one of PS and PL can write at the same time.
	always@(posedge clk or negedge rst_n) begin: WREADY
		if(~rst_n)
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			s_axi_wready <= 1'h0;
			// End of automatics
		else if(~wrt_en & s_axi_wvalid & ~s_axi_wready)
			s_axi_wready <= 1'b1;
		else
			s_axi_wready <= 1'h0;
	end

	// Write enable signals for PL side and PS side.
	// We simply ignore the write strobe, just writ all data received.
	wire ac_wren   = ac_crf_wrt & ~crf_ac_wbusy;
	wire axi_wren  = s_axi_wvalid & s_axi_wready;

	always@(posedge clk or negedge rst_n) begin: WRITE_PROC
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			UPSTAT <= {CRF_DATA_WIDTH{1'b0}};
			// End of automatics
		end else if(ac_wren) begin
			case(ac_crf_waddr)
				0: UPSTAT   <= ac_crf_wdata;
				default: begin
					UPSTAT   <= UPSTAT  ;
				end
			endcase
		end else if(axi_wren) begin
			case(axi_waddr)
				0: UPSTAT  <= s_axi_wdata;
				default: begin
					UPSTAT   <= UPSTAT  ;
				end
			endcase
		end
	end


	// Write response channel
	// Send a response after a successful write. The default value of bresp
	// is OKAY, just hard-wiring it.
	assign s_axi_bresp = RESP_OKAY;

	always@(posedge clk or negedge rst_n) begin: BVALID
		if(~rst_n) begin
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
	always@(posedge clk or negedge rst_n) begin: ARREADY
		if(~rst_n)
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

	always@(posedge clk or negedge rst_n) begin: READ_PROC
		if(~rst_n) begin
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
				0: s_axi_rdata  <= UPSTAT      ;
				4: s_axi_rdata  <= UPINHSKCNT  ;
				8: s_axi_rdata  <= UPINNRDYCNT ;
				12: s_axi_rdata <= UPOUTHSKCNT ;
				16: s_axi_rdata <= UPOUTNRDYCNT ;
				default: s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
			endcase
		end else begin
			s_axi_rvalid <= 1'b0;
			s_axi_rdata <= {AXI_DATA_WIDTH{1'b0}};
		end
	end

endmodule

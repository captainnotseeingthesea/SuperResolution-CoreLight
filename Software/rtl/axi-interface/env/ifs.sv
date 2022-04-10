/*************************************************

 Copyright: NUDT_CoreLight

 File name: ifs.sv

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 SV interfaces for verification.

 **************************************************/

// interface for axi-lite
interface axi_lite_if #(
    // AXI
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32
)();

	localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;

	logic                      aclk;
	logic                      arstn;
	// AW
	logic                      axi_awvalid;
	logic                      axi_awready;
	logic [AXI_ADDR_WIDTH-1:0] axi_awaddr;
	logic [2:0]                axi_awprot;
	// W
	logic                      axi_wvalid;
	logic                      axi_wready;
	logic [AXI_DATA_WIDTH-1:0] axi_wdata;
	logic [AXI_STRB_WIDTH-1:0] axi_wstrb;
	//B
	logic                 axi_bvalid;
	logic                 axi_bready;
	logic                 axi_bresp;
	// AR
	logic                      axi_arvalid;
	logic                      axi_arready;
	logic [AXI_ADDR_WIDTH-1:0] axi_araddr;
	logic [2:0]                axi_arprot;
	// R
	logic                      axi_rvalid;
	logic                      axi_rready;
	logic [AXI_DATA_WIDTH-1:0] axi_rdata;
	logic [1:0]                axi_rresp;
endinterface


// interface for axi-stream
interface axi_stream_if #(
    parameter AXIS_DATA_WIDTH = 32
)();

	localparam AXIS_STRB_WIDTH = AXIS_DATA_WIDTH/8;

	logic aclk;
    logic arstn;
	logic axis_tvalid;	
	logic axis_tready;

	logic                       axis_tid;
	logic [AXIS_DATA_WIDTH-1:0] axis_tdata;
	logic [AXIS_STRB_WIDTH-1:0] axis_tstrb;
	logic [AXIS_STRB_WIDTH-1:0] axis_tkeep;
	logic                       axis_tlast;
	logic                       axis_tdest;
	logic                       axis_user;

endinterface


// interface for upsp
interface upsp_if #(
    parameter CRF_DATA_WIDTH = 32,
    parameter UPSP_DATA_WIDTH = 32
)();

	logic clk;
	logic rst_n;

	// Signals with upsp
	logic [CRF_DATA_WIDTH-1:0]  UPSTR;
	logic [CRF_DATA_WIDTH-1:0]  UPENDR;
	logic                       upsp_ac_rd;
	logic                       ac_upsp_rvalid;
	logic [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	logic                       ac_upsp_wready;
	logic                       upsp_ac_wrt;
	logic [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;

endinterface


// interface for config register file and access control
interface ac_if # (
    // AXI
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32,
    // AXI-Stream
    parameter AXIS_DATA_WIDTH = 32,

    parameter CRF_DATA_WIDTH = 32,
    parameter UPSP_DATA_WIDTH = 32
) ();

	logic clk;
	logic rst_n;

	// Up-Sampling
	upsp_if #(
		.CRF_DATA_WIDTH  (CRF_DATA_WIDTH),
		.UPSP_DATA_WIDTH (UPSP_DATA_WIDTH)
	)
	usif();

	// AXI-Lite slave for configuration
	axi_lite_if #(
		.AXI_DATA_WIDTH	(AXI_DATA_WIDTH),
		.AXI_ADDR_WIDTH	(AXI_ADDR_WIDTH)
	) 
	lite_slave();

	// AXI-Stream slvae for input
	axi_stream_if #(
		.AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH)
	)
	stream_slave();

	// AXI-Stream master for output
	axi_stream_if #(
		.AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH)
	)
	stream_master();

	// Output for interrupt
	logic interrupt_updone;

	assign usif.clk = clk;
	assign usif.rst_n = rst_n;
	assign lite_slave.aclk  = clk;
	assign lite_slave.arstn = rst_n;
	assign stream_slave.aclk  = clk;
	assign stream_slave.arstn = rst_n;
	assign stream_master.aclk  = clk;
	assign stream_master.arstn = rst_n;

endinterface




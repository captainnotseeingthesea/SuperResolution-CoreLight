/*************************************************

 Copyright: NUDT_CoreLight

 File name: ifs.sv

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 SV interfaces for verification.

 **************************************************/

// interface for config register file and access control
interface ac_if # (
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
) ();

	logic clk;
	logic rst_n;

	// Signals with upsp
	logic [CRF_DATA_WIDTH-1:0]  UPSTR;
	logic [CRF_DATA_WIDTH-1:0]  UPENDR;
	logic                       upsp_ac_rd;
	logic                       ac_upsp_rvalid;
	logic [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	logic                       upsp_ac_wrt;
	logic [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;
    logic                       upsp_ac_done;


	// Signals as an AXI4-Full master
	// Common
	// input m_axi_aclk;
	// input m_rst_n;

	// Write address channel
	logic                      m_axi_awvalid;
	logic                      m_axi_awready;
	logic                      m_axi_awid;
	logic [AXI_ADDR_WIDTH-1:0] m_axi_awaddr;
	logic [7:0]                m_axi_awlen;
	logic [2:0]                m_axi_awsize;
	logic [1:0]                m_axi_awburst;
	logic [1:0]                m_axi_awlock;
	logic [3:0]                m_axi_awcache;
	logic [2:0]                m_axi_awprot;
	logic [3:0]                m_axi_awqos;
//  output                      m_axi_awregion;
//  output                      m_axi_awuser;

	// Write data channel
	logic                      m_axi_wvalid;
	logic                      m_axi_wready;
	logic                      m_axi_wid;
	logic [AXI_DATA_WIDTH-1:0] m_axi_wdata;
	logic [AXI_STRB_WIDTH-1:0] m_axi_wstrb;
	logic                      m_axi_wlast;
//  output                      m_axi_wuser;

	// Write response channel
	logic       m_axi_bvalid;
	logic       m_axi_bready;
	logic       m_axi_bid;
	logic [1:0] m_axi_bresp;
//  input       m_axi_buser;

	// Read address channel
	logic                      m_axi_arvalid;
	logic                      m_axi_arready;
	logic                      m_axi_arid;
	logic [AXI_ADDR_WIDTH-1:0] m_axi_araddr;
	logic [7:0]                m_axi_arlen;
	logic [2:0]                m_axi_arsize;
	logic [1:0]                m_axi_arburst;
	logic [1:0]                m_axi_arlock;
	logic [3:0]                m_axi_arcache;
	logic [2:0]                m_axi_arprot;
	logic [3:0]                m_axi_arqos;
//  output                      m_axi_arregion;
//  output                      m_axi_aruser;

	// Read data channel
	logic                      m_axi_rvalid;
	logic                      m_axi_rready;
	logic                      m_axi_rid;
	logic [AXI_DATA_WIDTH-1:0] m_axi_rdata;
	logic [1:0]                m_axi_rresp;
	logic                      m_axi_rlast;
//  input                      m_axi_ruser;


	// Signals as AXI-Stream slave
	// input s_axis_aclk;
    // input s_axis_arstn;
	logic                       s_axis_tvalid;	
	logic                       s_axis_tready;
	logic                       s_axis_tid;
	logic [AXIS_DATA_WIDTH-1:0] s_axis_tdata;
	logic [AXIS_STRB_WIDTH-1:0] s_axis_tstrb;
	logic [AXIS_STRB_WIDTH-1:0] s_axis_tkeep;
	logic                       s_axis_tlast;
	logic                       s_axis_tdest;
	logic                       s_axis_user;

    // Signals as AXI-Lite slave
	// Write address channel
	logic                      s_axi_awvalid;
	logic                      s_axi_awready;
	logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
	logic [2:0]                s_axi_awprot;

	// Write data channel
	logic                      s_axi_wvalid;
	logic                      s_axi_wready;
	logic [AXI_DATA_WIDTH-1:0] s_axi_wdata;
	logic [AXI_STRB_WIDTH-1:0] s_axi_wstrb;

	// Write response channel
	logic                 s_axi_bvalid;
	logic                 s_axi_bready;
	logic                 s_axi_bresp;

	// Read address channel
	logic                      s_axi_arvalid;
	logic                      s_axi_arready;
	logic [AXI_ADDR_WIDTH-1:0] s_axi_araddr;
	logic [2:0]                s_axi_arprot;

	// Read data channel
	logic                      s_axi_rvalid;
	logic                      s_axi_rready;
	logic [AXI_DATA_WIDTH-1:0] s_axi_rdata;
	logic [1:0]                s_axi_rresp;

	// Output for interrupt
	logic interrupt_updone;

endinterface




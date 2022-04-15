/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_lite_if.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 interface for axi-lite

 **************************************************/

interface axi_lite_if();

	localparam AXI_DATA_WIDTH  = `AXI_DATA_WIDTH ;
	localparam AXI_ADDR_WIDTH  = `AXI_ADDR_WIDTH ;
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
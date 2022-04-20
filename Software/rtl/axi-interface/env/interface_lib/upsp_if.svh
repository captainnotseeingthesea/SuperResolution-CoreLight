/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_if.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 interface for up-sampling module

 **************************************************/

interface upsp_if();

	localparam CRF_DATA_WIDTH  = `CRF_DATA_WIDTH ;
	localparam UPSP_DATA_WIDTH = `UPSP_DATA_WIDTH;

	logic clk;
	logic rst_n;

	// Signals with upsp
	logic [CRF_DATA_WIDTH-1:0]  UPSTR;
	logic [CRF_DATA_WIDTH-1:0]  UPENDR;
	logic                       upsp_ac_rready;
	logic                       ac_upsp_rvalid;
	logic [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;
	logic                       ac_upsp_wready;
	logic                       upsp_ac_wvalid;
	logic [UPSP_DATA_WIDTH-1:0] upsp_ac_wdata;

endinterface
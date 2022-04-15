/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_lite_if.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 interface for axi-stream

 **************************************************/

interface axi_stream_if();

	localparam AXIS_DATA_WIDTH = `AXIS_DATA_WIDTH;
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
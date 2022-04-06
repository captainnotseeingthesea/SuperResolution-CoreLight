/*************************************************

 Copyright: NUDT_CoreLight

 File name: tb_top.v

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 test bench for top module.

 **************************************************/

module tb_top();

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





`include "ifs.sv"



    ac_if acif();

    top my_top # (/*AUTOINSTPARAM*/
		  // Parameters
		  .AXI_DATA_WIDTH	(AXI_DATA_WIDTH),
		  .AXI_ADDR_WIDTH	(AXI_ADDR_WIDTH),
		  .AXI_STRB_WIDTH	(AXI_STRB_WIDTH),
		  .AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH),
		  .AXIS_STRB_WIDTH	(AXIS_STRB_WIDTH),
		  .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
		  .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH),
		  .UPSP_DATA_WIDTH	(UPSP_DATA_WIDTH),
		  .SRC_IMG_WIDTH	(SRC_IMG_WIDTH),
		  .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT),
		  .DST_IMG_WIDTH	(DST_IMG_WIDTH),
		  .DST_IMG_HEIGHT	(DST_IMG_HEIGHT))
    (.acif(acif));
    
    

endmodule

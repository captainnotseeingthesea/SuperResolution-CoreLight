/*************************************************

 Copyright: NUDT_CoreLight

 File name: tb_ac_crf.v

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 test bench for top module.

 **************************************************/

module tb_ac_crf();


    // AXI-Full
    parameter AXI_DATA_WIDTH = 32;
    parameter AXI_ADDR_WIDTH = 32;
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;
    // AXI-Stream
    parameter AXIS_DATA_WIDTH = 32;
    parameter AXIS_STRB_WIDTH = AXIS_DATA_WIDTH/8;

    parameter CRF_DATA_WIDTH = 32;
    parameter CRF_ADDR_WIDTH = 32;
    parameter UPSP_DATA_WIDTH = 32;

    parameter SRC_IMG_WIDTH  = 1920;
    parameter SRC_IMG_HEIGHT = 1080;
    parameter DST_IMG_WIDTH  = 4096;
    parameter DST_IMG_HEIGHT = 2160;



    ac_if acif();

    top # (/*AUTOINSTPARAM*/
	   // Parameters
	   .AXI_DATA_WIDTH		(AXI_DATA_WIDTH),
	   .AXI_ADDR_WIDTH		(AXI_ADDR_WIDTH),
	   .AXI_STRB_WIDTH		(AXI_STRB_WIDTH),
	   .AXIS_DATA_WIDTH		(AXIS_DATA_WIDTH),
	   .AXIS_STRB_WIDTH		(AXIS_STRB_WIDTH),
	   .CRF_DATA_WIDTH		(CRF_DATA_WIDTH),
	   .CRF_ADDR_WIDTH		(CRF_ADDR_WIDTH),
	   .UPSP_DATA_WIDTH		(UPSP_DATA_WIDTH),
	   .SRC_IMG_WIDTH		(SRC_IMG_WIDTH),
	   .SRC_IMG_HEIGHT		(SRC_IMG_HEIGHT),
	   .DST_IMG_WIDTH		(DST_IMG_WIDTH),
	   .DST_IMG_HEIGHT		(DST_IMG_HEIGHT))
    dut (/*AUTOINST*/
	    // Interfaces
	    .acif			(acif));

        
    // Clock generation
    initial begin
        forever begin
            acif.clk = 0;
            # 50 acif.clk = ~acif.clk;
        end
    end
    
    // Reset signal
    initial begin
        acif.rst_n = 0;
        #1000;
        acif.rst_n = 1;
    end

    // Run UVM test
    initial begin
        run_test("ac_crf_base_test");
    end

    // Config interfaces
    initial begin
        // axi-lite driver
        uvm_config_db#(virtual axi_lite_if)::set(null, 
        "uvm_test_top.env.axil_agt.drv",
        "vif",
        acif.lite_slave);

        // in axi-stream driver
        uvm_config_db#(virtual axi_stream_if)::set(null, 
        "uvm_test_top.env.m_axis_agt.drv",
        "vif",
        acif.stream_master);

        // in axi-stream monitor
        uvm_config_db#(virtual axi_stream_if)::set(null, 
        "uvm_test_top.env.m_axis_agt.mon",
        "vif",
        acif.stream_master);

        // out axi-stream driver
        uvm_config_db#(virtual axi_stream_if)::set(null, 
        "uvm_test_top.env.s_axis_agt.drv",
        "vif",
        acif.stream_slave);

        // out axi-stream monitor
        uvm_config_db#(virtual axi_stream_if)::set(null, 
        "uvm_test_top.env.s_axis_agt.mon",
        "vif",
        acif.stream_slave);

        // upsp driver
        uvm_config_db#(virtual upsp_if)::set(null, 
        "uvm_test_top.env.upsp_agt.drv",
        "vif",
        acif.usif);

        // upsp monitor
        uvm_config_db#(virtual upsp_if)::set(null, 
        "uvm_test_top.env.upsp_agt.mon",
        "vif",
        acif.usif);
    end

    


endmodule
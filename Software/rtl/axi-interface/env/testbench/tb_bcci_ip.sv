/*************************************************

 Copyright: NUDT_CoreLight

 File name: tb_bcci_ip.sv

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 **************************************************/

module tb_bcci_ip();

`include "uvm_macros.svh"
import uvm_pkg::*;

import test_pkg::*;
import utils_pkg::*;


	localparam AXI_DATA_WIDTH  = `AXI_DATA_WIDTH ;
	localparam AXI_ADDR_WIDTH  = `AXI_ADDR_WIDTH ;
	localparam AXIS_DATA_WIDTH = `AXIS_DATA_WIDTH;
	localparam CRF_DATA_WIDTH  = `CRF_DATA_WIDTH ;
	localparam CRF_ADDR_WIDTH  = `CRF_ADDR_WIDTH ;
	localparam UPSP_DATA_WIDTH = `UPSP_DATA_WIDTH;
	localparam SRC_IMG_WIDTH   = `SRC_IMG_WIDTH  ;
	localparam SRC_IMG_HEIGHT  = `SRC_IMG_HEIGHT ;
	localparam DST_IMG_WIDTH   = `DST_IMG_WIDTH  ;
	localparam DST_IMG_HEIGHT  = `DST_IMG_HEIGHT ;
    
    localparam string SRC_BMP_BASE    = "onepiece54";
    localparam string SRC_BMP_FILE    = {SRC_BMP_BASE, ".bmp"};
    localparam string SRC_BIN_FILE    = {SRC_BMP_BASE, "_tmp_bin"};
    localparam string DST_BMP_FILE    = {SRC_BMP_BASE, "_4.bmp"};
    localparam string DST_BIN_FILE    = {SRC_BMP_BASE, "_4_tmp_bin"};

    ac_if acif();

    bcci_ip_top dut (/*AUTOINST*/
		     // Interfaces
		     .acif		(acif));

        
    // Clock generation
    initial begin
        acif.clk = 0;
        forever #50 acif.clk = ~acif.clk;
    end
    
    // Reset signal
    initial begin
        acif.rst_n = 0;
        #1000;
        acif.rst_n = 1;
    end

    // Run UVM test
    initial begin
        utils_pkg::utils_path = "../env/utils";
        run_test("bcci_ip_test");
    end

    // Config interfaces
    initial begin
        // axi-lite driver
        uvm_config_db#(virtual axi_lite_if)::set(null, 
        "uvm_test_top.env.axil_agt.drv",
        "vif",
        acif.lite_master);

        uvm_config_db#(virtual ac_if)::set(null, 
        "uvm_test_top.env.axil_agt.drv",
        "acif",
        acif);

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

    // Set sequence and dump info
    initial begin
        // Input sequence
        uvm_config_db#(string)::set(null, 
        "uvm_test_top.env.m_axis_agt.sqr.*",
        "src_bmp",
        SRC_BMP_FILE);
        uvm_config_db#(string)::set(null, 
        "uvm_test_top.env.m_axis_agt.sqr.*",
        "dst_bin",
        SRC_BIN_FILE);
        uvm_config_db#(int)::set(null, 
        "uvm_test_top.env.m_axis_agt.sqr.*",
        "height",
        SRC_IMG_HEIGHT+3);
        uvm_config_db#(int)::set(null, 
        "uvm_test_top.env.m_axis_agt.sqr.*",
        "width",
        SRC_IMG_WIDTH+3);

        // Output dumper
        uvm_config_db#(string)::set(null, 
        "uvm_test_top.env.s_axis_agt.dmp",
        "src_bin",
        DST_BIN_FILE);
        uvm_config_db#(string)::set(null, 
        "uvm_test_top.env.s_axis_agt.dmp",
        "dst_bmp",
        DST_BMP_FILE);
        uvm_config_db#(int)::set(null, 
        "uvm_test_top.env.s_axis_agt.dmp",
        "height",
        DST_IMG_HEIGHT);
        uvm_config_db#(int)::set(null, 
        "uvm_test_top.env.s_axis_agt.dmp",
        "width",
        DST_IMG_WIDTH);

    end

	initial
	begin
		$dumpfile("../sim/waveform.vcd");
        $dumpvars(0, tb_bcci_ip);
        // wait(tb_bcci_ip.dut.AAA_bicubic_top.u_buffer.cur_row_cnt == 2);
        // $dumpoff;
        // wait(tb_bcci_ip.dut.AAA_bicubic_top.u_buffer.cur_row_cnt == 52);
        // $dumpon;
        // #10000;
        // $dumpoff;
        // $dumpvars(2, tb_bcci_ip.dut.AAA_access_control.upsp_wrtcnt, 
        // tb_bcci_ip.dut.AAA_access_control.ac_rdcnt, 
        // tb_bcci_ip.acif.stream_slave);
	end
 
endmodule

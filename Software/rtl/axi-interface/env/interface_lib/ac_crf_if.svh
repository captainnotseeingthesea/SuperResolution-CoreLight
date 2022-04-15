/*************************************************

 Copyright: NUDT_CoreLight

 File name: axi_lite_if.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 interface for config register file and access control

 **************************************************/

interface ac_if();

	logic clk;
	logic rst_n;

	// Up-Sampling
	upsp_if usif();

	// AXI-Lite slave for configuration
	axi_lite_if lite_slave();

	// AXI-Stream slvae for input
	axi_stream_if stream_slave();

	// AXI-Stream master for output
	axi_stream_if stream_master();

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
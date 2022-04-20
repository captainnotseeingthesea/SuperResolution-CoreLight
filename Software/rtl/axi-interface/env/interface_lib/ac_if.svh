/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_if.svh

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

	// AXI-Lite master for configuration
	axi_lite_if lite_master();

	// AXI-Stream master for input
	axi_stream_if stream_master();

	// AXI-Stream slvae for output
	axi_stream_if stream_slave();

	// Output for interrupt
	logic interrupt_updone;

	assign usif.clk = clk;
	assign usif.rst_n = rst_n;
	assign lite_master.aclk  = clk;
	assign lite_master.arstn = rst_n;
	assign stream_slave.aclk  = clk;
	assign stream_slave.arstn = rst_n;
	assign stream_master.aclk  = clk;
	assign stream_master.arstn = rst_n;

endinterface
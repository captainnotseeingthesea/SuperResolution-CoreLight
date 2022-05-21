/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip.sv

 Author: NUDT_CoreLight

 Date: 2021-04-11


 Description:

 **************************************************/

module bcci_ip
#(
	parameter  AXI_DATA_WIDTH  = `AXI_DATA_WIDTH   ,
	localparam AXI_STRB_WIDTH  = `AXI_STRB_WIDTH   ,
	parameter  AXI_ADDR_WIDTH  = `AXI_ADDR_WIDTH   ,
	parameter  AXIS_DATA_WIDTH = `AXIS_DATA_WIDTH  ,
	localparam AXIS_STRB_WIDTH = `AXIS_STRB_WIDTH  ,
	parameter  CRF_DATA_WIDTH  = `CRF_DATA_WIDTH   ,
	parameter  CRF_ADDR_WIDTH  = `CRF_ADDR_WIDTH   ,
	parameter  UPSP_DATA_WIDTH = `UPSP_DATA_WIDTH  ,
	parameter  SRC_IMG_WIDTH   = `SRC_IMG_WIDTH    ,
	parameter  SRC_IMG_HEIGHT  = `SRC_IMG_HEIGHT   ,
	parameter  DST_IMG_WIDTH   = `DST_IMG_WIDTH    ,
	parameter  DST_IMG_HEIGHT  = `DST_IMG_HEIGHT   ,
	localparam BUFFER_WIDTH    = `UPSP_DATA_WIDTH   ,
	parameter  CHANNEL_WIDTH   = 8
)
(/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bvalid, s_axi_bresp,
   s_axi_arready, s_axi_rvalid, s_axi_rdata, s_axi_rresp,
   s_axis_tready, m_axis_tvalid, m_axis_tid, m_axis_tdata,
   m_axis_tkeep, m_axis_tstrb, m_axis_tlast, m_axis_tdest,
   m_axis_user, interrupt_updone,
   // Inputs
   clk, rst_n, s_axi_awvalid, s_axi_awaddr, s_axi_awprot,
   s_axi_wvalid, s_axi_wdata, s_axi_wstrb, s_axi_bready,
   s_axi_arvalid, s_axi_araddr, s_axi_arprot, s_axi_rready,
   s_axis_tvalid, s_axis_tid, s_axis_tdata, s_axis_tstrb,
   s_axis_tkeep, s_axis_tlast, s_axis_tdest, s_axis_user,
   m_axis_tready
   );
	
	input clk;
	input rst_n;

	// AXI-Lite slave
	input                       s_axi_awvalid;
	output                      s_axi_awready;
	input [AXI_ADDR_WIDTH-1:0]  s_axi_awaddr;
	input [2:0]                 s_axi_awprot;
	input                       s_axi_wvalid;
	output                      s_axi_wready;
	input [AXI_DATA_WIDTH-1:0]  s_axi_wdata;
	input [AXI_STRB_WIDTH-1:0]  s_axi_wstrb;
	output                      s_axi_bvalid;
	input                       s_axi_bready;
	output                      s_axi_bresp;
	input                       s_axi_arvalid;
	output                      s_axi_arready;
	input [AXI_ADDR_WIDTH-1:0]  s_axi_araddr;
	input [2:0]                 s_axi_arprot;
	output                      s_axi_rvalid;
	input                       s_axi_rready;
	output [AXI_DATA_WIDTH-1:0] s_axi_rdata;
	output [1:0]                s_axi_rresp;

	// Interface as AXI-Stream slave, in
	input                       s_axis_tvalid;	
	output                      s_axis_tready;
	input                       s_axis_tid;
	input [AXIS_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXIS_STRB_WIDTH-1:0] s_axis_tkeep;
	input                       s_axis_tlast;
	input                       s_axis_tdest;
	input                       s_axis_user;

	// Interface as AXI-Stream master, out
	output                       m_axis_tvalid;	
	input                        m_axis_tready;
	output                       m_axis_tid;
	output [AXIS_DATA_WIDTH-1:0] m_axis_tdata;
	output [AXIS_STRB_WIDTH-1:0] m_axis_tkeep;
	output [AXIS_STRB_WIDTH-1:0] m_axis_tstrb;
	output                       m_axis_tlast;
	output                       m_axis_tdest;
	output                       m_axis_user;

	// Intterupt when finished
	output interrupt_updone;

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		ac_crf_axisi_tready;	// From AAA_access_control of access_control.v
    wire		ac_crf_axisi_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_crf_axiso_tready;	// From AAA_access_control of access_control.v
    wire		ac_crf_axiso_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_crf_processing;	// From AAA_access_control of access_control.v
    wire [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;	// From AAA_access_control of access_control.v
    wire [CRF_DATA_WIDTH-1:0] ac_crf_wdata;	// From AAA_access_control of access_control.v
    wire		ac_crf_wrt;		// From AAA_access_control of access_control.v
    wire [UPSP_DATA_WIDTH-1:0] ac_upsp_rdata;	// From AAA_access_control of access_control.v
    wire		ac_upsp_rvalid;		// From AAA_access_control of access_control.v
    wire		ac_upsp_wready;		// From AAA_access_control of access_control.v
    wire		crf_ac_UPEND;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_UPSTART;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_wbusy;		// From AAA_config_register_file of config_register_file.v
    wire		upsp_ac_rready;		// From AAA_bicubic_top of bicubic_top.v
    wire [BUFFER_WIDTH-1:0] upsp_ac_wdata;	// From AAA_bicubic_top of bicubic_top.v
    wire		upsp_ac_wvalid;		// From AAA_bicubic_top of bicubic_top.v
    // End of automatics


    /*AUTOREG*/



    /* config_register_file AUTO_TEMPLATE(

    );
    */
    config_register_file #(/*AUTOINSTPARAM*/
			   // Parameters
			   .AXI_DATA_WIDTH	(AXI_DATA_WIDTH),
			   .AXI_ADDR_WIDTH	(AXI_ADDR_WIDTH),
			   .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
			   .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH))
    AAA_config_register_file(/*AUTOINST*/
			     // Outputs
			     .s_axi_awready	(s_axi_awready),
			     .s_axi_wready	(s_axi_wready),
			     .s_axi_bvalid	(s_axi_bvalid),
			     .s_axi_bresp	(s_axi_bresp),
			     .s_axi_arready	(s_axi_arready),
			     .s_axi_rvalid	(s_axi_rvalid),
			     .s_axi_rdata	(s_axi_rdata[AXI_DATA_WIDTH-1:0]),
			     .s_axi_rresp	(s_axi_rresp[1:0]),
			     .interrupt_updone	(interrupt_updone),
			     .crf_ac_UPSTART	(crf_ac_UPSTART),
			     .crf_ac_UPEND	(crf_ac_UPEND),
			     .crf_ac_wbusy	(crf_ac_wbusy),
			     // Inputs
			     .clk		(clk),
			     .rst_n		(rst_n),
			     .s_axi_awvalid	(s_axi_awvalid),
			     .s_axi_awaddr	(s_axi_awaddr[AXI_ADDR_WIDTH-1:0]),
			     .s_axi_awprot	(s_axi_awprot[2:0]),
			     .s_axi_wvalid	(s_axi_wvalid),
			     .s_axi_wdata	(s_axi_wdata[AXI_DATA_WIDTH-1:0]),
			     .s_axi_wstrb	(s_axi_wstrb[AXI_STRB_WIDTH-1:0]),
			     .s_axi_bready	(s_axi_bready),
			     .s_axi_arvalid	(s_axi_arvalid),
			     .s_axi_araddr	(s_axi_araddr[AXI_ADDR_WIDTH-1:0]),
			     .s_axi_arprot	(s_axi_arprot[2:0]),
			     .s_axi_rready	(s_axi_rready),
			     .ac_crf_wrt	(ac_crf_wrt),
			     .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
			     .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]),
			     .ac_crf_axisi_tvalid(ac_crf_axisi_tvalid),
			     .ac_crf_axisi_tready(ac_crf_axisi_tready),
			     .ac_crf_axiso_tvalid(ac_crf_axiso_tvalid),
			     .ac_crf_axiso_tready(ac_crf_axiso_tready),
			     .ac_crf_processing	(ac_crf_processing));

    /* access_control AUTO_TEMPLATE (
    );
    */
    access_control #(/*AUTOINSTPARAM*/
		     // Parameters
		     .AXIS_DATA_WIDTH	(AXIS_DATA_WIDTH),
		     .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
		     .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH),
		     .UPSP_DATA_WIDTH	(UPSP_DATA_WIDTH),
		     .SRC_IMG_WIDTH	(SRC_IMG_WIDTH),
		     .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT),
		     .DST_IMG_WIDTH	(DST_IMG_WIDTH),
		     .DST_IMG_HEIGHT	(DST_IMG_HEIGHT))
    AAA_access_control(/*AUTOINST*/
		       // Outputs
		       .ac_crf_wrt	(ac_crf_wrt),
		       .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]),
		       .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
		       .ac_crf_processing(ac_crf_processing),
		       .ac_crf_axisi_tvalid(ac_crf_axisi_tvalid),
		       .ac_crf_axisi_tready(ac_crf_axisi_tready),
		       .ac_crf_axiso_tvalid(ac_crf_axiso_tvalid),
		       .ac_crf_axiso_tready(ac_crf_axiso_tready),
		       .ac_upsp_rvalid	(ac_upsp_rvalid),
		       .ac_upsp_rdata	(ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]),
		       .ac_upsp_wready	(ac_upsp_wready),
		       .s_axis_tready	(s_axis_tready),
		       .m_axis_tvalid	(m_axis_tvalid),
		       .m_axis_tid	(m_axis_tid),
		       .m_axis_tdata	(m_axis_tdata[AXIS_DATA_WIDTH-1:0]),
		       .m_axis_tkeep	(m_axis_tkeep[AXIS_STRB_WIDTH-1:0]),
		       .m_axis_tstrb	(m_axis_tstrb[AXIS_STRB_WIDTH-1:0]),
		       .m_axis_tlast	(m_axis_tlast),
		       .m_axis_tdest	(m_axis_tdest),
		       .m_axis_user	(m_axis_user),
		       // Inputs
		       .clk		(clk),
		       .rst_n		(rst_n),
		       .crf_ac_UPSTART	(crf_ac_UPSTART),
		       .crf_ac_UPEND	(crf_ac_UPEND),
		       .crf_ac_wbusy	(crf_ac_wbusy),
		       .upsp_ac_rready	(upsp_ac_rready),
		       .upsp_ac_wvalid	(upsp_ac_wvalid),
		       .upsp_ac_wdata	(upsp_ac_wdata[UPSP_DATA_WIDTH-1:0]),
		       .s_axis_tvalid	(s_axis_tvalid),
		       .s_axis_tid	(s_axis_tid),
		       .s_axis_tdata	(s_axis_tdata[AXIS_DATA_WIDTH-1:0]),
		       .s_axis_tstrb	(s_axis_tstrb[AXIS_STRB_WIDTH-1:0]),
		       .s_axis_tkeep	(s_axis_tkeep[AXIS_STRB_WIDTH-1:0]),
		       .s_axis_tlast	(s_axis_tlast),
		       .s_axis_tdest	(s_axis_tdest),
		       .s_axis_user	(s_axis_user),
		       .m_axis_tready	(m_axis_tready));
    
    /* bicubic_top AUTO_TEMPLATE (
    );
    */
    bicubic_top #(/*AUTOINSTPARAM*/
		  // Parameters
		  .BUFFER_WIDTH		(BUFFER_WIDTH),
		  .CHANNEL_WIDTH	(CHANNEL_WIDTH))
    AAA_bicubic_top(/*AUTOINST*/
		    // Outputs
		    .upsp_ac_rready	(upsp_ac_rready),
		    .upsp_ac_wdata	(upsp_ac_wdata[BUFFER_WIDTH-1:0]),
		    .upsp_ac_wvalid	(upsp_ac_wvalid),
		    // Inputs
		    .clk		(clk),
		    .rst_n		(rst_n),
		    .ac_upsp_rdata	(ac_upsp_rdata[23:0]),
		    .ac_upsp_rvalid	(ac_upsp_rvalid),
		    .ac_upsp_wready	(ac_upsp_wready));

endmodule

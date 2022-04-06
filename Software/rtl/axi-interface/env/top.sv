/*************************************************

 Copyright: NUDT_CoreLight

 File name: top.sv

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 top module of the control and communication part of
 the design for verification.

 **************************************************/

module top # (
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
) (
    ac_if acif
);

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;	// From AAA_access_control of access_control.v
    wire [CRF_DATA_WIDTH-1:0] ac_crf_wdata;	// From AAA_access_control of access_control.v
    wire		ac_crf_wrt;		// From AAA_access_control of access_control.v
    wire [CRF_DATA_WIDTH-1:0] crf_ac_UPDSTAR;	// From AAA_config_register_file of config_register_file.v
    wire [CRF_DATA_WIDTH-1:0] crf_ac_UPENDR;	// From AAA_config_register_file of config_register_file.v
    wire [CRF_DATA_WIDTH-1:0] crf_ac_UPSRCAR;	// From AAA_config_register_file of config_register_file.v
    wire [CRF_DATA_WIDTH-1:0] crf_ac_UPSTR;	// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_wbusy;		// From AAA_config_register_file of config_register_file.v
    // End of automatics


    /*AUTOREG*/



    /* config_register_file AUTO_TEMPLATE(
	    .s_axi_awready	(acif.s_axi_awready),
	    .s_axi_wready	(acif.s_axi_wready),
	    .s_axi_bvalid	(acif.s_axi_bvalid),
	    .s_axi_bresp	(acif.s_axi_bresp),
	    .s_axi_arready	(acif.s_axi_arready),
	    .s_axi_rvalid	(acif.s_axi_rvalid),
	    .s_axi_rdata	(acif.s_axi_rdata),
	    .s_axi_rresp	(acif.s_axi_rresp),
	    .interrupt_updone	(acif.interrupt_updone),  
	    .s_axi_aclk	(acif.clk),
	    .s_axi_rstn	(acif.rst_n),
	    .s_axi_awvalid	(acif.s_axi_awvalid),
	    .s_axi_awaddr	(acif.s_axi_awaddr),
	    .s_axi_awprot	(acif.s_axi_awprot),
	    .s_axi_wvalid	(acif.s_axi_wvalid),
	    .s_axi_wdata	(acif.s_axi_wdata),
	    .s_axi_wstrb	(acif.s_axi_wstrb),
	    .s_axi_bready	(acif.s_axi_bready),
	    .s_axi_arvalid	(acif.s_axi_arvalid),
	    .s_axi_araddr	(acif.s_axi_araddr),
	    .s_axi_arprot	(acif.s_axi_arprot),
	    .s_axi_rready	(acif.s_axi_rready),
    );
    */
    config_register_file #(/*AUTOINSTPARAM*/
			   // Parameters
			   .AXI_DATA_WIDTH	(AXI_DATA_WIDTH),
			   .AXI_ADDR_WIDTH	(AXI_ADDR_WIDTH),
			   .AXI_STRB_WIDTH	(AXI_STRB_WIDTH),
			   .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
			   .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH))
    AAA_config_register_file(/*AUTOINST*/
			     // Outputs
			     .s_axi_awready	(acif.s_axi_awready), // Templated
			     .s_axi_wready	(acif.s_axi_wready), // Templated
			     .s_axi_bvalid	(acif.s_axi_bvalid), // Templated
			     .s_axi_bresp	(acif.s_axi_bresp), // Templated
			     .s_axi_arready	(acif.s_axi_arready), // Templated
			     .s_axi_rvalid	(acif.s_axi_rvalid), // Templated
			     .s_axi_rdata	(acif.s_axi_rdata), // Templated
			     .s_axi_rresp	(acif.s_axi_rresp), // Templated
			     .interrupt_updone	(acif.interrupt_updone), // Templated
			     .crf_ac_UPSTR	(crf_ac_UPSTR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPENDR	(crf_ac_UPENDR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPSRCAR	(crf_ac_UPSRCAR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPDSTAR	(crf_ac_UPDSTAR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_wbusy	(crf_ac_wbusy),
			     // Inputs
			     .clk		(clk),
			     .rst_n		(rst_n),
			     .s_axi_awvalid	(acif.s_axi_awvalid), // Templated
			     .s_axi_awaddr	(acif.s_axi_awaddr), // Templated
			     .s_axi_awprot	(acif.s_axi_awprot), // Templated
			     .s_axi_wvalid	(acif.s_axi_wvalid), // Templated
			     .s_axi_wdata	(acif.s_axi_wdata), // Templated
			     .s_axi_wstrb	(acif.s_axi_wstrb), // Templated
			     .s_axi_bready	(acif.s_axi_bready), // Templated
			     .s_axi_arvalid	(acif.s_axi_arvalid), // Templated
			     .s_axi_araddr	(acif.s_axi_araddr), // Templated
			     .s_axi_arprot	(acif.s_axi_arprot), // Templated
			     .s_axi_rready	(acif.s_axi_rready), // Templated
			     .ac_crf_wrt	(ac_crf_wrt),
			     .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
			     .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]));

    /* access_control AUTO_TEMPLATE (
        	   .clk		(clk),
		       .rst_n		(acif.rst_n),
		       .UPSTR		(acif.UPSTR[CRF_DATA_WIDTH-1:0]),
		       .UPENDR		(acif.UPENDR[CRF_DATA_WIDTH-1:0]),
		       .UPSTR		(acif.UPSTR[CRF_DATA_WIDTH-1:0]),
		       .UPENDR		(acif.UPENDR[CRF_DATA_WIDTH-1:0]),
		       .ac_upsp_rvalid	(acif.ac_upsp_rvalid),
		       .ac_upsp_rdata	(acif.ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]),
		       .m_axi_awvalid	(acif.m_axi_awvalid),
		       .m_axi_awid	(acif.m_axi_awid),
		       .m_axi_awaddr	(acif.m_axi_awaddr[AXI_ADDR_WIDTH-1:0]),
		       .m_axi_awlen	(acif.m_axi_awlen[7:0]),
		       .m_axi_awsize	(acif.m_axi_awsize[2:0]),
		       .m_axi_awburst	(acif.m_axi_awburst[1:0]),
		       .m_axi_awlock	(acif.m_axi_awlock[1:0]),
		       .m_axi_awcache	(acif.m_axi_awcache[3:0]),
		       .m_axi_awprot	(acif.m_axi_awprot[2:0]),
		       .m_axi_awqos	(acif.m_axi_awqos[3:0]),
		       .m_axi_wvalid	(acif.m_axi_wvalid),
		       .m_axi_wid	(acif.m_axi_wid),
		       .m_axi_wdata	(acif.m_axi_wdata[AXI_DATA_WIDTH-1:0]),
		       .m_axi_wstrb	(acif.m_axi_wstrb[AXI_STRB_WIDTH-1:0]),
		       .m_axi_wlast	(acif.m_axi_wlast),
		       .m_axi_bready	(acif.m_axi_bready),
		       .m_axi_arvalid	(acif.m_axi_arvalid),
		       .m_axi_arid	(acif.m_axi_arid),
		       .m_axi_araddr	(acif.m_axi_araddr[AXI_ADDR_WIDTH-1:0]),
		       .m_axi_arlen	(acif.m_axi_arlen[7:0]),
		       .m_axi_arsize	(acif.m_axi_arsize[2:0]),
		       .m_axi_arburst	(acif.m_axi_arburst[1:0]),
		       .m_axi_arlock	(acif.m_axi_arlock[1:0]),
		       .m_axi_arcache	(acif.m_axi_arcache[3:0]),
		       .m_axi_arprot	(acif.m_axi_arprot[2:0]),
		       .m_axi_arqos	(acif.m_axi_arqos[3:0]),
		       .m_axi_rready	(acif.m_axi_rready),
		       .s_axis_tready	(acif.s_axis_tready),
               .upsp_ac_rd	(acif.upsp_ac_rd),
		       .upsp_ac_wrt	(acif.upsp_ac_wrt),
		       .upsp_ac_wdata	(acif.upsp_ac_wdata[UPSP_DATA_WIDTH-1:0]),
               .upsp_ac_done	(acif.upsp_ac_done),
		       .m_axi_awready	(acif.m_axi_awready),
		       .m_axi_wready	(acif.m_axi_wready),
		       .m_axi_bvalid	(acif.m_axi_bvalid),
		       .m_axi_bid	(acif.m_axi_bid),
		       .m_axi_bresp	(acif.m_axi_bresp[1:0]),
		       .m_axi_arready	(acif.m_axi_arready),
		       .m_axi_rvalid	(acif.m_axi_rvalid),
		       .m_axi_rid	(acif.m_axi_rid),
		       .m_axi_rdata	(acif.m_axi_rdata[AXI_DATA_WIDTH-1:0]),
		       .m_axi_rresp	(acif.m_axi_rresp[1:0]),
		       .m_axi_rlast	(acif.m_axi_rlast),
		       .s_axis_tvalid	(acif.s_axis_tvalid),
		       .s_axis_tid	(acif.s_axis_tid),
		       .s_axis_tdata	(acif.s_axis_tdata[AXIS_DATA_WIDTH-1:0]),
		       .s_axis_tstrb	(acif.s_axis_tstrb[AXIS_STRB_WIDTH-1:0]),
		       .s_axis_tkeep	(acif.s_axis_tkeep[AXIS_STRB_WIDTH-1:0]),
		       .s_axis_tlast	(acif.s_axis_tlast),
		       .s_axis_tdest	(acif.s_axis_tdest),
		       .s_axis_user	(acif.s_axis_user),
    );
    */
    access_control #(/*AUTOINSTPARAM*/
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
    AAA_access_control(/*AUTOINST*/
		       // Outputs
		       .ac_crf_wrt	(ac_crf_wrt),
		       .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]),
		       .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
		       .UPSTR		(acif.UPSTR[CRF_DATA_WIDTH-1:0]), // Templated
		       .UPENDR		(acif.UPENDR[CRF_DATA_WIDTH-1:0]), // Templated
		       .ac_upsp_rvalid	(acif.ac_upsp_rvalid),	 // Templated
		       .ac_upsp_rdata	(acif.ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]), // Templated
		       .m_axi_awvalid	(acif.m_axi_awvalid),	 // Templated
		       .m_axi_awid	(acif.m_axi_awid),	 // Templated
		       .m_axi_awaddr	(acif.m_axi_awaddr[AXI_ADDR_WIDTH-1:0]), // Templated
		       .m_axi_awlen	(acif.m_axi_awlen[7:0]), // Templated
		       .m_axi_awsize	(acif.m_axi_awsize[2:0]), // Templated
		       .m_axi_awburst	(acif.m_axi_awburst[1:0]), // Templated
		       .m_axi_awlock	(acif.m_axi_awlock[1:0]), // Templated
		       .m_axi_awcache	(acif.m_axi_awcache[3:0]), // Templated
		       .m_axi_awprot	(acif.m_axi_awprot[2:0]), // Templated
		       .m_axi_awqos	(acif.m_axi_awqos[3:0]), // Templated
		       .m_axi_wvalid	(acif.m_axi_wvalid),	 // Templated
		       .m_axi_wid	(acif.m_axi_wid),	 // Templated
		       .m_axi_wdata	(acif.m_axi_wdata[AXI_DATA_WIDTH-1:0]), // Templated
		       .m_axi_wstrb	(acif.m_axi_wstrb[AXI_STRB_WIDTH-1:0]), // Templated
		       .m_axi_wlast	(acif.m_axi_wlast),	 // Templated
		       .m_axi_bready	(acif.m_axi_bready),	 // Templated
		       .m_axi_arvalid	(acif.m_axi_arvalid),	 // Templated
		       .m_axi_arid	(acif.m_axi_arid),	 // Templated
		       .m_axi_araddr	(acif.m_axi_araddr[AXI_ADDR_WIDTH-1:0]), // Templated
		       .m_axi_arlen	(acif.m_axi_arlen[7:0]), // Templated
		       .m_axi_arsize	(acif.m_axi_arsize[2:0]), // Templated
		       .m_axi_arburst	(acif.m_axi_arburst[1:0]), // Templated
		       .m_axi_arlock	(acif.m_axi_arlock[1:0]), // Templated
		       .m_axi_arcache	(acif.m_axi_arcache[3:0]), // Templated
		       .m_axi_arprot	(acif.m_axi_arprot[2:0]), // Templated
		       .m_axi_arqos	(acif.m_axi_arqos[3:0]), // Templated
		       .m_axi_rready	(acif.m_axi_rready),	 // Templated
		       .s_axis_tready	(acif.s_axis_tready),	 // Templated
		       // Inputs
		       .clk		(clk),			 // Templated
		       .rst_n		(acif.rst_n),		 // Templated
		       .crf_ac_UPSTR	(crf_ac_UPSTR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPENDR	(crf_ac_UPENDR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPSRCAR	(crf_ac_UPSRCAR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPDSTAR	(crf_ac_UPDSTAR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_wbusy	(crf_ac_wbusy),
		       .upsp_ac_rd	(acif.upsp_ac_rd),	 // Templated
		       .upsp_ac_wrt	(acif.upsp_ac_wrt),	 // Templated
		       .upsp_ac_wdata	(acif.upsp_ac_wdata[UPSP_DATA_WIDTH-1:0]), // Templated
		       .upsp_ac_done	(acif.upsp_ac_done),	 // Templated
		       .m_axi_awready	(acif.m_axi_awready),	 // Templated
		       .m_axi_wready	(acif.m_axi_wready),	 // Templated
		       .m_axi_bvalid	(acif.m_axi_bvalid),	 // Templated
		       .m_axi_bid	(acif.m_axi_bid),	 // Templated
		       .m_axi_bresp	(acif.m_axi_bresp[1:0]), // Templated
		       .m_axi_arready	(acif.m_axi_arready),	 // Templated
		       .m_axi_rvalid	(acif.m_axi_rvalid),	 // Templated
		       .m_axi_rid	(acif.m_axi_rid),	 // Templated
		       .m_axi_rdata	(acif.m_axi_rdata[AXI_DATA_WIDTH-1:0]), // Templated
		       .m_axi_rresp	(acif.m_axi_rresp[1:0]), // Templated
		       .m_axi_rlast	(acif.m_axi_rlast),	 // Templated
		       .s_axis_tvalid	(acif.s_axis_tvalid),	 // Templated
		       .s_axis_tid	(acif.s_axis_tid),	 // Templated
		       .s_axis_tdata	(acif.s_axis_tdata[AXIS_DATA_WIDTH-1:0]), // Templated
		       .s_axis_tstrb	(acif.s_axis_tstrb[AXIS_STRB_WIDTH-1:0]), // Templated
		       .s_axis_tkeep	(acif.s_axis_tkeep[AXIS_STRB_WIDTH-1:0]), // Templated
		       .s_axis_tlast	(acif.s_axis_tlast),	 // Templated
		       .s_axis_tdest	(acif.s_axis_tdest),	 // Templated
		       .s_axis_user	(acif.s_axis_user));	 // Templated

endmodule
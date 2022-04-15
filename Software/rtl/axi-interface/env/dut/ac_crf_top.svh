/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_crf_top.sv

 Author: NUDT_CoreLight

 Date: 2021-04-06


 Description:

 ac_crf_top module of the control and communication part of
 the design for verification.

 **************************************************/

module ac_crf_top(ac_if acif);

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
			    .s_axi_awready		(acif.lite_slave.axi_awready),
				.s_axi_wready		(acif.lite_slave.axi_wready),
				.s_axi_bvalid		(acif.lite_slave.axi_bvalid),
				.s_axi_bresp		(acif.lite_slave.axi_bresp),
				.s_axi_arready		(acif.lite_slave.axi_arready),
				.s_axi_rvalid		(acif.lite_slave.axi_rvalid),
				.s_axi_rdata		(acif.lite_slave.axi_rdata[AXI_DATA_WIDTH-1:0]),
				.s_axi_rresp		(acif.lite_slave.axi_rresp[1:0]),
				.interrupt_updone	(acif.interrupt_updone),
				.clk				(acif.clk),
				.rst_n				(acif.rst_n),
				.s_axi_awvalid		(acif.lite_slave.axi_awvalid),
				.s_axi_awaddr		(acif.lite_slave.axi_awaddr[AXI_ADDR_WIDTH-1:0]),
				.s_axi_awprot		(acif.lite_slave.axi_awprot[2:0]),
				.s_axi_wvalid		(acif.lite_slave.axi_wvalid),
				.s_axi_wdata		(acif.lite_slave.axi_wdata[AXI_DATA_WIDTH-1:0]),
				.s_axi_wstrb		(acif.lite_slave.axi_wstrb),
				.s_axi_bready		(acif.lite_slave.axi_bready),
				.s_axi_arvalid		(acif.lite_slave.axi_arvalid),
				.s_axi_araddr		(acif.lite_slave.axi_araddr[AXI_ADDR_WIDTH-1:0]),
				.s_axi_arprot		(acif.lite_slave.axi_arprot[2:0]),
				.s_axi_rready		(acif.lite_slave.axi_rready),
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
			     .s_axi_awready	(acif.lite_slave.axi_awready), // Templated
			     .s_axi_wready	(acif.lite_slave.axi_wready), // Templated
			     .s_axi_bvalid	(acif.lite_slave.axi_bvalid), // Templated
			     .s_axi_bresp	(acif.lite_slave.axi_bresp), // Templated
			     .s_axi_arready	(acif.lite_slave.axi_arready), // Templated
			     .s_axi_rvalid	(acif.lite_slave.axi_rvalid), // Templated
			     .s_axi_rdata	(acif.lite_slave.axi_rdata[AXI_DATA_WIDTH-1:0]), // Templated
			     .s_axi_rresp	(acif.lite_slave.axi_rresp[1:0]), // Templated
			     .interrupt_updone	(acif.interrupt_updone), // Templated
			     .crf_ac_UPSTR	(crf_ac_UPSTR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPENDR	(crf_ac_UPENDR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPSRCAR	(crf_ac_UPSRCAR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_UPDSTAR	(crf_ac_UPDSTAR[CRF_DATA_WIDTH-1:0]),
			     .crf_ac_wbusy	(crf_ac_wbusy),
			     // Inputs
			     .clk		(acif.clk),	 // Templated
			     .rst_n		(acif.rst_n),	 // Templated
			     .s_axi_awvalid	(acif.lite_slave.axi_awvalid), // Templated
			     .s_axi_awaddr	(acif.lite_slave.axi_awaddr[AXI_ADDR_WIDTH-1:0]), // Templated
			     .s_axi_awprot	(acif.lite_slave.axi_awprot[2:0]), // Templated
			     .s_axi_wvalid	(acif.lite_slave.axi_wvalid), // Templated
			     .s_axi_wdata	(acif.lite_slave.axi_wdata[AXI_DATA_WIDTH-1:0]), // Templated
			     .s_axi_wstrb	(acif.lite_slave.axi_wstrb), // Templated
			     .s_axi_bready	(acif.lite_slave.axi_bready), // Templated
			     .s_axi_arvalid	(acif.lite_slave.axi_arvalid), // Templated
			     .s_axi_araddr	(acif.lite_slave.axi_araddr[AXI_ADDR_WIDTH-1:0]), // Templated
			     .s_axi_arprot	(acif.lite_slave.axi_arprot[2:0]), // Templated
			     .s_axi_rready	(acif.lite_slave.axi_rready), // Templated
			     .ac_crf_wrt	(ac_crf_wrt),
			     .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
			     .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]));

    /* access_control AUTO_TEMPLATE (
		       .UPSTR		(acif.usif.UPSTR[CRF_DATA_WIDTH-1:0]),
		       .UPENDR		(acif.usif.UPENDR[CRF_DATA_WIDTH-1:0]),
		       .ac_upsp_rvalid	(acif.usif.ac_upsp_rvalid),
		       .ac_upsp_rdata	(acif.usif.ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]),
		       .ac_upsp_wready	(acif.usif.ac_upsp_wready),
		       .m_axis_tready	(acif.stream_slave.axis_tready),
		       .m_axis_tvalid	(acif.stream_slave.axis_tvalid),
		       .m_axis_tid		(acif.stream_slave.axis_tid),
		       .m_axis_tdata	(acif.stream_slave.axis_tdata[AXIS_DATA_WIDTH-1:0]),
		       .m_axis_tkeep	(acif.stream_slave.axis_tkeep),
		       .m_axis_tstrb	(acif.stream_slave.axis_tstrb),
		       .m_axis_tlast	(acif.stream_slave.axis_tlast),
		       .m_axis_tdest	(acif.stream_slave.axis_tdest),
		       .m_axis_user		(acif.stream_slave.axis_user),
		       .clk				(acif.clk),
		       .rst_n			(acif.rst_n),
		       .upsp_ac_rd		(acif.usif.upsp_ac_rd),
		       .upsp_ac_wrt		(acif.usif.upsp_ac_wrt),
		       .upsp_ac_wdata	(acif.usif.upsp_ac_wdata[UPSP_DATA_WIDTH-1:0]),
		       .s_axis_tvalid	(acif.stream_master.axis_tvalid),
		       .s_axis_tid		(acif.stream_master.axis_tid),
		       .s_axis_tdata	(acif.stream_master.axis_tdata[AXIS_DATA_WIDTH-1:0]),
		       .s_axis_tstrb	(acif.stream_master.axis_tstrb),
		       .s_axis_tkeep	(acif.stream_master.axis_tkeep),
		       .s_axis_tlast	(acif.stream_master.axis_tlast),
		       .s_axis_tdest	(acif.stream_master.axis_tdest),
		       .s_axis_user		(acif.stream_master.axis_user),
		       .s_axis_tready	(acif.stream_master.axis_tready),
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
		       .UPSTR		(acif.usif.UPSTR[CRF_DATA_WIDTH-1:0]), // Templated
		       .UPENDR		(acif.usif.UPENDR[CRF_DATA_WIDTH-1:0]), // Templated
		       .ac_upsp_rvalid	(acif.usif.ac_upsp_rvalid), // Templated
		       .ac_upsp_rdata	(acif.usif.ac_upsp_rdata[UPSP_DATA_WIDTH-1:0]), // Templated
		       .ac_upsp_wready	(acif.usif.ac_upsp_wready), // Templated
		       .s_axis_tready	(acif.stream_master.axis_tready), // Templated
		       .m_axis_tvalid	(acif.stream_slave.axis_tvalid), // Templated
		       .m_axis_tid	(acif.stream_slave.axis_tid), // Templated
		       .m_axis_tdata	(acif.stream_slave.axis_tdata[AXIS_DATA_WIDTH-1:0]), // Templated
		       .m_axis_tkeep	(acif.stream_slave.axis_tkeep), // Templated
		       .m_axis_tstrb	(acif.stream_slave.axis_tstrb), // Templated
		       .m_axis_tlast	(acif.stream_slave.axis_tlast), // Templated
		       .m_axis_tdest	(acif.stream_slave.axis_tdest), // Templated
		       .m_axis_user	(acif.stream_slave.axis_user), // Templated
		       // Inputs
		       .clk		(acif.clk),		 // Templated
		       .rst_n		(acif.rst_n),		 // Templated
		       .crf_ac_UPSTR	(crf_ac_UPSTR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPENDR	(crf_ac_UPENDR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPSRCAR	(crf_ac_UPSRCAR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_UPDSTAR	(crf_ac_UPDSTAR[CRF_DATA_WIDTH-1:0]),
		       .crf_ac_wbusy	(crf_ac_wbusy),
		       .upsp_ac_rd	(acif.usif.upsp_ac_rd),	 // Templated
		       .upsp_ac_wrt	(acif.usif.upsp_ac_wrt), // Templated
		       .upsp_ac_wdata	(acif.usif.upsp_ac_wdata[UPSP_DATA_WIDTH-1:0]), // Templated
		       .s_axis_tvalid	(acif.stream_master.axis_tvalid), // Templated
		       .s_axis_tid	(acif.stream_master.axis_tid), // Templated
		       .s_axis_tdata	(acif.stream_master.axis_tdata[AXIS_DATA_WIDTH-1:0]), // Templated
		       .s_axis_tstrb	(acif.stream_master.axis_tstrb), // Templated
		       .s_axis_tkeep	(acif.stream_master.axis_tkeep), // Templated
		       .s_axis_tlast	(acif.stream_master.axis_tlast), // Templated
		       .s_axis_tdest	(acif.stream_master.axis_tdest), // Templated
		       .s_axis_user	(acif.stream_master.axis_user), // Templated
		       .m_axis_tready	(acif.stream_slave.axis_tready)); // Templated

endmodule
/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_bcci_top.svh

 Author: NUDT_CoreLight

 Date: 2021-04-15


 Description:

 **************************************************/

module ac_bcci_top(ac_if acif);
 
    localparam AXI_DATA_WIDTH     = `AXI_DATA_WIDTH    ;
    localparam AXI_ADDR_WIDTH     = `AXI_ADDR_WIDTH    ;
    localparam AXISIN_DATA_WIDTH  = `AXISIN_DATA_WIDTH ;
    localparam AXISOUT_DATA_WIDTH = `AXISOUT_DATA_WIDTH;
    localparam CRF_DATA_WIDTH     = `CRF_DATA_WIDTH    ;
    localparam CRF_ADDR_WIDTH     = `CRF_ADDR_WIDTH    ;
	localparam UPSP_RDDATA_WIDTH  = `UPSP_RDDATA_WIDTH  ;
	localparam UPSP_WRTDATA_WIDTH = `UPSP_WRTDATA_WIDTH;
    localparam SRC_IMG_WIDTH      = `SRC_IMG_WIDTH     ;
    localparam SRC_IMG_HEIGHT     = `SRC_IMG_HEIGHT    ;
    localparam DST_IMG_WIDTH      = `DST_IMG_WIDTH     ;
    localparam DST_IMG_HEIGHT     = `DST_IMG_HEIGHT    ;
	localparam BUFFER_WIDTH       = `BUFFER_WIDTH      ;
	localparam OUT_FIFO_DEPTH     = `OUT_FIFO_DEPTH    ;
	localparam CHANNEL_WIDTH      = 8;
	localparam N_PARALLEL         = `N_PARALLEL;


    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		ac_crf_ac2usm_tlast;	// From AAA_access_control of access_control.v
    wire		ac_crf_ac2usm_tready;	// From AAA_access_control of access_control.v
    wire		ac_crf_ac2usm_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_crf_axisi_tready;	// From AAA_access_control of access_control.v
    wire		ac_crf_axisi_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_crf_axiso_tready;	// From AAA_access_control of access_control.v
    wire		ac_crf_axiso_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_crf_processing;	// From AAA_access_control of access_control.v
    wire [CRF_ADDR_WIDTH-1:0] ac_crf_waddr;	// From AAA_access_control of access_control.v
    wire [CRF_DATA_WIDTH-1:0] ac_crf_wdata;	// From AAA_access_control of access_control.v
    wire		ac_crf_wrt;		// From AAA_access_control of access_control.v
    wire [AXISOUT_DATA_WIDTH-1:0] ac_m_axis_tdata;// From AAA_access_control of access_control.v
    wire		ac_m_axis_tdest;	// From AAA_access_control of access_control.v
    wire		ac_m_axis_tid;		// From AAA_access_control of access_control.v
    wire [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tkeep;// From AAA_access_control of access_control.v
    wire		ac_m_axis_tlast;	// From AAA_access_control of access_control.v
    wire [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb;// From AAA_access_control of access_control.v
    wire		ac_m_axis_tuser;	// From AAA_access_control of access_control.v
    wire		ac_m_axis_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_upsp_reset;		// From AAA_access_control of access_control.v
    wire		crf_ac_UPEND;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_UPSTART;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_wbusy;		// From AAA_config_register_file of config_register_file.v
    // End of automatics
 

    /*AUTOREG*/


    /* config_register_file AUTO_TEMPLATE(
	        .s_axi_awready		(acif.lite_master.axi_awready),
	        .s_axi_wready		(acif.lite_master.axi_wready),
	        .s_axi_bvalid		(acif.lite_master.axi_bvalid),
	        .s_axi_bresp		(acif.lite_master.axi_bresp),
	        .s_axi_arready		(acif.lite_master.axi_arready),
	        .s_axi_rvalid		(acif.lite_master.axi_rvalid),
	        .s_axi_rdata		(acif.lite_master.axi_rdata[AXI_DATA_WIDTH-1:0]),
	        .s_axi_rresp		(acif.lite_master.axi_rresp[1:0]),
	        .interrupt_updone	(acif.interrupt_updone),
	        .clk				(acif.clk),
	        .rst_n				(acif.rst_n),
	        .s_axi_awvalid		(acif.lite_master.axi_awvalid),
	        .s_axi_awaddr		(acif.lite_master.axi_awaddr[AXI_ADDR_WIDTH-1:0]),
	        .s_axi_awprot		(acif.lite_master.axi_awprot[2:0]),
	        .s_axi_wvalid		(acif.lite_master.axi_wvalid),
	        .s_axi_wdata		(acif.lite_master.axi_wdata[AXI_DATA_WIDTH-1:0]),
	        .s_axi_wstrb		(acif.lite_master.axi_wstrb),
	        .s_axi_bready		(acif.lite_master.axi_bready),
	        .s_axi_arvalid		(acif.lite_master.axi_arvalid),
	        .s_axi_araddr		(acif.lite_master.axi_araddr[AXI_ADDR_WIDTH-1:0]),
	        .s_axi_arprot		(acif.lite_master.axi_arprot[2:0]),
	        .s_axi_rready		(acif.lite_master.axi_rready),
    );
    */
    config_register_file #(/*AUTOINSTPARAM*/
			   // Parameters
			   .AXI_DATA_WIDTH	(AXI_DATA_WIDTH),
			   .AXI_ADDR_WIDTH	(AXI_ADDR_WIDTH),
			   .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
			   .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH),
			   .N_PARALLEL		(N_PARALLEL))
    AAA_config_register_file(/*AUTOINST*/
			     // Outputs
			     .s_axi_awready	(acif.lite_master.axi_awready), // Templated
			     .s_axi_wready	(acif.lite_master.axi_wready), // Templated
			     .s_axi_bvalid	(acif.lite_master.axi_bvalid), // Templated
			     .s_axi_bresp	(acif.lite_master.axi_bresp), // Templated
			     .s_axi_arready	(acif.lite_master.axi_arready), // Templated
			     .s_axi_rvalid	(acif.lite_master.axi_rvalid), // Templated
			     .s_axi_rdata	(acif.lite_master.axi_rdata[AXI_DATA_WIDTH-1:0]), // Templated
			     .s_axi_rresp	(acif.lite_master.axi_rresp[1:0]), // Templated
			     .interrupt_updone	(acif.interrupt_updone), // Templated
			     .crf_ac_UPSTART	(crf_ac_UPSTART),
			     .crf_ac_UPEND	(crf_ac_UPEND),
			     .crf_ac_wbusy	(crf_ac_wbusy),
			     // Inputs
			     .clk		(acif.clk),	 // Templated
			     .rst_n		(acif.rst_n),	 // Templated
			     .s_axi_awvalid	(acif.lite_master.axi_awvalid), // Templated
			     .s_axi_awaddr	(acif.lite_master.axi_awaddr[AXI_ADDR_WIDTH-1:0]), // Templated
			     .s_axi_awprot	(acif.lite_master.axi_awprot[2:0]), // Templated
			     .s_axi_wvalid	(acif.lite_master.axi_wvalid), // Templated
			     .s_axi_wdata	(acif.lite_master.axi_wdata[AXI_DATA_WIDTH-1:0]), // Templated
			     .s_axi_wstrb	(acif.lite_master.axi_wstrb), // Templated
			     .s_axi_bready	(acif.lite_master.axi_bready), // Templated
			     .s_axi_arvalid	(acif.lite_master.axi_arvalid), // Templated
			     .s_axi_araddr	(acif.lite_master.axi_araddr[AXI_ADDR_WIDTH-1:0]), // Templated
			     .s_axi_arprot	(acif.lite_master.axi_arprot[2:0]), // Templated
			     .s_axi_rready	(acif.lite_master.axi_rready), // Templated
			     .ac_crf_wrt	(ac_crf_wrt),
			     .ac_crf_waddr	(ac_crf_waddr[CRF_ADDR_WIDTH-1:0]),
			     .ac_crf_wdata	(ac_crf_wdata[CRF_DATA_WIDTH-1:0]),
			     .ac_crf_axisi_tvalid(ac_crf_axisi_tvalid),
			     .ac_crf_axisi_tready(ac_crf_axisi_tready),
			     .ac_crf_axiso_tvalid(ac_crf_axiso_tvalid),
			     .ac_crf_axiso_tready(ac_crf_axiso_tready),
			     .ac_crf_processing	(ac_crf_processing),
			     .ac_crf_ac2usm_tvalid(ac_crf_ac2usm_tvalid),
			     .ac_crf_ac2usm_tready(ac_crf_ac2usm_tready),
			     .ac_crf_ac2usm_tlast(ac_crf_ac2usm_tlast),
			     .upsp_ac_rready	(upsp_ac_rready[N_PARALLEL-1:0]));
 
    /* access_control AUTO_TEMPLATE (
		.UPSTR		(acif.usif.UPSTR[CRF_DATA_WIDTH-1:0]),
		.UPENDR		(acif.usif.UPENDR[CRF_DATA_WIDTH-1:0]),
		.ac_upsp_rvalid	(acif.usif.ac_upsp_rvalid),
		.ac_upsp_rdata	(acif.usif.ac_upsp_rdata[UPSP_RDDATA_WIDTH-1:0]),
		.ac_upsp_wready	(acif.usif.ac_upsp_wready),
		.m_axis_tready	(acif.stream_slave.axis_tready),
		.m_axis_tvalid	(acif.stream_slave.axis_tvalid),
		.m_axis_tid		(acif.stream_slave.axis_tid),
		.m_axis_tdata	(acif.stream_slave.axis_tdata[AXISOUT_DATA_WIDTH-1:0]),
		.m_axis_tkeep	(acif.stream_slave.axis_tkeep),
		.m_axis_tstrb	(acif.stream_slave.axis_tstrb),
		.m_axis_tlast	(acif.stream_slave.axis_tlast),
		.m_axis_tdest	(acif.stream_slave.axis_tdest),
		.m_axis_tuser		(acif.stream_slave.axis_tuser),
		.clk				(acif.clk),
		.rst_n			(acif.rst_n),
		.upsp_ac_rready		(acif.usif.upsp_ac_rready),
		.upsp_ac_wvalid		(acif.usif.upsp_ac_wvalid),
		.upsp_ac_wdata	(acif.usif.upsp_ac_wdata[UPSP_WRTDATA_WIDTH-1:0]),
		.s_axis_tvalid	(acif.stream_master.axis_tvalid),
		.s_axis_tid		(acif.stream_master.axis_tid),
		.s_axis_tdata	(acif.stream_master.axis_tdata[AXISIN_DATA_WIDTH-1:0]),
		.s_axis_tstrb	(acif.stream_master.axis_tstrb),
		.s_axis_tkeep	(acif.stream_master.axis_tkeep),
		.s_axis_tlast	(acif.stream_master.axis_tlast),
		.s_axis_tdest	(acif.stream_master.axis_tdest),
		.s_axis_tuser		(acif.stream_master.axis_tuser),
		.s_axis_tready	(acif.stream_master.axis_tready),
    );
    */
    access_control #(/*AUTOINSTPARAM*/
		     // Parameters
		     .AXISIN_DATA_WIDTH	(AXISIN_DATA_WIDTH),
		     .AXISOUT_DATA_WIDTH(AXISOUT_DATA_WIDTH),
		     .CRF_DATA_WIDTH	(CRF_DATA_WIDTH),
		     .CRF_ADDR_WIDTH	(CRF_ADDR_WIDTH),
		     .UPSP_RDDATA_WIDTH	(UPSP_RDDATA_WIDTH),
		     .UPSP_WRTDATA_WIDTH(UPSP_WRTDATA_WIDTH),
		     .SRC_IMG_WIDTH	(SRC_IMG_WIDTH),
		     .SRC_IMG_HEIGHT	(SRC_IMG_HEIGHT),
		     .DST_IMG_WIDTH	(DST_IMG_WIDTH),
		     .DST_IMG_HEIGHT	(DST_IMG_HEIGHT),
		     .OUT_FIFO_DEPTH	(OUT_FIFO_DEPTH),
		     .N_PARALLEL	(N_PARALLEL))
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
		       .ac_crf_ac2usm_tvalid(ac_crf_ac2usm_tvalid),
		       .ac_crf_ac2usm_tready(ac_crf_ac2usm_tready),
		       .ac_crf_ac2usm_tlast(ac_crf_ac2usm_tlast),
		       .ac_upsp_rvalid	(acif.usif.ac_upsp_rvalid), // Templated
		       .ac_upsp_rdata	(acif.usif.ac_upsp_rdata[UPSP_RDDATA_WIDTH-1:0]), // Templated
		       .ac_upsp_wready	(acif.usif.ac_upsp_wready), // Templated
		       .ac_upsp_reset	(ac_upsp_reset),
		       .s_axis_tready	(acif.stream_master.axis_tready), // Templated
		       .ac_m_axis_tvalid(ac_m_axis_tvalid),
		       .ac_m_axis_tid	(ac_m_axis_tid),
		       .ac_m_axis_tdata	(ac_m_axis_tdata[AXISOUT_DATA_WIDTH-1:0]),
		       .ac_m_axis_tkeep	(ac_m_axis_tkeep[AXISOUT_STRB_WIDTH-1:0]),
		       .ac_m_axis_tstrb	(ac_m_axis_tstrb[AXISOUT_STRB_WIDTH-1:0]),
		       .ac_m_axis_tlast	(ac_m_axis_tlast),
		       .ac_m_axis_tdest	(ac_m_axis_tdest),
		       .ac_m_axis_tuser	(ac_m_axis_tuser),
		       // Inputs
		       .clk		(acif.clk),		 // Templated
		       .rst_n		(acif.rst_n),		 // Templated
		       .crf_ac_UPSTART	(crf_ac_UPSTART),
		       .crf_ac_UPEND	(crf_ac_UPEND),
		       .crf_ac_wbusy	(crf_ac_wbusy),
		       .upsp_ac_rready	(acif.usif.upsp_ac_rready), // Templated
		       .upsp_ac_wvalid	(acif.usif.upsp_ac_wvalid), // Templated
		       .upsp_ac_wdata	(acif.usif.upsp_ac_wdata[UPSP_WRTDATA_WIDTH-1:0]), // Templated
		       .s_axis_tvalid	(acif.stream_master.axis_tvalid), // Templated
		       .s_axis_tid	(acif.stream_master.axis_tid), // Templated
		       .s_axis_tdata	(acif.stream_master.axis_tdata[AXISIN_DATA_WIDTH-1:0]), // Templated
		       .s_axis_tstrb	(acif.stream_master.axis_tstrb), // Templated
		       .s_axis_tkeep	(acif.stream_master.axis_tkeep), // Templated
		       .s_axis_tlast	(acif.stream_master.axis_tlast), // Templated
		       .s_axis_tdest	(acif.stream_master.axis_tdest), // Templated
		       .s_axis_tuser	(acif.stream_master.axis_tuser), // Templated
		       .ac_m_axis_tready(ac_m_axis_tready),
		       .finnalout_m_axis_tvalid(finnalout_m_axis_tvalid),
		       .finnalout_m_axis_tready(finnalout_m_axis_tready),
		       .finnalout_m_axis_tlast(finnalout_m_axis_tlast));
     
	
    /* bicubic_processing_element AUTO_TEMPLATE (
		    .upsp_ac_rready	(acif.usif.upsp_ac_rready),
		    .upsp_ac_wdata	(acif.usif.upsp_ac_wdata),
		    .upsp_ac_wvalid	(acif.usif.upsp_ac_wvalid),
			.clk			(acif.clk),
			.rst_n			(acif.rst_n),
            .ac_upsp_rdata		(acif.usif.ac_upsp_rdata),
            .ac_upsp_rvalid		(acif.usif.ac_upsp_rvalid),
			.ac_upsp_wready   (acif.usif.ac_upsp_wready),
     );
     */
    bicubic_processing_element #(/*AUTOINSTPARAM*/
				 // Parameters
				 .BUFFER_WIDTH		(BUFFER_WIDTH),
				 .CHANNEL_WIDTH		(CHANNEL_WIDTH),
				 .BLOCK_SIZE		(BLOCK_SIZE))
    AAA_bicubic_processing_element(/*AUTOINST*/
				   // Outputs
				   .upsp_ac_rready	(acif.usif.upsp_ac_rready), // Templated
				   .upsp_ac_wdata	(acif.usif.upsp_ac_wdata), // Templated
				   .upsp_ac_wvalid	(acif.usif.upsp_ac_wvalid), // Templated
				   // Inputs
				   .clk			(acif.clk),	 // Templated
				   .rst_n		(acif.rst_n),	 // Templated
				   .ac_upsp_rdata	(acif.usif.ac_upsp_rdata), // Templated
				   .ac_upsp_rvalid	(acif.usif.ac_upsp_rvalid), // Templated
				   .ac_upsp_wready	(acif.usif.ac_upsp_wready)); // Templated

endmodule
 

/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip_top.svh

 Author: NUDT_CoreLight

 Date: 2021-04-23


 Description:

 **************************************************/

 module bcci_ip_top(ac_if acif);
 
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
	localparam BLOCK_SIZE         = SRC_IMG_WIDTH;

    /*AUTOWIRE*/
 

    /*AUTOREG*/

    /*bcci_ip AUTO_TEMPLATE(
	     // Outputs
	     .s_axi_awready		(acif.lite_master.axi_awready),
	     .s_axi_wready		(acif.lite_master.axi_wready),
	     .s_axi_bvalid		(acif.lite_master.axi_bvalid),
	     .s_axi_bresp		(acif.lite_master.axi_bresp),
	     .s_axi_arready		(acif.lite_master.axi_arready),
	     .s_axi_rvalid		(acif.lite_master.axi_rvalid),
	     .s_axi_rdata		(acif.lite_master.axi_rdata),
	     .s_axi_rresp		(acif.lite_master.axi_rresp[1:0]),
	     .s_axis_tready		(acif.stream_master.axis_tready),
	     .m_axis_tvalid		(acif.stream_slave.axis_tvalid),
	     .m_axis_tid		(acif.stream_slave.axis_tid),
	     .m_axis_tdata		(acif.stream_slave.axis_tdata),
	     .m_axis_tkeep		(acif.stream_slave.axis_tkeep),
	     .m_axis_tstrb		(acif.stream_slave.axis_tstrb),
	     .m_axis_tlast		(acif.stream_slave.axis_tlast),
	     .m_axis_tdest		(acif.stream_slave.axis_tdest),
	     .m_axis_user		(acif.stream_slave.axis_user),
	     .interrupt_updone	(acif.interrupt_updone),
	     // Inputs
	     .clk			    (acif.clk),
	     .rst_n			    (acif.rst_n),
	     .s_axi_awvalid		(acif.lite_master.axi_awvalid),
	     .s_axi_awaddr		(acif.lite_master.axi_awaddr),
	     .s_axi_awprot		(acif.lite_master.axi_awprot[2:0]),
	     .s_axi_wvalid		(acif.lite_master.axi_wvalid),
	     .s_axi_wdata		(acif.lite_master.axi_wdata),
	     .s_axi_wstrb		(acif.lite_master.axi_wstrb),
	     .s_axi_bready		(acif.lite_master.axi_bready),
	     .s_axi_arvalid		(acif.lite_master.axi_arvalid),
	     .s_axi_araddr		(acif.lite_master.axi_araddr),
	     .s_axi_arprot		(acif.lite_master.axi_arprot[2:0]),
	     .s_axi_rready		(acif.lite_master.axi_rready),
	     .s_axis_tvalid		(acif.stream_master.axis_tvalid),
	     .s_axis_tid		(acif.stream_master.axis_tid),
	     .s_axis_tdata		(acif.stream_master.axis_tdata),
	     .s_axis_tstrb		(acif.stream_master.axis_tstrb),
	     .s_axis_tkeep		(acif.stream_master.axis_tkeep),
	     .s_axis_tlast		(acif.stream_master.axis_tlast),
	     .s_axis_tdest		(acif.stream_master.axis_tdest),
	     .s_axis_user		(acif.stream_master.axis_user),
	     .m_axis_tready		(acif.stream_slave.axis_tready),
    )*/

    bcci_ip #(/*AUTOINSTPARAM*/
	      // Parameters
	      .AXI_DATA_WIDTH		(AXI_DATA_WIDTH),
	      .AXI_ADDR_WIDTH		(AXI_ADDR_WIDTH),
	      .AXISIN_DATA_WIDTH	(AXISIN_DATA_WIDTH),
	      .AXISOUT_DATA_WIDTH	(AXISOUT_DATA_WIDTH),
	      .CRF_DATA_WIDTH		(CRF_DATA_WIDTH),
	      .CRF_ADDR_WIDTH		(CRF_ADDR_WIDTH),
	      .UPSP_RDDATA_WIDTH	(UPSP_RDDATA_WIDTH),
	      .UPSP_WRTDATA_WIDTH	(UPSP_WRTDATA_WIDTH),
	      .SRC_IMG_WIDTH		(SRC_IMG_WIDTH),
	      .SRC_IMG_HEIGHT		(SRC_IMG_HEIGHT),
	      .DST_IMG_WIDTH		(DST_IMG_WIDTH),
	      .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
	      .BUFFER_WIDTH		(BUFFER_WIDTH),
	      .OUT_FIFO_DEPTH		(OUT_FIFO_DEPTH),
	      .CHANNEL_WIDTH		(CHANNEL_WIDTH),
	      .BLOCK_SIZE		(BLOCK_SIZE))
    AAA_bcci(/*AUTOINST*/
	     // Outputs
	     .s_axi_awready		(acif.lite_master.axi_awready), // Templated
	     .s_axi_wready		(acif.lite_master.axi_wready), // Templated
	     .s_axi_bvalid		(acif.lite_master.axi_bvalid), // Templated
	     .s_axi_bresp		(acif.lite_master.axi_bresp), // Templated
	     .s_axi_arready		(acif.lite_master.axi_arready), // Templated
	     .s_axi_rvalid		(acif.lite_master.axi_rvalid), // Templated
	     .s_axi_rdata		(acif.lite_master.axi_rdata), // Templated
	     .s_axi_rresp		(acif.lite_master.axi_rresp[1:0]), // Templated
	     .s_axis_tready		(acif.stream_master.axis_tready), // Templated
	     .m_axis_tvalid		(acif.stream_slave.axis_tvalid), // Templated
	     .m_axis_tid		(acif.stream_slave.axis_tid), // Templated
	     .m_axis_tdata		(acif.stream_slave.axis_tdata), // Templated
	     .m_axis_tkeep		(acif.stream_slave.axis_tkeep), // Templated
	     .m_axis_tstrb		(acif.stream_slave.axis_tstrb), // Templated
	     .m_axis_tlast		(acif.stream_slave.axis_tlast), // Templated
	     .m_axis_tdest		(acif.stream_slave.axis_tdest), // Templated
	     .m_axis_user		(acif.stream_slave.axis_user), // Templated
	     .interrupt_updone		(acif.interrupt_updone), // Templated
	     // Inputs
	     .clk			(acif.clk),		 // Templated
	     .rst_n			(acif.rst_n),		 // Templated
	     .s_axi_awvalid		(acif.lite_master.axi_awvalid), // Templated
	     .s_axi_awaddr		(acif.lite_master.axi_awaddr), // Templated
	     .s_axi_awprot		(acif.lite_master.axi_awprot[2:0]), // Templated
	     .s_axi_wvalid		(acif.lite_master.axi_wvalid), // Templated
	     .s_axi_wdata		(acif.lite_master.axi_wdata), // Templated
	     .s_axi_wstrb		(acif.lite_master.axi_wstrb), // Templated
	     .s_axi_bready		(acif.lite_master.axi_bready), // Templated
	     .s_axi_arvalid		(acif.lite_master.axi_arvalid), // Templated
	     .s_axi_araddr		(acif.lite_master.axi_araddr), // Templated
	     .s_axi_arprot		(acif.lite_master.axi_arprot[2:0]), // Templated
	     .s_axi_rready		(acif.lite_master.axi_rready), // Templated
	     .s_axis_tvalid		(acif.stream_master.axis_tvalid), // Templated
	     .s_axis_tid		(acif.stream_master.axis_tid), // Templated
	     .s_axis_tdata		(acif.stream_master.axis_tdata), // Templated
	     .s_axis_tstrb		(acif.stream_master.axis_tstrb), // Templated
	     .s_axis_tkeep		(acif.stream_master.axis_tkeep), // Templated
	     .s_axis_tlast		(acif.stream_master.axis_tlast), // Templated
	     .s_axis_tdest		(acif.stream_master.axis_tdest), // Templated
	     .s_axis_user		(acif.stream_master.axis_user), // Templated
	     .m_axis_tready		(acif.stream_slave.axis_tready)); // Templated

endmodule
 

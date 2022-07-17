/*************************************************

 Copyright: NUDT_CoreLight

 File name: bcci_ip.sv

 Author: NUDT_CoreLight

 Date: 2021-04-11


 Description:

 **************************************************/

module bcci_ip
#(
	parameter N_PARALLEL         = `N_PARALLEL        ,
    parameter AXI_DATA_WIDTH     = `AXI_DATA_WIDTH    ,
    parameter AXI_ADDR_WIDTH     = `AXI_ADDR_WIDTH    ,
    parameter AXISIN_DATA_WIDTH  = `AXISIN_DATA_WIDTH ,
    parameter CRF_DATA_WIDTH     = `CRF_DATA_WIDTH    ,
    parameter CRF_ADDR_WIDTH     = `CRF_ADDR_WIDTH    ,
    parameter SRC_IMG_WIDTH      = `SRC_IMG_WIDTH     ,
    parameter SRC_IMG_HEIGHT     = `SRC_IMG_HEIGHT    ,
	parameter BUFFER_WIDTH       = `BUFFER_WIDTH      ,
	parameter OUT_FIFO_DEPTH     = `OUT_FIFO_DEPTH    ,
	parameter CHANNEL_WIDTH      = 8,

	parameter AXISOUT_DATA_WIDTH = 24*4*N_PARALLEL     ,
	parameter AXI_STRB_WIDTH     = AXI_DATA_WIDTH/8    ,
	parameter AXISIN_STRB_WIDTH  = AXISIN_DATA_WIDTH/8 ,
	parameter AXISOUT_STRB_WIDTH = AXISOUT_DATA_WIDTH/8
)
(/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bvalid, s_axi_bresp,
   s_axi_arready, s_axi_rvalid, s_axi_rdata, s_axi_rresp,
   s_axis_tready, m_axis_tvalid, m_axis_tid, m_axis_tdata,
   m_axis_tkeep, m_axis_tstrb, m_axis_tlast, m_axis_tdest,
   m_axis_tuser, interrupt_updone,
   // Inputs
   clk, rst_n, s_axi_awvalid, s_axi_awaddr, s_axi_awprot,
   s_axi_wvalid, s_axi_wdata, s_axi_wstrb, s_axi_bready,
   s_axi_arvalid, s_axi_araddr, s_axi_arprot, s_axi_rready,
   s_axis_tvalid, s_axis_tid, s_axis_tdata, s_axis_tstrb,
   s_axis_tkeep, s_axis_tlast, s_axis_tdest, s_axis_tuser,
   m_axis_tready
   );

	localparam UPSP_RDDATA_WIDTH  = 24;
	localparam UPSP_WRTDATA_WIDTH = 24*4;
    localparam DST_IMG_WIDTH      = SRC_IMG_WIDTH*4;
    localparam DST_IMG_HEIGHT     = SRC_IMG_HEIGHT*4;
	localparam COV_SIZE           = 3;
	localparam CH_WIDTH           = 8;
	localparam WEIGHT_WIDTH       = 8;

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
	input [AXISIN_DATA_WIDTH-1:0] s_axis_tdata;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tstrb;
	input [AXISIN_STRB_WIDTH-1:0] s_axis_tkeep;
	input                       s_axis_tlast;
	input                       s_axis_tdest;
	input                       s_axis_tuser;

	// Interface as AXI-Stream master, out
	output                       m_axis_tvalid;	
	input                        m_axis_tready;
	output                       m_axis_tid;
	output [AXISOUT_DATA_WIDTH-1:0] m_axis_tdata;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tkeep;
	output [AXISOUT_STRB_WIDTH-1:0] m_axis_tstrb;
	output                       m_axis_tlast;
	output                       m_axis_tdest;
	output                       m_axis_tuser;

	// Intterupt when finished
	output interrupt_updone;

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
    wire		ac_m_axis_tready;	// From AAA_stream_transformer of stream_transformer.v
    wire [AXISOUT_STRB_WIDTH-1:0] ac_m_axis_tstrb;// From AAA_access_control of access_control.v
    wire		ac_m_axis_tuser;	// From AAA_access_control of access_control.v
    wire		ac_m_axis_tvalid;	// From AAA_access_control of access_control.v
    wire		ac_upsp_reset;		// From AAA_access_control of access_control.v
    wire		crf_ac_UPEND;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_UPSTART;		// From AAA_config_register_file of config_register_file.v
    wire		crf_ac_wbusy;		// From AAA_config_register_file of config_register_file.v
    wire		m_axis_user;		// From AAA_usm of usm.v
    wire [AXISOUT_DATA_WIDTH-1:0] st_usm_axis_tdata;// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tdest;	// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tid;	// From AAA_stream_transformer of stream_transformer.v
    wire [AXISOUT_STRB_WIDTH-1:0] st_usm_axis_tkeep;// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tlast;	// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tready;	// From AAA_usm of usm.v
    wire [AXISOUT_STRB_WIDTH-1:0] st_usm_axis_tstrb;// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tuser;	// From AAA_stream_transformer of stream_transformer.v
    wire		st_usm_axis_tvalid;	// From AAA_stream_transformer of stream_transformer.v
    wire		trans_m_axis_tlast;	// From AAA_stream_transformer of stream_transformer.v
    wire		trans_m_axis_tready;	// From AAA_stream_transformer of stream_transformer.v
    wire		trans_m_axis_tvalid;	// From AAA_stream_transformer of stream_transformer.v
    // End of automatics


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg			m_axis_tuser;
    // End of automatics



	wire [N_PARALLEL-1:0]					 upsp_ac_rready;
	wire [N_PARALLEL-1:0]         		     ac_upsp_rvalid;
	wire [UPSP_RDDATA_WIDTH-1:0]             ac_upsp_rdata;
	wire [N_PARALLEL-1:0]                    ac_upsp_wready;
	wire [N_PARALLEL-1:0]                    upsp_ac_wvalid;
	wire [N_PARALLEL*UPSP_WRTDATA_WIDTH-1:0] upsp_ac_wdata;

    /* config_register_file AUTO_TEMPLATE(
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
			     .ac_crf_processing	(ac_crf_processing),
			     .ac_crf_ac2usm_tvalid(ac_crf_ac2usm_tvalid),
			     .ac_crf_ac2usm_tready(ac_crf_ac2usm_tready),
			     .ac_crf_ac2usm_tlast(ac_crf_ac2usm_tlast),
			     .upsp_ac_rready	(upsp_ac_rready[N_PARALLEL-1:0]));


    /* access_control AUTO_TEMPLATE (
		.finnalout_m_axis_tvalid(m_axis_tvalid),
		.finnalout_m_axis_tready(m_axis_tready),
		.finnalout_m_axis_tlast(m_axis_tlast),
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
		       .ac_upsp_rvalid	(ac_upsp_rvalid[N_PARALLEL-1:0]),
		       .ac_upsp_rdata	(ac_upsp_rdata[UPSP_RDDATA_WIDTH-1:0]),
		       .ac_upsp_wready	(ac_upsp_wready[N_PARALLEL-1:0]),
		       .ac_upsp_reset	(ac_upsp_reset),
		       .s_axis_tready	(s_axis_tready),
		       .ac_m_axis_tvalid(ac_m_axis_tvalid),
		       .ac_m_axis_tid	(ac_m_axis_tid),
		       .ac_m_axis_tdata	(ac_m_axis_tdata[AXISOUT_DATA_WIDTH-1:0]),
		       .ac_m_axis_tkeep	(ac_m_axis_tkeep[AXISOUT_STRB_WIDTH-1:0]),
		       .ac_m_axis_tstrb	(ac_m_axis_tstrb[AXISOUT_STRB_WIDTH-1:0]),
		       .ac_m_axis_tlast	(ac_m_axis_tlast),
		       .ac_m_axis_tdest	(ac_m_axis_tdest),
		       .ac_m_axis_tuser	(ac_m_axis_tuser),
		       // Inputs
		       .clk		(clk),
		       .rst_n		(rst_n),
		       .crf_ac_UPSTART	(crf_ac_UPSTART),
		       .crf_ac_UPEND	(crf_ac_UPEND),
		       .crf_ac_wbusy	(crf_ac_wbusy),
		       .upsp_ac_rready	(upsp_ac_rready[N_PARALLEL-1:0]),
		       .upsp_ac_wvalid	(upsp_ac_wvalid[N_PARALLEL-1:0]),
		       .upsp_ac_wdata	(upsp_ac_wdata[N_PARALLEL*UPSP_WRTDATA_WIDTH-1:0]),
		       .s_axis_tvalid	(s_axis_tvalid),
		       .s_axis_tid	(s_axis_tid),
		       .s_axis_tdata	(s_axis_tdata[AXISIN_DATA_WIDTH-1:0]),
		       .s_axis_tstrb	(s_axis_tstrb[AXISIN_STRB_WIDTH-1:0]),
		       .s_axis_tkeep	(s_axis_tkeep[AXISIN_STRB_WIDTH-1:0]),
		       .s_axis_tlast	(s_axis_tlast),
		       .s_axis_tdest	(s_axis_tdest),
		       .s_axis_tuser	(s_axis_tuser),
		       .ac_m_axis_tready(ac_m_axis_tready),
		       .finnalout_m_axis_tvalid(m_axis_tvalid),	 // Templated
		       .finnalout_m_axis_tready(m_axis_tready),	 // Templated
		       .finnalout_m_axis_tlast(m_axis_tlast));	 // Templated

	// N processing elements
	genvar j;
	generate
		for(j = 0; j < N_PARALLEL; j=j+1) begin: MULTI_PROC_ELE

			localparam BLOCK_SIZE = (j==0)?(((N_PARALLEL==1)?SRC_IMG_WIDTH/N_PARALLEL:(SRC_IMG_WIDTH/N_PARALLEL) + 3))
								    :(j<N_PARALLEL-1)?(SRC_IMG_WIDTH/N_PARALLEL) + 3
									:SRC_IMG_WIDTH/N_PARALLEL;

    		bicubic_processing_element #(
						 // Parameters
						 .BUFFER_WIDTH		(BUFFER_WIDTH),
						 .CHANNEL_WIDTH		(CHANNEL_WIDTH),
						 .BLOCK_SIZE		(BLOCK_SIZE))
    		AAA_bicubic_processing_element(
						   // Outputs
						   .upsp_ac_rready	(upsp_ac_rready[j]),
						   .upsp_ac_wdata	(upsp_ac_wdata[j*UPSP_WRTDATA_WIDTH+:UPSP_WRTDATA_WIDTH]),
						   .upsp_ac_wvalid	(upsp_ac_wvalid[j]),
						   // Inputs
						   .clk			(clk),
						   .rst_n		(rst_n & (~ac_upsp_reset)),
						   .ac_upsp_rdata	(ac_upsp_rdata),
						   .ac_upsp_rvalid	(ac_upsp_rvalid[j]),
						   .ac_upsp_wready	(ac_upsp_wready[j]));

		end
	endgenerate


	/* stream_transformer AUTO_TEMPLATE(
		.m_axis_tvalid	(st_usm_axis_tvalid),
		.m_axis_tid	    (st_usm_axis_tid),
		.m_axis_tdata	(st_usm_axis_tdata[AXISOUT_DATA_WIDTH-1:0]),
		.m_axis_tkeep	(st_usm_axis_tkeep[AXISOUT_STRB_WIDTH-1:0]),
		.m_axis_tstrb	(st_usm_axis_tstrb[AXISOUT_STRB_WIDTH-1:0]),
		.m_axis_tlast	(st_usm_axis_tlast),
		.m_axis_tdest	(st_usm_axis_tdest),
		.m_axis_tuser	(st_usm_axis_tuser),
		.m_axis_tready	(st_usm_axis_tready),
	)
	*/
	stream_transformer # (/*AUTOINSTPARAM*/
			      // Parameters
			      .AXISOUT_DATA_WIDTH(AXISOUT_DATA_WIDTH),
			      .DST_IMG_WIDTH	(DST_IMG_WIDTH))
	AAA_stream_transformer(/*AUTOINST*/
			       // Outputs
			       .ac_m_axis_tready(ac_m_axis_tready),
			       .m_axis_tvalid	(st_usm_axis_tvalid), // Templated
			       .m_axis_tid	(st_usm_axis_tid), // Templated
			       .m_axis_tdata	(st_usm_axis_tdata[AXISOUT_DATA_WIDTH-1:0]), // Templated
			       .m_axis_tkeep	(st_usm_axis_tkeep[AXISOUT_STRB_WIDTH-1:0]), // Templated
			       .m_axis_tstrb	(st_usm_axis_tstrb[AXISOUT_STRB_WIDTH-1:0]), // Templated
			       .m_axis_tlast	(st_usm_axis_tlast), // Templated
			       .m_axis_tdest	(st_usm_axis_tdest), // Templated
			       .m_axis_tuser	(st_usm_axis_tuser), // Templated
			       .trans_m_axis_tvalid(trans_m_axis_tvalid),
			       .trans_m_axis_tready(trans_m_axis_tready),
			       .trans_m_axis_tlast(trans_m_axis_tlast),
			       // Inputs
			       .clk		(clk),
			       .rst_n		(rst_n),
			       .ac_m_axis_tvalid(ac_m_axis_tvalid),
			       .ac_m_axis_tid	(ac_m_axis_tid),
			       .ac_m_axis_tdata	(ac_m_axis_tdata[AXISOUT_DATA_WIDTH-1:0]),
			       .ac_m_axis_tkeep	(ac_m_axis_tkeep[AXISOUT_STRB_WIDTH-1:0]),
			       .ac_m_axis_tstrb	(ac_m_axis_tstrb[AXISOUT_STRB_WIDTH-1:0]),
			       .ac_m_axis_tlast	(ac_m_axis_tlast),
			       .ac_m_axis_tdest	(ac_m_axis_tdest),
			       .ac_m_axis_tuser	(ac_m_axis_tuser),
			       .m_axis_tready	(st_usm_axis_tready)); // Templated



	/* usm AUTO_TEMPLATE(
		.s_axis_tvalid		(st_usm_axis_tvalid),
		.s_axis_tid		    (st_usm_axis_tid),
		.s_axis_tdata		(st_usm_axis_tdata),
		.s_axis_tkeep		(st_usm_axis_tkeep),
		.s_axis_tstrb		(st_usm_axis_tstrb),
		.s_axis_tlast		(st_usm_axis_tlast),
		.s_axis_tdest		(st_usm_axis_tdest),
		.s_axis_user		(st_usm_axis_user),
		.s_axis_tready		(st_usm_axis_tready),
		.m_axis_tdata		(m_axis_tdata),
		.m_axis_tkeep		(m_axis_tkeep),
		.m_axis_tstrb		(m_axis_tstrb),
	)
	*/
	usm # (
	       .AXIS_DATA_WIDTH		(AXISOUT_DATA_WIDTH),
	       .AXIS_STRB_WIDTH		(AXISOUT_STRB_WIDTH),
	       .COV_SIZE		(COV_SIZE),
	       .CH_WIDTH		(CH_WIDTH),
	       .WEIGHT_WIDTH		(WEIGHT_WIDTH),
	       .DST_IMAGE_WIDTH		(DST_IMG_WIDTH),
	       .DST_IMAGE_HEIGHT	(DST_IMG_HEIGHT))
	AAA_usm(/*AUTOINST*/
		// Outputs
		.s_axis_tready		(st_usm_axis_tready),	 // Templated
		.m_axis_tvalid		(m_axis_tvalid),
		.m_axis_tid		(m_axis_tid),
		.m_axis_tdata		(m_axis_tdata),		 // Templated
		.m_axis_tkeep		(m_axis_tkeep),		 // Templated
		.m_axis_tstrb		(m_axis_tstrb),		 // Templated
		.m_axis_tlast		(m_axis_tlast),
		.m_axis_tdest		(m_axis_tdest),
		.m_axis_user		(m_axis_user),
		// Inputs
		.s_axis_tvalid		(st_usm_axis_tvalid),	 // Templated
		.s_axis_tid		(st_usm_axis_tid),	 // Templated
		.s_axis_tdata		(st_usm_axis_tdata),	 // Templated
		.s_axis_tkeep		(st_usm_axis_tkeep),	 // Templated
		.s_axis_tstrb		(st_usm_axis_tstrb),	 // Templated
		.s_axis_tlast		(st_usm_axis_tlast),	 // Templated
		.s_axis_tdest		(st_usm_axis_tdest),	 // Templated
		.s_axis_user		(st_usm_axis_user),	 // Templated
		.m_axis_tready		(m_axis_tready),
		.clk			(clk),
		.rst_n			(rst_n));

endmodule

/*************************************************

 Copyright: NUDT_CoreLight

 File name: ac_outbuf.v

 Author: NUDT_CoreLight

 Date: 2021-05-03


 Description:

 Output buffer for access control module. UPSP output 4 pixels every time, when paralleling,
 the IP-to-PS AXI-Stream bus must be wider, multiple of 4.
 **************************************************/

module ac_outbuf # (
        parameter UPSP_WRTDATA_WIDTH     = 24,
        parameter DST_IMG_WIDTH          = 4096,
        parameter DST_IMG_HEIGHT         = 2160,
        parameter N_PARALLEL	         = 2
) (/*AUTOARG*/
   // Outputs
   buf_wready, buf_rdata, buf_empty,
   // Inputs
   clk, rst_n, buf_wvalid, buf_wdata, buf_rd
   );
    localparam IMG_CNT_WIDTH = $clog2(DST_IMG_WIDTH*DST_IMG_HEIGHT);
    localparam BLOCK_SIZE    = (DST_IMG_WIDTH/N_PARALLEL);
    localparam N_FIFO        = N_PARALLEL;
    localparam N_PARALLEL_B2 = $clog2(N_PARALLEL);

    input clk  ;
    input rst_n;

	// Write channel
	input                           buf_wvalid;
	input  [UPSP_WRTDATA_WIDTH-1:0] buf_wdata;
    output                          buf_wready;

	// Read channel
	input                                       buf_rd;
	output  [UPSP_WRTDATA_WIDTH*N_PARALLEL-1:0] buf_rdata;
    output                                      buf_empty;

    /*AUTOWIRE*/


    /*AUTOREG*/

    // upsp_outbuf to transform the data

    wire [[UPSP_WRTDATA_WIDTH-1:0]] aligned_data;
    wire aligned_empty;
    wire aligned_rd;
    reg  aligned_data_valid;

    always@(posedge clk or negedge rst_n) begin:ALIGN_VALID
        if(~rst_n)
            aligned_data_valid <= 1'b1;
        else
            aligned_data_valid <= aligned_rd;
    end

	upsp_outbuf #(
		  .DATA_WIDTH		(UPSP_WRTDATA_WIDTH),
		  .DEPTH		(4),
		  .DST_IMG_HEIGHT		(DST_IMG_HEIGHT),
		  .DST_IMG_WIDTH	(DST_IMG_WIDTH))
	obuf(/*AUTOINST*/
	     // Outputs
	     .buf_wready		(buf_wready),		 // Templated
	     .buf_rdata			(aligned_data),		 // Templated
	     .buf_empty			(aligned_empty),		 // Templated
	     // Inputs
	     .clk			(clk),			 // Templated
	     .rst_n			(rst_n),	 // Templated
	     .buf_wvalid		(buf_wvalid),		 // Templated
	     .buf_wdata			(buf_wdata),	 // Templated
	     .buf_rd			(aligned_rd));		 // Templated



    // Use multiple fifos to hold the transformed data in a wider form.
    reg [IMG_CNT_WIDTH-1:0]  write_count;
    wire [IMG_CNT_WIDTH-1:0] write_count_inrow;
    wire [N_PARALLEL_B2-1:0] write_count_inrow_nfifo;
    assign write_count_inrow = (write_count % DST_IMG_WIDTH);
    // assign write_count_inrow_nfifo = (write_count_inrow/4) % N_PARALLEL;

    localparam N_ROW_PACKAGE = DST_IMG_WIDTH/4;
    localparam ROWEND_POS = (N_ROW_PACKAGE-1) % N_PARALLEL;

    reg [N_FIFO-1:0] mask;
    reg [N_FIFO-1:0] write_mask;
    genvar j;
    generate
        for(j = 0; j< N_PARALLEL; j=j+1) begin
            assign mask[j] = (write_count_inrow_nfifo == j)?1'b1:1'b0;
        end
    endgenerate

    always@(*) begin: WRT_MASK
        if(write_count_inrow == DST_IMG_WIDTH - 4)
            write_mask = {{(N_FIFO-ROWEND_POS){1'b1}}, {(ROWEND_POS){1'b0}}};
        else
            write_mask = mask;
    end

    // Fifos
    wire [N_FIFO-1:0] fifo_empty;
    wire [N_FIFO-1:0] fifo_full;
    wire [N_FIFO-1:0] fifo_wrt;
    wire [N_FIFO-1:0] fifo_rd;
    wire [UPSP_WRTDATA_WIDTH-1:0] fifo_odata[N_FIFO-1:0];
    wire [UPSP_WRTDATA_WIDTH-1:0] fifo_idata[N_FIFO-1:0];


    assign aligned_rd = ~aligned_empty & fifo_wready;
    assign fifo_wrt = aligned_data_valid?{N_FIFO{1'b1}}:{N_FIFO{1'b0}};
    assign fifo_wready = ~(|fifo_full);
    assign buf_empty = (&fifo_empty) || (write_count == DST_IMG_HEIGHT*DST_IMG_WIDTH);
    assign fifo_rd   = buf_rd?{N_FIFO{1'b1}}:{N_FIFO{1'b0}};

    // Counter for already written data.
    always@(posedge clk or negedge rst_n) begin: WRT_COUNT
        if(~rst_n) begin
            /*AUTORESET*/
	        // Beginning of autoreset for uninitialized flops
	        write_count <= {IMG_CNT_WIDTH{1'b0}};
	        // End of automatics
        end else if((|fifo_wrt) & fifo_wready) begin
			write_count <= write_count + 4;

            if(write_count_inrow_nfifo == N_FIFO - 1)
                write_count_inrow_nfifo <= 0;
            else
                write_count_inrow_nfifo <= write_count_inrow_nfifo + 1;
        end
    end


    // genvar j;
    generate
        for(j = 0; j < N_FIFO; j=j+1) begin
            fifo #(
	           .FIFO_DEPTH			(DST_IMG_HEIGHT*2),
	           .FIFO_WIDTH			(UPSP_WRTDATA_WIDTH))
            ofifo(
		        // Outputs
		        .fifo_odata		(fifo_odata[j]),
		        .fifo_empty		(fifo_empty[j]),
		        .fifo_full		(fifo_full[j]),
		        // Inputs
		        .clk			(clk),
		        .rst_n		(rst_n),
		        .fifo_rd		(fifo_rd[j]),
		        .fifo_wrt		(fifo_wrt[j]&write_mask[j]&fifo_wready),
		        .fifo_idata		(fifo_idata[j]));

            // Buf write data
            assign fifo_idata[j] = aligned_data;

            // Buf read data
            assign buf_rdata[j*UPSP_WRTDATA_WIDTH+:UPSP_WRTDATA_WIDTH] = fifo_odata[j];

        end
    endgenerate


// Additional code for easy debugging
`ifndef DISABLE_DEBUG_CODE

`endif

endmodule

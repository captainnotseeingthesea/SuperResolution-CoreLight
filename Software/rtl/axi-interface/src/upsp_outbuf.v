/*************************************************

 Copyright: NUDT_CoreLight

 File name: upsp_outbuf.v

 Author: NUDT_CoreLight

 Date: 2021-06-18


 Description:

 Output buffer for Up-Sampling module, implemented by fifos.
 Every read is 4-pixel.
 **************************************************/

module upsp_outbuf # (
        parameter DATA_WIDTH     = 24,
		parameter DEPTH          = 32,
        parameter DST_IMG_WIDTH  = 4096,
        parameter DST_IMG_HEIGHT = 2160
) (/*AUTOARG*/
   // Outputs
   buf_wready, buf_rdata, buf_empty,
   // Inputs
   clk, rst_n, buf_wvalid, buf_wdata, buf_rd
   );
    localparam IMG_CNT_WIDTH      = $clog2(DST_IMG_WIDTH*DST_IMG_HEIGHT);
    localparam N_BUF_FIFO         = DATA_WIDTH/24;

    input clk  ;
    input rst_n;

	// Write channel
	input                   buf_wvalid;
	input  [DATA_WIDTH-1:0] buf_wdata;
    output                  buf_wready;

	// Read channel
	input                    buf_rd;
	output  [DATA_WIDTH-1:0] buf_rdata;
    output                   buf_empty;

    /*AUTOWIRE*/


    /*AUTOREG*/


    /* This buffer contains many fifos, each fifo is 1-pixel width.
      First and last writes of a line contain only two pixels.
    */
    reg [IMG_CNT_WIDTH-1:0] write_count;
    reg [IMG_CNT_WIDTH-1:0] write_count_inrow;
    // assign write_count_inrow = (write_count % DST_IMG_WIDTH);

    reg [N_BUF_FIFO-1:0] write_mask;
    always@(*) begin: WRT_MASK
        if(write_count_inrow == 0)
            write_mask = {2'b0,{(N_BUF_FIFO-2){1'b1}}};
        else if(write_count_inrow == DST_IMG_WIDTH-2)
            write_mask = {{(N_BUF_FIFO-2){1'b1}}, 2'b0};
        else
            write_mask = {N_BUF_FIFO{1'b1}};
    end

    reg [IMG_CNT_WIDTH-1:0] write_num;
    integer i;
    always@(*) begin: WRT_NUM
        write_num = 0;
        for(i = 0; i < N_BUF_FIFO; i=i+1) begin
            if(write_mask[i])
                write_num = write_num + 1;
            else
                write_num = write_num;
        end
    end
    
    // Counter for already written data.
    always@(posedge clk or negedge rst_n) begin: WRT_COUNT
        if(~rst_n) begin
            /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    write_count <= {IMG_CNT_WIDTH{1'b0}};
	    write_count_inrow <= {IMG_CNT_WIDTH{1'b0}};
	    // End of automatics
        end else if(buf_wvalid & buf_wready) begin
			write_count <= write_count + write_num;

            if(write_count_inrow + write_num >= DST_IMG_WIDTH)
                write_count_inrow <= write_count_inrow + write_num - DST_IMG_WIDTH;
            else
                write_count_inrow <= write_count_inrow + write_num;
        end
    end


    // Fifos
    wire [N_BUF_FIFO-1:0] fifo_empty;
    wire [N_BUF_FIFO-1:0] fifo_full;
    wire [N_BUF_FIFO-1:0] fifo_wrt;
    wire [N_BUF_FIFO-1:0] fifo_rd;
    wire [23:0] fifo_odata[N_BUF_FIFO-1:0];
    wire [23:0] fifo_idata[N_BUF_FIFO-1:0];

    assign fifo_wrt = buf_wvalid?{N_BUF_FIFO{1'b1}}:{N_BUF_FIFO{1'b0}};
    assign buf_wready = ~(|fifo_full);
    assign buf_empty = |fifo_empty;
    assign fifo_rd   = buf_rd?{N_BUF_FIFO{1'b1}}:{N_BUF_FIFO{1'b0}};

    genvar j;
    generate
        for(j = 0; j < N_BUF_FIFO; j=j+1) begin
            fifo #(
	           .FIFO_DEPTH			(DEPTH),
	           .FIFO_WIDTH			(24))
            ofifo(
		        // Outputs
		        .fifo_odata		(fifo_odata[j]),
		        .fifo_empty		(fifo_empty[j]),
		        .fifo_full		(fifo_full[j]),
		        // Inputs
		        .clk			(clk),
		        .rst_n		(rst_n),
		        .fifo_rd		(fifo_rd[j]),
		        .fifo_wrt		(fifo_wrt[j]&write_mask[j]&buf_wready),
		        .fifo_idata		(fifo_idata[j]));

            // Buf write data
            assign fifo_idata[j] = buf_wdata[24*j+23:24*j];

            // Buf read data
            if(j >= N_BUF_FIFO - 2) 
                assign buf_rdata[(j+2-N_BUF_FIFO)*24+23:(j+2-N_BUF_FIFO)*24] = fifo_odata[j];
            else
                assign buf_rdata[24*j+23+48:24*j+48] = fifo_odata[j];

        end
    endgenerate


// Additional code for easy debugging
`ifndef DISABLE_DEBUG_CODE

`endif

endmodule

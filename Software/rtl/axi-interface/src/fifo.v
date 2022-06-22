/*************************************************

 Copyright: NUDT_CoreLight

 File name: fifo.v

 Author: NUDT_CoreLight

 Date: 2021-03-27


 Description:

 Fifo based on bram.
 **************************************************/
module fifo # (
    parameter  FIFO_DEPTH = 128,
    parameter  FIFO_WIDTH = 24
)(
    /*AUTOARG*/
   // Outputs
   fifo_odata, fifo_empty, fifo_full,
   // Inputs
   clk, rst_n, fifo_rd, fifo_wrt, fifo_idata
   );

    localparam FIFO_COUNT_WIDTH = $clog2(FIFO_DEPTH);

    input clk;
    input rst_n;

    input                   fifo_rd;
    output [FIFO_WIDTH-1:0] fifo_odata;

    input                   fifo_wrt;
    input  [FIFO_WIDTH-1:0] fifo_idata;

    output                  fifo_empty;
    output                  fifo_full;


    /*AUTOWIRE*/


    /*AUTOREG*/

	// fifo read/write count
	reg [FIFO_COUNT_WIDTH:0]  fifo_rd_count, fifo_wrt_count;
    
	// fifo read/write pointer
	wire [FIFO_COUNT_WIDTH:0] rd_sub = fifo_rd_count - FIFO_DEPTH;
	wire [FIFO_COUNT_WIDTH:0] wrt_sub = fifo_wrt_count - FIFO_DEPTH;

	wire [FIFO_COUNT_WIDTH-1:0] fifo_rd_ptr  = (fifo_rd_count<FIFO_DEPTH)?fifo_rd_count:rd_sub;
	wire [FIFO_COUNT_WIDTH-1:0] fifo_wrt_ptr = (fifo_wrt_count<FIFO_DEPTH)?fifo_wrt_count:wrt_sub;

	// Empty and full signals
	wire fifo_ptrsame = (fifo_rd_ptr == fifo_wrt_ptr)?1'b1:1'b0;
	wire fifo_empty = fifo_ptrsame & (fifo_rd_count == fifo_wrt_count);
	wire fifo_full  = fifo_ptrsame & (fifo_rd_count != fifo_wrt_count);

	// Fifo count management
	always @(posedge clk or negedge rst_n) begin: fifo_MANAGE
		if(~rst_n) begin
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			fifo_rd_count <= {(1+(FIFO_COUNT_WIDTH)){1'b0}};
			fifo_wrt_count <= {(1+(FIFO_COUNT_WIDTH)){1'b0}};
			// End of automatics
		end else begin
			if(fifo_wrt & ~fifo_full)
				fifo_wrt_count <= (fifo_wrt_count + 1) % (2 * FIFO_DEPTH);
			if(fifo_rd & ~fifo_empty)
				fifo_rd_count  <= (fifo_rd_count + 1) % (2 * FIFO_DEPTH);
		end
	end

    /*bram_subbank AUTO_TEMPLATE(
        .dout(fifo_odata),
        .clk(clk),
		.din(fifo_idata),
		.raddr(fifo_rd_ptr),
        .waddr(fifo_wrt_ptr),
        .cs(fifo_rd|fifo_wrt),
        .re(fifo_rd),
        .we(fifo_wrt),
    )*/
    bram_subbank #(
		   .DEPTH		(FIFO_DEPTH),
		   .DATA_WIDTH		(FIFO_WIDTH),
		   .ADDR_WIDTH		(FIFO_COUNT_WIDTH))
    mem(/*AUTOINST*/
	// Outputs
	.dout				(fifo_odata),		 // Templated
	// Inputs
	.clk				(clk),			 // Templated
	.din				(fifo_idata),		 // Templated
	.raddr				(fifo_rd_ptr),		 // Templated
	.waddr				(fifo_wrt_ptr),		 // Templated
	.cs				(fifo_rd|fifo_wrt),	 // Templated
	.re				(fifo_rd),		 // Templated
	.we				(fifo_wrt));		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated,


endmodule

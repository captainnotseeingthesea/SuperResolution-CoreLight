/*************************************************

 Copyright: NUDT_CoreLight

 File name: axis_outbuf.v

 Author: NUDT_CoreLight

 Date: 2021-05-03


 Description:

 Output buffer for axi-stream.
 **************************************************/

module axis_outbuf # (
        parameter DATA_WIDTH = 24,
		parameter DEPTH      = 32,
        parameter ADDR_WIDTH = 32
) (/*AUTOARG*/
   // Outputs
   rdout,
   // Inputs
   clk, rst_n, raddr, rcs, re, wdin, waddr, wcs, we
   );

    input clk  ;
    input rst_n;

    // Read data channel
    input  [ADDR_WIDTH-1:0] raddr;
    input  [1:0]            rcs  ;
    input                   re   ;
    output [DATA_WIDTH-1:0] rdout;

    // Write data channel
    input  [DATA_WIDTH-1:0] wdin ;
    input  [ADDR_WIDTH-1:0] waddr;
    input  [1:0]            wcs  ;
    input                   we   ;


    /*AUTOWIRE*/


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [DATA_WIDTH-1:0] rdout;
    // End of automatics


    reg [3:0] cs_t;
    reg [3:0] re_t;
    reg [3:0] we_t;
    wire [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3;

    always@(*) begin
        cs_t = 4'b0;
        re_t = 4'b0;
        we_t = 4'b0;

        if(re) begin
            case(rcs)
            2'b00:   begin cs_t[0] = 1'b1; re_t[0] = 1'b1; end
            2'b01:   begin cs_t[1] = 1'b1; re_t[1] = 1'b1; end
            2'b10:   begin cs_t[2] = 1'b1; re_t[2] = 1'b1; end
            default: begin cs_t[3] = 1'b1; re_t[3] = 1'b1; end
            endcase 
        end

        if(we) begin
            case(wcs)
            2'b00:   begin cs_t[0] = 1'b1; we_t[0] = 1'b1; end
            2'b01:   begin cs_t[1] = 1'b1; we_t[1] = 1'b1; end
            2'b10:   begin cs_t[2] = 1'b1; we_t[2] = 1'b1; end
            default: begin cs_t[3] = 1'b1; we_t[3] = 1'b1; end
            endcase
        end

    end

    reg [3:0] rd_status;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            rd_status <= 4'b0;
        else
            rd_status <= cs_t & re_t;
    end

    reg [DATA_WIDTH-1:0] rdout_r;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            rdout_r <= 4'b0;
        else
            rdout_r <= rdout;
    end

    always@(*) begin
        case(rd_status)
        4'b0001: rdout = dout0;
        4'b0010: rdout = dout1;
        4'b0100: rdout = dout2;
        4'b1000: rdout = dout3;
        default: rdout = rdout_r;
        endcase
    end

    /*bram_subbank AUTO_TEMPLATE(
        .dout(dout@),
        .clk(clk),
		.din(wdin),
		.raddr(raddr),
        .waddr(waddr),
        .cs(cs_t[@]),
        .re(re_t[@]),
        .we(we_t[@]),
    )*/

    bram_subbank #(/*AUTOINSTPARAM*/
		   // Parameters
		   .DEPTH		(DEPTH),
		   .DATA_WIDTH		(DATA_WIDTH),
		   .ADDR_WIDTH		(ADDR_WIDTH))
    bank0(/*AUTOINST*/
	  // Outputs
	  .dout				(dout0),		 // Templated
	  // Inputs
	  .clk				(clk),			 // Templated
	  .din				(wdin),			 // Templated
	  .raddr			(raddr),		 // Templated
	  .waddr			(waddr),		 // Templated
	  .cs				(cs_t[0]),		 // Templated
	  .re				(re_t[0]),		 // Templated
	  .we				(we_t[0]));		 // Templated

    bram_subbank #(/*AUTOINSTPARAM*/
		   // Parameters
		   .DEPTH		(DEPTH),
		   .DATA_WIDTH		(DATA_WIDTH),
		   .ADDR_WIDTH		(ADDR_WIDTH))
    bank1(/*AUTOINST*/
	  // Outputs
	  .dout				(dout1),		 // Templated
	  // Inputs
	  .clk				(clk),			 // Templated
	  .din				(wdin),			 // Templated
	  .raddr			(raddr),		 // Templated
	  .waddr			(waddr),		 // Templated
	  .cs				(cs_t[1]),		 // Templated
	  .re				(re_t[1]),		 // Templated
	  .we				(we_t[1]));		 // Templated

    bram_subbank #(/*AUTOINSTPARAM*/
		   // Parameters
		   .DEPTH		(DEPTH),
		   .DATA_WIDTH		(DATA_WIDTH),
		   .ADDR_WIDTH		(ADDR_WIDTH))
    bank2(/*AUTOINST*/
	  // Outputs
	  .dout				(dout2),		 // Templated
	  // Inputs
	  .clk				(clk),			 // Templated
	  .din				(wdin),			 // Templated
	  .raddr			(raddr),		 // Templated
	  .waddr			(waddr),		 // Templated
	  .cs				(cs_t[2]),		 // Templated
	  .re				(re_t[2]),		 // Templated
	  .we				(we_t[2]));		 // Templated

    bram_subbank #(/*AUTOINSTPARAM*/
		   // Parameters
		   .DEPTH		(DEPTH),
		   .DATA_WIDTH		(DATA_WIDTH),
		   .ADDR_WIDTH		(ADDR_WIDTH))
    bank3(/*AUTOINST*/
	  // Outputs
	  .dout				(dout3),		 // Templated
	  // Inputs
	  .clk				(clk),			 // Templated
	  .din				(wdin),			 // Templated
	  .raddr			(raddr),		 // Templated
	  .waddr			(waddr),		 // Templated
	  .cs				(cs_t[3]),		 // Templated
	  .re				(re_t[3]),		 // Templated
	  .we				(we_t[3]));		 // Templated

endmodule

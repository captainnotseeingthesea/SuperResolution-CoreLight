/*************************************************

 Copyright: NUDT_CoreLight

 File name: bram_subbank.v

 Author: NUDT_CoreLight

 Date: 2021-05-03


 Description:

 This is memory intended for using block memory inside FPGA
 after synthesis.
 **************************************************/

module bram_subbank # (
		parameter DEPTH      = 32,
        parameter DATA_WIDTH = 24,
        parameter ADDR_WIDTH = 32
) (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, din, raddr, waddr, cs, re, we
   );


    input                   clk;
    input  [DATA_WIDTH-1:0] din; 
    input  [ADDR_WIDTH-1:0] raddr;
    input  [ADDR_WIDTH-1:0] waddr;
    input                   cs;
    input                   re;
    input                   we;
    output [DATA_WIDTH-1:0] dout;


    /*AUTOWIRE*/


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [DATA_WIDTH-1:0] dout;
    // End of automatics


    // memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    wire ren = cs & re;
    wire wen = cs & we;

    always@(posedge clk) begin
        if(ren)
            dout <= mem[raddr];
        if(wen)
            mem[waddr] <= din;
    end

endmodule


module bram_subbank_dual_port # (
		parameter DEPTH      = 32,
        parameter DATA_WIDTH = 24,
        parameter ADDR_WIDTH = 32
) (/*AUTOARG*/
   // Outputs
   douta, doutb,
   // Inputs
   clka, clkb, dina, dinb, addra, addrb, ena, enb, wea, web
   );


    input                   clka;
    input                   clkb;
    input  [DATA_WIDTH-1:0] dina;
    input  [DATA_WIDTH-1:0] dinb;
    input  [ADDR_WIDTH-1:0] addra;
    input  [ADDR_WIDTH-1:0] addrb;
    input                   ena;
    input                   enb;
    input                   wea;
    input                   web;
    output [DATA_WIDTH-1:0] douta;
    output [DATA_WIDTH-1:0] doutb;


    /*AUTOWIRE*/


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [DATA_WIDTH-1:0] douta;
    reg [DATA_WIDTH-1:0] doutb;
    // End of automatics


    // memory array
    (*ram_style = "block"*)reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always@(posedge clka) begin
        if(ena) begin
            if(wea)
                mem[addra] <= dina;
            douta <= mem[addra];
        end
    end

    always@(posedge clka) begin
        if(enb) begin
            if(web)
                mem[addrb] <= dinb;
            doutb <= mem[addrb];
        end
    end

    initial begin : init_ram
        integer i;
        for(i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end
    end

endmodule
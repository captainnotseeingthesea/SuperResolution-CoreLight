
// `ifndef DFFS
//     `include "dffs.v"
// `endif

// `define LINE_BUFFER

module line_buffer #(
    parameter DEPTH = 960,
    parameter DW = 24
) (
    input shift_en,
    input [DW-1:0] bf_nxt,
    output [DW-1:0] bf_out,
    input clk
);
    wire [DEPTH*DW-1:0] buffer_in, buffer_out;
    genvar i;
    generate 
        for(i = 0; i < DEPTH; i = i + 1)
        begin : gen_line_buffer
            dffl #(
                .DW(DW)
            ) u_dffl (
                .lden(shift_en),
                .dnxt(buffer_in[(i+1)*DW-1:i*DW]),
                .qout(buffer_out[(i+1)*DW-1:i*DW]),
                .clk(clk)
            );
        end
    endgenerate
    assign buffer_in = {buffer_out[DW*(DEPTH-1)-1:0], bf_nxt};
    assign bf_out = buffer_out[DW*DEPTH-1:DW*(DEPTH-1)];

endmodule

// module line_buffer_tb();

//     reg shift_en_tb;
//     reg [5-1:0] bf_nxt_tb;
//     wire [5-1:0] bf_out_tb;
//     reg clk_tb;


//     initial begin
//         clk_tb = 1'b1;
//         shift_en_tb = 1'b0;
//         bf_nxt_tb = 5'd0;
//     end
    
//     always #2 clk_tb = ~clk_tb;

//     initial begin
//         #5 shift_en_tb = 1'b1;
//            bf_nxt_tb = 5'd1;
//         #4 bf_nxt_tb = 5'd2;
//         #4 bf_nxt_tb = 5'd3;
//         #4 bf_nxt_tb = 5'd4;
//         #4 bf_nxt_tb = 5'd5;
//         #4 bf_nxt_tb = 5'd6;

//         #20 $finish;

//     end



//     line_buffer #(
//         .DEPTH(3),
//         .DW(5)
//     ) u_line_buffer (
//         .shift_en(shift_en_tb),
//         .bf_nxt(bf_nxt_tb),
//         .bf_out(bf_out_tb),
//         .clk(clk_tb)
//     );


//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, line_buffer_tb);
//     end



// endmodule


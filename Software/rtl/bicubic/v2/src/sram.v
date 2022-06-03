
module sram #(
    parameter DATA_WIDTH=24,
    parameter DEPTH = 960
) (
    input wire clk,
    input wire [$clog2(DEPTH)-1:0] addr,
    input wire cs_n,
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out


);
    reg [DATA_WIDTH-1:0] ram [DEPTH-1:0];
    reg [DATA_WIDTH-1:0] data_t;
    reg data_valid_t;

    always @(posedge clk) begin
        // ram not work while cs_n is high
        if(cs_n) begin
            data_t <= #1 {DATA_WIDTH{1'b0}};
            // data_valid_t <= #1 1'b0;
        end
        else begin
            if(wr_en) begin
                ram[addr] <= data_in;
                data_t <= #1 {DATA_WIDTH{1'b0}};
                // data_valid_t <= #1 1'b0;
            end
            else begin
                data_t <= #1 ram[addr];
                // data_valid_t <= #1 1'b1;
            end
        end
    end

    assign data_out = data_t;
    // assign data_valid = data_valid_t;

endmodule


// module sram_tb();

//     localparam DEPTH = 960;
//     localparam DATA_WIDTH = 24;

//     reg clk_tb;
//     reg [$clog2(DEPTH)-1:0] addr_tb;
//     reg cs_n_tb;
//     reg wr_en_tb;
//     reg [DATA_WIDTH-1:0] data_in_tb;
//     wire [DATA_WIDTH-1:0] data_out_tb;
//     sram u_sram(
//         .clk           (clk_tb),
//         .addr         (addr_tb),
//         .cs_n         (cs_n_tb),
//         .wr_en       (wr_en_tb),
//         .data_in   (data_in_tb),
//         .data_out (data_out_tb) 
//     );


//     initial begin
//         clk_tb = 1'b0;
//         addr_tb = 0;
//         cs_n_tb = 1'b1;
//         wr_en_tb = 1'b0;
//         data_in_tb = 0;
//     end
//     always #2 clk_tb = ~clk_tb;
//     initial begin
//         #5 cs_n_tb = 1'b1;
//     end

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, sram_tb);
//     end

//     initial begin
//         #100 $finish;
//     end


// endmodule

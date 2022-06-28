
`define DFFS
module dfflrs #(
    parameter DW=32
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,
    input clk,
    input rst_n
);
    reg [DW-1:0] qout_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            qout_reg <= {DW{1'b1}};
        else if(lden) 
            qout_reg <= #1 dnxt;
    end
    assign qout = qout_reg;

endmodule

module dfflr #(
    parameter DW=32
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,
    input clk,
    input rst_n
);
    reg [DW-1:0] qout_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            qout_reg <= {DW{1'b0}};
        else if(lden) 
            qout_reg <= #1 dnxt;
            // qout_reg <= dnxt;
    end
    assign qout = qout_reg;

endmodule

module dffl #(
    parameter DW=32
) (
    input lden,
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,
    input clk
);
    reg [DW-1:0] qout_reg;
    always @(posedge clk) begin
        if(lden) 
            qout_reg <= #1 dnxt;
            // qout_reg <= dnxt;
    end
    assign qout = qout_reg;

endmodule

module dffrs #(
    parameter DW=32
) (
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,
    input clk,
    input rst_n
);
    reg [DW-1:0] qout_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) 
            qout_reg <= {DW{1'b1}};
        else
            qout_reg <= #1 dnxt;
            // qout_reg <= dnxt;
    end
endmodule

module dffr #(
    parameter DW=32
) (
    input [DW-1:0] dnxt,
    output [DW-1:0] qout,
    input clk,
    input rst_n
);
    reg [DW-1:0] qout_reg;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) 
            qout_reg <= {DW{1'b0}};
        else
            qout_reg <= #1 dnxt;
            // qout_reg <= dnxt;
    end
endmodule


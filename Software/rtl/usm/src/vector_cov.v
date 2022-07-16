//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/26 16:56:12
// Design Name: 
// Module Name: vector_cov
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vector_cov #(
    parameter LENGTH = 10, // length of the input pixel vector
    parameter COV_SIZE = 3, // size of the convolution kernel
    parameter CH_WIDTH = 8, // channel width
    parameter WEIGHT_WIDTH = 8, // weight width
    localparam INNER_MUL_WIDTH = CH_WIDTH + WEIGHT_WIDTH, // width of the inner multiplication value
    localparam OUTPUT_LENGTH = LENGTH - COV_SIZE + 1 // length of the output vector
) (
    input clk,
    input rst_n,
    input valid_data,
    input [CH_WIDTH * LENGTH - 1 : 0] pixel_vector,
    input [WEIGHT_WIDTH * COV_SIZE - 1: 0] weight_vector,
    output [OUTPUT_LENGTH * (INNER_MUL_WIDTH + $clog2(COV_SIZE)) - 1 : 0] partial_sum,
    output cov_done
);
    localparam OUTPUT_DELAY = 4;

    reg [INNER_MUL_WIDTH - 1: 0] inner_mul [OUTPUT_LENGTH * COV_SIZE - 1 : 0];
    reg [CH_WIDTH * LENGTH - 1 : 0] pixel_vector_next; // cut the critical path
    reg [OUTPUT_DELAY - 1 : 0] delay;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            pixel_vector_next <= {(CH_WIDTH * LENGTH){1'b0}};
        end
        else begin
            pixel_vector_next <= pixel_vector;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            delay <= {OUTPUT_DELAY{1'b0}};
        end
        else begin
            if(valid_data) begin
                delay <= {delay[OUTPUT_DELAY-2:0],valid_data};
            end
            else begin
                delay <= {delay[OUTPUT_DELAY-2:0],1'b0};
            end
        end
    end

    assign cov_done = delay[OUTPUT_DELAY - 1];

    genvar i, j;
    generate
        for (i = 0; i < LENGTH - COV_SIZE + 1; i = i + 1) begin: gen_sum
            for(j = 0; j < COV_SIZE; j = j + 1) begin:gen_mul
                always @(posedge clk or negedge rst_n) begin : convolution
                    if(~rst_n) begin
                        inner_mul[i * COV_SIZE + j] <= {INNER_MUL_WIDTH{1'b0}};
                    end
                    else begin
                        inner_mul[i * COV_SIZE + j] <= pixel_vector_next[(i + j) * CH_WIDTH +: CH_WIDTH] * weight_vector[j * WEIGHT_WIDTH +: WEIGHT_WIDTH];
                    end
                end 
            end
        end
    endgenerate


    generate
        for(i = 0; i < OUTPUT_LENGTH; i = i + 1) begin : gen_adder_tree
            reg [INNER_MUL_WIDTH * COV_SIZE - 1:0] mul_vector;
            always @(*) begin : coalesce
                integer j;
                for(j = 0; j < COV_SIZE; j = j + 1) begin
                    mul_vector[j * INNER_MUL_WIDTH +: INNER_MUL_WIDTH] = inner_mul[i * COV_SIZE + j];
                end
            end
            UnsignedAdderTreePipeline #(
                .DATA_WIDTH(INNER_MUL_WIDTH),
                .LENGTH(COV_SIZE)
            )
            adder_tree(
                .clk(clk),
                .rst_n(rst_n),
                .in_addends(mul_vector),
                .out_sum(partial_sum[i * (INNER_MUL_WIDTH + $clog2(COV_SIZE)) +: (INNER_MUL_WIDTH + $clog2(COV_SIZE))])
            );
        end
    endgenerate
endmodule

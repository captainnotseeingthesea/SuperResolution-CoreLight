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


(*use_dsp = "no"*)module vector_cov #(
    parameter LENGTH = 10, // length of the input pixel vector
    parameter COV_SIZE = 3, // size of the convolution kernel
    parameter CH_WIDTH = 8, // channel width
    parameter WEIGHT_WIDTH = 8, // weight width
    localparam INNER_MUL_WIDTH = CH_WIDTH + WEIGHT_WIDTH, // width of the inner multiplication value
    localparam OUTPUT_LENGTH = LENGTH - COV_SIZE + 1 // length of the output vector
) (
    input [CH_WIDTH * LENGTH - 1 : 0] pixel_vector,
    input [WEIGHT_WIDTH * COV_SIZE - 1: 0] weight_vector,
    output [OUTPUT_LENGTH * (INNER_MUL_WIDTH + $clog2(COV_SIZE)) - 1 : 0] partial_sum
);

    reg [INNER_MUL_WIDTH - 1: 0] inner_mul [OUTPUT_LENGTH * COV_SIZE - 1 : 0];
    always @(*) begin : convolution
        integer i , j;
        for (i = 0; i < LENGTH - COV_SIZE + 1; i = i + 1) begin: gen_sum
            for(j = 0; j < COV_SIZE; j = j + 1) begin:gen_mul
                inner_mul[i * COV_SIZE + j] = pixel_vector[(i + j) * CH_WIDTH +: CH_WIDTH] * weight_vector[j * WEIGHT_WIDTH +: WEIGHT_WIDTH];
            end
        end
    end

    genvar i;
    generate
        for(i = 0; i < OUTPUT_LENGTH; i = i + 1) begin : gen_adder_tree
            reg [INNER_MUL_WIDTH * COV_SIZE - 1:0] mul_vector;
            always @(*) begin : coalesce
                integer j;
                for(j = 0; j < COV_SIZE; j = j + 1) begin
                    mul_vector[j * INNER_MUL_WIDTH +: INNER_MUL_WIDTH] = inner_mul[i * COV_SIZE + j];
                end
            end
            UnsignedAdderTree #(
                .DATA_WIDTH(INNER_MUL_WIDTH),
                .LENGTH(COV_SIZE)
            )
            adder_tree(
                .in_addends(mul_vector),
                .out_sum(partial_sum[i * (INNER_MUL_WIDTH + $clog2(COV_SIZE)) +: (INNER_MUL_WIDTH + $clog2(COV_SIZE))])
            );
        end
    endgenerate
endmodule

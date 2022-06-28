module vector_cov #(
    parameter LENGTH = 10, // length of the input pixel vector
    parameter COV_SIZE = 3, // size of the convolution kernel
    parameter CH_WIDTH = 8, // channel width
    parameter WEIGHT_WIDTH = 8 // weight width
) (
    input [CH_WIDTH * LENGTH - 1 : 0] pixel_vector,
    input [WEIGHT_WIDTH * COV_SIZE - 1: 0] weight_vector,
    output [(LENGTH - COV_SIZE + 1) * (WEIGHT_WIDTH + CH_WIDTH) * $clog2(COV_SIZE) - 1 : 0] partial_sum
);
    localparam INNER_MUL_WIDTH = CH_WIDTH + WEIGHT_WIDTH; // width of the inner multiplication value
    localparam OUTPUT_LENGTH = LENGTH - COV_SIZE + 1; // length of the output vector

    reg [INNER_MUL_WIDTH * OUTPUT_LENGTH * COV_SIZE - 1: 0] inner_mul;
    always @(*) begin : convolution
        integer i , j;
        for (i = 0; i < LENGTH - COV_SIZE + 1; i = i + 1) begin: gen_sum
            for(j = 0; j < COV_SIZE; j = j + 1) begin:gen_mul
                inner_mul[i * COV_SIZE * INNER_MUL_WIDTH + j * INNER_MUL_WIDTH +: INNER_MUL_WIDTH] = pixel_vector[(i + j) * CH_WIDTH +: CH_WIDTH] * weight[j * WEIGHT_WIDTH +: WEIGHT_WIDTH];
            end
        end
    end
endmodule


module bicubic_mult #
(
    parameter INTER_PRODUCT_WIDTH = 24
) (
    input wire [2:0] weight,
    input wire signed [8:0] pixel,
    output wire signed [INTER_PRODUCT_WIDTH - 1:0] product
);

    // Determine the multiplication function based on the weight
    wire multi_by_21   = (weight == 3'd0) ? 1'b1 : 1'b0;
    wire multi_by_135  = (weight == 3'd1) ? 1'b1 : 1'b0;
    wire multi_by_147  = (weight == 3'd2) ? 1'b1 : 1'b0;
    wire multi_by_225  = (weight == 3'd3) ? 1'b1 : 1'b0;
    wire multi_by_235  = (weight == 3'd4) ? 1'b1 : 1'b0;
    wire multi_by_873  = (weight == 3'd5) ? 1'b1 : 1'b0;
    wire multi_by_1535 = (weight == 3'd6) ? 1'b1 : 1'b0;
    wire multi_by_1981 = (weight == 3'd7) ? 1'b1 : 1'b0;

    wire signed [12-1:0] multiplier_data = ({12{multi_by_21}}   & -12'd21)
                             | ({12{multi_by_135}}  & -12'd135)
                             | ({12{multi_by_147}}  & -12'd147)
                             | ({12{multi_by_225}}  & -12'd225)
                             | ({12{multi_by_235}}  & 12'd235)
                             | ({12{multi_by_873}}  & 12'd873)
                             | ({12{multi_by_1535}} & 12'd1535)
                             | ({12{multi_by_1981}} & 12'd1981);

    // Calculate the product
    wire signed [INTER_PRODUCT_WIDTH -1:0] product_data = multiplier_data * pixel;
    assign product = product_data;


endmodule

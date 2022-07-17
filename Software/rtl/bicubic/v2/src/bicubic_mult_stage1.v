
 `include "../../../../../new/define.v"

module bicubic_mult_stage1 #
(
    parameter INTER_PRODUCT_WIDTH = 24
) (
    input wire clk,
    input wire ena,
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

`ifdef USE_IPs

    `ifdef STAGE1_MULT_IN_ONE_CYCLE
        wire signed [INTER_PRODUCT_WIDTH -1:0] product_data;
        stage1_mult_in_1_cycle u_two_cycle_multiplier (.CLK(clk), .A(pixel), .B(multiplier_data), .CE(ena), .P(product_data)); 
        assign product = product_data;

    `elsif STAGE1_MULT_IN_TWO_CYCLE
        wire signed [INTER_PRODUCT_WIDTH -1:0] product_data;
        stage1_mult_in_2_cycle u_two_cycle_multiplier (.CLK(clk), .A(pixel), .B(multiplier_data), .CE(ena), .P(product_data));    
        assign product = product_data;
    
    `elsif STAGE1_MULT_IN_THREE_CYCLE
        wire signed [PRODUCT_WIDTH -1:0] product_data;
        stage1_mult_in_3_cycle u_three_cycle_multiplier (.CLK(clk), .A(pixel), .B(multiplier_data), .CE(ena), .P(product_data));    
        assign product = product_data;
    
    `endif
    
`else

// simulate the behaviour of multi-cycle multiplier here.
// when considering using Xilinx IPs, the cycles needs to be configured.

    `ifdef STAGE1_MULT_IN_ONE_CYCLE
        // Calculate the product
        wire signed [INTER_PRODUCT_WIDTH -1:0] product_data = multiplier_data * pixel;
        reg signed [INTER_PRODUCT_WIDTH -1:0] product_data_t1;
        always @(posedge clk) begin
            if(ena) begin
                product_data_t1 <= #1 product_data;
            end
        end
        assign product = product_data_t1;

    `elsif STAGE1_MULT_IN_TWO_CYCLE
        // Calculate the product
        wire signed [INTER_PRODUCT_WIDTH -1:0] product_data = multiplier_data * pixel;
        reg signed [INTER_PRODUCT_WIDTH -1:0] product_data_t1, product_data_t2;
        always @(posedge clk) begin
            if(ena) begin
                product_data_t1 <= #1 product_data;
                product_data_t2 <= #1 product_data_t1;
            end
        end
        assign product = product_data_t2;

    `elsif STAGE1_MULT_IN_THREE_CYCLE
        // Calculate the product
        wire signed [INTER_PRODUCT_WIDTH -1:0] product_data = multiplier_data * pixel;
        reg signed [INTER_PRODUCT_WIDTH -1:0] product_data_t1, product_data_t2, product_data_t3;
        always @(posedge clk) begin
            if(ena) begin
                product_data_t1 <= #1 product_data;
                product_data_t2 <= #1 product_data_t1;
                product_data_t3 <= #1 product_data_t2;
            end
        end
        assign product = product_data_t3;


    `endif


`endif


endmodule

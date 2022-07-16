//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/24 10:39:51
// Design Name: 
// Module Name: top
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


module UnsignedAdderTree#(
    parameter DATA_WIDTH = 8,
    parameter LENGTH = 3,
    localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH),
    localparam LENGTH_A = LENGTH / 2,
    localparam LENGTH_B = LENGTH - LENGTH_A,
    localparam OUT_WIDTH_A = DATA_WIDTH + $clog2(LENGTH_A),
    localparam OUT_WIDTH_B = DATA_WIDTH + $clog2(LENGTH_B)
) (
    input [LENGTH * DATA_WIDTH-1:0] in_addends, 
    output [OUT_WIDTH-1:0] out_sum
);

generate
	if (LENGTH == 1) begin
		assign out_sum = in_addends[DATA_WIDTH - 1 : 0];
	end else begin
		wire [OUT_WIDTH_A-1:0] sum_a;
		wire [OUT_WIDTH_B-1:0] sum_b;
		
		reg [LENGTH_A * DATA_WIDTH-1:0] addends_a;
		reg [LENGTH_B * DATA_WIDTH-1:0] addends_b;
        always @(*) begin : ele_assign
            integer i;
            for (i = 0; i < LENGTH_A; i = i+1) begin : elem_a
                addends_a[i * DATA_WIDTH +: DATA_WIDTH] = in_addends[i * DATA_WIDTH +: DATA_WIDTH];
            end
            for (i = 0; i < LENGTH_B; i = i + 1) begin : elem_b
                addends_b[i * DATA_WIDTH +: DATA_WIDTH] = in_addends[(i + LENGTH_A) * DATA_WIDTH +: DATA_WIDTH];
            end
        end
		
		//divide set into two chunks, conquer
		UnsignedAdderTree #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_A)
		) subtree_a (
			.in_addends(addends_a),
			.out_sum(sum_a)
		);
		
		UnsignedAdderTree #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_B)
		) subtree_b (
			.in_addends(addends_b),
			.out_sum(sum_b)
		);
		
		assign out_sum = sum_a + sum_b;
	end
endgenerate

endmodule


module UnsignedAdderTreePipeline #(
  parameter LENGTH = 3,  // 一共输入多少个数据;
  parameter DATA_WIDTH = 8,  // 每个数据的位宽;

  localparam STAGES_NUM = $clog2(LENGTH),  // 根据输入数据的个数, 求2的对数, 计算需要多少层加法器;
  localparam INPUTS_NUM_INT = 2 ** STAGES_NUM,  // 输入数据的个数可以不是2的幂次, 求完对数之后再求幂次, 得到满二叉树的叶子结点数目;
  localparam ODATA_WIDTH = DATA_WIDTH + STAGES_NUM  // 计算输出数据的位宽, 输出数据位宽 = 输入数据位宽 + 加法器的层数;
)(
  input clk,  // 时钟信号, 说明该加法树是个时序逻辑;
  input rst_n,  // 复位信号, 低电平有效;
  input [LENGTH * DATA_WIDTH - 1 : 0] in_addends, // 输入数据的个数, 输入数据位宽;
  output [ODATA_WIDTH-1:0] out_sum  // 输出数据位宽;
);

// 这种定义方式会不会产生资源浪费呢? 有些位置的数据并没有被使用;
reg [ODATA_WIDTH-1:0] data [STAGES_NUM:0][INPUTS_NUM_INT-1:0];
// generating tree
genvar stage, adder;
generate
  // 对于每一层加法器来说;
  for( stage = 0; stage <= STAGES_NUM; stage = stage + 1) begin: stage_gen
    // for语句中也是可以加localparam参数的;
    localparam ST_OUT_NUM = INPUTS_NUM_INT >> stage;  // 每一层加法器的输入数据个数, 最底层是N, 上一层则是N/2, 依次类推;
    localparam ST_WIDTH = DATA_WIDTH + stage;  // 中间值的位宽, 和加法树的高度有关;
    // 对于最底层的加法器来说, 非满二叉树要将其他数据赋值为0;
    if( stage == 0 ) begin
      // 对于每一个输入数据;
      for( adder = 0; adder < ST_OUT_NUM; adder = adder + 1) begin: inputs_gen
        // for语句中可以进一步添加always_comb组合逻辑;
        always @(*) begin
			// 对于每个加法器而言, 都是ODATA_WIDTH位的加法器, 因此需要高位补0处理;
			if( adder < LENGTH ) begin
				data[stage][adder][ST_WIDTH-1:0] <= in_addends[adder * ST_WIDTH +: ST_WIDTH];
				data[stage][adder][ODATA_WIDTH-1:ST_WIDTH] <= {(ODATA_WIDTH - ST_WIDTH){1'b0}};
			// 对于非满二叉树而言, 需要将其他数据赋值为0;
			end else begin
				data[stage][adder] <= {ODATA_WIDTH{1'b0}};
			end
		end
      end // for
    end else begin
      // 对于非底层的加法器来说;
      for( adder = 0; adder < ST_OUT_NUM; adder = adder + 1 ) begin: adder_gen
        // 这里是一个时序逻辑, 每一层加法器之间是流水的;
        always@(posedge clk or negedge rst_n) begin
          // 复位信号有效时, 除最底层以外, 其余加法器的输入都是寄存器, 进行复位;
          if( ~rst_n) begin
            data[stage][adder] <= {ODATA_WIDTH{1'b0}};
          end else begin
            // 复位信号无效时, 下一层加法器的运算结果保存到上一层加法器的输入;
            data[stage][adder][ST_WIDTH-1:0] <=
                    data[stage-1][adder*2][(ST_WIDTH-1)-1:0] +
                    data[stage-1][adder*2+1][(ST_WIDTH-1)-1:0];
          end
        end // always
      end // for
    end // if stage
  end // for
endgenerate

// 最后的输出结果, 硬连线;
assign out_sum = data[STAGES_NUM][0];

endmodule

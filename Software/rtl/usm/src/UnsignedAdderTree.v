module UnsignedAdderTree#(
    parameter DATA_WIDTH = 8,
    parameter LENGTH = 42,
    parameter OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH),
    parameter LENGTH_A = LENGTH / 2,
    parameter LENGTH_B = LENGTH - LENGTH_A,
    parameter OUT_WIDTH_A = DATA_WIDTH + $clog2(LENGTH_A),
    parameter OUT_WIDTH_B = DATA_WIDTH + $clog2(LENGTH_B)
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
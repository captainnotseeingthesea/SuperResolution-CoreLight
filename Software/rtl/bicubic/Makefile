.PHONY:clean

read_bmp:
	make clean
	iverilog -o vvp.exec bicubic_read_bmp.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

mult:
	make clean
	iverilog -o vvp.exec bicubic_mult.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

vector_mult:
	make clean
	iverilog -o vvp.exec bicubic_vector_mult.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

vector_mult_matrix:
	make clean
	iverilog -o vvp.exec bicubic_vector_mult_matrix.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd	

line_buffer:
	make clean
	iverilog -o vvp.exec line_buffer.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

bicubic:
	make clean
	iverilog -o vvp.exec bicubic_top.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd
run:
	make clean
	verilator -Wno-lint --output-split 40000 -threads 8 -cc -exe --build -top bicubic_top sim_main.cpp bicubic_top.v
	numactl -C 1-8 -- obj_dir/Vbicubic_top


clean:
	rm -rf vvp.exec wave.vcd out.txt


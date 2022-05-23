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

bicubic_iverilog:
	make clean
	iverilog -o vvp.exec -s bicubic_top_tb -D SRC_IMG_HEIGHT=27 -D SRC_IMG_WIDTH=48 -D SIM_WITHOUT_AXI -D UPSP_DATA_WIDTH=24 \
		 ../src/bicubic_mult.v  ../src/bicubic_vector_mult.v ../src/bicubic_pvector_mult_wmatrix.v ../src/bicubic_wvector_mult_pmatrix.v \
		 ../src/dffs.v ../src/sram.v ./bicubic_read_bmp.v ../src/bicubic_upsample.v ../src/buffer_sram.v ../src/bicubic_top.v ./bicubic_top_tb.v

	vvp -n vvp.exec > display.txt
	gtkwave wave.vcd



gen_bmp:
	rm -rf 49_4k.bmp tt.bmp 2_4k.bmp 4_4k.bmp
	python3 gen_bmp.py

bicubic_verilator:
	make clean
	verilator -Wno-lint --output-split 40000 -threads 2 --trace -cc -exe --build -top bicubic_top sim_main.cpp -I define.v  \
		 ../src/bicubic_mult.v  ../src/bicubic_vector_mult.v ../src/bicubic_pvector_mult_wmatrix.v ../src/bicubic_wvector_mult_pmatrix.v \
		 ../src/dffs.v ../src/sram.v ./bicubic_read_bmp.v ../src/bicubic_upsample.v ../src/buffer_sram.v ../src/bicubic_top.v
	numactl -C 1-2 -- obj_dir/Vbicubic_top > display_verilator.txt

metircs:
	python3 psnr_ssim.py
	python3 lpips_2imgs.py -p0 49_4k.bmp -p1 49.bmp



sram:
	make clean
	iverilog -o vvp.exec sram.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

clean:
	rm -rf vvp.exec wave.vcd out.txt display_verilator.txt obj_dir display.txt


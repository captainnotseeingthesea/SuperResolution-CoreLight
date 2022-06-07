.PHONY:clean

read_bmp:
	make clean
	iverilog -o vvp.exec bicubic_read_bmp.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

mult:
	make clean
	iverilog -o vvp.exec ../src/bicubic_mult.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

vector_mult:
	make clean
	iverilog -o vvp.exec ../src/bicubic_mult.v ../src/bicubic_vector_mult.v 
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

vector_mult_matrix:
	make clean
	iverilog -o vvp.exec ../src/bicubic_vector_mult_matrix.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd	

bicubic_iverilog:
	make clean
	iverilog -o vvp.exec -s bicubic_processing_element_tb -D SRC_IMG_HEIGHT=6 -D SRC_IMG_WIDTH=11 -D SIM_WITHOUT_AXI -D UPSP_DATA_WIDTH=24 \
		 ../src/bicubic_mult.v  ../src/bicubic_vector_mult.v ../src/bicubic_pvector_mult_wmatrix.v ../src/bicubic_wvector_mult_pmatrix.v \
		 ../src/dffs.v ../src/sram.v ./bicubic_read_bmp.v ../src/bicubic_upsample.v ../src/buffer_sram.v ../src/bicubic_processing_element.v ./bicubic_processing_element_tb.v

	vvp -n vvp.exec > display.txt
	gtkwave wave.vcd

gen_bmp:
	rm -rf 49_4k.bmp tt.bmp 2_4k.bmp 4_4k.bmp
	python3 gen_bmp.py

bicubic_verilator:
	make clean
	verilator -Wno-lint --output-split 40000 -threads 2 --trace -cc -exe --build -top bicubic_processing_element sim_main.cpp -I define.v  \
		 ../src/bicubic_mult.v  ../src/bicubic_vector_mult.v ../src/bicubic_pvector_mult_wmatrix.v ../src/bicubic_wvector_mult_pmatrix.v \
		 ../src/dffs.v ../src/sram.v ./bicubic_read_bmp.v ../src/bicubic_upsample.v ../src/buffer_sram.v ../src/bicubic_processing_element.v
	numactl -C 0-1 -- obj_dir/Vbicubic_processing_element > display_verilator.txt


coverage: bicubic_verilator
	verilator_coverage --annotate logs/annotate --annotate-all -write-info logs/merged.info logs/coverage.dat
	genhtml logs/merged.info --output-directory logs/html

metircs:
	python3 psnr_ssim.py
	python3 lpips_2imgs.py -p0 49_4k.bmp -p1 49.bmp

sram:
	make clean
	iverilog -o vvp.exec ../src/sram.v
	vvp -n vvp.exec wave -lxt2
	gtkwave wave.vcd

clean:
	rm -rf vvp.exec wave.vcd out.txt display_verilator.txt obj_dir display.txt logs/


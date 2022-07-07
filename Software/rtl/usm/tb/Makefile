.PHONY:clean

usm_iverilog:
	make clean
	iverilog -o vvp.exec -s test ../src/bram_subbank.v ../src/dffs.v \
	../src/vector_cov.v ../src/UnsignedAdderTree.v ../src/usm.v ./test.v

	vvp -n vvp.exec
	# gtkwave wave.vcd

clean:
	rm -rf vvp.exec wave.vcd display.txt


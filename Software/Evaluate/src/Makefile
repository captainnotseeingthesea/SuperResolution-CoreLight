# JJW bmp 24bpp test

CFLAGS=-std=c99 -Wall -g -O0 -lm

all: make_dir bmp scale downscale_main read_header_main upscale_main upscale_example compare_main

make_dir:
	mkdir -p bin

bmp: bmp.c
	gcc -c bmp.c ${CFLAGS} -o bin/bmp.o

scale: scale.c
	gcc -c scale.c ${CFLAGS} -o bin/scale.o

downscale_main: downscale_main.c 
	gcc downscale_main.c bin/scale.o bin/bmp.o ${CFLAGS} -o bin/downscale

compare_main: compare_main.c 
	gcc compare_main.c bin/bmp.o ${CFLAGS} -o bin/compare

upscale_main: upscale_main.c
	gcc upscale_main.c bin/scale.o bin/bmp.o ${CFLAGS} -o bin/upscale

read_header_main: read_header_main.c
	gcc read_header_main.c bin/bmp.o ${CFLAGS} -o bin/read_header

upscale_example: upscale_example.c
	gcc upscale_example.c bin/scale.o bin/bmp.o ${CFLAGS} -o bin/upscale_example

clean:
	@rm bin/*
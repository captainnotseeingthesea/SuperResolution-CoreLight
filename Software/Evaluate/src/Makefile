# JJW bmp 24bpp test

CFLAGS=-std=c99 -Wall -lm

all: make_dir bmp scale downscale_main read_header_main upscale_example

make_dir:
	mkdir -p bin

bmp: bmp.c
	gcc -c bmp.c ${CFLAGS} -o bin/bmp.o

scale: scale.c
	gcc -c scale.c ${CFLAGS} -o bin/scale.o

downscale_main: downscale_main.c 
	gcc downscale_main.c bin/scale.o bin/bmp.o ${CFLAGS} -o bin/downscale

read_header_main: read_header_main.c
	gcc read_header_main.c bin/bmp.o ${CFLAGS} -o bin/read_header

upscale_example: upscale_example.c
	gcc upscale_example.c bin/scale.o bin/bmp.o ${CFLAGS} -o bin/upscale_example

clean:
	@rm bin/*

SHELL := /bin/bash

build: hello_c3 ../../build/X86/gem5.opt


hello_c3: hello_c3.c
	gcc hello_c3.c -o hello_c3

../../build/X86/gem5.opt:
	cd ../..; \
	scons build/X86/gem5.opt -j$$((`nproc`+1))

test: build
	pytest .

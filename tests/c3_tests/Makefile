SHELL := /bin/bash

build: ../../build/X86/gem5.opt c3_glibc

# NOTE: If this repository is not cloned with --recursive-submodules,
# much of this will not work!

GEM5_REPO = $(realpath ../..)
C3_SIMULATOR_REPO = ${GEM5_REPO}/c3-simulator
GLIBC = ${C3_SIMULATOR_REPO}/glibc/glibc-2.30_install

c3_glibc:
	bash ${C3_SIMULATOR_REPO}/glibc/make_glibc.sh

hello_c3: ./hello_c3.c
	gcc -O1\
		-L ${GLIBC}/lib \
		-I ${GLIBC}/include \
		-Wl,--rpath=${GLIBC}/lib \
		-Wl,--dynamic-linker=${GLIBC}/lib/ld-linux-x86-64.so.2 \
		./hello_c3.c \
		-o hello_c3

../../build/X86/gem5.opt:
	cd ../..; \
	scons build/X86/gem5.opt -j$$((`nproc`+1))

test: build hello_c3
	pytest .

.PHONY: ../../build/X86/gem5.opt

SHELL := /bin/bash

build: ../../build/X86/gem5.opt c3_glibc

# NOTE: If this repository is not cloned with --recursive-submodules,
# much of this will not work!

GEM5_REPO = $(realpath ../..)
C3_SIMULATOR_REPO = ${GEM5_REPO}/c3-simulator
GLIBC = ${C3_SIMULATOR_REPO}/glibc/glibc-2.30_install

c3_glibc:
	bash ${C3_SIMULATOR_REPO}/glibc/make_glibc.sh

%_c3ctest: ./%_c3ctest.c
	gcc -O1\
		-L ${GLIBC}/lib \
		-I ${GLIBC}/include \
		-Wl,--rpath=${GLIBC}/lib \
		-Wl,--dynamic-linker=${GLIBC}/lib/ld-linux-x86-64.so.2 \
		$< \
		-o $@

dataEncDec:
	g++ -O1\
		-L ${GLIBC}/lib \
		-I ${GLIBC}/include \
		-I ../../c3-simulator \
		-Wl,--rpath=${GLIBC}/lib \
		-Wl,--dynamic-linker=${GLIBC}/lib/ld-linux-x86-64.so.2 \
		-c dataEncDec.c \
		-o dataEncDec.o;
	g++ dataEncDec.o ${GEM5_REPO}/build/X86/crypto/bipbip.o -o dataEncDec

../../build/X86/gem5.opt:
	cd ../..; \
	scons build/X86/gem5.opt -j$$((`nproc`+1))

test: build hello_c3ctest dataEncDec dataEncDec_c3ctest
	pytest .

.PHONY: ../../build/X86/gem5.opt

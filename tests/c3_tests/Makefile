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

prep_bf_c:
	grep -qxF '#include <stdlib.h>' mibench/security/blowfish/bf.c || sed -i '1s/^/#include <stdlib.h>\n/' mibench/security/blowfish/bf.c

prep_bf_makefile:
	sed -i '/-static/s///' mibench/security/blowfish/Makefile; \
	sed -i '/gcc/s//clang/' mibench/security/blowfish/Makefile

mibench/security/blowfish/bf: prep_bf_c prep_bf_makefile
	cd mibench/security/blowfish; \
	make clean; \
	make; \
	patchelf --set-interpreter ${GLIBC}/lib/ld-linux-x86-64.so.2 \
		--set-rpath ${GLIBC}/lib \
		bf; \

mibench/security/blowfish/bf_slh: prep_bf_c prep_bf_makefile
	cd mibench/security/blowfish; \
	make clean; \
	sed -i '/CFLAG=/s//CFLAG=-mspeculative-load-hardening /' Makefile; \
	make; \
	sed -i '/CFLAG=-mspeculative-load-hardening /s//CFLAG=/' Makefile; \
	patchelf --set-interpreter ${GLIBC}/lib/ld-linux-x86-64.so.2 \
		--set-rpath ${GLIBC}/lib \
		bf; \

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

test: build hello_c3ctest dataEncDec dataEncDec_c3ctest mibench/security/blowfish/bf
	pytest .

clean:
	rm -f dataEncDec \
	rm -f dataEncDec.o \
	rm -f dataEncDec_c3ctest \
	rm -f hello_c3ctest

.PHONY: ../../build/X86/gem5.opt prep_bf_c prep_bf_makefile

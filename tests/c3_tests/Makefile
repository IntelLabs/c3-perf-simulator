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
	sed -i '/-static/s///' mibench/security/blowfish/Makefile

mibench/security/blowfish/bf: prep_bf_c prep_bf_makefile
	cd mibench/security/blowfish; \
	make; \
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


# Safeside tests
# unmod: original safeside
# dataenc: data-encryption mitigation demo
# ptrenc: pointer-encryption mitigation demo

clean_safesides:
	rm -rf safeside-*

gather_safesides:
	git clone https://github.com/google/safeside; \
	cp -r safeside safeside-unmod; \
	git clone https://github.com/intellabs/c3-simulator safeside/c3-simulator; \
	patch -p0 < dataenc-safeside-patch.txt; \
	mv safeside safeside-dataenc; \
	cp -r safeside-unmod safeside; \
	patch -p0 < ptrenc-safeside-patch.txt; \
	mv safeside-unmod safeside-ptrenc; \
	mv safeside safeside-unmod; \
	touch gather_safesides


build_safeside_unmod build_safeside_dataenc build_safeside_ptrenc : build_safeside_% : gather_safesides
	cd safeside-$*; \
	cmake -B build; \
	make -C build spectre_v1_pht_sa


run_safeside_unmod: build_safeside_unmod
	cd ${GEM5_REPO}; \
	build/X86/gem5.opt configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -c tests/c3_tests/safeside-unmod/build/demos/spectre_v1_pht_sa --enableCryptoFunctionality --enablePredTLB --enableSTLF

run_safeside_dataenc: build_safeside_dataenc
	cd ${GEM5_REPO}; \
	build/X86/gem5.opt configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -c tests/c3_tests/safeside-dataenc/build/demos/spectre_v1_pht_sa --enableCryptoFunctionality --enablePredTLB --enableSTLF

run_safeside_ptrenc: build_safeside_ptrenc
	cd ${GEM5_REPO}; \
	timeout 10m build/X86/gem5.opt configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -c tests/c3_tests/safeside-ptrenc/build/demos/spectre_v1_pht_sa --enableCryptoFunctionality --enablePredTLB --enableSTLF


test: build hello_c3ctest dataEncDec_c3ctest mibench/security/blowfish/bf
	pytest .

clean: clean_safesides
	rm -f dataEncDec \
	rm -f dataEncDec.o \
	rm -f dataEncDec_c3ctest \
	rm -f hello_c3ctest \

.PHONY: ../../build/X86/gem5.opt prep_bf_c prep_bf_makefile clean_safesides

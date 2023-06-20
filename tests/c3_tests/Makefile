SHELL := /bin/bash

build: ../../build/X86/gem5.opt

# TODO: Need a portable, more automated way to build hello_c3.
# (gcc alone won't work: we need the custom glibc!)
# Build instructions are currently in hello_c3.c.

../../build/X86/gem5.opt:
	cd ../..; \
	scons build/X86/gem5.opt -j$$((`nproc`+1))

test: build
	pytest .

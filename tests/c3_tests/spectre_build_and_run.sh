#!/usr/bin/bash

git clone https://github.com/google/safeside safeside
unzip ../../harden-p1-d1-c3-simulator.zip -d safeside
patch -p0 < c3-safeside-patch.txt
cd safeside
cmake -B build
cd build
make spectre_v1_pht_sa
cd ../../../..
build/X86/gem5.opt configs/example/se.py --cpu-type=O3_X86_icelake_1 --caches -c tests/c3_tests/safeside/build/demos/spectre_v1_pht_sa

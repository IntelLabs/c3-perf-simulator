GEM5_DIR=/c3-perf-simulator
GEM5_BUILD_DIR=$GEM5_DIR/build/X86
GEM5_TEST_DIR=$GEM5_DIR/tests
GEM5_C3_TEST_DIR=$GEM5_TEST_DIR/c3_tests
OUTPUT_DIR=/outputs

cd $GEM5_C3_TEST_DIR
make mibench/security/blowfish/bf

echo
echo
echo "RUN0: NO C3"
$GEM5_BUILD_DIR/gem5.opt --outdir=$GEM5_C3_TEST_DIR/blowfish_c3 $GEM5_DIR/configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -c $GEM5_C3_TEST_DIR/mibench/security/blowfish/bf -o 'e /c3-perf-simulator/tests/c3_tests/mibench/security/blowfish/input_small.asc /c3-perf-simulator/tests/c3_tests/bf_c3.enc 1234567890abcdeffedcba0987654321' 2>&1| tee $OUTPUT_DIR/blowfish_run0.txt

echo
echo
echo "RUN1: C3, Heap only, No PredTLB"
$GEM5_BUILD_DIR/gem5.opt --outdir=$GEM5_C3_TEST_DIR/blowfish_c3 $GEM5_DIR/configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -e $GEM5_DIR/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 -c $GEM5_C3_TEST_DIR/mibench/security/blowfish/bf -o 'e /c3-perf-simulator/tests/c3_tests/mibench/security/blowfish/input_small.asc /c3-perf-simulator/tests/c3_tests/bf_c3.enc 1234567890abcdeffedcba0987654321' 2>&1 | tee $OUTPUT_DIR/blowfish_run1.txt

echo
echo
echo "RUN2: C3, All addresses, No PredTLB"
$GEM5_BUILD_DIR/gem5.opt --outdir=$GEM5_C3_TEST_DIR/blowfish_c3 $GEM5_DIR/configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -e $GEM5_DIR/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --forceCryptoDelay -c $GEM5_C3_TEST_DIR/mibench/security/blowfish/bf -o 'e /c3-perf-simulator/tests/c3_tests/mibench/security/blowfish/input_small.asc /c3-perf-simulator/tests/c3_tests/bf_c3.enc 1234567890abcdeffedcba0987654321' 2>&1 | tee $OUTPUT_DIR/blowfish_run2.txt

echo
echo
echo "RUN3: C3, Heap only, PredTLB"
$GEM5_BUILD_DIR/gem5.opt --outdir=$GEM5_C3_TEST_DIR/blowfish_c3 $GEM5_DIR/configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -e $GEM5_DIR/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --enablePredTLB -c $GEM5_C3_TEST_DIR/mibench/security/blowfish/bf -o 'e /c3-perf-simulator/tests/c3_tests/mibench/security/blowfish/input_small.asc /c3-perf-simulator/tests/c3_tests/bf_c3.enc 1234567890abcdeffedcba0987654321' 2>&1 | tee $OUTPUT_DIR/blowfish_run3.txt

echo
echo
echo "RUN4: C3, All addresses, PredTLB"
$GEM5_BUILD_DIR/gem5.opt --outdir=$GEM5_C3_TEST_DIR/blowfish_c3 $GEM5_DIR/configs/example/se.py --cpu-type=O3_X86_icelake_c3 --caches -e $GEM5_DIR/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --forceCryptoDelay --enablePredTLB -c $GEM5_C3_TEST_DIR/mibench/security/blowfish/bf -o 'e /c3-perf-simulator/tests/c3_tests/mibench/security/blowfish/input_small.asc /c3-perf-simulator/tests/c3_tests/bf_c3.enc 1234567890abcdeffedcba0987654321' 2>&1 | tee $OUTPUT_DIR/blowfish_run4.txt

echo
echo
echo
echo
echo "---------- BLOWFISH RESULTS ----------"
echo
echo
echo -e 'RUN0:\tNo C3'
echo 'Simulation finished in ' $(grep -oP '(?<=tick\s)\w+' $OUTPUT_DIR/blowfish_run0.txt) ' ticks'
echo
echo -e 'RUN1:\tC3,\tHeap Addresses,\tNO PredTLB'
echo 'Simulation finished in ' $(grep -oP '(?<=tick\s)\w+' $OUTPUT_DIR/blowfish_run1.txt) ' ticks'
echo
echo -e 'RUN2:\tC3,\tAll Addresses,\tNO PredTLB'
echo 'Simulation finished in ' $(grep -oP '(?<=tick\s)\w+' $OUTPUT_DIR/blowfish_run2.txt) ' ticks'
echo
echo -e 'RUN3:\tC3,\tHeap Addresses,\tPredTLB'
echo 'Simulation finished in ' $(grep -oP '(?<=tick\s)\w+' $OUTPUT_DIR/blowfish_run3.txt) ' ticks'
echo
echo -e 'RUN4:\tC3,\tAll addresses,\tPredTLB'
echo 'Simulation finished in ' $(grep -oP '(?<=tick\s)\w+' $OUTPUT_DIR/blowfish_run4.txt) ' ticks'
echo
echo

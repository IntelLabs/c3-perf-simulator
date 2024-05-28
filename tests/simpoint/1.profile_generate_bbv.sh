#!/bin/bash

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass all required arguments!"
  echo "Usage: $0 <benchmark_code> [optional <max_inst_count> <gem5_path> <spec_path>]"
  echo
  echo "<benchmark_code>  :   Benchmark to be run. Choose from the list in README_SPEC."
  echo
  echo "Optional args"
  echo "<max_inst_count>  :   Maximum number of instructions to run the benchmark for. [Default = 50,000,000,000]"
  echo "<gem5_path>       :   gem5 installation path. [Default = /c3-perf-simulator]"
  echo "<spec_path>       :   Root of SPEC2017 installation path. [Default = /spec2017]"
	exit
fi

############ DIRECTORY VARIABLES: MODIFY ACCORDINGLY #############
#Need to export GEM5_PATH and SPEC_PATH
GEM5_PATH=${3:-"/c3-perf-simulator"}          # Same as Dockerfile
SPEC_ROOT=${4:-"/spec2017"}                   # Same as run_docker_withSPEC.sh
SPEC_PATH=$SPEC_ROOT/benchspec/CPU
SCRIPT_IN=$GEM5_PATH/configs/example/se.py
LABEL=intel_spec_simpoints

BENCHMARK=$1                    # Benchmark name, e.g. gcc_r
# These values have been written in easily readable format but converted to int
# later. Please use only comma `,` to as the thousands operator
SIMPOINT_INTERVAL=100,000,000
MAX_INST_COUNT=${2:-50,000,000,000}

if [ -z ${GEM5_PATH+x} ];
then
    echo "GEM5_PATH is unset";
    exit
else
    echo "GEM5_PATH is set to '$GEM5_PATH'";
fi

if [ -z ${SPEC_PATH+x} ];
then
    echo "SPEC_PATH is unset";
    exit
else
    echo "SPEC_PATH is set to '$SPEC_PATH'";
fi

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass at least one argument!"
	exit
fi

# Check BENCHMARK input
#################### BENCHMARK CODE MAPPING ######################
BENCHMARK_CODE="none"
PERIOD=$5

if [ -n "$PERIOD" ]
then
	PERIOD=$(( PERIOD * 1000000 ))
	echo "Your period is $PERIOD"
fi


if [[ "$BENCHMARK" == "perlbench_r" ]]; then
  BENCHMARK_CODE="perlbench_r"
	COMMAND_OPT="-I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1"
	OUTPUT_LOG="checkspam.2500.5.25.11.150.1.1.1.1.out"
	ERROUT_LOG="checkspam.2500.5.25.11.150.1.1.1.1.err"
	#COMMAND_OPT="-I./lib diffmail.pl 4 800 10 17 19 300 > diffmail.4.800.10.17.19.300.out 2>> diffmail.4.800.10.17.19.300.err"
	#COMMAND_OPT="-I./lib splitmail.pl 6400 12 26 16 100 0 > splitmail.6400.12.26.16.100.0.out 2>> splitmail.6400.12.26.16.100.0.err"
fi
if [[ "$BENCHMARK" == "gcc_r" ]]; then
  BENCHMARK_CODE="gcc_r"
	COMMAND_OPT="gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.s"
	OUTPUT_LOG="gcc-pp.opts-O3_-finlinelimit_0_-fif-conversion_-fif-conversion2.out"
	ERROUT_LOG="gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.err"
	#COMMAND_OPT="gcc-pp.c -O2 -finline-limit=36000 -fpic -o gcc-pp.opts-O2_-finline-limit_36000_-fpic.s > gcc-pp.opts-O2_-finline-limit_36000_-fpic.out 2>> gcc-pp.opts-O2_-finlinelimit_36000_-fpic.err"
	#COMMAND_OPT="gcc-smaller.c -O3 -fipa-pta -o gcc-smaller.opts-O3_-fipa-pta.s > gcc-smaller.opts-O3_-fipa-pta.out 2>> gcc-smaller.opts-O3_-fipa-pta.err"
	#COMMAND_OPT="ref32.c -O5 -o ref32.opts-O5.s > ref32.opts-O5.out 2>> ref32.opts-O5.err"
	#COMMAND_OPT="ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.s > ref32.opts-O3_-fselectivescheduling_-fselective-scheduling2.out 2>> ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.err"
fi
if [[ "$BENCHMARK" == "mcf_r" ]]; then
  BENCHMARK_CODE="mcf_r"
	COMMAND_OPT="inp.in"
	OUTPUT_LOG="inp.out"
	ERROUT_LOG="inp.err"
fi
if [[ "$BENCHMARK" == "namd_r" ]]; then
  BENCHMARK_CODE="namd_r"
	COMMAND_OPT="--input apoa1.input --output apoa1.ref.output --iterations 65"
	OUTPUT_LOG="namd.out"
	ERROUT_LOG="namd.err"
fi
if [[ "$BENCHMARK" == "parest_r" ]]; then
  BENCHMARK_CODE="parest_r"
	COMMAND_OPT="ref.prm"
	OUTPUT_LOG="ref.out"
	ERROUT_LOG="ref.err"
fi
if [[ "$BENCHMARK" == "povray_r" ]]; then
  BENCHMARK_CODE="povray_r"
	COMMAND_OPT="SPEC-benchmark-ref.ini"
	OUTPUT_LOG="SPEC-benchmark-ref.stdout"
	ERROUT_LOG="SPEC-benchmark-ref.stderr"
fi
if [[ "$BENCHMARK" == "lbm_r" ]]; then
  BENCHMARK_CODE="lbm_r"
	COMMAND_OPT="2000 reference.dat 0 0 200_200_260_ldc.of"
	OUTPUT_LOG="lbm.out"
	ERROUT_LOG="lbm.err"
fi
if [[ "$BENCHMARK" == "omnetpp_r" ]]; then
  BENCHMARK_CODE="omnetpp_r"
	COMMAND_OPT="-c General -r 0"
	OUTPUT_LOG="omnetpp.General-0.out"
	ERROUT_LOG="omnetpp.General-0.err"
fi
if [[ "$BENCHMARK" == "xalancbmk_r" ]]; then
  BENCHMARK_CODE="xalancbmk_r"
	COMMAND_OPT="-v t5.xml xalanc.xsl"
	OUTPUT_LOG="ref-t5.out"
	ERROUT_LOG="ref-t5.err"
fi
if [[ "$BENCHMARK" == "x264_r" ]]; then
  BENCHMARK_CODE="x264_r"
	COMMAND_OPT="--pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
	OUTPUT_LOG="run_000-1000_x264_pass1.out"
	ERROUT_LOG="run_000-1000_x264_pass1.err"
	#COMMAND_OPT="--pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > run_000-1000_x264_pass2.out 2>> run_000-1000_x264_pass2.err"
	#COMMAND_OPT="--seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > run_0500-1250_x264.out 2>> run_0500-1250_x264.err"
fi
if [[ "$BENCHMARK" == "blender_r" ]]; then
  BENCHMARK_CODE="blender_r"
	COMMAND_OPT="sh3_no_char.blend --render-output sh3_no_char_ --threads 1 -b -F RAWTGA -s 849 -e 849 -a"
	OUTPUT_LOG="sh3_no_char.849.spec.out"
	ERROUT_LOG="sh3_no_char.849.spec.err"
fi
if [[ "$BENCHMARK" == "deepsjeng_r" ]]; then
  BENCHMARK_CODE="deepsjeng_r"
	COMMAND_OPT="ref.txt"
	OUTPUT_LOG="ref.out"
	ERROUT_LOG="ref.err"
fi
if [[ "$BENCHMARK" == "leela_r" ]]; then
  BENCHMARK_CODE="leela_r"
  COMMAND_OPT="ref.sgf"
  OUTPUT_LOG="ref.out"
  ERROUT_LOG="ref.err"
fi
if [[ "$BENCHMARK" == "imagick_r" ]]; then
  BENCHMARK_CODE="imagick_r"
	COMMAND_OPT=" -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga"
	OUTPUT_LOG="refrate_convert.out"
	ERROUT_LOG="refrate_convert.err"
fi
if [[ "$BENCHMARK" == "nab_r" ]]; then
  BENCHMARK_CODE="nab_r"
	COMMAND_OPT="3j1n 20140317 220"
	OUTPUT_LOG="3j1n.out"
	ERROUT_LOG="3j1n.err"
fi
if [[ "$BENCHMARK" == "xz_r" ]]; then
  BENCHMARK_CODE="xz_r"
	COMMAND_OPT="cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6"
	OUTPUT_LOG="cld.tar-160-6.out"
	ERROUT_LOG="cld.tar-160-6.err"
	#COMMAND_OPT="cpu2006docs.tar.xz 250 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 2304777423513385 6e > cpu2006docs.tar-250-6e.out 2>> cpu2006docs.tar-250-6e.err"
	#COMMAND_OPT="input.combined.xz 250 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 4040148441217675 7 > input.combined-250-7.out 2>> input.combined-250-7.err"
fi

# Sanity check
if [[ "$BENCHMARK_CODE" == "none" ]]; then
    echo "Input benchmark selection $BENCHMARK did not match any known SPEC CPU2006 benchmarks! Exiting."
    exit 1
fi
##################################################################

OUTPUT_DIR=$GEM5_PATH/tests/simpoint/output/$BENCHMARK_CODE

echo "output directory: " $OUTPUT_DIR

if [ -d "$OUTPUT_DIR" ]
then
    rm -r $OUTPUT_DIR
fi
mkdir -p $OUTPUT_DIR

RUN_DIR=$SPEC_PATH/$BENCHMARK_CODE/run/run_base_refrate_$LABEL.0000/

# Run directory for the selected SPEC benchmark
SCRIPT_OUT=$OUTPUT_DIR/runscript.log
# File log for this script's stdout henceforth

################## REPORT SCRIPT CONFIGURATION ###################

echo "Command line:"                                | tee $SCRIPT_OUT
echo "$0 $*"                                        | tee -a $SCRIPT_OUT
echo "================= Hardcoded directories ==================" | tee -a $SCRIPT_OUT
echo "GEM5_PATH:                                    $GEM5_PATH" | tee -a $SCRIPT_OUT
echo "SPEC_PATH:                                    $SPEC_PATH" | tee -a $SCRIPT_OUT
echo "==================== Script inputs =======================" | tee -a $SCRIPT_OUT
echo "BENCHMARK:                                    $BENCHMARK" | tee -a $SCRIPT_OUT
echo "COMMAND_OPT:                                  $COMMAND_OPT" | tee -a $SCRIPT_OUT
echo "OUTPUT_DIR:                                   $OUTPUT_DIR" | tee -a $SCRIPT_OUT
echo "==========================================================" | tee -a $SCRIPT_OUT
##################################################################


#################### LAUNCH GEM5 SIMULATION ######################
echo ""
echo "Changing to SPEC benchmark runtime directory: $RUN_DIR" | tee -a $SCRIPT_OUT
cd $RUN_DIR

echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "--------- Here goes nothing! Starting gem5! ------------" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT

SIMPOINT_INTERVAL_VAL=$(tr -d ',' <<< "$SIMPOINT_INTERVAL")
MAX_INST_COUNT_VAL=$(tr -d ',' <<< "$MAX_INST_COUNT")

# Actually launch gem5!
$GEM5_PATH/build/X86/gem5.opt \
	--outdir=$OUTPUT_DIR $SCRIPT_IN \
	--num-cpus=1 --mem-size=4GB \
	--simpoint-profile --simpoint-interval 100000000 \
  -e $GEM5_PATH/c3_no_wrap_enable.env \
	--cmd=$RUN_DIR/base.exe \
	--options="$COMMAND_OPT" \
	--cpu-type=AtomicSimpleCPU | tee -a $SCRIPT_OUT

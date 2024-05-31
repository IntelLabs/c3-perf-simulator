#!/bin/bash

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass all required arguments!"
  echo "Usage: $0 <benchmark_code> [optional <config> <simpoint_count> <gem5_path> <spec_path>]"
  echo
  echo "<benchmark_code>  :   Benchmark to be run. Choose from the list in README_SPEC."
  echo
  echo "Optional args"
  echo "<config>          :   C3 configuration to run gem5 in. [Default = base]"
  echo "<simpoint_count>  :   Number of simpoints to be run. [Default = 3]"
  echo "<gem5_path>       :   gem5 installation path. [Default = /c3-perf-simulator]"
  echo "<spec_path>       :   Root of SPEC2017 installation path. [Default = /spec2017]"
	exit
fi

############ DIRECTORY VARIABLES: MODIFY ACCORDINGLY #############
#Need to export GEM5_PATH and SPEC_PATH
GEM5_PATH=${4:-"/c3-perf-simulator"}          # Same as Dockerfile
SPEC_ROOT=${5:-"/spec2017"}                   # Same as run_docker_withSPEC.sh
SPEC_PATH=$SPEC_ROOT/benchspec/CPU
SCRIPT_IN=$GEM5_PATH/configs/example/se.py
LABEL=intel_spec_simpoints

BENCHMARK=$1                    # Benchmark name, e.g. bzip2
CONFIG=${2:-"base"}
SIMPOINT_COUNT=${3:-3}

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

# Check BENCHMARK input
#################### BENCHMARK CODE MAPPING ######################
BENCHMARK_CODE="none"

if [[ "$BENCHMARK" == "perlbench_r" ]]; then
  BENCHMARK_CODE="500.perlbench_r"
	COMMAND_OPT="-I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1"
	OUTPUT_LOG="checkspam.2500.5.25.11.150.1.1.1.1.out"
	ERROUT_LOG="checkspam.2500.5.25.11.150.1.1.1.1.err"
	BIN_FILE="perlbench_r_base.$LABEL"
	#COMMAND_OPT="-I./lib diffmail.pl 4 800 10 17 19 300 > diffmail.4.800.10.17.19.300.out 2>> diffmail.4.800.10.17.19.300.err"
	#COMMAND_OPT="-I./lib splitmail.pl 6400 12 26 16 100 0 > splitmail.6400.12.26.16.100.0.out 2>> splitmail.6400.12.26.16.100.0.err"
fi
if [[ "$BENCHMARK" == "gcc_r" ]]; then
  BENCHMARK_CODE="502.gcc_r"
	COMMAND_OPT="gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.s"
	OUTPUT_LOG="gcc-pp.opts-O3_-finlinelimit_0_-fif-conversion_-fif-conversion2.out"
	ERROUT_LOG="gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.err"
	BIN_FILE="cpugcc_r_base.$LABEL"
	#COMMAND_OPT="gcc-pp.c -O2 -finline-limit=36000 -fpic -o gcc-pp.opts-O2_-finline-limit_36000_-fpic.s > gcc-pp.opts-O2_-finline-limit_36000_-fpic.out 2>> gcc-pp.opts-O2_-finlinelimit_36000_-fpic.err"
	#COMMAND_OPT="gcc-smaller.c -O3 -fipa-pta -o gcc-smaller.opts-O3_-fipa-pta.s > gcc-smaller.opts-O3_-fipa-pta.out 2>> gcc-smaller.opts-O3_-fipa-pta.err"
	#COMMAND_OPT="ref32.c -O5 -o ref32.opts-O5.s > ref32.opts-O5.out 2>> ref32.opts-O5.err"
	#COMMAND_OPT="ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.s > ref32.opts-O3_-fselectivescheduling_-fselective-scheduling2.out 2>> ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.err"
fi
if [[ "$BENCHMARK" == "mcf_r" ]]; then
  BENCHMARK_CODE="505.mcf_r"
	COMMAND_OPT="inp.in"
	OUTPUT_LOG="inp.out"
	ERROUT_LOG="inp.err"
	BIN_FILE="mcf_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "namd_r" ]]; then
  BENCHMARK_CODE="508.namd_r"
	COMMAND_OPT="--input apoa1.input --output apoa1.ref.output --iterations 65"
	OUTPUT_LOG="namd.out"
	ERROUT_LOG="namd.err"
	BIN_FILE="namd_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "parest_r" ]]; then
  BENCHMARK_CODE="510.parest_r"
	COMMAND_OPT="ref.prm"
	OUTPUT_LOG="ref.out"
	ERROUT_LOG="ref.err"
	BIN_FILE="parest_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "povray_r" ]]; then
  BENCHMARK_CODE="511.povray_r"
	COMMAND_OPT="SPEC-benchmark-ref.ini"
	OUTPUT_LOG="SPEC-benchmark-ref.stdout"
	ERROUT_LOG="SPEC-benchmark-ref.stderr"
	BIN_FILE="povray_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "lbm_r" ]]; then
  BENCHMARK_CODE="519.lbm_r"
	# COMMAND_OPT="2000 reference.dat 0 0 200_200_260_ldc.of"
	COMMAND_OPT="2000 reference.dat 0 0"
	OUTPUT_LOG="lbm.out"
	ERROUT_LOG="lbm.err"
	BIN_FILE="lbm_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "omnetpp_r" ]]; then
  BENCHMARK_CODE="520.omnetpp_r"
	COMMAND_OPT="-c General -r 0"
	OUTPUT_LOG="omnetpp.General-0.out"
	ERROUT_LOG="omnetpp.General-0.err"
	BIN_FILE="omnetpp_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "xalancbmk_r" ]]; then
  BENCHMARK_CODE="523.xalancbmk_r"
	COMMAND_OPT="-v t5.xml xalanc.xsl"
	OUTPUT_LOG="ref-t5.out"
	ERROUT_LOG="ref-t5.err"
	BIN_FILE="cpuxalan_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "x264_r" ]]; then
  BENCHMARK_CODE="525.x264_r"
	COMMAND_OPT="--pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
	OUTPUT_LOG="run_000-1000_x264_pass1.out"
	ERROUT_LOG="run_000-1000_x264_pass1.err"
	BIN_FILE="x264_r_base.$LABEL"
	#COMMAND_OPT="--pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > run_000-1000_x264_pass2.out 2>> run_000-1000_x264_pass2.err"
	#COMMAND_OPT="--seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > run_0500-1250_x264.out 2>> run_0500-1250_x264.err"
fi
if [[ "$BENCHMARK" == "blender_r" ]]; then
  BENCHMARK_CODE="526.blender_r"
	COMMAND_OPT="sh3_no_char.blend --render-output sh3_no_char_ --threads 1 -b -F RAWTGA -s 849 -e 849 -a"
	OUTPUT_LOG="sh3_no_char.849.spec.out"
	ERROUT_LOG="sh3_no_char.849.spec.err"
	BIN_FILE="blender_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "deepsjeng_r" ]]; then
  BENCHMARK_CODE="531.deepsjeng_r"
	COMMAND_OPT="ref.txt"
	OUTPUT_LOG="ref.out"
	ERROUT_LOG="ref.err"
	BIN_FILE="deepsjeng_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "imagick_r" ]]; then
  BENCHMARK_CODE="538.imagick_r"
	COMMAND_OPT=" -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga"
	OUTPUT_LOG="refrate_convert.out"
	ERROUT_LOG="refrate_convert.err"
	BIN_FILE="imagick_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "nab_r" ]]; then
  BENCHMARK_CODE="544.nab_r"
	COMMAND_OPT="1am0 20140317 220"
	OUTPUT_LOG="1am0.out"
	ERROUT_LOG="1am0.err"
	BIN_FILE="nab_r_base.$LABEL"
fi
if [[ "$BENCHMARK" == "xz_r" ]]; then
  BENCHMARK_CODE="557.xz_r"
	COMMAND_OPT="cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6"
	OUTPUT_LOG="cld.tar-160-6.out"
	ERROUT_LOG="cld.tar-160-6.err"
	BIN_FILE="xz_r_base.$LABEL"
	#COMMAND_OPT="cpu2006docs.tar.xz 250 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 2304777423513385 6e > cpu2006docs.tar-250-6e.out 2>> cpu2006docs.tar-250-6e.err"
	#COMMAND_OPT="input.combined.xz 250 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 4040148441217675 7 > input.combined-250-7.out 2>> input.combined-250-7.err"
fi

# Sanity check
if [[ "$BENCHMARK_CODE" == "none" ]]; then
    echo "Input benchmark selection $BENCHMARK did not match any known SPEC CPU2006 benchmarks! Exiting."
    exit 1
fi
##################################################################

if [[ "$CONFIG" == "base" ]]; then
	C3_OPT="--cpu-type=O3_X86_icelake_base -e $GEM5_PATH/c3_no_wrap_enable.env --pointer-decryption-delay 0 --data-keystream-delay 0 --enableSTLF"
elif [[ "$CONFIG" == "c3" ]]; then
	C3_OPT="--cpu-type=O3_X86_icelake_c3 -e $GEM5_PATH/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --enableSTLF"
elif [[ "$CONFIG" == "c3-predtlb" ]]; then
	C3_OPT="--cpu-type=O3_X86_icelake_c3 -e $GEM5_PATH/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --enablePredTLB --enableSTLF"
elif [[ "$CONFIG" == "c3-forceDelay" ]]; then
	C3_OPT="--cpu-type=O3_X86_icelake_c3 -e $GEM5_PATH/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --enableSTLF --forceCryptoDelay"
elif [[ "$CONFIG" == "c3-predtlb-forceDelay" ]]; then
	C3_OPT="--cpu-type=O3_X86_icelake_c3 -e $GEM5_PATH/c3_no_wrap_enable.env --pointer-decryption-delay 3 --data-keystream-delay 4 --enablePredTLB --enableSTLF --forceCryptoDelay"
else
    echo "Configuration not specified! Should be one of \"base\" or \"c3\" or \"c3-predtlb\" or \"c3-forceDelay\" or \"c3-predtlb-forceDelay\". Exiting."
    exit 1
fi

OUTPUT_DIR=/outputs/simpoint/$BENCHMARK_CODE/$CONFIG    # Store outputs in the mounted outputs directory
CHECKPOINT_DIR=/outputs/simpoint/$BENCHMARK_CODE        # Checkpoints output directory from script 3.take_checkpoints.sh (Output of script 3)
SIMPOINTS_FILE=$OUTPUT_DIR/simpoints.out
WEIGHTS_FILE=$OUTPUT_DIR/weights.out

if [[ "$FORCE_DELAY" == "forceCryptoDelay" ]]; then
  C3_OPT=$C3_OPT" --forceCryptoDelay"
  OUTPUT_DIR=$OUTPUT_DIR"-forceCryptoDelay"
fi

echo "output directory: " $OUTPUT_DIR

mkdir -p $OUTPUT_DIR

RUN_DIR=$SPEC_PATH/$BENCHMARK_CODE/run/run_base_refrate_$LABEL.0000/

# Run directory for the selected SPEC benchmark
SCRIPT_OUT=$OUTPUT_DIR/runscript.log
# File log for this script's stdout henceforth

################## REPORT SCRIPT CONFIGURATION ###################

echo "Command line:"                                | tee $SCRIPT_OUT
echo "$0 $*"                                        | tee -a $SCRIPT_OUT
echo "================= Hardcoded directories ==================" | tee -a $SCRIPT_OUT
echo "GEM5_PATH:                                     $GEM5_PATH" | tee -a $SCRIPT_OUT
echo "SPEC_PATH:                                     $SPEC_PATH" | tee -a $SCRIPT_OUT
echo "==================== Script inputs =======================" | tee -a $SCRIPT_OUT
echo "BENCHMARK:                                    $BENCHMARK" | tee -a $SCRIPT_OUT
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

# Actually launch gem5!

for ((SIMPOINT_IDX=1; SIMPOINT_IDX<=$SIMPOINT_COUNT; SIMPOINT_IDX++))
do
  $GEM5_PATH/build/X86/gem5.opt \
    --outdir=$OUTPUT_DIR/Checkpoint1 $SCRIPT_IN \
    --cmd=$RUN_DIR/$BIN_FILE \
    --options="$COMMAND_OPT" $C3_OPT \
    --num-cpus=1 --mem-size=4GB \
    --restore-simpoint-checkpoint -r $SIMPOINT_IDX --checkpoint-dir $CHECKPOINT_DIR \
    --caches | tee -a $SCRIPT_OUT
done

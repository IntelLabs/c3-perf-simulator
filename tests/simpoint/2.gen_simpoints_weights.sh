#!/bin/bash

############ DIRECTORY VARIABLES: MODIFY ACCORDINGLY #############
#Need to export GEM5_PATH (gem5 home)
GEM5_PATH=/c3-perf-simulator
#Need to export SIM_PATH where SimPoint executable is located
SIM_PATH=/c3-perf-simulator/pinplay-scripts/PinPointsHome/Linux/bin

if [ -z ${GEM5_PATH+x} ];
then
    echo "GEM5_PATH is unset";
    exit
else
    echo "GEM5_PATH is set to '$GEM5_PATH'";
fi

if [ -z ${SIM_PATH+x} ];
then
    echo "SIM_PATH is unset";
    exit
else
    echo "SIM_PATH is set to '$SIM_PATH'";
fi

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass at least one argument!"
	exit
fi

# Check BENCHMARK input
#################### BENCHMARK CODE MAPPING ######################
BENCHMARK=$1                    # Benchmark name, e.g. bzip2
BENCHMARK_CODE="none"

if [[ "$BENCHMARK" == "perlbench_r" ]]; then
  BENCHMARK_CODE="perlbench_r"
fi
if [[ "$BENCHMARK" == "gcc_r" ]]; then
  BENCHMARK_CODE="gcc_r"
fi
if [[ "$BENCHMARK" == "bwaves_r" ]]; then
  BENCHMARK_CODE="bwaves_r"
fi
if [[ "$BENCHMARK" == "mcf_r" ]]; then
  BENCHMARK_CODE="mcf_r"
fi
if [[ "$BENCHMARK" == "cactusBSSN_r" ]]; then
  BENCHMARK_CODE="cactusBSSN_r"
fi
if [[ "$BENCHMARK" == "namd_r" ]]; then
  BENCHMARK_CODE="namd_r"
fi
if [[ "$BENCHMARK" == "parest_r" ]]; then
  BENCHMARK_CODE="parest_r"
fi
if [[ "$BENCHMARK" == "povray_r" ]]; then
  BENCHMARK_CODE="povray_r"
fi
if [[ "$BENCHMARK" == "lbm_r" ]]; then
  BENCHMARK_CODE="lbm_r"
fi
if [[ "$BENCHMARK" == "omnetpp_r" ]]; then
  BENCHMARK_CODE="omnetpp_r"
fi
if [[ "$BENCHMARK" == "wrf_r" ]]; then
  BENCHMARK_CODE="wrf_r"
fi
if [[ "$BENCHMARK" == "xalancbmk_r" ]]; then
  BENCHMARK_CODE="xalancbmk_r"
fi
if [[ "$BENCHMARK" == "x264_r" ]]; then
  BENCHMARK_CODE="x264_r"
fi
if [[ "$BENCHMARK" == "blender_r" ]]; then
  BENCHMARK_CODE="blender_r"
fi
if [[ "$BENCHMARK" == "cam4_r" ]]; then
  BENCHMARK_CODE="cam4_r"
fi
if [[ "$BENCHMARK" == "deepsjeng_r" ]]; then
  BENCHMARK_CODE="deepsjeng_r"
fi
if [[ "$BENCHMARK" == "imagick_r" ]]; then
  BENCHMARK_CODE="imagick_r"
fi
if [[ "$BENCHMARK" == "leela_r" ]]; then
  BENCHMARK_CODE="leela_r"
fi
if [[ "$BENCHMARK" == "nab_r" ]]; then
  BENCHMARK_CODE="nab_r"
fi
if [[ "$BENCHMARK" == "exchange2_r" ]]; then
  BENCHMARK_CODE="exchange2_r"
fi
if [[ "$BENCHMARK" == "fotonik3d_r" ]]; then
  BENCHMARK_CODE="fotonik3d_r"
fi
if [[ "$BENCHMARK" == "roms_r" ]]; then
  BENCHMARK_CODE="roms_r"
fi
if [[ "$BENCHMARK" == "xz_r" ]]; then
  BENCHMARK_CODE="xz_r"
fi
if [[ "$BENCHMARK" == "specrand_fr" ]]; then
  BENCHMARK_CODE="specrand_fr"
fi
if [[ "$BENCHMARK" == "specrand_ir" ]]; then
  BENCHMARK_CODE="specrand_ir"
fi

# Sanity check
if [[ "$BENCHMARK_CODE" == "none" ]]; then
    echo "Input benchmark selection $BENCHMARK did not match any known SPEC CPU2006 benchmarks! Exiting."
    exit 1
fi

OUTPUT_DIR=$GEM5_PATH/tests/simpoint/output/$BENCHMARK_CODE
SIMPOINTS_FILE=$OUTPUT_DIR/simpoints.out
WEIGHTS_FILE=$OUTPUT_DIR/weights.out

#################### RUN SIMPOINT ANALYSIS ######################
echo ""
echo "Changing to SimPoint BBV directory: $OUTPUT_DIR" | tee -a $SCRIPT_OUT
cd $OUTPUT_DIR

$SIM_PATH/simpoint -loadFVFile simpoint.bb.gz -maxK 30 \
	-saveSimpoints $SIMPOINTS_FILE -saveSimpointWeights $WEIGHTS_FILE \
	-inputVectorsGzipped  | tee -a $SCRIPT_OUT

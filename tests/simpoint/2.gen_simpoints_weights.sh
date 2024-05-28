#!/bin/bash

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass all required arguments!"
  echo "Usage: $0 <benchmark_code> [optional <simpoint_count> <gem5_path> <pinpoints_path>]"
  echo
  echo "<benchmark_code>  :   Benchmark to be run. Choose from the list in README_SPEC."
  echo
  echo "Optional args"
  echo "<simpoint_count>  :   Maximum number of simpoints to be collected. [Default = 3]"
  echo "<gem5_path>       :   gem5 installation path. [Default = /c3-perf-simulator]"
  echo "<pinpoints_path>  :   PinPoints path (installed by prep_spec_run.sh) [Default = "/pinplay-scripts/PinPointsHome/Linux/bin"]"
	exit
fi

############ DIRECTORY VARIABLES: MODIFY ACCORDINGLY #############
#Need to export GEM5_PATH and SIM_PATH
GEM5_PATH=${3:-"/c3-perf-simulator"}          # Same as Dockerfile
SIM_PATH=${4:-"/pinplay-scripts/PinPointsHome/Linux/bin"}

BENCHMARK=$1                # Benchmark name, e.g. gcc_r
MAX_SIMPOINTS=${2:-3}       # Maximum number of simpoints to be collected. Default = 3

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

# Check BENCHMARK input
#################### BENCHMARK CODE MAPPING ######################
BENCHMARK_CODE="none"

if [[ "$BENCHMARK" == "perlbench_r" ]]; then
  BENCHMARK_CODE="500.perlbench_r"
fi
if [[ "$BENCHMARK" == "gcc_r" ]]; then
  BENCHMARK_CODE="502.gcc_r"
fi
if [[ "$BENCHMARK" == "bwaves_r" ]]; then
  BENCHMARK_CODE="bwaves_r"
fi
if [[ "$BENCHMARK" == "mcf_r" ]]; then
  BENCHMARK_CODE="505.mcf_r"
fi
if [[ "$BENCHMARK" == "cactusBSSN_r" ]]; then
  BENCHMARK_CODE="cactusBSSN_r"
fi
if [[ "$BENCHMARK" == "namd_r" ]]; then
  BENCHMARK_CODE="508.namd_r"
fi
if [[ "$BENCHMARK" == "parest_r" ]]; then
  BENCHMARK_CODE="510.parest_r"
fi
if [[ "$BENCHMARK" == "povray_r" ]]; then
  BENCHMARK_CODE="511.povray_r"
fi
if [[ "$BENCHMARK" == "lbm_r" ]]; then
  BENCHMARK_CODE="519.lbm_r"
fi
if [[ "$BENCHMARK" == "omnetpp_r" ]]; then
  BENCHMARK_CODE="520.omnetpp_r"
fi
if [[ "$BENCHMARK" == "wrf_r" ]]; then
  BENCHMARK_CODE="wrf_r"
fi
if [[ "$BENCHMARK" == "xalancbmk_r" ]]; then
  BENCHMARK_CODE="523.xalancbmk_r"
fi
if [[ "$BENCHMARK" == "x264_r" ]]; then
  BENCHMARK_CODE="525.x264_r"
fi
if [[ "$BENCHMARK" == "blender_r" ]]; then
  BENCHMARK_CODE="526.blender_r"
fi
if [[ "$BENCHMARK" == "cam4_r" ]]; then
  BENCHMARK_CODE="cam4_r"
fi
if [[ "$BENCHMARK" == "deepsjeng_r" ]]; then
  BENCHMARK_CODE="531.deepsjeng_r"
fi
if [[ "$BENCHMARK" == "imagick_r" ]]; then
  BENCHMARK_CODE="538.imagick_r"
fi
if [[ "$BENCHMARK" == "leela_r" ]]; then
  BENCHMARK_CODE="leela_r"
fi
if [[ "$BENCHMARK" == "nab_r" ]]; then
  BENCHMARK_CODE="544.nab_r"
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
  BENCHMARK_CODE="557.xz_r"
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

OUTPUT_DIR=/outputs/simpoint/$BENCHMARK_CODE    # Store outputs in the mounted outputs directory
SIMPOINTS_FILE=$OUTPUT_DIR/simpoints.out
WEIGHTS_FILE=$OUTPUT_DIR/weights.out

#################### RUN SIMPOINT ANALYSIS ######################
echo ""
echo "Changing to SimPoint BBV directory: $OUTPUT_DIR" | tee -a $SCRIPT_OUT
cd $OUTPUT_DIR

$SIM_PATH/simpoint -loadFVFile $OUTPUT_DIR/simpoint.bb.gz -maxK $MAX_SIMPOINTS \
	-saveSimpoints $SIMPOINTS_FILE -saveSimpointWeights $WEIGHTS_FILE \
	-inputVectorsGzipped  | tee -a $SCRIPT_OUT

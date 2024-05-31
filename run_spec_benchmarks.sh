ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 3 ]]; then # Bad number of arguments.
	echo "Need to pass at least one argument!"
  echo "Usage: $0 <benchmark_code> [optional <simpoint_count> <max_inst_count> <warmup_inst_count>]"
  echo
  echo "<benchmark_code>    :   Benchmark to be run. Choose from the list in README_SPEC."
  echo
  echo "Optional args"
  echo "<simpoint_count>    :   Maximum number of to be collected. [Default = 3]"
  echo "<max_inst_count>    :   Maximum number of instructions to run the benchmark for. [Default = 50,000,000,000]"
  echo "<warmup_inst_count> :   Warmup period/number of instructions for running gem5 from simpoints. [Default = 10,000,000]"
	exit
fi

GEM5_PATH=/c3-perf-simulator          # Same as Dockerfile
SPEC_ROOT=/spec2017                   # Same as run_docker_withSPEC.sh
PINPLAY_PATH=/pinplay-tools/pinplay-scripts/PinPointsHome/Linux/bin
SIMPOIONT_TESTS_DIR=$GEM5_PATH/tests/simpoint

# These values have been written in easily readable format but converted to int
# later. Please use only comma `,` to as the thousands operator
BENCHMARK=$1
SIMPOINT_COUNT=${2:-3}
MAX_INST_COUNT=${3:-50,000,000,000}
WARMUP_LEN=${4:-10,000,000}
CONFIGS="base c3 c3-predtlb c3-forceDelay c3-predtlb-forceDelay"


cd $SIMPOIONT_TESTS_DIR

# Generate BBV
echo "Step1: Generating BBV for $1"
./1.profile_generate_bbv.sh $BENCHMARK $MAX_INST_COUNT $GEM5_PATH $SPEC_ROOT

echo "STEP2: Generate Simpoint weights"
./2.gen_simpoints_weights.sh $BENCHMARK $SIMPOINT_COUNT $GEM5_PATH $PINPLAY_PATH

echo "Step3: Take checkpoints"
./3.take_checkpoints.sh $BENCHMARK $MAX_INST_COUNT $WARMUP_LEN $GEM5_PATH $SPEC_ROOT

echo "Step4: Run from checkpoints"
for CFG in $CONFIGS
do
  echo "Running $CFG config"
  echo
  ./4.run_from_checkpoints.sh $BENCHMARK $CFG $SIMPOINT_COUNT $GEM5_PATH $SPEC_ROOT
done

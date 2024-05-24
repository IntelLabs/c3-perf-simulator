#!/bin/bash
SPEC_ROOT=${1:-"/spec2017"}

echo "Build and Run SPEC becnhamarks natively"
cp tests/simpoint/c3-spec-config.cfg $SPEC_ROOT/config/
cd $SPEC_ROOT/bin

./runcpu -c ../config/c3-spec-config.cfg -a run \
  500.perlbench_r \
  502.gcc_r \
  505.mcf_r \
  520.omnetpp_r \
  523.xalancbmk_r \
  525.x264_r \
  531.deepsjeng_r \
  557.xz_r

./runcpu -c ../config/c3-spec-config.cfg -a run \
  508.namd_r \
  510.parest_r \
  511.povray_r \
  519.lbm_r \
  526.blender_r \
  538.imagick_r \
  544.nab_r

echo "Get PinPoints"
cd /
git clone https://github.com/intel/pinplay-tools.git
cd pinplay-scripts/PinPointsHome/Linux/bin/
make

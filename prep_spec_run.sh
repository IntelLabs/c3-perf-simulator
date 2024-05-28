#!/bin/bash
SPEC_ROOT=${1:-"/spec2017"}

echo "Build and Run SPEC becnhamarks natively"

echo "Get PinPoints"
cd /
git clone https://github.com/intel/pinplay-tools.git
cd pinplay-scripts/PinPointsHome/Linux/bin/
make

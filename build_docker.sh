DOCKER_NAME=c3-gem5-docker
GEM5_SRC_DIR=./c3-perf-simulator

mkdir outputs
docker build -t $DOCKER_NAME .
#docker run -u 0 -it $DOCKER_NAME
docker run -u 0 --volume ./outputs:/outputs -it $DOCKER_NAME

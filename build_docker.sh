DOCKER_NAME=c3-gem5-docker

docker build -t $DOCKER_NAME .
mkdir -p outputs
# Run docker
#docker run -u 0 -it $DOCKER_NAME
# Run docker with outputs directory mounted (to retrieve any test results)
docker run -u 0 --volume ./outputs:/outputs -it $DOCKER_NAME

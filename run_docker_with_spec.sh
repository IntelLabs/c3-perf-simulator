DOCKER_NAME=c3-gem5-docker
SPEC_ROOT=/spec2017/

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" < 1 ]]; then # Bad number of arguments.
	echo "Need to pass required args!"
  echo "Usage: $0 <Path/To/SPEC2017>"
	exit
fi

docker run -u 0 --volume ./outputs:/outputs --volume $1:$SPEC_ROOT -it $DOCKER_NAME

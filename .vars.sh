#!/bin/bash

set -e
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}


if ! _is_sourced; then
  echo "Error: script not sourced"
	exit 1;
fi

CONTAINER=$(docker ps -q -f name=${SERVICE})
NODE=$(docker service ps ${SERVICE} | awk '{print $4}' | grep -v NODE | head -1)

if [ -z "$NODE" ]; then
   echo "Error: node not found or service not scaled";
   exit 1
fi

NODE_ADDR=$(docker node inspect ${NODE} --pretty | grep "Address:" | grep -v 0.0.0.0 | awk '{print $2}' | awk -F: '{print $1}' | sort | uniq | head -1)

if [ -z "$CONTAINER" ]; then
  REMOTE_NODE=true
  CONTAINER=$(ssh ${NODE_ADDR} docker ps -q -f name=${SERVICE})
  DOCKER_EXEC="ssh ${NODE_ADDR} docker exec -u postgres -i ${CONTAINER}"
else
  REMOTE_NODE=false
  DOCKER_EXEC="docker exec -u postgres -it $(docker ps -q -f name=${SERVICE})"
fi

if [ -z "$CONTAINER" ]; then
    echo "No such container ${SERVICE} on this node or ${NODE} node".
fi

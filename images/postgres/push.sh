#!/bin/bash

set -xe
source .vars.sh

docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

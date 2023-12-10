#!/bin/bash

set -e
SERVICE=pg-database_db02
source .vars.sh

${DOCKER_EXEC} "$@"

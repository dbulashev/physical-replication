#!/bin/bash

set -e
SERVICE=pg-database_db01
source .vars.sh

${DOCKER_EXEC} "$@"
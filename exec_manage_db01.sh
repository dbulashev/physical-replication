#!/bin/bash

set -e
SERVICE=pg-database_manage_db01
source .vars.sh

${DOCKER_EXEC} "$@"

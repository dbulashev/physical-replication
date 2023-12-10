#!/bin/bash

set -e
pg_rewind -D ${PGDATA} --source-server="host=$1 password=${POSTGRES_PASSWORD}" -R -P

#!/bin/bash

set -e
./exec_db01.sh psql -c checkpoint;
docker service scale pg-database_db01=0
./exec_db02.sh pg_ctl promote
./exec_db02.sh sanitize_postgresql.conf.sh



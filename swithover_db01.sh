#!/bin/bash

set -e

export $(cat .env)

FPW=$(./exec_db02.sh sql_snippet.sh show_full_page_writes.sql | tr -d '\r')

if [ "on" != "${FPW}" ]; then
  echo "On db02 param full_page_writes must be set to 'ON'";
  exit 1
fi

docker service scale pg-database_db01=1
sleep 5
DCS=$(./exec_db01.sh sql_snippet.sh show_data_checksums.sql | tr -d '\r')
WLH=$(./exec_db01.sh sql_snippet.sh show_wal_log_hints.sql | tr -d '\r')

echo Param full_page_writes at db02 is ${FPW}
echo Param data_checksums at db01 is ${DCS}
echo Param wal_log_hints at db01 is ${WLH}

if [ "on" != "${DCS}" ] && [ "on" != "${WLH}" ]; then
  echo "On db01 param data_checksums or wal_log_hints must be set to 'ON'";
  docker service scale pg-database_db01=0
  exit 1
fi

./exec_db02.sh sql_snippet.sh create_replication_slot.sql

echo ""
docker service scale pg-database_manage_db01=1
echo ""
docker service scale pg-database_db01=0
echo ""

./exec_manage_db01.sh pg_rewind_from_server.sh db02

docker service scale pg-database_db01=1
echo ""
docker service scale pg-database_manage_db01=0

#!/bin/bash

set -e
cat /pgdata/postgresql.auto.conf  | grep -v primary_conninfo | grep -v primary_slot_name > /pgdata/postgresql.auto.conf.1
mv  /pgdata/postgresql.auto.conf.1 /pgdata/postgresql.auto.conf
chmod 0600 /pgdata/postgresql.auto.conf
pg_ctl reload

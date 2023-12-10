#!/bin/bash

set -ex

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  alter system set datestyle to 'iso, dmy';
  alter system set shared_buffers TO '2048MB';
  alter system set temp_buffers to '64MB';
  alter system set work_mem to '64MB';
  alter system set maintenance_work_mem to '512MB';
  alter system set random_page_cost = '1.1';
  alter system set log_min_duration_statement to '400';
  alter system set hot_standby_feedback to 'on';
  alter system set wal_log_hints to 'on';
EOSQL

if [ -z "$DB_ROLE" ]; then
    cat >&2 <<-'EOE'
			Error: You must specify DB_ROLE to a non-empty value
		EOE
		exit 1
fi

if [ "$DB_ROLE" = "primary" ]; then
  psql -U postgres -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  select pg_create_physical_replication_slot('replica');
  alter system set max_slot_wal_keep_size to '10GB';
EOSQL

fi;

echo "host    replication     all             10.0.9.0/24            trust" >> /pgdata/pg_hba.conf

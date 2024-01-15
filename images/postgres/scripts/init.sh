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
  alter system set archive_mode to 'on';
  alter system set archive_command = '/bin/true';
  alter system set logging_collector to 'on';
  alter system set log_autovacuum_min_duration to '10s';
  alter system set log_line_prefix to '%m %p %u@%d from %h [vxid:%v txid:%x] [%i] %Q ';
  alter system set log_lock_waits to 'on';
  alter system set log_recovery_conflict_waits to 'on';
  alter system set log_replication_commands to 'on';
  alter system set log_temp_files to '4MB';
  alter system set track_io_timing to 'on';
  alter system set track_wal_io_timing to 'on';
  alter system set track_functions to 'all';
  alter system set shared_preload_libraries to 'pg_stat_statements';
EOSQL

pg_ctl -D "$PGDATA" -m fast -w restart

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  alter system set pg_stat_statements.track to 'all';
  alter system set pg_stat_statements.track_utility to 'on';
  alter system set pg_stat_statements.track_planning to 'on';
  create extension if not exists pg_buffercache;
  create extension if not exists pgstattuple;
  create extension if not exists pg_stat_statements;
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

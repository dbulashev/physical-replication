#!/bin/bash

set -xe

if [ "$DB_ROLE" = "secondary" ]; then
  if [ -z "$PGDATA" ]; then
		echo "Error: You must specify PGDATA to a non-empty value"
		exit 1
  fi

  declare -g DATABASE_ALREADY_EXISTS
  if [ -s "$PGDATA/PG_VERSION" ]; then
		DATABASE_ALREADY_EXISTS='true'
	fi

  if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
    chown postgres:postgres "$PGDATA"

    if [ -z "$PRIMARY_HOST" ]; then
      echo "Error: You must specify PRIMARY_HOST to a non-empty value"
      exit 1
    fi
    if [ -z "$REPLICA_SLOT" ]; then
      REPLICA_SLOT=replica
    fi

    gosu postgres pg_basebackup --pgdata="$PGDATA" -R --slot="$REPLICA_SLOT" -h "$PRIMARY_HOST"
  fi

fi

/usr/local/bin/docker-entrypoint.sh "$@"

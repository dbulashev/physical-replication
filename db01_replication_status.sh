#!/bin/bash

echo Server is in recovery `./exec_db01.sh sql_snippet.sh pg_is_in_recovery.sql`
./exec_db01.sh sql_snippet_x.sh replication_status.sql

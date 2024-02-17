#!/bin/bash

docker service logs --tail 100 -f cron_cron_pg_profile_db01

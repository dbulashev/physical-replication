#!/bin/bash

docker service logs --tail 100 -f cron_pg_profile_db01

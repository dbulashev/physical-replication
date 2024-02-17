#!/bin/bash

export $(cat .env)
echo "db01:5432:postgres:postgres:${POSTGRES_PASSWORD}" > .pgpass
docker stack deploy --compose-file docker-compose-cron.yml cron
rm .pgpass
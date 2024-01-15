#!/bin/bash

export $(cat .env)
docker stack deploy --compose-file docker-compose-monitoring.yml monitoring

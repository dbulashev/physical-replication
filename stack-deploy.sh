#!/bin/bash

export $(cat .env | grep -v '^#')
docker stack deploy --compose-file docker-compose.yml pg-database

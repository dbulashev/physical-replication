#!/bin/bash

psql -h db01 -U postgres -d postgres -c 'SELECT profile.take_sample()'


#!/bin/bash

set -e
cat /snippets/$1 | psql -A -t

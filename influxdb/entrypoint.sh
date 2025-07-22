#!/bin/bash
set -euo pipefail

/docker-entrypoint-initdb.d/createdb.sh &
influxdb3 serve \
  --node-id local01 \
  --object-store file \
  --data-dir ~/.influxdb3 \
  --without-auth

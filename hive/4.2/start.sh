#!/bin/bash

echo "========== CUSTOM START.SH EXECUTED =========="
date
echo "USER: $(whoami)"
echo "PID: $$"
echo "SERVICE_NAME: ${SERVICE_NAME:-UNDEFINED}"
echo "HIVE_HOME: ${HIVE_HOME:-UNDEFINED}"
echo "==============================================="

set -euo pipefail

echo "Starting HiveServer2..."

/entrypoint.sh &
HIVE_PID=$!

echo "HiveServer2 process started: $HIVE_PID"

# setup-testdb.sh waits for JDBC and metastore readiness before running DDL.
echo "Initializing Hive database..."

if ! /opt/hive/setup-testdb.sh; then
    echo "ERROR: Hive database initialization failed"
    kill "$HIVE_PID" 2>/dev/null || true
    wait "$HIVE_PID" || true
    exit 1
fi

echo "Hive database initialization completed"

# Keep the container alive while HiveServer2 is running.
wait "$HIVE_PID"

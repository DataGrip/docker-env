#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for HiveServer2..."

HIVE_URL="jdbc:hive2://localhost:10000/default"
HIVE_TEST_DB="${HIVE_TEST_DB:-testdb}"
MAX_ATTEMPTS=${HIVE_INIT_MAX_ATTEMPTS:-60}
RETRY_INTERVAL=${HIVE_INIT_RETRY_INTERVAL:-5}
ATTEMPT=0

# The name is interpolated into SQL and a shell command below.
if [[ ! "$HIVE_TEST_DB" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "ERROR: Invalid Hive database name: $HIVE_TEST_DB" >&2
    exit 1
fi

PROBE_LOG=$(mktemp)
trap 'rm -f "$PROBE_LOG"' EXIT

while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do

    # -e propagates Beeline's exit status; without it script reports false success.
    # SHOW DATABASES also checks access to the metastore, without starting a query job.
    if timeout --kill-after=5s 60s script -q -e -c "/opt/hive/bin/beeline \
        -u '$HIVE_URL' \
        -n hive \
        --silent=true \
        --fastConnect=true \
        -e 'SHOW DATABASES'" /dev/null >"$PROBE_LOG" 2>&1; then

        echo "HiveServer2 is ready"
        break
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "Waiting for HiveServer2... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep "$RETRY_INTERVAL"
done

if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "ERROR: HiveServer2 is not ready"
    cat "$PROBE_LOG" >&2
    exit 1
fi

echo "Creating database: $HIVE_TEST_DB"

script -q -e -c "/opt/hive/bin/beeline \
    -u '$HIVE_URL' \
    -n hive \
    --silent=true \
    --fastConnect=true \
    -e 'SET ROLE ADMIN; CREATE DATABASE IF NOT EXISTS $HIVE_TEST_DB;'" /dev/null

echo "Verifying database..."

script -q -e -c "/opt/hive/bin/beeline \
    -u 'jdbc:hive2://localhost:10000/$HIVE_TEST_DB' \
    -n hive \
    --silent=true \
    --fastConnect=true \
    -e 'SHOW TABLES'" /dev/null

echo "Database $HIVE_TEST_DB successfully created and verified!"

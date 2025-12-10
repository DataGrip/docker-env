#!/bin/bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis SCHEMA postgis;
    DO \$\$
        BEGIN
            EXECUTE format('ALTER DATABASE %I SET search_path TO public, postgis', current_database());
        END
        \$\$;
EOSQL

echo "database: ${POSTGRES_DB}"
echo "user: ${POSTGRES_USER}"
echo "==================== initialization completed ===================="

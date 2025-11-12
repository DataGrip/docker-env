#!/bin/bash
set -e
echo "[INFO] ---------------------------< create extention >---------------------------"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER guest WITH PASSWORD 'guest';
    CREATE DATABASE guest;
    GRANT ALL PRIVILEGES ON DATABASE guest TO guest;
EOSQL

echo "[INFO] ---------------------------< create extention finished >------------------"
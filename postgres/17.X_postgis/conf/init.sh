#!/bin/bash
set -e
echo "[INFO] ---------------------------< create extention >---------------------------"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;

    CREATE SCHEMA postgis;

    UPDATE pg_extension SET extrelocatable = TRUE WHERE extname = 'postgis';

    ALTER EXTENSION postgis SET SCHEMA postgis;
    
    ALTER EXTENSION postgis UPDATE;

    CREATE EXTENSION postgis_raster SCHEMA postgis;
    
    CREATE  EXTENSION pgrouting SCHEMA postgis;
EOSQL
echo "[INFO] ---------------------------< create extention finished >------------------"
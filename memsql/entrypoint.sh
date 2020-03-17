#!/bin/bash
set -e

#if [[ "$1" = "memsqld" ]]; then
cd /
./memsql-ops start

    #Eliminate Minimum Core Count Requirement
./memsql-ops memsql-update-config --all --key minimum_core_count --value 0

    if [[ "$IGNORE_MIN_REQUIREMENTS" = "1" ]]; then
        ./memsql-ops memsql-update-config --all --key minimum_memory_mb --value 0
    fi

    memsql-ops memsql-start --all
    memsql-ops memsql-list

  if [ ! -z $MEMSQL_USER ]; then
        echo "MEMSQL_USER: $MEMSQL_USER"
    else
        MEMSQL_USER=guest
        echo "MEMSQL_USER: $MEMSQL_USER"
    fi

    if [ ! -z $MEMSQL_PASSWORD ]; then
        echo "MEMSQL_PASSWORD: $MEMSQL_PASSWORD"
    else
        MEMSQL_PASSWORD=guest
        echo "MEMSQL_PASSWORD: $MEMSQL_PASSWORD"
    fi

    if [ ! -z $MEMSQL_DB ]; then
        echo "MEMSQL_DB: $MEMSQL_DB"
    else
        MEMSQL_DB=guest
        echo "MEMSQL_DB: $MEMSQL_DB"
    fi

cat <<-EOSQL > /schema.sql
create database $MEMSQL_DB;
grant all on *.* to '$MEMSQL_USER'@'%' identified by '$MEMSQL_PASSWORD' with grant option;
EOSQL


    # Check for a schema file at /schema.sql and load it
#    if [[ -e /schema.sql ]]; then
        echo "Loading schema from /schema.sql"
        cat /schema.sql
        memsql < /schema.sql
#    fi

    # Tail the logs to keep the container alive
    exec tail -F /memsql/master/tracelogs/memsql.log /memsql/leaf/tracelogs/memsql.log
#else
#    exec "$@"
#fi
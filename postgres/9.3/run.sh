#!/bin/bash
set -e

POSTGRESQL_USER=${POSTGRESQL_USER:-"guest"}
POSTGRESQL_PASS=${POSTGRESQL_PASS:-"guest"}
POSTGRESQL_DB=${POSTGRESQL_DB:-"guest"}

POSTGRESQL_BIN_PATH=/usr/lib/postgresql/9.3/bin
POSTGRESQL_INITDB=/usr/lib/postgresql/9.3/bin/initdb
POSTGRESQL_CONFIG_FILE=/etc/postgresql/9.3/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/9.3/main

if [ -d $POSTGRESQL_DATA ]
then
	chown -R postgres:postgres $POSTGRESQL_DATA
fi

# initialize db if needed
if [ ! "`ls -A $POSTGRESQL_DATA`" ] ; then
	su postgres sh -c "$POSTGRESQL_INITDB --locale=en_US.UTF-8 $POSTGRESQL_DATA"
fi

su postgres /bin/bash -c "$POSTGRESQL_BIN_PATH/postgres --single -c config_file=$POSTGRESQL_CONFIG_FILE" <<< "CREATE USER $POSTGRESQL_USER WITH SUPERUSER PASSWORD '$POSTGRESQL_PASS';"
su postgres /bin/bash -c "$POSTGRESQL_BIN_PATH/postgres --single -c config_file=$POSTGRESQL_CONFIG_FILE" <<< "CREATE DATABASE $POSTGRESQL_DB WITH OWNER $POSTGRESQL_USER ENCODING 'utf8' TEMPLATE template0;"

su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main --config_file=/etc/postgresql/9.3/main/postgresql.conf"

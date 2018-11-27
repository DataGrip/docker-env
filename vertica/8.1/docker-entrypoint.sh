#!/bin/bash
set -e

# Function to shut down Vertica gracefully
function shut_down() {
  echo "Shutting Down Vertica"
  gosu dbadmin /opt/vertica/bin/admintools -t stop_db -d docker -i
  exit
}

# Ensure Vertica gets shutdown correctly
trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Set dbadmin as the owner of our data
chown -R dbadmin:verticadba "$VERTICADATA"

if [ ! -z $VERTICA_DB ]; then
  echo "VERTICA_DB: $VERTICA_DB"
else
	VERTICA_DB=testdb
	echo "VERTICA_DB: $VERTICA_DB"
fi

if [ ! -z $VERTICA_USER ]; then
	echo "VERTICA_USER: $VERTICA_USER"	
else
	VERTICA_USER=tester
	echo "VERTICA_USER: $VERTICA_USER"
fi

if [ ! -z $VERTICA_PASSWORD ]; then
	echo "VERTICA_PASSWORD: $VERTICA_PASSWORD"	
else
	VERTICA_PASSWORD=guest1234
	echo "VERTICA_PASSWORD: $VERTICA_PASSWORD"
fi

# If no data exists, create the database, otherwise just start the db
if [ -z "$(ls -A "$VERTICADATA")" ]; then
  echo "Creating database"
  gosu dbadmin /opt/vertica/bin/admintools -t drop_db -d docker
  gosu dbadmin /opt/vertica/bin/admintools -t create_db -s localhost --skip-fs-checks -d $VERTICA_DB -c /home/dbadmin/docker/catalog -D /home/dbadmin/docker/data
else
  gosu dbadmin /opt/vertica/bin/admintools -t drop_db -d docker
  gosu dbadmin /opt/vertica/bin/admintools -t create_db -s localhost --skip-fs-checks -d $VERTICA_DB  
fi

echo "Vertica is now running"

mkdir /objects/
cd /objects

cat <<-EOSQL > init.sql
CREATE USER $VERTICA_USER IDENTIFIED BY '$VERTICA_PASSWORD';

GRANT USAGE ON SCHEMA PUBLIC TO $VERTICA_USER;
EOSQL

cat ./init.sql

# If sql files were provided, run them to bootstrap the database
if [ -d /objects ]; then
    echo "Creating objects..."
    find /objects/init.sql -exec /opt/vertica/bin/vsql -h localhost -U dbadmin -d $VERTICA_DB -f {} \;
else
    echo "No object scripts found, proceeding with an empty database."
fi

while true; do
  sleep 1
done


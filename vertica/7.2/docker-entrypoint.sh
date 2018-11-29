#!/bin/bash
set -e

STOP_LOOP="false"

# Vertica should be shut down properly
function shut_down() {
  echo "Shutting Down"
  vertica_proper_shutdown
  echo 'Saving configuration'
  mkdir -p ${VERTICADATA}/config
  /bin/cp /opt/vertica/config/admintools.conf ${VERTICADATA}/config/admintools.conf
  echo 'Stopping loop'
  STOP_LOOP="true"
}

function vertica_proper_shutdown() {
  echo 'Vertica: Closing active sessions'
  /bin/su - dbadmin -c '/opt/vertica/bin/vsql -U dbadmin -d docker -c "SELECT CLOSE_ALL_SESSIONS();"'
  echo 'Vertica: Flushing everything on disk'
  /bin/su - dbadmin -c '/opt/vertica/bin/vsql -U dbadmin -d docker -c "SELECT MAKE_AHM_NOW();"'
  echo 'Vertica: Stopping database'
  /bin/su - dbadmin -c '/opt/vertica/bin/admintools -t stop_db -d docker -i'
}

function fix_filesystem_permissions() {
  chown -R dbadmin:verticadba "${VERTICADATA}"
  chown dbadmin:verticadba /opt/vertica/config/admintools.conf
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT

if [ ! -z $VERTICA_DB ]; then
  echo "VERTICA_DB: $VERTICA_DB"
else
	VERTICA_DB=testdb
	echo "VERTICA_DB: $VERTICA_DB"
fi

if [ ! -z $VERTICA_SCHEMA ]; then
  echo "VERTICA_SCHEMA: $VERTICA_SCHEMA"
else
	VERTICA_SCHEMA=guest
	echo "VERTICA_SCHEMA: $VERTICA_SCHEMA"
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

echo 'Starting up'
if [ -z "$(ls -A "${VERTICADATA}")" ]; then
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Creating database'
  su - dbadmin -c "/opt/vertica/bin/admintools -t create_db --skip-fs-checks -s localhost -d docker -c ${VERTICADATA}/catalog -D ${VERTICADATA}/data"

else
  if [ -f ${VERTICADATA}/config/admintools.conf ]; then
    echo 'Restoring configuration'
    cp ${VERTICADATA}/config/admintools.conf /opt/vertica/config/admintools.conf
  fi
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Starting Database'
  # drop docker db to create a custom one
  su - dbadmin -c "/opt/vertica/bin/admintools -t drop_db -d docker"
  su - dbadmin -c "/opt/vertica/bin/admintools -t create_db -s localhost -d $VERTICA_DB -c ${VERTICADATA}/catalog -D ${VERTICADATA}/data"
fi

mkdir /objects/
cd /objects

cat <<-EOSQL > init.sql
CREATE USER $VERTICA_USER IDENTIFIED BY '$VERTICA_PASSWORD';

CREATE SCHEMA $VERTICA_SCHEMA;

GRANT ALL ON SCHEMA PUBLIC TO $VERTICA_USER;

GRANT ALL ON SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA PUBLIC TO $VERTICA_USER;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;

GRANT ALL ON ALL SEQUENCES IN SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;
EOSQL

cat ./init.sql

su - dbadmin -c "/opt/vertica/bin/vsql -U dbadmin -d $VERTICA_DB -f /objects/init.sql"

echo "Vertica is now running"

while [ "${STOP_LOOP}" == "false" ]; do
  sleep 1
done

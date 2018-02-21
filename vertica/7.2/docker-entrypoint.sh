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
# todo: need to pass env variable to another user
#if [ ! -z $VERTICA_SCHEMA ]; then
#	echo "VERTICA_SCHEMA: $VERTICA_SCHEMA"
#else
#	VERTICA_SCHEMA=guest
#	echo "VERTICA_SCHEMA: $VERTICA_SCHEMA"
#fi

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
  su - dbadmin -c '/opt/vertica/bin/admintools -t start_db -d docker -i'
fi

su - dbadmin -c '/opt/vertica/bin/vsql -U dbadmin -d docker -c "CREATE SCHEMA guest;"'

echo "Vertica is now running"

while [ "${STOP_LOOP}" == "false" ]; do
  sleep 1
done

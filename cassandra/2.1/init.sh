#!/bin/bash
set -e

echo =============== WAITING FOR CASSANDRA ==========================
#waiting for CASSANDRA to start
export STATUS=0
i=0
while [[ $STATUS -eq 0 ]] || [[ $i -lt 90 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep 'Starting listening for CQL clients' /var/log/cassandra/system.log | wc -l)
done

echo =============== CASSANDRA STARTED ==========================

if [ ! -z $KEY_SPACE ]; then
	echo "KEY_SPACE: $KEY_SPACE"	
else
	KEY_SPACE=guest
	echo "KEY_SPACE: $KEY_SPACE"
fi

cd /tmp/
cat <<-EOSQL > init
CREATE KEYSPACE $KEY_SPACE WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
CREATE USER IF NOT EXISTS limited_access_role WITH PASSWORD 'limited_access_role' NOSUPERUSER;

EOSQL

cqlsh -u cassandra -p cassandra --file=/tmp/init

echo =============== KEY_SPACE CREATED ==========================

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "END=1" INT TERM
done
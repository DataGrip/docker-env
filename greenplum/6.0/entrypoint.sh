#!/bin/bash
export STATUS=0
i=0
echo "STARTING... (about 30 sec)"
while [[ $STATUS -eq 0 ]] || [[ $i -lt 30 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep -r -i --include \*.log "Database successfully started" | wc -l)
done

echo "STARTED"

if [ ! -z $GP_USER ]; then
	echo "GP_USER: $GP_USER"
else
	GP_USER=tester
	echo "GP_USER: $GP_USER"
fi

if [ ! -z $GP_PASSWORD ]; then
	echo "GP_PASSWORD: $GP_PASSWORD"
else
	GP_PASSWORD=pivotal
	echo "GP_PASSWORD: $GP_PASSWORD"
fi

if [ ! -z $GP_DB ]; then
	echo "GP_DB: $GP_DB"
else
	GP_DB=testdb
	echo "GP_DB: $GP_DB"
fi

source /home/gpadmin/.bash_profile
/opt/greenplum-db-6.1.0/bin/psql -v ON_ERROR_STOP=1 --username gpadmin --dbname postgres <<-EOSQL
CREATE USER $GP_USER WITH PASSWORD '$GP_PASSWORD' SUPERUSER;
CREATE DATABASE $GP_DB WITH OWNER $GP_USER;
CREATE USER guest WITH PASSWORD 'guest';
CREATE DATABASE guest WITH OWNER guest;
EOSQL

cat << EOF
+-------------------------------------------------
|  CREATE USER $GP_USER WITH PASSWORD '$GP_PASSWORD' SUPERUSER;
|  CREATE USER guest WITH PASSWORD 'guest';
+-------------------------------------------------
EOF

cat << EOF
+-------------------------------------------------
|  CREATE DATABASE $GP_DB WITH OWNER $GP_USER;
|  CREATE DATABASE guest WITH OWNER guest;
+-------------------------------------------------
EOF

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "gpstop -M && END=1" INT TERM
done

#!/bin/bash

set -e

/etc/init.d/ssh start
sleep 1
su - gpadmin bash -c 'gpstart -a'

export STATUS=0
i=0
echo "STARTING... (about 30 sec)"
while [[ $STATUS -eq 0 ]] || [[ $i -lt 30 ]]; do
    sleep 1
    i=$((i+1))
    STATUS=$(grep -r -i --include \*.log "Database successfully started" | wc -l)
done

echo "STARTED"

source /home/gpadmin/.bash_profile
su - gpadmin bash -c 'psql -d postgres -f /init.sql'

trap "kill %1; su - gpadmin bash -c 'gpstop -a -M fast' && END=1" INT TERM

tail -f `ls /data/master/gpsne-1/pg_log/gpdb-* | tail -n1` &

#trap
while [ "$END" == '' ]; do
    sleep 1
done
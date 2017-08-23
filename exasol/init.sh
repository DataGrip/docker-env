#!/bin/bash

echo =============== WAITING FOR EXASOL ==========================
#waiting for exasol to start
export STATUS=0
i=0
while [[ $STATUS -eq 0 ]] || [[ $i -lt 120 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep 'System is ready to receive client connections.' /exa/logs/logd/DWAd.log | wc -l)
done

echo =============== PUTTING ADAPTER TO DEFAULT BUCKET ==========================
#get default bucket write password
BW_PWD=$(grep 'write-password' /exa/etc/bucketfs.cfg | sed "s/write-password = //g" | base64 -d)
curl -X PUT -T /virtualschema-jdbc-adapter-dist-0.0.1-SNAPSHOT.jar http://w:$BW_PWD@localhost:6583/default/virtualschema-jdbc-adapter-dist-0.0.1-SNAPSHOT.jar


if [ ! -f /exa/logs/logd/Authentication.log ]; then
    echo =============== ADAPTER ADDED TO DEFAULT BUCKET ==========================
fi

#trap
while [ "$END" == '' ]; do
    sleep 1
	trap "/usr/opt/EXASuite-6/EXAClusterOS-6.0.2/devel/docker/exadt stop && END=1" INT TERM
done

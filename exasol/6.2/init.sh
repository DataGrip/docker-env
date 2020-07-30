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
BW_PWD=$(grep 'write-password' /exa/etc/bucketfs.cfg_bfsdefault | sed "s/write-password = //g" | base64 -d)
curl -X PUT -T /virtual-schema-dist-5.0.2-exasol-3.0.2.jar http://w:$BW_PWD@localhost:6583/default/virtual-schema-dist-5.0.2-exasol-3.0.2.jar

if [ ! -f /exa/logs/logd/Authentication.log ]; then
    echo =============== ADAPTER ADDED TO DEFAULT BUCKET ==========================
fi

if [ ! -z $EXASOL_SCHEMA ]; then
	echo "EXASOL_SCHEMA: $EXASOL_SCHEMA"
else
	EXASOL_SCHEMA=test
	echo "EXASOL_SCHEMA: $EXASOL_SCHEMA"
fi

#creating default schema
echo "CREATE SCHEMA $EXASOL_SCHEMA;" | ./usr/opt/EXASuite-6/EXASolution-${EXA_RE_VERSION?}/bin/Console/exaplus -c n11:8888 -u sys -P exasol

echo =============== EXASOL STARTED ==========================

#trap
while [ "$END" == '' ]; do
    sleep 1
	trap "/usr/opt/EXASuite-6/EXAClusterOS-${EXA_RE_VERSION?}/devel/docker/exadt stop && END=1" INT TERM
done

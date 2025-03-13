#!/bin/bash

echo =============== WAITING FOR EXASOL ==========================
#waiting for exasol to start
while ! grep -q 'System is ready to receive client connections.' /exa/logs/logd/DWAd.log; do
    echo "Wait 5 seconds..."
    sleep 5
done
echo "EXASOL is ready!"

echo =============== PUTTING ADAPTER TO DEFAULT BUCKET ==========================
#get default bucket write password
export BW_PWD=$(grep 'write-password' /exa/etc/bucketfs.cfg_bfsdefault | sed "s/write-password = //g" | base64 -d)
curl -X PUT -T /virtual-schema-dist-9.0.2-exasol-5.0.1.jar https://w:$BW_PWD@localhost:2581/default/virtual-schema-dist-9.0.2-exasol-5.0.1.jar -f --insecure

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

export FINGERPRINT=$(openssl s_client -connect localhost:8563 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256 | tr -d ':' | awk -F= '{print $2}')
echo "CREATE SCHEMA $EXASOL_SCHEMA;" | ./opt/exasol/db-8.32.0/bin/Console/exaplus -c n11/$FINGERPRINT -u sys -p exasol

echo =============== EXASOL STARTED ==========================

#trap
#while [ "$END" == '' ]; do
#    sleep 1
#  trap "/opt/exasol/cos-8.51.0/docker/exadt stop && END=1" INT TERM
#done

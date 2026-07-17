#!/bin/bash

set -m
set -e

/entrypoint.sh couchbase-server &

export STATUS=0
i=0
while (( $i < 90 )); do
	sleep 1
	i=$((i+1))
	echo $i
	STATUS=$(grep -r "Apache CouchDB has started on.*" /opt/couchbase/var/lib/couchbase/logs/couchdb.log | wc -l)
	if (( $STATUS != 0 )); then
		echo "Server has started"
		break
	fi
done
if (( $STATUS == 0 )); then
	echo "ERROR: Couchbase server did not start within 90s" >&2
	exit 1
fi

yes | ./opt/couchbase/bin/couchbase-cli enable-developer-preview --enable -c localhost:8091 -u Administrator -p password

if [ ! -z $COUCH_ADMPWD ]; then
	echo "COUCH_ADMPWD: $COUCH_ADMPWD"
else
	COUCH_ADMPWD=dGr3En238
	echo "COUCH_ADMPWD: $COUCH_ADMPWD"
fi

if [ ! -z $COUCH_USRPWD ]; then
	echo "COUCH_USRPWD: $COUCH_USRPWD"
else
	COUCH_USRPWD=239dGr3En
	echo "COUCH_USRPWD: $COUCH_USRPWD"
fi

curl -v -f -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=1024 -d indexMemoryQuota=1024 -d ftsMemoryQuota=1024
curl -v -f http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex%2Cfts
curl -v -f http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
curl -v -f -X POST http://127.0.0.1:8091/pools/default/buckets \
-u Administrator:password \
-d name=guest \
-d ramQuotaMB=512 \
-d bucketType=ephemeral

curl -v -f -X POST http://127.0.0.1:8091/settings/indexes \
-u Administrator:password \
-d indexerThreads=0 \
-d logLevel=info \
-d maxRollbackPoints=5 \
-d memorySnapshotInterval=200 \
-d stableSnapshotInterval=5000 \
-d storageMode=plasma

curl -v -f -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/admin \
-d password=$COUCH_ADMPWD \
-d roles=admin

curl -v -f -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/roadmin \
-d password=$COUCH_USRPWD \
-d roles=ro_admin

fg 1

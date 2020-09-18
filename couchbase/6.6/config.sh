#!/bin/bash

set -m

/entrypoint.sh couchbase-server &

export STATUS=0
i=0
while [[ $STATUS -eq 0 ]] || [[ $i -lt 30 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep -r "Apache CouchDB has started on.*" /opt/couchbase/var/lib/couchbase/logs/couchdb.log | wc -l)
done

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

curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=1024 -d indexMemoryQuota=1024 -d ftsMemoryQuota=1024
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex%2Cfts
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
curl -v -X POST http://127.0.0.1:8091/pools/default/buckets \
-u Administrator:password \
-d name=guest \
-d ramQuotaMB=512 \
-d bucketType=ephemeral

curl -v -X POST http://127.0.0.1:8091/settings/indexes \
-u Administrator:password \
-d indexerThreads=0 \
-d logLevel=info \
-d maxRollbackPoints=5 \
-d memorySnapshotInterval=200 \
-d stableSnapshotInterval=5000 \
-d storageMode=memory_optimized

curl -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/admin \
-d password=$COUCH_ADMPWD \
-d roles=admin

curl -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/roadmin \
-d password=$COUCH_USRPWD \
-d roles=ro_admin

fg 1

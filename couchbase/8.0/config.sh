#!/bin/bash

set -m
set -e

/entrypoint.sh couchbase-server &

export STATUS=0
i=0
while (( $i < 600 )); do
	sleep 1
	i=$((i+1))
	echo $i
	STATUS=$(grep -r "Server has started on.*" /opt/couchbase/var/lib/couchbase/logs/info.log | wc -l)
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

echo "=============== Initialize Node ==============="
curl --fail-with-body -v -u Administrator:password -X POST \
  http://localhost:8091/nodes/self/controller/settings \
  -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata' \
  -d 'index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata' \
  -d 'cbas_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata' \
  -d 'eventing_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata'

echo "=============== Memory Quotas ==============="
curl --fail-with-body -v -u Administrator:password -X POST http://localhost:8091/pools/default \
  -d 'memoryQuota=1024' \
  -d 'indexMemoryQuota=1024' \
  -d 'ftsMemoryQuota=1024'

echo "=============== Services ==============="
curl --fail-with-body -v -u Administrator:password -X POST http://localhost:8091/node/controller/setupServices \
  -d 'services=kv%2Cn1ql%2Cindex%2Cfts'

echo "=============== Administrator username and password ==============="
curl --fail-with-body -v -u Administrator:password -X POST http://localhost:8091/settings/web \
  -d 'password=password' \
  -d 'username=Administrator' \
  -d 'port=SAME'

echo "=============== Indexes ==============="
curl --fail-with-body -v -X POST http://127.0.0.1:8091/settings/indexes \
-u Administrator:password  \
--data-urlencode 'storageMode=plasma' \
--data-urlencode 'indexerThreads=0' \
--data-urlencode 'logLevel=info' \
--data-urlencode 'maxRollbackPoints=5' \
--data-urlencode 'memorySnapshotInterval=200' \
--data-urlencode 'stableSnapshotInterval=5000'


echo "=============== Bucket ==============="
curl --fail-with-body -v -u Administrator:password -X POST http://localhost:8091/pools/default/buckets \
  -d 'flushEnabled=1' \
  -d 'threadsNumber=3' \
  -d 'replicaIndex=0' \
  -d 'replicaNumber=0' \
  -d 'evictionPolicy=valueOnly' \
  -d 'ramQuotaMB=256' \
  -d 'bucketType=membase' \
  -d 'name=guest'


echo "=============== Admin user ==============="
curl --fail-with-body -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/admin \
-d password=$COUCH_ADMPWD \
-d roles=admin

echo "=============== Read only admin ==============="
curl --fail-with-body -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/roadmin \
-d password=$COUCH_USRPWD \
-d roles=ro_admin

fg 1

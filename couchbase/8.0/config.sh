#!/bin/bash

set -m

/entrypoint.sh couchbase-server &

export STATUS=0
i=0
while (( $i < 30 )); do
	sleep 1
	i=$((i+1))
	echo $i
	STATUS=$(grep -r "Server has started on.*" /opt/couchbase/var/lib/couchbase/logs/info.log | wc -l)
	if (( $STATUS != 0 )); then
 		echo "Server has started"
 		break
 	fi
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


# Initialize Node
curl  -u Administrator:password -v -X POST \
  http://localhost:8091/nodes/self/controller/settings \
  -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' \
  -d 'index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' \
  -d 'cbas_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' \
  -d 'eventing_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&'

# services
curl  -u Administrator:password -v -X POST http://localhost:8091/node/controller/setupServices \
  -d 'services=kv%2Cn1ql%2Cindex%2Cfts'

# Memory Quotas
curl  -u Administrator:password -v -X POST http://localhost:8091/pools/default \
  -d 'memoryQuota=256' \
  -d 'indexMemoryQuota=256' \
  -d 'ftsMemoryQuota=256'

# Administrator username and password
curl  -u Administrator:password -v -X POST http://localhost:8091/settings/web \
  -d 'password=password&username=Administrator&port=SAME'

# bucket
curl  -u Administrator:password -v -X POST http://localhost:8091/pools/default/buckets \
  -d 'flushEnabled=1&threadsNumber=3&replicaIndex=0&replicaNumber=0& \
  evictionPolicy=valueOnly&ramQuotaMB=256&bucketType=membase&name=guest'

# indexes
curl -v -X POST http://127.0.0.1:8091/settings/indexes \
-u Administrator:password \
-d indexerThreads=0 \
-d logLevel=info \
-d maxRollbackPoints=5 \
-d memorySnapshotInterval=200 \
-d stableSnapshotInterval=5000 \
-d storageMode=memory_optimized

# admin user
curl -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/admin \
-d password=$COUCH_ADMPWD \
-d roles=admin

# read only admin
curl -v -X  PUT -u Administrator:password \
http://localhost:8091/settings/rbac/users/local/roadmin \
-d password=$COUCH_USRPWD \
-d roles=ro_admin

fg 1

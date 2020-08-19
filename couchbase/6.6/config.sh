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

curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=256 -d indexMemoryQuota=256 -d ftsMemoryQuota=256
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex%2Cfts
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
curl -v -X POST http://127.0.0.1:8091/pools/default/buckets \
-u Administrator:password \
-d name=guest \
-d ramQuotaMB=256 \
-d bucketType=ephemeral

fg 1

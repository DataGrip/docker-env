#!/bin/bash

set -e

CB_USER="${COUCHBASE_ADMINISTRATOR_USERNAME:-Administrator}"
CB_PASS="${COUCHBASE_ADMINISTRATOR_PASSWORD:-password}"

COUCH_ADMPWD="${COUCH_ADMPWD:-dGr3En238}"
COUCH_USRPWD="${COUCH_USRPWD:-239dGr3En}"

CB_RAM_MB="${CB_RAM_MB:-1024}"
CB_INDEX_RAM_MB="${CB_INDEX_RAM_MB:-1024}"
CB_FTS_RAM_MB="${CB_FTS_RAM_MB:-256}"
CB_ANALYTICS_RAM_MB="${CB_ANALYTICS_RAM_MB:-1024}"

CB_BUCKET="${CB_BUCKET:-ea-storage}"
CB_SCOPE="${CB_SCOPE:-app}"
CB_COLLECTION="${CB_COLLECTION:-events}"

CB_DATA_PATH=/opt/couchbase/var/lib/couchbase/data
CB_API=http://127.0.0.1:8091
CB_ANALYTICS=http://127.0.0.1:8095/analytics/service

cb() {
	local code
	code=$(curl -sS -o /tmp/response -w '%{http_code}' -u "$CB_USER:$CB_PASS" "$@")
	cat /tmp/response
	echo
	case "$code" in
		2*) return 0 ;;
		*)  echo "ERROR: HTTP $code" >&2; return 1 ;;
	esac
}

analytics() {
	cb "$CB_ANALYTICS" \
		-H 'Content-Type: application/json' \
		--data-binary "{\"statement\":\"$1\"}"
}

wait_for() {
	local desc="$1"; shift
	echo "Waiting for $desc"
	for ((i = 0; i < 45; i++)); do
		"$@" >/dev/null 2>&1 && return 0
		sleep 2
	done
	echo "ERROR: $desc not available after 90s" >&2
	exit 1
}

echo "Starting Couchbase Server"
/entrypoint.sh "$@" &
CB_PID=$!
trap 'kill "$CB_PID" 2>/dev/null || true' SIGTERM SIGINT

wait_for "Couchbase HTTP API" curl -sS -f "$CB_API/pools"

echo "Initialize Node"
cb -X POST "$CB_API/nodes/self/controller/settings" \
	--data-urlencode "path=$CB_DATA_PATH" \
	--data-urlencode "index_path=$CB_DATA_PATH" \
	--data-urlencode "cbas_path=$CB_DATA_PATH" \
	--data-urlencode "eventing_path=$CB_DATA_PATH"

echo "Set services"
cb -X POST "$CB_API/node/controller/setupServices" \
	--data-urlencode 'services=kv,n1ql,index,fts,cbas'

echo "Set administrator username and password"
cb -X POST "$CB_API/settings/web" \
	--data-urlencode "username=$CB_USER" \
	--data-urlencode "password=$CB_PASS" \
	--data-urlencode 'port=SAME'

wait_for "authenticated API" cb "$CB_API/pools/default"

echo "Set memory quotas"
cb -X POST "$CB_API/pools/default" \
	--data-urlencode "memoryQuota=$CB_RAM_MB" \
	--data-urlencode "indexMemoryQuota=$CB_INDEX_RAM_MB" \
	--data-urlencode "ftsMemoryQuota=$CB_FTS_RAM_MB" \
	--data-urlencode "cbasMemoryQuota=$CB_ANALYTICS_RAM_MB"

echo "Set Developer preview"
yes | /opt/couchbase/bin/couchbase-cli enable-developer-preview --enable \
	-c "$CB_API" -u "$CB_USER" -p "$CB_PASS"

echo "Set indexes"
cb -X POST "$CB_API/settings/indexes" \
	--data-urlencode 'storageMode=plasma' \
	--data-urlencode 'indexerThreads=0' \
	--data-urlencode 'logLevel=info' \
	--data-urlencode 'maxRollbackPoints=5' \
	--data-urlencode 'memorySnapshotInterval=200' \
	--data-urlencode 'stableSnapshotInterval=5000'

echo "Create bucket: guest"
cb -X POST "$CB_API/pools/default/buckets" \
  --data-urlencode 'flushEnabled=1' \
  --data-urlencode 'threadsNumber=3' \
  --data-urlencode 'replicaIndex=0' \
  --data-urlencode 'replicaNumber=0' \
  --data-urlencode 'evictionPolicy=valueOnly' \
  --data-urlencode 'ramQuotaMB=256' \
  --data-urlencode 'bucketType=membase' \
  --data-urlencode 'name=guest'

echo "Set Admin user"
cb -X PUT "$CB_API/settings/rbac/users/local/admin" \
	--data-urlencode "password=$COUCH_ADMPWD" \
	--data-urlencode 'roles=admin'

echo "Set read only admin"
cb -X PUT "$CB_API/settings/rbac/users/local/roadmin" \
	--data-urlencode "password=$COUCH_USRPWD" \
	--data-urlencode 'roles=ro_admin'

echo "Couchbase is ready"
touch /tmp/couchbase-ready

wait "$CB_PID"
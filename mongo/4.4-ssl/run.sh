#!/bin/bash
set -m

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE"
cmd="$mongodb_cmd --bind_ip_all"

cat <<-MONGOCFG > /mongod.conf
systemLog:
   destination: file
   path: '/data/mongod.log'
   logAppend: true
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
net:
   bindIp: 127.0.0.1,localhost
   port: 27017
   tls:
      mode: requireTLS
      certificateKeyFile: '/opt/certs/server.pem'
      CAFile: '/opt/certs/ca.crt'
      clusterFile: '/opt/certs/server.pem'
security:
   clusterAuthMode: x509
storage:
   dbPath: '/data/db'
MONGOCFG

if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth --config /mongod.conf"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi
echo "========================================================================"
echo $cmd
echo "========================================================================"

$cmd &

if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

fg

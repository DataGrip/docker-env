#!/bin/bash
set -m

cat <<-MONGOCFG > /etc/mongod.conf
systemLog:
   destination: file
   path: '/data/mongod.log'
   logAppend: true
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
net:
   bindIp: 0.0.0.0
   port: 27017
   tls:
      mode: requireTLS
      certificateKeyFile: '/opt/certs/server.pem'
      CAFile: '/opt/certs/ca.pem'
storage:
   dbPath: '/data/db'
MONGOCFG

cmd="mongod --config /etc/mongod.conf"

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

echo "========================================================================"
echo $cmd
echo "========================================================================"

if [ ! -f /data/db/.mongodb_password_set ]; then
    echo "=> Starting MongoDB..."
    $cmd &
    MONGO_PID=$!

    sleep 3

    /set_password.sh

    if [ $? -eq 0 ]; then
        echo "=> Stopping MongoDB for restart with auth..."
        kill $MONGO_PID
        wait $MONGO_PID 2>/dev/null
    else
        echo "=> Password setup failed!"
        exit 1
    fi
fi

if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

echo "=> Starting MongoDB with auth enabled..."
exec $cmd
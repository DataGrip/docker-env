#!/bin/bash

MONGO_ADMIN=${MONGO_ADMIN:-"admin"}
MONGO_A_DB=${MONGO_A_DB:-"admin"}
MONGO_A_PWD=${MONGO_A_PWD:-$(pwgen -s 12 1)}
_word=$( [ ${MONGO_A_PWD} ] && echo "preset" || echo "random" )

USER=${MONGODB_USER:-"guest"}
DATABASE=${MONGODB_DATABASE:-"guest"}
PASS=${MONGODB_PASS:-"guest"}

MONGO_CMD="mongosh --tls --tlsCAFile /opt/certs/ca.pem --tlsAllowInvalidHostnames --tlsCertificateKeyFile /opt/certs/client.pem --quiet"

sleep 2

i=0
while [[ $i -lt 90 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup ($i)"

    if $MONGO_CMD --host 127.0.0.1 --port 27017 --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
        echo "=> MongoDB is ready!"
        break
    fi
    sleep 2
    i=$((i+1))
done

if [[ $i -eq 90 ]]; then
    echo "=> ERROR: MongoDB did not start in time"
    echo "=> Check /data/mongod.log for details:"
    tail -50 /data/mongod.log
    exit 1
fi

echo "=> Creating an ${MONGO_ADMIN}"
$MONGO_CMD --host 127.0.0.1 --port 27017 admin --eval "db.createUser({user: '$MONGO_ADMIN', pwd: '$MONGO_A_PWD', roles:[{role:'root',db:'$MONGO_A_DB'}]})"

echo "=> Creating an ${USER}"
$MONGO_CMD --host 127.0.0.1 --port 27017 admin -u "$MONGO_ADMIN" -p "$MONGO_A_PWD" --eval "db.createUser({user: '$USER', pwd: '$PASS', roles: [{ role: 'userAdminAnyDatabase', db: '$MONGO_A_DB' }, 'readWriteAnyDatabase']})"

echo "=> Done!"
touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "MongoDB admin user: $MONGO_ADMIN"
echo "MongoDB admin password: $MONGO_A_PWD"
echo ""
echo "MongoDB app user: $USER"
echo "MongoDB app password: $PASS"
echo ""
echo "Connect with:"
echo "    mongosh --tls --tlsCAFile ca.pem --tlsAllowInvalidHostnames --tlsCertificateKeyFile client.pem -u $USER -p $PASS --host <host>"
echo "========================================================================"
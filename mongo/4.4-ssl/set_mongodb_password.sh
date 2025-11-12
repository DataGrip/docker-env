#!/bin/bash

MONGO_ADMIN=${MONGO_ADMIN:-"admin"}
MONGO_A_DB=${MONGO_A_DB:-"admin"}
MONGO_A_PWD=${MONGO_A_PWD:-$(pwgen -s 12 1)}
_word=$( [ ${MONGO_A_PWD} ] && echo "preset" || echo "random" )

USER=${MONGODB_USER:-"guest"}
DATABASE=${MONGODB_DATABASE:-"guest"}
PASS=${MONGODB_PASS:-"guest"}

export i=0
while [[ $i -lt 90 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup ($i)"
    sleep 1
    i=$((i+1))
    mongo admin --tls --tlsCAFile /opt/certs/ca.crt --tlsAllowInvalidHostnames --tlsCertificateKeyFile /opt/certs/client.pem --eval "help" >/dev/null 2>&1
done

echo "=> Creating an ${MONGO_ADMIN} user with a ${_word} password in MongoDB"
mongo admin --tls --tlsCAFile /opt/certs/ca.crt --tlsAllowInvalidHostnames --tlsCertificateKeyFile /opt/certs/client.pem --eval "db.createUser({user: '$MONGO_ADMIN', pwd: '$MONGO_A_PWD', roles:[{role:'root',db:'$MONGO_A_DB'}]});"


echo "=> Creating an ${USER} user with a ${PASS} password in MongoDB"
mongo admin --tls --tlsCAFile /opt/certs/ca.crt --tlsAllowInvalidHostnames --tlsCertificateKeyFile /opt/certs/client.pem -u $MONGO_ADMIN -p ${MONGO_A_PWD} --eval "db.createUser({user: '$USER', pwd: '$PASS', roles: [{ role: 'userAdminAnyDatabase', db: '$MONGO_A_DB' }, 'readWriteAnyDatabase']})"

echo "=> Done!"
touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo $DATABASE -u $USER -p $PASS --host <host> --port <port> --tls --tlsCAFile <ca.crt> --tlsAllowInvalidHostnames --tlsCertificateKeyFile <client.pem>"
echo ""
echo "========================================================================"
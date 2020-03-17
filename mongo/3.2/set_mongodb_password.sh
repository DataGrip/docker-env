#!/bin/bash

MONGO_ADMIN=${MONGO_ADMIN:-"admin"}
MONGO_A_DB=${MONGO_A_DB:-"admin"}
MONGO_A_PWD=${MONGO_A_PWD:-$(pwgen -s 12 1)}
_word=$( [ ${MONGO_A_PWD} ] && echo "preset" || echo "random" )

USER=${MONGODB_USER:-"guest"}
DATABASE=${MONGODB_DATABASE:-"guest"}
PASS=${MONGODB_PASS:-"guest"}

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

echo "=> Creating an ${MONGO_ADMIN} user with a ${_word} password in MongoDB"
mongo admin --eval "db.createUser({user: '$MONGO_ADMIN', pwd: '$MONGO_A_PWD', roles:[{role:'root',db:'$MONGO_A_DB'}]});"


echo "=> Creating an ${USER} user with a ${PASS} password in MongoDB"
mongo admin -u $MONGO_ADMIN -p ${MONGO_A_PWD} << EOF
db.createUser({user: '$USER', pwd: '$PASS', roles: [{ role: 'userAdminAnyDatabase', db: '$MONGO_A_DB' }, 'readWriteAnyDatabase']})
use $DATABASE
EOF

echo "=> Done!"
touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo $DATABASE -u $USER -p $PASS --host <host> --port <port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"

#!/bin/bash
set -e

if [ -z "$DB2INST1_PASSWORD" ]; then
  echo ""
  echo >&2 'error: DB2INST1_PASSWORD not set'  
  exit 1
else
  echo -e "$DB2INST1_PASSWORD\n$DB2INST1_PASSWORD" | passwd db2inst1
fi

if [ -z "$LICENSE" ];then
   echo ""
   echo >&2 'error: LICENSE not set'
   echo >&2 "Did you forget to add '-e LICENSE=accept' ?"
   exit 1
fi

if [ "${LICENSE}" != "accept" ];then
   echo ""
   echo >&2 "error: LICENSE not set to 'accept'"   
   exit 1
fi

if [[ $1 = "db2start" ]]; then
  su - db2inst1 -c "db2start && db2 -td@ -f /init.sql"
  nohup /usr/sbin/sshd -D 2>&1 > /dev/null &
  while true; do sleep 1000; done
else
  exec "$1"
fi
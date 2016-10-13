#!/bin/bash

if [ "$SERVER_KEY" ]; then
  echo $SERVER_KEY | sed "s/\\$/\n/g" | sed "s/^ //g" >/etc/mysql/server.key
  echo $SERVER_CERT | sed "s/\\$/\n/g" | sed "s/^ //g" >/etc/mysql/server.crt
  echo $CA_CERT | sed "s/\\$/\n/g" | sed "s/^ //g" >/etc/mysql/CA.crt
  export MYSQLD_SSL_KEY=/etc/mysql/server.key
  export MYSQLD_SSL_CERT=/etc/mysql/server.crt
  export MYSQLD_SSL_CA=/etc/mysql/CA.crt
fi

echo -e "[mysqld]\n" >/etc/mysql/conf.d/custom.cnf

for var in $(env | grep MYSQLD_ | sed 's/MYSQLD_//'); do
  echo $var | tr '[:upper:]' '[:lower:]' >>/etc/mysql/conf.d/custom.cnf
done


exec /docker-entrypoint.sh $*

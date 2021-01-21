#!/bin/bash
set -e
cd /
./startup --init

cat <<-EOSQL > /home/memsql/schema.sql
create database guest;
grant all on *.* to 'guest'@'%' identified by 'guest' with grant option;
EOSQL

echo "Loading schema from /schema.sql"
cat /home/memsql/schema.sql
memsql < /home/memsql/schema.sql

#trap
tail -F $(find /var/lib -name "*memsql.log" | head -n 1)

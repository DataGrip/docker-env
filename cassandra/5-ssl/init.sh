#!/bin/bash
set -e

echo "=============== WAITING FOR CASSANDRA =========================="

i=0
while [[ $i -lt 90 ]]; do
  if cqlsh -u cassandra -p cassandra -e "describe cluster" &>/dev/null; then
    echo "Cassandra is ready"
    break
  fi
  sleep 2
  i=$((i+1))
done

if [[ $i -eq 90 ]]; then
  echo "Timeout waiting for Cassandra"
  exit 1
fi

echo "=============== CASSANDRA STARTED =========================="

KEY_SPACE="${KEY_SPACE:-guest}"
echo "KEY_SPACE: $KEY_SPACE"

cqlsh -u cassandra -p cassandra -e "CREATE KEYSPACE IF NOT EXISTS $KEY_SPACE WITH replication = {'class':'SimpleStrategy', 'replication_factor': 1};
CREATE ROLE IF NOT EXISTS limited_access_role WITH LOGIN = true AND PASSWORD = 'limited_access_role';"

echo "=============== KEY_SPACE CREATED =========================="
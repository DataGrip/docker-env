#!/usr/bin/env bash

set -euo pipefail

HOST="localhost"
PORT="8181"
DB_NAME="testdb"

echo "Wait for InfluxDB starts on $HOST:$PORT..."
for i in {1..30}; do
  if curl -s "http://$HOST:$PORT/health" | grep -q '"status":"pass"'; then
    echo "InfluxDB started."
    break
  fi
  sleep 1
done
#
## Get token
#echo "Getting admin token"
#TOKEN=$(curl -s -X POST "http://$HOST:$PORT/api/v3/configure/token/admin" \
#  -H "Accept: application/json" \
#  -H "Content-Type: application/json" | jq -r '.token')
#
#if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
#  echo "Operation failed. Token name already exists."
#  exit 1
#fi
#
#echo "Your token: $TOKEN"
#echo "$TOKEN" > /home/influxdb3/.token

# Checking the database
#DB_LIST=$(influxdb3 show databases --host http://"$HOST":"$PORT" --token "$TOKEN" | tail -n +2)
DB_LIST=$(influxdb3 show databases --host http://"$HOST":"$PORT" | tail -n +2)

if echo "$DB_LIST" | grep -q "^| $DB_NAME *|$"; then
  echo "The database '$DB_NAME' already exists."
else
  echo "Creating database..."
#  influxdb3 create database --token "$TOKEN" "$DB_NAME"
  influxdb3 create database "$DB_NAME"
  echo "Your database '$DB_NAME' is created."
fi

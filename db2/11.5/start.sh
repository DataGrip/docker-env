#!/bin/bash
set -e

su - db2inst1 -c "DBNAME=${DBNAME} /var/scripts/createschema.sh"
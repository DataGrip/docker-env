#!/bin/bash

set -e

. ~db2inst1/sqllib/db2profile

db2 connect to ${DBNAME}

#echo Enabling explain plan feature
#db2 -tvf /var/scripts/init.sql

echo Creating buffer pool and table space
db2 -tvf /var/scripts/initspatial.sql

echo Enabling spatial operations feature
db2se enable_db ${DBNAME}

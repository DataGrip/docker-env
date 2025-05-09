#!/usr/bin/env bash
set -ex pipefail

echo "Waiting for HiveServer2..."

while true; do
  count=$(grep -cF "Hive Session ID =" "/tmp/hive/hive.log" 2>/dev/null || echo 0)
  if [ "$count" -ge 2 ]; then
    break
  fi
  sleep 5
done

echo "HiveServer2 is ready to connect!"

if [ ! -z $HIVE_TEST_DB ]; then
    echo "HIVE_TEST_DB: $HIVE_TEST_DB"
else
	HIVE_TEST_DB=testdb
    echo "HIVE_TEST_DB: $HIVE_TEST_DB"
fi

cat << EOF
+--------------------------------------------------+
|               CREATE DATABASE $HIVE_TEST_DB;            |
+--------------------------------------------------+
EOF

/opt/hive/bin/beeline -n hive -u jdbc:hive2://localhost:10000/ -e "
SET ROLE ADMIN;
CREATE DATABASE IF NOT EXISTS $HIVE_TEST_DB;
USE $HIVE_TEST_DB;"

echo "$HIVE_TEST_DB is created!"

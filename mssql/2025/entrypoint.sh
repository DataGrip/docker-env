#!/bin/bash
set -e
# Start server
/opt/mssql/bin/sqlservr &

export MSSQL_PID=$!
export SQLCMD_PATH=/opt/mssql-tools18/bin/sqlcmd
export MSSQL_SA_PASSWORD=My@Super@Secret

# Wait until server starts
echo "Waiting for SQL Server to start..."

until $SQLCMD_PATH -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -No -Q "SELECT 1;" &> /dev/null

do
  echo "SQL Server is starting up... "
  sleep 5
done
echo "SQL Server started successfully"

# Running SQL-scripts
echo =============== SETTING ENVIRONMENT ==========================

if [ ! -z $MSSQL_USER ]; then
	echo "MSSQL_USER: $MSSQL_USER"
else
	MSSQL_USER=tester
	echo "MSSQL_USER: $MSSQL_USER"
fi

if [ ! -z $MSSQL_PASSWORD ]; then
	echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
else
	MSSQL_PASSWORD=My@Super@Secret
	echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
fi

if [ ! -z $MSSQL_DB ]; then
	echo "MSSQL_DB: $MSSQL_DB"
else
	MSSQL_DB=testdb
	echo "MSSQL_DB: $MSSQL_DB"
fi

echo =============== CREATING INIT DATA ==========================

cd /opt/mssql/

cat <<-EOSQL > init.sql
CREATE DATABASE $MSSQL_DB;
GO

USE $MSSQL_DB;
GO

CREATE LOGIN $MSSQL_USER WITH PASSWORD = '$MSSQL_PASSWORD';
GO

CREATE USER $MSSQL_USER FOR LOGIN $MSSQL_USER;
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [$MSSQL_USER];
GO

EOSQL

cat <<-EOSQL > init_memory.sql
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'min server memory', 2048;
GO
RECONFIGURE;
GO
sp_configure 'max server memory', 4096;
GO
RECONFIGURE;
GO
EOSQL

cd /opt/mssql-tools18/bin/
./sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -i "/opt/mssql/init.sql" -No -o "/opt/mssql/initout.log"
./sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -i "/opt/mssql/init_memory.sql" -No -o "/opt/mssql/initout2.log"

echo =============== INIT DATA CREATED ==========================

echo =============== CHECKING TEST ENVIRONMENT =====================

echo "Checking test user..."
    if $SQLCMD_PATH -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -Q "SELECT name FROM sys.server_principals;" | grep -i $MSSQL_USER > /dev/null; then
        echo "✓ User $MSSQL_USER exists"
    else
        echo "✗ User $MSSQL_USER does not exist"
    fi

echo "Checking test database..."
    if $SQLCMD_PATH -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -Q "SELECT name FROM sys.databases;" | grep -i $MSSQL_DB > /dev/null; then
        echo "✓ User $MSSQL_DB exists"
    else
        echo "✗ User $MSSQL_DB does not exist"
    fi

echo =============== TEST ENVIRONMENT IS CHECKED ==========================


# Waiting for the main process
wait $MSSQL_PID

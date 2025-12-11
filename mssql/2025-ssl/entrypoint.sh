#!/bin/bash
set -e

chown mssql:mssql /etc/ssl/certs/mssql.pem /etc/ssl/private/mssql.key
chmod 644 /etc/ssl/certs/mssql.pem
chmod 600 /etc/ssl/private/mssql.key


/opt/mssql/bin/mssql-conf set network.tlscert /etc/ssl/certs/mssql.pem
/opt/mssql/bin/mssql-conf set network.tlskey /etc/ssl/private/mssql.key
/opt/mssql/bin/mssql-conf set network.tlsprotocols 1.2
/opt/mssql/bin/mssql-conf set network.forceencryption 1

echo "Starting MS SQL Server"

# Start server
/opt/mssql/bin/sqlservr &

export MSSQL_PID=$!
export SSL_CERT_FILE=/usr/local/share/ca-certificates/mssql-ca.crt

cd /opt/mssql-tools18/bin
# Wait until server starts
echo "Waiting for SQL Server to start..."
until ./sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -N -Q "SELECT 1;" &> /dev/null

do
  echo "SQL Server is starting up... "
  sleep 5
done
echo "SQL Server started successfully"

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
    if ./sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -Q "SELECT name FROM sys.server_principals;" | grep -i $MSSQL_USER > /dev/null; then
        echo "✓ User $MSSQL_USER exists"
    else
        echo "✗ User $MSSQL_USER does not exist"
    fi

echo "Checking test database..."
    if ./sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -Q "SELECT name FROM sys.databases;" | grep -i $MSSQL_DB > /dev/null; then
        echo "✓ User $MSSQL_DB exists"
    else
        echo "✗ User $MSSQL_DB does not exist"
    fi

echo =============== TEST ENVIRONMENT IS CHECKED ==========================


# Waiting for the main process
wait $MSSQL_PID

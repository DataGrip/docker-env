#!/bin/bash

set -e

MSSQL_USER=${MSSQL_USER:-tester}
MSSQL_PASSWORD=${MSSQL_PASSWORD:-My@Super@Secret}
MSSQL_DB=${MSSQL_DB:-testdb}
export SQLCMDPASSWORD="${MSSQL_SA_PASSWORD:-${SA_PASSWORD:-}}"

if [[ -z $SQLCMDPASSWORD ]]; then
	echo "MSSQL_SA_PASSWORD or SA_PASSWORD must be set" >&2
	exit 1
fi

echo =============== WAITING FOR MSSQL ==========================
# SQL Server can accept connections before database recovery is complete.
readiness_sql="SELECT TOP (0) name FROM model.sys.objects;
SELECT TOP (0) name FROM msdb.sys.objects;
IF DB_ID(N'$MSSQL_DB') IS NOT NULL EXEC(N'USE [$MSSQL_DB];');"
STATUS=0
deadline=$((SECONDS + 90))
while (( SECONDS < deadline )); do
	if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -l 1 -t 1 -Q "$readiness_sql" >/dev/null 2>&1; then
		STATUS=1
		break
	fi
	sleep 1
done

if [[ $STATUS -eq 0 ]]; then
	echo "SQL Server did not start within 90 seconds" >&2
	exit 1
fi

echo =============== MSSQL STARTED ==========================

echo "MSSQL_USER: $MSSQL_USER"
echo "MSSQL_DB: $MSSQL_DB"

echo =============== CREATING INIT DATA ==========================

cd /opt/mssql/

cat <<-EOSQL > init.sql
IF DB_ID(N'$MSSQL_DB') IS NULL
	CREATE DATABASE [$MSSQL_DB];
GO

USE [$MSSQL_DB];
GO

IF SUSER_ID(N'$MSSQL_USER') IS NULL
	CREATE LOGIN [$MSSQL_USER] WITH PASSWORD = '$MSSQL_PASSWORD';
GO

IF DATABASE_PRINCIPAL_ID(N'$MSSQL_USER') IS NULL
	CREATE USER [$MSSQL_USER] FOR LOGIN [$MSSQL_USER];
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [$MSSQL_USER];
GO

EOSQL

cat <<-EOSQL > init_memory.sql
-- SQL Server Agent can disable advanced options during startup. Retry only this race.
DECLARE @attempt int = 0;
WHILE 1 = 1
BEGIN
	BEGIN TRY
		EXEC sys.sp_configure N'show advanced options', 1;
		RECONFIGURE;
		EXEC sys.sp_configure N'min server memory (MB)', 2048;
		EXEC sys.sp_configure N'max server memory (MB)', 4096;
		RECONFIGURE;
		BREAK;
	END TRY
	BEGIN CATCH
		SET @attempt += 1;
		IF ERROR_NUMBER() <> 15123 OR @attempt >= 10
			THROW;
		PRINT N'Advanced options changed during initialization; retrying memory configuration.';
		WAITFOR DELAY '00:00:01';
	END CATCH
END;
GO
EOSQL

cd /opt/mssql-tools18/bin/
run_sql() {
	if ! ./sqlcmd -S localhost -U sa -C -b -t 30 -i "$1" -o "$2"; then
		cat "$2" >&2
		exit 1
	fi
}
run_sql /opt/mssql/init.sql /opt/mssql/initout.log
run_sql /opt/mssql/init_memory.sql /opt/mssql/initout2.log

echo =============== INIT DATA CREATED ==========================
echo =============== MSSQL SERVER SUCCESSFULLY STARTED ==========================

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "END=1" INT TERM
done

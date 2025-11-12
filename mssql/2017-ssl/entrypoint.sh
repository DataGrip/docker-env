#!/bin/bash

echo "(*) Killing MS SQL Server to init SSL certificates"
pkill -9 -f "./sqlservr"
ps aux

echo "(*) Applying SSL certificates"

/opt/mssql/bin/mssql-conf validate

chown mssql:mssql /etc/ssl/certs/mssql.pem /etc/ssl/private/mssql.key
chmod 600 /etc/ssl/certs/mssql.pem /etc/ssl/private/mssql.key

/opt/mssql/bin/mssql-conf set network.tlscert /etc/ssl/certs/mssql.pem
/opt/mssql/bin/mssql-conf set network.tlskey /etc/ssl/private/mssql.key
/opt/mssql/bin/mssql-conf set network.tlsprotocols 1.2
/opt/mssql/bin/mssql-conf set network.forceencryption 1

cat /var/opt/mssql/mssql.conf


echo "(*) Starting MS SQL Server"

cd /opt/mssql/bin/
./sqlservr &

ps aux

export STATUS=0
i=0
while [[ $STATUS -eq 0 ]] || [[ $i -lt 90 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep 'SQL Server is now ready for client connections' /var/opt/mssql/log/errorlog | wc -l)
done

echo "(*) MS SQL Server has started"

cd /opt/mssql/

echo "(*) MS SQL Server initialization"

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

cd /opt/mssql-tools/bin/
./sqlcmd -S localhost -U sa -P $SA_PASSWORD -t 30 -i"/opt/mssql/init.sql" -o"/opt/mssql/initout.log"


echo "(*) MS SQL Server successfully initialized and started "

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "END=1" INT TERM
done

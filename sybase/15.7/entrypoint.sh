#!/bin/bash
export SYBASE=/opt/sybase

sh /opt/sybase/SYBASE.sh && sh /opt/sybase/ASE-15_0/install/RUN_DKSYBASE > /dev/null &

#waiting for sybase to start
export STATUS=0
i=0
echo "STARTING... (about 30 sec)"
while [[ $STATUS -eq 0 ]] || [[ $i -lt 30 ]]; do
	sleep 1
	i=$i+1
	STATUS=$(/etc/init.d/sybase status | grep DKSYBASE | wc -c)
done

echo =============== SYBASE STARTED ==========================
cd /sybase

if [ ! -z $SYBASE_USER ]; then
	echo "SYBASE_USER: $SYBASE_USER"	
else
	SYBASE_USER=guest
	echo "SYBASE_USER: $SYBASE_USER"
fi

if [ ! -z $SYBASE_PASSWORD ]; then
	echo "SYBASE_PASSWORD: $SYBASE_PASSWORD"	
else
	SYBASE_PASSWORD=guest1234
	echo "SYBASE_PASSWORD: $SYBASE_PASSWORD"
fi

if [ ! -z $SYBASE_DB ]; then
	echo "SYBASE_DB: $SYBASE_DB"	
else
	SYBASE_DB=guest
	echo "SYBASE_DB: $SYBASE_DB"
fi

echo =============== CREATING LOGIN/PWD ==========================
cat <<-EOSQL > init1.sql
use master
go
create database $SYBASE_DB
go
create login $SYBASE_USER with password $SYBASE_PASSWORD
go
exec sp_dboption $SYBASE_DB, 'abort tran on log full', true
go
exec sp_dboption $SYBASE_DB, 'allow nulls by default', true
go
exec sp_dboption $SYBASE_DB, 'ddl in tran', true
go
exec sp_dboption $SYBASE_DB, 'trunc log on chkpt', true
go

EOSQL

/opt/sybase/OCS-15_0/bin/isql -Usa -Ppassword -SDKSYBASE -i"./init1.sql"

echo =============== CREATING DB ==========================
cat <<-EOSQL > init2.sql
use $SYBASE_DB
go

sp_adduser '$SYBASE_USER', '$SYBASE_USER', null
go

grant create default to $SYBASE_USER
go
grant create table to $SYBASE_USER
go
grant create view to $SYBASE_USER
go
grant create rule to $SYBASE_USER
go
grant create function to $SYBASE_USER
go
grant create procedure to $SYBASE_USER
go
commit
go

EOSQL

/opt/sybase/OCS-15_0/bin/isql -Usa -Ppassword -SDKSYBASE -i"./init2.sql"

echo =============== CREATING SCHEMA ==========================
cat <<-EOSQL > init3.sql
use $SYBASE_DB
go

create schema authorization $SYBASE_USER
go

EOSQL
/opt/sybase/OCS-15_0/bin/isql -Usa -Ppassword -SDKSYBASE -i"./init3.sql"

#trap 
while [ "$END" == '' ]; do
			sleep 1
			trap "/etc/init.d/oracle-xe stop && END=1" INT TERM
done


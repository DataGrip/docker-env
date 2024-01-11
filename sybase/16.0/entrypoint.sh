#!/bin/bash
export SYBASE=/opt/sybase
source /opt/sybase/SYBASE.sh

sh /opt/sybase/SYBASE.sh && sh /opt/sybase/ASE-16_0/install/RUN_MYSYBASE > /dev/null &

#waiting for sybase to start
export STATUS=0
i=1
echo ===============  WAITING FOR master.dat SPACE ALLOCATION ==========================
while (( $i < 60 )); do
	sleep 1
	i=$((i+1))
	STATUS=$(grep "Performing space allocation for device '/opt/sybase/data/master.dat'" /opt/sybase/ASE-16_0/install/MYSYBASE.log | wc -c)
	if (( $STATUS > 300 )); then
	  break
	fi
done

echo ===============  WAITING FOR INITIALIZATION ==========================
export STATUS2=0
j=1
while (( $j < 30 )); do
  sleep 1
  j=$((j+1))
  STATUS2=$(grep "Finished initialization." /opt/sybase/ASE-16_0/install/MYSYBASE.log | wc -c)
  if (( $STATUS2 > 350 )); then
    break
  fi
done

echo =============== SYBASE STARTED ==========================
cd /opt/sybase

if [ ! -z $SYBASE_USER ]; then
	echo "SYBASE_USER: $SYBASE_USER"
else
	SYBASE_USER=tester
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
	SYBASE_DB=testdb
	echo "SYBASE_DB: $SYBASE_DB"
fi

echo =============== CREATING LOGIN/PWD ==========================
cat <<-EOSQL > init1.sql
use master
go
disk resize name='master', size='60m'
go
create database $SYBASE_DB on master = '48m'
go
exec sp_extendsegment logsegment, $SYBASE_DB, master
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
exec sp_dboption $SYBASE_DB, 'full logging for select into', true
go
exec sp_dboption $SYBASE_DB, 'full logging for alter table', true
go
sp_dboption $SYBASE_DB, "select into", true
go

EOSQL

/opt/sybase/OCS-16_0/bin/isql -Usa -PmyPassword -SMYSYBASE -i"./init1.sql"

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

/opt/sybase/OCS-16_0/bin/isql -Usa -PmyPassword -SMYSYBASE -i"./init2.sql"

#echo =============== CREATING SCHEMA ==========================
#cat <<-EOSQL > init3.sql
#use $SYBASE_DB
#go
#create schema authorization $SYBASE_USER
#go
#
#EOSQL
#/opt/sybase/OCS-16_0/bin/isql -Usa -PmyPassword -SMYSYBASE -i"./init3.sql"

echo =============== SYBASE INITIALIZED ==========================

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "/etc/init.d/sybase stop && END=1" INT TERM
done

#!/bin/bash

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product
# Update hostname
sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
sed -i -E "s/PORT = [^)]+/PORT = 1521/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
echo "export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe" > /etc/profile.d/oracle-xe.sh
echo "export PATH=\$ORACLE_HOME/bin:\$PATH" >> /etc/profile.d/oracle-xe.sh
echo "export ORACLE_SID=XE" >> /etc/profile.d/oracle-xe.sh
. /etc/profile

case "$1" in
	'')
		#Check for mounted database files
		if [ "$(ls -A /u01/app/oracle/oradata)" ]; then
			echo "found files in /u01/app/oracle/oradata Using them instead of initial database"
			echo "XE:$ORACLE_HOME:N" >> /etc/oratab
			chown oracle:dba /etc/oratab
			chown 664 /etc/oratab
			printf "ORACLE_DBENABLED=false\nLISTENER_PORT=1521\nHTTP_PORT=8080\nCONFIGURE_RUN=true\n" > /etc/default/oracle-xe
			rm -rf /u01/app/oracle-product/11.2.0/xe/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/11.2.0/xe/dbs
		else
			echo "Database not initialized. Initializing database."

			printf "Setting up:\nprocesses=$processes\nsessions=$sessions\ntransactions=$transactions\n"
			echo "If you want to use different parameters set processes, sessions, transactions env variables and consider this formula:"
			printf "processes=x\nsessions=x*1.1+5\ntransactions=sessions*1.1\n"

			mv /u01/app/oracle-product/11.2.0/xe/dbs /u01/app/oracle/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/11.2.0/xe/dbs

			#Setting up processes, sessions, transactions.
			sed -i -E "s/processes=[^)]+/processes=$processes/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
			sed -i -E "s/processes=[^)]+/processes=$processes/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora

			sed -i -E "s/sessions=[^)]+/sessions=$sessions/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
			sed -i -E "s/sessions=[^)]+/sessions=$sessions/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora

			sed -i -E "s/transactions=[^)]+/transactions=$transactions/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
			sed -i -E "s/transactions=[^)]+/transactions=$transactions/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora

			printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

			echo "Database initialized. Please visit http://#containeer:8080/apex to proceed with configuration"
		fi

		/etc/init.d/oracle-xe start

		cat <<-EOSQL > disable_direct_io.sql
		ALTER SYSTEM SET FILESYSTEMIO_OPTIONS=DIRECTIO SCOPE=SPFILE
		/
		ALTER SYSTEM SET DISK_ASYNCH_IO=FALSE SCOPE=SPFILE
		/
		EOSQL

		sqlplus system/oracle@localhost @./disable_direct_io.sql
		# rm ./disable_direct_io.sql

		/etc/init.d/oracle-xe restart

		cat <<-EOSQL > sys_init.sql
		---- DEVELOPMENT ROLE ----
		create role Development
		/

		grant create cluster,
			create sequence,
			create type,
			create table,
			create view,
			create materialized view,
			create trigger,
			create procedure,
			create operator,
			create indextype,
			create dimension,
			create library,
			create synonym
		to Development
		/

		---- REMOVE STUPID "SECURITY" ----
		alter profile default limit password_life_time unlimited
		/

		alter profile default
			limit failed_login_attempts unlimited
			password_life_time unlimited
		/

		alter system set sec_case_sensitive_logon = false  -- starts from Oracle 10
		/
		EOSQL

		sqlplus system/oracle@localhost @./sys_init.sql
		rm ./sys_init.sql

		cat <<-EOSQL > default_users.sql
		create user Test_User identified by test
							default tablespace users
							temporary tablespace temp
							quota unlimited on users
		/

		grant connect, development
			to Test_User with admin option
		/

		grant debug connect session
		    to Test_User
		/

		create user Test_Admin identified by test
							default tablespace users
							temporary tablespace temp
							quota unlimited on users
		/

		grant connect, development
			to Test_Admin with admin option
		/

		grant select any dictionary, debug connect session, debug any procedure
			to Test_Admin
		/

		grant create user, create profile, create tablespace, alter tablespace, drop user, drop profile, drop tablespace
    		to Test_Admin
		/

		grant select_catalog_role
			to Test_Admin
		/

		grant execute on sys.dbms_Lock to Test_User
		/

    grant execute on sys.dbms_Lock to Test_Admin
    /

		EOSQL

#		sqlplus system/oracle@localhost @./default_users.sql
		sqlplus sys/oracle@localhost as sysdba @./default_users.sql

		rm ./default_users.sql

		if [ ! -z $ORACLE_USER ] && [ ! -z $ORACLE_PASSWORD ] ; then
		        echo "ORACLE_USER: $ORACLE_USER"
		        echo "ORACLE_PASSWORD: $ORACLE_PASSWORD"
		        cat <<-EOSQL > create_user.sql
				DECLARE
				  user_exists INTEGER := 0;
				BEGIN
				  SELECT COUNT(1) INTO user_exists FROM dba_users WHERE username = UPPER('$ORACLE_USER');
				  IF user_exists = 0
				  THEN
				    EXECUTE IMMEDIATE ('CREATE USER $ORACLE_USER IDENTIFIED BY $ORACLE_PASSWORD');
				    EXECUTE IMMEDIATE ('GRANT ALL PRIVILEGES TO $ORACLE_USER');
				    EXECUTE IMMEDIATE ('GRANT SELECT ANY DICTIONARY TO $ORACLE_USER');
				    EXECUTE IMMEDIATE ('ALTER SYSTEM FLUSH SHARED_POOL');
				  END IF;
				END;
				/
			EOSQL
		        sqlplus system/oracle@localhost @./create_user.sql
		        rm ./create_user.sql
		fi

		echo "(*) Installing utPLSQL"

		UTPLSQL_DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip\"" | sed 's/"//g')
		curl -Lk "${UTPLSQL_DOWNLOAD_URL}" -o utPLSQL.zip
		unzip -q utPLSQL.zip
		# sqlplus system/oracle@localhost @/utPLSQL/source/install_headless.sql
		# sqlplus sys/oracle@127.0.0.1:1521/xe as sysdba @/utPLSQL/source/install_headless.sql
		cd /utPLSQL/source
		sqlplus sys/oracle@localhost as sysdba @./install_headless.sql

		echo "(*) Database ready to use"
		echo "(*) Database ready to use" >> /home/finished.log

		##
		## Workaround for graceful shutdown. ....ing oracle... ‿( ́ ̵ _-`)‿
		##
		while [ "$END" == '' ]; do
			sleep 1
			trap "/etc/init.d/oracle-xe stop && END=1" INT TERM
		done
		;;

	*)
		echo "Database is not configured. Please run /etc/init.d/oracle-xe configure if needed."
		$1
		;;
esac

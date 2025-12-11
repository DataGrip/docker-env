#!/bin/bash
cp -fp /var/lib/mysql2/ca.pem /var/lib/mysql/ca-cert.pem
cp -fp /var/lib/mysql2/ca.key /var/lib/mysql/ca-key.pem
cp -fp /var/lib/mysql2/server.key /var/lib/mysql/server-key.pem
cp -fp /var/lib/mysql2/server.pem /var/lib/mysql/server-cert.pem

# /etc/mysql/mariadb.conf.d/50-server.cnf
# cat <<-EOSQL > 50-server.cnf
# [mysqld]
# ssl-ca=/var/lib/mysql/ca-cert.pem
# ssl-cert=/var/lib/mysql/server-cert.pem
# ssl-key=/var/lib/mysql/server-key.pem
# EOSQL


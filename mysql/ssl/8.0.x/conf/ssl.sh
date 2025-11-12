#!/bin/bash
rm -f /var/lib/mysql/ca.pem
rm -f /var/lib/mysql/client-cert.pem
rm -f /var/lib/mysql/client-key.pem
rm -f /var/lib/mysql/server-cert.pem
rm -f /var/lib/mysql/server-key.pem

cp -fp /var/lib/mysql2/ca.pem /var/lib/mysql/ca.pem
cp -fp /var/lib/mysql2/server.key /var/lib/mysql/server-key.pem
cp -fp /var/lib/mysql2/server.pem /var/lib/mysql/server-cert.pem
cp -fp /var/lib/mysql2/client.key /var/lib/mysql/client-key.pem
cp -fp /var/lib/mysql2/client.pem /var/lib/mysql/client-cert.pem


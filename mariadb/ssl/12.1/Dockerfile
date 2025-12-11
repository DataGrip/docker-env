FROM mariadb:12.1

COPY ./conf/init.sql /docker-entrypoint-initdb.d/init.sql

COPY ./certs/ca.pem     /etc/mysql/cacert.pem
COPY ./certs/server.key /etc/mysql/server-key.pem
COPY ./certs/server.pem /etc/mysql/server-cert.pem

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

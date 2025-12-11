FROM mariadb:10.3.0

COPY ./conf/init.sql /docker-entrypoint-initdb.d/init.sql
COPY ./cert3/ /var/lib/mysql2/

COPY ./conf/ssl.sh /docker-entrypoint-initdb.d/
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

RUN chown root.root /docker-entrypoint-initdb.d/ssl.sh && \
    chmod +x /docker-entrypoint-initdb.d/ssl.sh && \
    chgrp root /docker-entrypoint-initdb.d/ssl.sh
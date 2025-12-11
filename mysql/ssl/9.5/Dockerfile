FROM mysql:9.5

COPY ./conf/init.sql /docker-entrypoint-initdb.d/init.sql
COPY ./conf/ssl.sh /docker-entrypoint-initdb.d/
COPY ./certs/ /var/lib/mysql2/

RUN chown root.root /docker-entrypoint-initdb.d/ssl.sh && \
    chmod +x /docker-entrypoint-initdb.d/ssl.sh && \
    chgrp root /docker-entrypoint-initdb.d/ssl.sh
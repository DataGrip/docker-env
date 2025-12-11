FROM registry.jetbrains.team/p/datagrip/containers/mssql-server-linux:2025

COPY ./certs/server.pem /etc/ssl/certs/mssql.pem
COPY ./certs/server.key /etc/ssl/private/mssql.key
COPY ./certs/ca.pem /usr/local/share/ca-certificates/mssql-ca.crt
RUN update-ca-certificates

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

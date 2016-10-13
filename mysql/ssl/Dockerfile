FROM mysql:5.7

ENV DIR /etc/mysql
ENV MYSQL_ROOT_PASSWORD=toor
ENV MYSQL_USER=guest
ENV MYSQL_PASSWORD=guest
ENV MYSQL_DATABASE=guest
ENV MYSQL_CHARSET=utf8

COPY ca.pem /etc/mysql/ca.pem
COPY server-cert.pem /etc/mysql/server-cert.pem
COPY server-key.pem /etc/mysql/server-key.pem
COPY server-cert.pem /etc/mysql/client-cert.pem
COPY server-key.pem /etc/mysql/client-key.pem


RUN \
chmod 644 /etc/mysql/ca.pem &&\
chmod 644 /etc/mysql/server-cert.pem &&\
chmod 644 /etc/mysql/server-key.pem &&\
echo "\n[client]\n\
ssl-ca=${DIR}/ca.pem\n\
ssl-cert=${DIR}/client-cert.pem\n\
ssl-key=${DIR}/client-key.pem\n\
[mysqld]\n\
ssl-ca=${DIR}/ca.pem\n\
ssl-cert=${DIR}/server-cert.pem\n\
ssl-key=${DIR}/server-key.pem\n"\ >> ${DIR}/my.cnf &&\
echo "------------\n" &&\
cat /etc/mysql/my.cnf &&\
echo "------------\n"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld --ssl"]


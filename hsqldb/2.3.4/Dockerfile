FROM java:8-alpine

ENV HSQLDB_VERSION 2.3.4 

RUN \
mkdir -p /opt/database && \
mkdir -p /opt/hsqldb && \
apk update && \
apk add bash

ADD entrypoint.sh /entrypoint.sh

RUN \
chmod +x /entrypoint.sh && \
wget -O /opt/hsqldb/hsqldb.jar http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar && \
wget -O /opt/hsqldb/sqltool.jar http://central.maven.org/maven2/org/hsqldb/sqltool/${HSQLDB_VERSION}/sqltool-${HSQLDB_VERSION}.jar 

EXPOSE 9001 

ENTRYPOINT ["/entrypoint.sh"]

CMD ["hsqldb"]

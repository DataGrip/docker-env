FROM blacklabelops/java:openjre8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Image Environment Variables
ENV HSQLDB_VERSION=2.0.0 \
    JAVA_VM_PARAMETERS= \
    HSQLDB_TRACE= \
    HSQLDB_SILENT= \
    HSQLDB_REMOTE= \
    HSQLDB_DATABASE_NAME=guest \
    HSQLDB_DATABASE_ALIAS=guest \
    HSQLDB_DATABASE_HOST= \
    HSQLDB_USER=guest \
    HSQLDB_PASSWORD=guest

RUN export CONTAINER_USER=hsql && \
    export CONTAINER_UID=1000 && \
    export CONTAINER_GROUP=hsql && \
    export CONTAINER_GID=1000 && \
    # Add user
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP && \
    adduser -u $CONTAINER_UID -G $CONTAINER_GROUP -h /home/$CONTAINER_USER -s /bin/bash -S $CONTAINER_USER && \
    # Install tooling
    apk add --update \
      ca-certificates \
      wget && \
    # Install HSDLDB
    mkdir -p /opt/database && \
    mkdir -p /opt/hsqldb && \
    mkdir -p /scripts && \
    wget -O /opt/hsqldb/hsqldb.jar http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar && \
    wget -O /opt/hsqldb/sqltool.jar http://central.maven.org/maven2/org/hsqldb/sqltool/${HSQLDB_VERSION}/sqltool-${HSQLDB_VERSION}.jar && \
    chown -R $CONTAINER_UID:$CONTAINER_GID /opt/hsqldb /opt/database /scripts && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      wget && \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

VOLUME ["/opt/database","/scripts"]
EXPOSE 9001

USER hsql
WORKDIR /scripts
#COPY imagescripts/docker-entrypoint.sh /opt/hsqldb/docker-entrypoint.sh
#ENTRYPOINT ["/opt/hsqldb/docker-entrypoint.sh"]
CMD java -cp /opt/hsqldb/hsqldb.jar org.hsqldb.Server -database.0 "file:/opt/database/guest;user=guest;password=guest" -dbname.0 guest -trace true -silent false -remote_open true

#CMD ["hsqldb"]

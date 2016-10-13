FROM blacklabelops/java:openjre7

ENV DERBY_VERSION=10.11.1.1 
ENV	DERBY_INSTALL=/db-derby-$DERBY_VERSION-bin 
ENV	DERBY_HOME=/db-derby-$DERBY_VERSION-bin 
ENV	CLASSPATH=$DERBY_INSTALL/lib/derbynet.jar:$DERBY_INSTALL/lib/derbytools.jar:.
ENV PORT_TO_EXPOSE=1527
	
RUN \
	apk update &&\
	apk add --update wget &&\
	wget http://apache.mirror.iphh.net//db/derby/db-derby-${DERBY_VERSION}/db-derby-${DERBY_VERSION}-bin.tar.gz &&\
	tar xzf db-derby-${DERBY_VERSION}-bin.tar.gz &&\
	rm -Rf /db-derby-${DERBY_VERSION}-bin.tar.gz &&\
	mkdir -p /dbs &&\
	mkdir -p /dbbackup &&\
	mkdir -p /upload &&\
	rm -Rf /var/cache/apk/* && \
    rm -Rf /tmp/* && \
	rm -Rf /var/log/*
	
COPY init.sql /upload/
	
VOLUME ["/dbs", "/upload"]
EXPOSE ${PORT_TO_EXPOSE}

RUN java org.apache.derby.tools.ij /upload/init.sql

CMD ${DERBY_INSTALL}/bin/startNetworkServer -p ${PORT_TO_EXPOSE} -h 0.0.0.0
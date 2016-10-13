FROM blacklabelops/java:openjre7

ENV DOWNLOAD_LINK=http://www.h2database.com/h2-2014-04-05.zip
ENV DATA_DIR=/opt/h2-data
ENV EXPOSE_PORT=9092

RUN \
	apk update &&\
	apk add --update curl \
		unzip &&\
	curl ${DOWNLOAD_LINK} -o h2.zip &&\
	unzip h2.zip -d /opt/ &&\
	mkdir -p ${DATA_DIR} &&\
	rm -Rf /var/cache/apk/* &&\
	rm h2.zip &&\
	rm -Rf /tmp/* &&\
	rm -Rf /var/log/*


#COPY sakila.h2.db ${DATA_DIR}/sakila.h2.db

VOLUME ["${DATA_DIR}"]

EXPOSE ${EXPOSE_PORT}

CMD java -cp "/opt/h2/bin/*" org.h2.tools.Server \
	-tcp -tcpAllowOthers -tcpPort ${EXPOSE_PORT} \
	-baseDir '${DATA_DIR}'

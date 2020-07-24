FROM exasol/docker-db:latest-6.2

ADD "virtualschema-jdbc-adapter-dist-0.0.1-SNAPSHOT.jar" /
ADD entrypoint.sh /
ADD init.sh /

RUN ["/bin/bash", "-c", "chmod +x /virtualschema-jdbc-adapter-dist-0.0.1-SNAPSHOT.jar &&\
chmod +x entrypoint.sh &&\
chmod +x init.sh"]

EXPOSE 8888 6583 2580

ENTRYPOINT ["/entrypoint.sh"]
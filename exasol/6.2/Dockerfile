FROM exasol/docker-db:latest-6.2

ADD "virtual-schema-dist-5.0.2-exasol-3.0.2.jar" /

ADD entrypoint.sh /
ADD init.sh /

RUN ["/bin/bash", "-c", "chmod +x /virtual-schema-dist-5.0.2-exasol-3.0.2.jar &&\
chmod +x entrypoint.sh &&\
chmod +x init.sh"]

EXPOSE 8888 6583 2580

ENTRYPOINT ["/entrypoint.sh"]
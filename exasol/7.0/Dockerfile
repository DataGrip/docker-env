FROM exasol/docker-db:latest-7.0

ADD "virtual-schema-dist-9.0.2-exasol-5.0.1.jar" /

ADD entrypoint.sh /
ADD init.sh /

RUN ["/bin/bash", "-c", "chmod +x /virtual-schema-dist-9.0.2-exasol-5.0.1.jar &&\
chmod +x entrypoint.sh &&\
chmod +x init.sh"]

EXPOSE 8888 6583 2580 8563

ENTRYPOINT ["/entrypoint.sh"]
FROM exasol/docker-db:8.32.0

COPY "virtual-schema-dist-12.0.0-exasol-8.0.0.jar" /

COPY entrypoint.sh /
COPY init.sh /

RUN ["/bin/bash", "-c", "chmod +x /virtual-schema-dist-12.0.0-exasol-8.0.0.jar &&\
chmod +x entrypoint.sh &&\
chmod +x init.sh"]

EXPOSE 8888 6583 2581 8563

ENTRYPOINT ["/entrypoint.sh"]

FROM cjonesy/docker-vertica:8.1.1-0

COPY ./docker-entrypoint.sh /opt/vertica/bin/

RUN chmod +x /opt/vertica/bin/docker-entrypoint.sh

ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]
EXPOSE 5433
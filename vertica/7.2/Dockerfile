FROM jbfavre/vertica:7.2

ADD ./docker-entrypoint.sh /opt/vertica/bin/

RUN chmod +x /opt/vertica/bin/docker-entrypoint.sh

ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]

EXPOSE 5433
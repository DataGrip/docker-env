FROM yandex/clickhouse-server:18

COPY ./data/os.tsv /opt/dictionaries/os.tsv
COPY ./config/test_dictionary.xml /opt/dictionaries/test_dictionary.xml

ENV CLICKHOUSE_CONFIG /etc/clickhouse-server/config.xml
ENV CLICKHOUSE_CONFD /etc/clickhouse-server/config.d/docker_related_config.xml
ENV CLICKHOUSE_USER_CONFIG /etc/clickhouse-server/users.xml

RUN sed -ri 's/<dictionaries_config>\*_dictionary\.xml<\/dictionaries_config>/<dictionaries_config>\/opt\/dictionaries\/test_dictionary.xml<\/dictionaries_config>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<ip>\:\:1<\/ip>/<ip>\:\:\/0<\/ip>/' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<ip>127\.0\.0\.1<\/ip>/\ /' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<\/listen_try>/<\/listen_try>\n\t<keep_alive_timeout>240<\/keep_alive_timeout>/' ${CLICKHOUSE_CONFD}

ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
FROM clickhouse/clickhouse-server:22.8
COPY ./data/os.tsv /opt/dictionaries/os.tsv
COPY ./config/test_dictionary.xml /opt/dictionaries/test_dictionary.xml
COPY --chown=clickhouse:clickhouse ./config/ssl.xml /etc/clickhouse-server/config.d/ssl.xml
COPY --chown=clickhouse:clickhouse ./cert/ /etc/clickhouse-server/

ENV CLICKHOUSE_CONFIG=/etc/clickhouse-server/config.xml
ENV CLICKHOUSE_CONFD=/etc/clickhouse-server/config.d/docker_related_config.xml
ENV CLICKHOUSE_USER_CONFIG=/etc/clickhouse-server/users.xml

RUN sed -ri 's/<dictionaries_config>\*_dictionary\.xml<\/dictionaries_config>/<dictionaries_config>\/opt\/dictionaries\/test_dictionary.xml<\/dictionaries_config>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/3<\/keep_alive_timeout>/<keep_alive_timeout>240<\/keep_alive_timeout>/' ${CLICKHOUSE_CONFD}

# readonly user
RUN sed -ri 's/<ip>\:\:1<\/ip>/<ip>\:\:\/0<\/ip>/' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<ip>127\.0\.0\.1<\/ip>/\ /' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<!-- <readonly>/<readonly>/' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<\/readonly> -->/<\/readonly>/' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<!-- <access_management>/<access_management>/' ${CLICKHOUSE_USER_CONFIG}
RUN sed -ri 's/<\/access_management> -->/<\/access_management>/' ${CLICKHOUSE_USER_CONFIG}
 
 # ssl related ports
RUN sed -ri 's/<!-- <https_port>/<https_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/https_port> -->/<\/https_port>/' ${CLICKHOUSE_CONFIG}
 
RUN sed -ri 's/<!-- <tcp_port_secure>/<tcp_port_secure>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/tcp_port_secure> -->/<\/tcp_port_secure>/' ${CLICKHOUSE_CONFIG}
 
RUN sed -ri 's/<!-- <interserver_https_port>/<interserver_https_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/interserver_https_port> -->/<\/interserver_https_port>/' ${CLICKHOUSE_CONFIG}
 
 # disable non-secure ports
RUN sed -ri 's/<http_port>/<!-- <http_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/http_port>/<\/http_port>  -->/' ${CLICKHOUSE_CONFIG}
 
RUN sed -ri 's/<tcp_port>/<!-- <tcp_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/tcp_port>/<\/tcp_port>  -->/' ${CLICKHOUSE_CONFIG}
 
RUN sed -ri 's/<interserver_http_port>/<!-- <interserver_http_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<\/interserver_http_port>/<\/interserver_http_port> -->/' ${CLICKHOUSE_CONFIG}

ENTRYPOINT ["/entrypoint.sh"]
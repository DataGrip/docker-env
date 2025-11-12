FROM registry.jetbrains.team/p/datagrip/containers/clickhouse:25

COPY --chown=clickhouse:clickhouse ./config/ssl.xml /etc/clickhouse-server/config.d/ssl.xml
COPY --chown=clickhouse:clickhouse ./certs/* /etc/clickhouse-server/

# ssl related ports
RUN sed -ri 's/<!-- <https_port>([0-9]+)<\/https_port> -->/<https_port>\1<\/https_port>/' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's/<!-- <interserver_https_port>([0-9]+)<\/interserver_https_port> -->/<interserver_https_port>\1<\/interserver_https_port>/' ${CLICKHOUSE_CONFIG}

# disable non-secure ports
RUN sed -ri 's|<http_port>[0-9]*</http_port>|<!-- & -->|' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's|<tcp_port>[0-9]*</tcp_port>|<!-- & -->|' ${CLICKHOUSE_CONFIG}
RUN sed -ri 's|<interserver_http_port>[0-9]*</interserver_http_port>|<!-- & -->|' ${CLICKHOUSE_CONFIG}

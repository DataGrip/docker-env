FROM apache/hive:4.2.1

USER root

RUN mkdir -p /home/hive && chown -R hive:hive /home/hive/

RUN mkdir -p /opt/hive/scratch /opt/hive/warehouse /user/hive/warehouse /tmp/hive/operation_logs /opt/hive/logs /var/run/hive

# The upstream entrypoint generates hive-site.xml from this template on every start.
COPY ./hive-config/hive-site.xml /opt/hive/conf/hive-site.xml.template
COPY ./setup/setup-testdb.sh /opt/hive/setup-testdb.sh
COPY ./start.sh /start.sh

RUN chmod -R 777 /opt/hive/warehouse && \
    chmod -R 777 /opt/hive/scratch && \
    chmod -R 777 /user/hive && \
    chmod -R 777 /tmp/hive && \
    chown hive:hive /opt/hive/conf/hive-site.xml.template && \
    chmod +x /start.sh && \
    chmod +x /opt/hive/setup-testdb.sh && \
    chown -R hive:hive /opt/hive/logs && \
    chown -R hive:hive /var/run/hive


USER hive

ENTRYPOINT ["/start.sh"]


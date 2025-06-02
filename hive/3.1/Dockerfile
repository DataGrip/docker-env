FROM apache/hive:3.1.3

USER root

RUN mkdir -p /home/hive && chown -R hive:hive /home/hive/

RUN mkdir -p /opt/hive/scratch /opt/hive/warehouse /user/hive/warehouse /tmp/hive/operation_logs /opt/hive/logs /var/run/hive

COPY ./hive-config/hive-site.xml /opt/hive/conf/hive-site.xml
COPY ./setup/setup-testdb.sh /opt/hive/setup-testdb.sh
COPY ./start.sh /start.sh

RUN chmod -R 777 /opt/hive/warehouse && \
    chmod -R 777 /opt/hive/scratch && \
    chmod -R 777 /user/hive && \
    chmod -R 777 /tmp/hive && \
    chmod +x /start.sh && \
    chmod +x /opt/hive/setup-testdb.sh && \
    chown -R hive:hive /opt/hive/logs && \
    chown -R hive:hive /var/run/hive

RUN apt-get update && apt-get -y install iproute2 curl sudo vim && apt-get clean && rm -rf /var/lib/apt/lists/*;

RUN echo "hive ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hive

USER hive

ENTRYPOINT ["/start.sh"]


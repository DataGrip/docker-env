FROM couchbase:enterprise-8.0.2

COPY config.sh /opt/couchbase
RUN chmod +x /opt/couchbase/config.sh

CMD ["/opt/couchbase/config.sh"]
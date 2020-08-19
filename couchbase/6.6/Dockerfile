FROM couchbase/server:enterprise-6.6.0

COPY config.sh /opt/couchbase
RUN chmod +x /opt/couchbase/config.sh

CMD ["/opt/couchbase/config.sh"]
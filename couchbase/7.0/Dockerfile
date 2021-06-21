FROM couchbase/server:enterprise-7.0.0-beta

COPY config.sh /opt/couchbase
RUN chmod +x /opt/couchbase/config.sh

CMD ["/opt/couchbase/config.sh"]
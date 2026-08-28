FROM couchbase:enterprise-7.2.9

COPY config.sh /opt/couchbase/config.sh
RUN chmod +x /opt/couchbase/config.sh

ENTRYPOINT ["/opt/couchbase/config.sh"]
CMD ["couchbase-server"]
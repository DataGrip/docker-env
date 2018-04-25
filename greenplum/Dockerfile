FROM pivotaldata/gpdb-base:0.3

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 5432

ENTRYPOINT ["/entrypoint.sh"]
FROM andruche/greenplum:7

COPY entrypoint.sh /
COPY init.sql /

EXPOSE 5432

RUN ["/bin/bash", "-c", "chmod +x /init.sql"]
RUN ["/bin/bash", "-c", "chown gpadmin:gpadmin /init.sql"]
RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh"]
RUN ["/bin/bash", "-c", "chown gpadmin:gpadmin /entrypoint.sh"]

# ENTRYPOINT ["/entrypoint.sh"]
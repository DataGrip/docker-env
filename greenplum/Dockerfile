FROM pivotaldata/gpdb-base:0.3

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 5432

CMD echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts \
            && service sshd start \
    #       && sysctl -p \
            && su gpadmin -l -c "/usr/local/bin/run.sh" \
    && su gpadmin -l -c "/entrypoint.sh"
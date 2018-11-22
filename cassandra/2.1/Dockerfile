FROM cassandra:2.1

ADD entrypoint.sh /
ADD init.sh /

ENV CASSANDRA_CONFIG /etc/cassandra

RUN chmod +x /entrypoint.sh && \
	chmod +x /init.sh

# authenticator: PasswordAuthenticator
RUN set -ex; \
	if grep -q -- '^authenticator: AllowAllAuthenticator' "$CASSANDRA_CONFIG/cassandra.yaml"; then \
		sed -ri 's/^authenticator:\sAllowAllAuthenticator$/authenticator:\ PasswordAuthenticator/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
	fi

# authorizer: CassandraAuthorizer
RUN set -ex; \
	if grep -q -- '^authorizer: AllowAllAuthorizer' "$CASSANDRA_CONFIG/cassandra.yaml"; then \
		sed -ri 's/^authorizer:\sAllowAllAuthorizer$/authorizer:\ CassandraAuthorizer/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
	fi

EXPOSE 9042

ENTRYPOINT ["/entrypoint.sh"]
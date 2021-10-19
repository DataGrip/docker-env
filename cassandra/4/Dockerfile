FROM cassandra:4

ADD entrypoint.sh /
ADD init.sh /
ADD AuditTrigger.jar /etc/cassandra/triggers/
ADD AuditTrigger.properties /etc/cassandra/

ENV CASSANDRA_CONFIG /etc/cassandra

RUN chmod +x /entrypoint.sh && \
	chmod +x /init.sh

# enable_user_defined_functions: true
RUN set -ex; \
    if grep -q -- '^enable_user_defined_functions: false' "$CASSANDRA_CONFIG/cassandra.yaml"; then \
        sed -ri 's/^enable_user_defined_functions:\sfalse$/enable_user_defined_functions:\ true/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
    fi

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
CMD ["cassandra", "-f"]
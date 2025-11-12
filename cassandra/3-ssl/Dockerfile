FROM cassandra:3

ADD entrypoint.sh /
ADD init.sh /
ADD AuditTrigger.jar /etc/cassandra/triggers/
ADD AuditTrigger.properties /etc/cassandra/

ENV CASSANDRA_CONFIG /etc/cassandra

COPY ./cert/keystore.node0 "$CASSANDRA_CONFIG"
COPY ./cert/node0.cer "$CASSANDRA_CONFIG"
COPY ./cert/node0.cer.pem "$CASSANDRA_CONFIG"
COPY ./cert/node0.key.pem "$CASSANDRA_CONFIG"
COPY ./cert/node0.p12 "$CASSANDRA_CONFIG"
COPY ./cert/truststore.node0 "$CASSANDRA_CONFIG"

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

# client_encryption_options:
#1     enabled: false
#2     # If enabled and optional is set to true encrypted and unencrypted connections are handled.
#3     optional: false
#4     keystore: conf/.keystore
#5     keystore_password: cassandra

#6     # require_client_auth: false
#7     # Set trustore and truststore_password if require_client_auth is true
#8     # truststore: conf/.truststore
#9     # truststore_password: cassandra

#10    # More advanced defaults below:
#11    # protocol: TLS
#12    # algorithm: SunX509
#13    # store_type: JKS
#14    # cipher_suites: [TLS_RSA_WITH_AES_256_CBC_SHA]

#-Djavax.net.ssl.trustStore=.\truststore.node0
#-Djavax.net.ssl.trustStorePassword=cassandra
#-Djavax.net.ssl.keyStore=.\keystore.node0
#-Djavax.net.ssl.keyStorePassword=cassandra

RUN set -ex; \
	if grep -q -- '^client_encryption_options' "$CASSANDRA_CONFIG/cassandra.yaml"; then \
		sed -i 's/# native_transport_port_ssl/native_transport_port_ssl/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NUM=$(grep -n 'client_encryption_options:' "$CASSANDRA_CONFIG/cassandra.yaml" | grep -Eo '^[^:]+'); \
		NN=$((NUM+1)); \
		sed -i ''"${NN}"'s/false/true/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+4)); \
		sed -i ''"${NN}"'s/conf\/.keystore/\/etc\/cassandra\/keystore.node0/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+6)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		sed -i ''"${NN}"'s/false/true/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+8)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		sed -i ''"${NN}"'s/conf\/.truststore/\/etc\/cassandra\/truststore.node0/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+9)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+11)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+12)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+13)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		NN=$((NUM+14)); \
		sed -i ''"${NN}"'s/# //' "$CASSANDRA_CONFIG/cassandra.yaml"; \
		sed -i ''"${NN}"'s/\[.*$/\[TLS_RSA_WITH_AES_256_CBC_SHA\]/' "$CASSANDRA_CONFIG/cassandra.yaml"; \
	fi

EXPOSE 9042
EXPOSE 9142

ENTRYPOINT ["/entrypoint.sh"]
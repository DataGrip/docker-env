FROM registry.jetbrains.team/p/datagrip/containers/cassandra:5

COPY ./certs/keystore.node0 "$CASSANDRA_CONFIG"
COPY ./certs/node0.cer "$CASSANDRA_CONFIG"
COPY ./certs/node0.cer.pem "$CASSANDRA_CONFIG"
COPY ./certs/node0.key.pem "$CASSANDRA_CONFIG"
COPY ./certs/node0.p12 "$CASSANDRA_CONFIG"
COPY ./certs/truststore.node0 "$CASSANDRA_CONFIG"

COPY ./cassandra.yaml "$CASSANDRA_CONFIG"

EXPOSE 9042
EXPOSE 9142


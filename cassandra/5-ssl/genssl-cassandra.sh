#!/bin/bash

CERT_DIR="./certs"
KEYSTORE_PASSWORD="${KEYSTORE_PASSWORD:-cassandra}"
TRUSTSTORE_PASSWORD="${TRUSTSTORE_PASSWORD:-cassandra}"
DAYS="${DAYS:-3650}"

mkdir -p "$CERT_DIR"

openssl req -new -x509 -days $DAYS -nodes \
    -out "$CERT_DIR/ca-cert.pem" \
    -keyout "$CERT_DIR/ca-key.pem" \
    -subj "/CN=CassandraCA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign"

keytool -genkeypair -noprompt \
    -alias server \
    -keyalg RSA \
    -keysize 2048 \
    -validity $DAYS \
    -keystore "$CERT_DIR/server.keystore" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEYSTORE_PASSWORD" \
    -dname "CN=cassandra-server"

keytool -certreq -noprompt \
    -alias server \
    -keystore "$CERT_DIR/server.keystore" \
    -storepass "$KEYSTORE_PASSWORD" \
    -file "$CERT_DIR/server.csr"

openssl x509 -req \
    -CA "$CERT_DIR/ca-cert.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -in "$CERT_DIR/server.csr" \
    -out "$CERT_DIR/server-cert.pem" \
    -days $DAYS \
    -CAcreateserial

keytool -importcert -noprompt \
    -alias ca \
    -file "$CERT_DIR/ca-cert.pem" \
    -keystore "$CERT_DIR/server.keystore" \
    -storepass "$KEYSTORE_PASSWORD"

keytool -importcert -noprompt \
    -alias server \
    -file "$CERT_DIR/server-cert.pem" \
    -keystore "$CERT_DIR/server.keystore" \
    -storepass "$KEYSTORE_PASSWORD"

keytool -genkeypair -noprompt \
    -alias client \
    -keyalg RSA \
    -keysize 2048 \
    -validity $DAYS \
    -keystore "$CERT_DIR/client.keystore" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEYSTORE_PASSWORD" \
    -dname "CN=cassandra-client"

keytool -certreq -noprompt \
    -alias client \
    -keystore "$CERT_DIR/client.keystore" \
    -storepass "$KEYSTORE_PASSWORD" \
    -file "$CERT_DIR/client.csr"

openssl x509 -req \
    -CA "$CERT_DIR/ca-cert.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -in "$CERT_DIR/client.csr" \
    -out "$CERT_DIR/client-cert.pem" \
    -days $DAYS \
    -CAcreateserial

keytool -importcert -noprompt \
    -alias ca \
    -file "$CERT_DIR/ca-cert.pem" \
    -keystore "$CERT_DIR/client.keystore" \
    -storepass "$KEYSTORE_PASSWORD"

keytool -importcert -noprompt \
    -alias client \
    -file "$CERT_DIR/client-cert.pem" \
    -keystore "$CERT_DIR/client.keystore" \
    -storepass "$KEYSTORE_PASSWORD"

keytool -importcert -noprompt \
    -alias ca \
    -file "$CERT_DIR/ca-cert.pem" \
    -keystore "$CERT_DIR/cassandra.truststore" \
    -storepass "$TRUSTSTORE_PASSWORD"

keytool -importkeystore -noprompt \
    -srckeystore "$CERT_DIR/client.keystore" \
    -srcstorepass "$KEYSTORE_PASSWORD" \
    -destkeystore "$CERT_DIR/client.p12" \
    -deststoretype PKCS12 \
    -deststorepass "$KEYSTORE_PASSWORD" \
    -srcalias client

openssl pkcs12 -in "$CERT_DIR/client.p12" \
    -passin pass:"$KEYSTORE_PASSWORD" \
    -nokeys -out "$CERT_DIR/client-cert.pem"

openssl pkcs12 -in "$CERT_DIR/client.p12" \
    -passin pass:"$KEYSTORE_PASSWORD" \
    -nocerts -nodes -out "$CERT_DIR/client-key.pem"

chmod 600 "$CERT_DIR"/*.keystore "$CERT_DIR"/*.truststore "$CERT_DIR"/*.p12 "$CERT_DIR"/*-key.pem
chmod 644 "$CERT_DIR"/*.pem 2>/dev/null || true
chmod 600 "$CERT_DIR"/ca-key.pem "$CERT_DIR"/client-key.pem

echo "Certificates are generated"
echo "server:"
echo "   - server.keystore"
echo "   - cassandra.truststore"
echo "client:"
echo "   - client.keystore"
echo "   - client-key.pem"
echo "   - client-cert.pem"
echo "CA:"
echo "   - ca-cert.pem"
echo "   - ca-key.pem"
echo ""
echo "Passwords:"
echo "   - Keystore: $KEYSTORE_PASSWORD"
echo "   - Truststore: $TRUSTSTORE_PASSWORD"

#!/bin/bash

set -euo pipefail

# defaults
: "${CERT_DIR:=./certs}"
: "${DOMAIN:=localhost}"
: "${DAYS:=3650}"
: "${KEY_SIZE:=2048}"
: "${CERT_CN:=Universal}"

mkdir -p "$CERT_DIR"

[[ "$DOMAIN" == "localhost" ]] && SAN="DNS:$DOMAIN,IP:127.0.0.1,IP:::1" || SAN="DNS:$DOMAIN"

# Config
cat > "$CERT_DIR/ssl.cnf" << EOF
[req]
distinguished_name = dn
prompt = no

[dn]
CN = placeholder

[ca]
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash

[server]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = $SAN
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[client]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
EOF

# Generate CA
echo "Generating CA..."
#openssl req -new -x509 -sha256 -days "$DAYS" -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.pem" -config "$CERT_DIR/ca.cnf"
openssl req -x509 -newkey rsa:$KEY_SIZE -nodes -sha256 \
    -days $DAYS -keyout "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.pem" -config "$CERT_DIR/ssl.cnf" -extensions ca -subj "/CN=$CERT_CN CA"

# Generate server certificate
echo "Generating server certificate..."
#
#openssl req -new -sha256 -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.csr" -config "$CERT_DIR/server.cnf"
#openssl x509 -req -sha256 -days "$DAYS" -in "$CERT_DIR/server.csr" -CA "$CERT_DIR/ca.pem" -CAkey "$CERT_DIR/ca.key" -CAcreateserial -out "$CERT_DIR/server.crt" -extfile "$CERT_DIR/server.cnf" -extensions v3_ext

openssl req -newkey rsa:$KEY_SIZE -nodes -sha256 \
    -keyout "$CERT_DIR/server.key"  -out "$CERT_DIR/server.csr" -config "$CERT_DIR/ssl.cnf" -subj "/CN=$DOMAIN"
openssl x509 -req -sha256 -days $DAYS -in "$CERT_DIR/server.csr" -CA "$CERT_DIR/ca.pem" -CAkey "$CERT_DIR/ca.key"  -CAcreateserial -out "$CERT_DIR/server.crt" -extfile "$CERT_DIR/ssl.cnf" -extensions server

# Generate client certificate
echo "Generating client certificate..."
#generate_key "$CERT_DIR/client.key"
#openssl req -new -sha256 -key "$CERT_DIR/client.key" -out "$CERT_DIR/client.csr" -config "$CERT_DIR/client.cnf"
#openssl x509 -req -sha256 -days "$DAYS" -in "$CERT_DIR/client.csr" -CA "$CERT_DIR/ca.pem" -CAkey "$CERT_DIR/ca.key" -CAserial "$CERT_DIR/ca.srl" -out "$CERT_DIR/client.crt" -extfile "$CERT_DIR/client.cnf" -extensions v3_ext

openssl req -newkey rsa:$KEY_SIZE -nodes -sha256 \
    -keyout "$CERT_DIR/client.key" -out "$CERT_DIR/client.csr" -config "$CERT_DIR/ssl.cnf" -subj "/CN=$CERT_CN-client"
openssl x509 -req -sha256 -days $DAYS -in "$CERT_DIR/client.csr" \
    -CA "$CERT_DIR/ca.pem" -CAkey "$CERT_DIR/ca.key" -CAserial "$CERT_DIR/ca.srl" -out "$CERT_DIR/client.crt" \
    -extfile "$CERT_DIR/ssl.cnf" -extensions client

# Chains
cat "$CERT_DIR"/server.crt "$CERT_DIR"/ca.pem > "$CERT_DIR"/server.pem
cat "$CERT_DIR"/client.crt "$CERT_DIR"/ca.pem > "$CERT_DIR"/client.pem
rm -f "$CERT_DIR/ssl.cnf" "$CERT_DIR"/*.csr "$CERT_DIR"/*.srl
chmod 600 "$CERT_DIR"/*.key 2>/dev/null || true

# Chain verification
echo "Verifying certificate chain..."
openssl verify -CAfile "$CERT_DIR/ca.pem" "$CERT_DIR/server.crt"
openssl verify -CAfile "$CERT_DIR/ca.pem" "$CERT_DIR/client.crt"

echo "Done!"
echo "Certificates are in $CERT_DIR/"

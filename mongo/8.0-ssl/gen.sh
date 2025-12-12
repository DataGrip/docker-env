#!/bin/bash

CERT_DIR="./certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

openssl genrsa -out ca.key 4096

openssl req -new -x509 -days 3650 -key ca.key -out ca.pem \
    -subj "/CN=MongoDB CA"

cat > server.cnf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = localhost

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = mongo
DNS.3 = mongodb
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0
EOF

openssl genrsa -out server.key 4096

openssl req -new -key server.key -out server.csr -config server.cnf

openssl x509 -req -days 3650 -in server.csr -CA ca.pem -CAkey ca.key \
    -CAcreateserial -out server.crt \
    -extensions v3_req -extfile server.cnf

cat server.key server.crt > server.pem

cat > client.cnf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = mongo-client

[v3_req]
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
EOF

openssl genrsa -out client.key 4096

openssl req -new -key client.key -out client.csr -config client.cnf

openssl x509 -req -days 3650 -in client.csr -CA ca.pem -CAkey ca.key \
    -CAcreateserial -out client.crt \
    -extensions v3_req -extfile client.cnf

cat client.key client.crt > client.pem


chmod 600 *.key *.pem


echo "=== Server certificate ==="
openssl x509 -in server.crt -text -noout | grep -A2 "Extended Key Usage"

echo "=== Client certificate ==="
openssl x509 -in client.crt -text -noout | grep -A2 "Extended Key Usage"


rm -f *.csr *.cnf *.srl

echo "Certificates created:"
ls -la

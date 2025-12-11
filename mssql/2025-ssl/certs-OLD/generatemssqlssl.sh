#!/bin/bash

openssl genrsa -out ca.key 4096

cat > ca.ext << EOF
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

openssl req -new -x509 -days 3650 -key ca.key -out ca.pem \
  -subj "/CN=MSSQL CA" \
  -extensions v3_ca \
  -config <(cat /etc/ssl/openssl.cnf <(printf "\n[v3_ca]\nbasicConstraints=critical,CA:TRUE\nkeyUsage=critical,keyCertSign,cRLSign\nsubjectKeyIdentifier=hash"))

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=localhost"

cat > server.ext << EOF
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = mssql
IP.1 = 127.0.0.1
EOF

openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key \
  -CAcreateserial -out server.pem -days 365 -sha256 -extfile server.ext

echo "=== CA Extensions ==="
openssl x509 -in ca.pem -noout -text | grep -A1 "Basic Constraints"

echo "=== Verification ==="
openssl verify -CAfile ca.pem server.pem

rm -f server.csr server.ext ca.srl

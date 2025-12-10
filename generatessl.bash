#!/bin/bash

set -e

: "${CERT_DIR:=./certs}"
: "${DOMAIN:=localhost}"
: "${DAYS:=3650}"
: "${KEY_SIZE:=2048}"
: "${CERT_CN:=Universal}"

mkdir -p "$CERT_DIR"

# Checking the OS type
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    SUBJ_PREFIX="//"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SUBJ_PREFIX="/"
else
    SUBJ_PREFIX="/"
fi

# Creating a temporary config file for CA
cat > "$CERT_DIR/ca.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = $CERT_CN CA
EOF

# Creating a temporary config file for server
cat > "$CERT_DIR/server.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = $DOMAIN
EOF

# Creating a temporary config file for client
cat > "$CERT_DIR/client.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = $CERT_CN-client
EOF

# Generating CA
echo "Generating CA key and certificate..."
openssl genrsa -out "$CERT_DIR/ca.key" $KEY_SIZE
openssl req -new -x509 -days $DAYS -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.pem" \
    -config "$CERT_DIR/ca.cnf"

# Generating server private key
echo "Generating server private key and CSR..."
openssl genrsa -out "$CERT_DIR/server.key" $KEY_SIZE
openssl req -new -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.csr" \
    -config "$CERT_DIR/server.cnf"

# Signing server certificate with CA
echo "Signing server certificate with CA..."
openssl x509 -req -days $DAYS \
    -in "$CERT_DIR/server.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca.key" \
    -CAcreateserial \
    -out "$CERT_DIR/server.crt"

cat "$CERT_DIR/server.crt" > "$CERT_DIR/server.pem"

# Generating client private key
echo "Generating client private key and CSR..."
openssl genrsa -out "$CERT_DIR/client.key" $KEY_SIZE
openssl req -new -key "$CERT_DIR/client.key" -out "$CERT_DIR/client.csr" \
    -config "$CERT_DIR/client.cnf"

# Signing client certificate with CA
echo "Signing client certificate with CA..."
openssl x509 -req -days $DAYS \
    -in "$CERT_DIR/client.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca.key" \
    -CAserial "$CERT_DIR/ca.srl" \
    -out "$CERT_DIR/client.crt"

cat "$CERT_DIR/client.crt" > "$CERT_DIR/client.pem"

# Verifying certificates
echo "Verifying server certificate..."
openssl x509 -in "$CERT_DIR/server.crt" -text -noout | grep -E 'Subject:|Issuer:|Not Before:|Not After :'

echo "Verifying client certificate..."
openssl x509 -in "$CERT_DIR/client.crt" -text -noout | grep -E 'Subject:|Issuer:|Not Before:|Not After :'

# Setting permissions (may not work on Windows if there are errors)
chmod 600 "$CERT_DIR/ca.key" "$CERT_DIR/server.key" "$CERT_DIR/client.key" 2>/dev/null || echo "Info: Skipping chmod for Windows"
chmod 644 "$CERT_DIR/ca.pem" "$CERT_DIR/server.crt" "$CERT_DIR/server.pem" "$CERT_DIR/client.crt" "$CERT_DIR/client.pem" 2>/dev/null || echo "Info: Skipping chmod for Windows"

# Removing temporary files
rm -f "$CERT_DIR/ca.cnf" "$CERT_DIR/server.cnf" "$CERT_DIR/client.cnf"

echo "Certificate generation complete. Files are in $CERT_DIR/"
echo "Server files: server.key, server.crt, server.pem"
echo "Client files: client.key, client.crt, client.pem"
echo "CA file: ca.pem"

#!/bin/bash

set -euo pipefail

# Configuration with defaults
: "${CERT_DIR:=./certs}"
: "${DOMAIN:=localhost}"
: "${DAYS:=3650}"
: "${KEY_SIZE:=2048}"
: "${CERT_CN:=Universal}"
: "${USE_ECDSA:=false}"
: "${STORE_PASS:=changeit}"
: "${GENERATE_JKS:=true}"

# Parse additional domains from EXTRA_DOMAINS (comma-separated)
: "${EXTRA_DOMAINS:=}"

mkdir -p "$CERT_DIR"

# Generate private key (RSA or ECDSA)
generate_key() {
    local keyfile="$1"
    if [[ "$USE_ECDSA" == "true" ]]; then
        openssl ecparam -genkey -name prime256v1 -out "$keyfile"
    else
        openssl genrsa -out "$keyfile" "$KEY_SIZE"
    fi
}

# Build SAN entries for server certificate
build_san() {
    local san="DNS:$DOMAIN"
    local idx=2

    # Add localhost variants if domain is localhost
    if [[ "$DOMAIN" == "localhost" ]]; then
        san+=",IP:127.0.0.1,IP:::1"
        idx=4
    fi

    # Add extra domains
    if [[ -n "$EXTRA_DOMAINS" ]]; then
        IFS=',' read -ra DOMAINS <<< "$EXTRA_DOMAINS"
        for d in "${DOMAINS[@]}"; do
            d=$(echo "$d" | xargs)  # trim whitespace
            if [[ "$d" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                san+=",IP:$d"
            else
                san+=",DNS:$d"
            fi
        done
    fi

    echo "$san"
}

# CA configuration
cat > "$CERT_DIR/ca.cnf" << EOF
[req]
distinguished_name = req_dn
prompt = no
x509_extensions = v3_ca

[req_dn]
CN = $CERT_CN CA

[v3_ca]
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

# Server configuration with SAN
SAN_ENTRIES=$(build_san)
cat > "$CERT_DIR/server.cnf" << EOF
[req]
distinguished_name = req_dn
prompt = no
req_extensions = v3_req

[req_dn]
CN = $DOMAIN

[v3_req]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = $SAN_ENTRIES

[v3_ext]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = $SAN_ENTRIES
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
EOF

# Client configuration
cat > "$CERT_DIR/client.cnf" << EOF
[req]
distinguished_name = req_dn
prompt = no
req_extensions = v3_req

[req_dn]
CN = $CERT_CN-client

[v3_req]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth

[v3_ext]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
EOF

# Generate CA
echo "Generating CA..."
generate_key "$CERT_DIR/ca.key"
openssl req -new -x509 -sha256 -days "$DAYS" \
    -key "$CERT_DIR/ca.key" \
    -out "$CERT_DIR/ca.pem" \
    -config "$CERT_DIR/ca.cnf"

# Generate server certificate
echo "Generating server certificate..."
generate_key "$CERT_DIR/server.key"
openssl req -new -sha256 \
    -key "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.csr" \
    -config "$CERT_DIR/server.cnf"

openssl x509 -req -sha256 -days "$DAYS" \
    -in "$CERT_DIR/server.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca.key" \
    -CAcreateserial \
    -out "$CERT_DIR/server.crt" \
    -extfile "$CERT_DIR/server.cnf" \
    -extensions v3_ext

# Create full chain for server
cat "$CERT_DIR/server.crt" "$CERT_DIR/ca.pem" > "$CERT_DIR/server.pem"

# Generate client certificate
echo "Generating client certificate..."
generate_key "$CERT_DIR/client.key"
openssl req -new -sha256 \
    -key "$CERT_DIR/client.key" \
    -out "$CERT_DIR/client.csr" \
    -config "$CERT_DIR/client.cnf"

openssl x509 -req -sha256 -days "$DAYS" \
    -in "$CERT_DIR/client.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca.key" \
    -CAserial "$CERT_DIR/ca.srl" \
    -out "$CERT_DIR/client.crt" \
    -extfile "$CERT_DIR/client.cnf" \
    -extensions v3_ext

cat "$CERT_DIR/client.crt" "$CERT_DIR/ca.pem" > "$CERT_DIR/client.pem"

# Generate Java keystores
if [[ "$GENERATE_JKS" == "true" ]]; then
    echo "Generating Java keystores..."

    # Truststore with CA certificate
    keytool -importcert -alias ca \
        -file "$CERT_DIR/ca.pem" \
        -keystore "$CERT_DIR/truststore.jks" \
        -storepass "$STORE_PASS" \
        -noprompt 2>/dev/null || true

    # Client keystore (PKCS12)
    openssl pkcs12 -export \
        -in "$CERT_DIR/client.crt" \
        -inkey "$CERT_DIR/client.key" \
        -certfile "$CERT_DIR/ca.pem" \
        -out "$CERT_DIR/client.p12" \
        -password "pass:$STORE_PASS" \
        -name client

    # Server keystore (PKCS12)
    openssl pkcs12 -export \
        -in "$CERT_DIR/server.crt" \
        -inkey "$CERT_DIR/server.key" \
        -certfile "$CERT_DIR/ca.pem" \
        -out "$CERT_DIR/server.p12" \
        -password "pass:$STORE_PASS" \
        -name server

    echo "    Truststore: truststore.jks (password: $STORE_PASS)"
    echo "    Client P12: client.p12 (password: $STORE_PASS)"
    echo "    Server P12: server.p12 (password: $STORE_PASS)"
fi

# Set permissions (skip silently on Windows)
chmod 600 "$CERT_DIR"/*.key "$CERT_DIR"/*.p12 "$CERT_DIR"/*.jks 2>/dev/null || true
chmod 644 "$CERT_DIR"/*.pem "$CERT_DIR"/*.crt 2>/dev/null || true

# Verification
echo ""
echo "Verifying certificates..."
openssl x509 -in "$CERT_DIR/server.crt" -noout \
    -subject -issuer -dates -ext subjectAltName 2>/dev/null || \
openssl x509 -in "$CERT_DIR/server.crt" -noout -subject -issuer -dates
openssl x509 -in "$CERT_DIR/client.crt" -noout -subject -issuer -dates

# Verify chain
echo ""
echo "Verifying certificate chain..."
openssl verify -CAfile "$CERT_DIR/ca.pem" "$CERT_DIR/server.crt"
openssl verify -CAfile "$CERT_DIR/ca.pem" "$CERT_DIR/client.crt"

echo ""
echo "Files in $CERT_DIR/"

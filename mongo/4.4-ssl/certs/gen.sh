#!/bin/sh

openssl req -nodes -x509 -days 1001 -newkey rsa:2048 -keyout ca.key -out ca.crt -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=root/CN=127.0.0.1/emailAddress=tjlee1@inbox.ru"

# Generate server cert to be signed
openssl req -nodes -newkey rsa:2048 -days 1001 -keyout server.key -out server.csr  -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=server/CN=127.0.0.1/emailAddress=tjlee1@inbox.ru" 

# Sign the server cert
openssl x509 -days 1001 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

# Create server PEM file
cat server.key server.crt > server.pem
openssl x509 -enddate -noout -in ./server.pem

# Generate client cert to be signed
openssl req -nodes -newkey rsa:2048 -days 1001 -keyout client.key -out client.csr -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=client/CN=127.0.0.1/emailAddress=tjlee1@inbox.ru"

# Sign the client cert
openssl x509 -days 1001 -req -in client.csr -CA ca.crt -CAkey ca.key -CAserial ca.srl -out client.crt

# Create client PEM file
cat client.key client.crt > client.pem
openssl x509 -enddate -noout -in ./client.pem
#create pwd protected
#openssl pkcs8 -topk8 -in client.key -out clientpwd.key

#mongo --tls --host localhost --port 27021 --tlsCAFile ~/projects/docker-env-compose/ssl/mongo/4.4/certs/ca.crt \
# --tlsCertificateKeyFile ~/projects/docker-env-compose/ssl/mongo/4.4/certs/clientpwd.key --tlsCertificateKeyFilePassword password1

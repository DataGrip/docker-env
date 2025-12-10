# docker-env
Docker environment for DataGrip testing

Also see https://github.com/DataGrip/docker-env-oracle for Oracle 11 and https://github.com/DataGrip/docker-env-db2 for Db2


### Create certificates

For creating self-signed certificates run:

`CERT_DIR=</path/to/certificates> CERT_CN="<your-CN-name>" DOMAIN="<your-domain-name>" DAYS=<certificates-duration> KEY_SIZE=<key-size> ./ssl/generatessl.bash`

**The default values are:**  
CERT_DIR = ./certs  
CERT_CN = Universal  
DOMAIN = localhost  
DAYS = 3650  
KEY_SIZE = 2048

Example:  
`CERT_DIR=./ssl/clickhouse/25/certs CERT_CN="Clickhouse" ./ssl/generatessl.bash`  
  
Check the certificate:  
`openssl.exe x509 -in path/to/your/cert -noout -text`  

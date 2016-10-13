# Generating ssl certificates for your docker image

If you are using Windows OS make sure you have installed openssl with Git for Windows

If you are using Windows OS use ```winpty``` before each command provided in this guide

## Server certificates

1. Generate a private key (provide passphrase)
```openssl genrsa -des3 -out server.key 1024```

2. Remove the passphrase 
```openssl rsa -in server.key -out server.key```

3. Create server certificate
Provide *Common Name* as 192.168.99.100 (your docker host ip)
```openssl req -new -key server.key -days 3650 -out server.crt -x509```

4. Sinse we are self-signing, we use the server certificate as the trusted root cetrificate
```cp server.crt root.crt```

5. Edit your *pg_hba.conf*, e.g.: 
```# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust

host    all all 172.17.0.0/8   md5
hostssl all all 0.0.0.0/0      md5```

6. Edit your *postgresql.conf* to activate ssl:
```ssl = on
ssl_ciphers = 'DEFAULT:!LOW:!EXP:!MD5:@STRENGTH'
ssl_cert_file = '/var/lib/postgresql/data/server.crt'
ssl_key_file = '/var/lib/postgresql/data/server.key'
#ssl_ca_file = ''           # (change requires restart)
#ssl_renegotiation_limit = 512MB    # amount of data between renegotiations```

## Client certificates

On client we need 3 files, for Windows these files must be in ```%appdata%/postgresql/``` directory. For Linux ```~/.postgresql/``` directory. Copy these files to mentioned directories after generation. 
* root.crt (trusted root certificate)
* postgresql.crt (client certificate)
* postgresql.key (private key)

7. Generate private key ```postgresql.key``` for client machine and remove passphrase
```openssl genrsa -des3 -out ./postgresql.key 1024
openssl rsa -in /tmp/postgresql.key -out ./postgresql.key```

8. Generate ```postgresql.crt```
Certificate common name (CN) must be set to the database user name we'll connect as!
```openssl req -new -key /tmp/postgresql.key -out /tmp/postgresql.csr
openssl x509 -req -in ./postgresql.csr -CA root.crt -CAkey server.key -out ./postgresql.crt -CAcreateserial```



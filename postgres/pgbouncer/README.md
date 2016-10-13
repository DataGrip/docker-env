### pgBouncer
Works upon postgres 9.3 based on ubuntu:14.04

#### Usage:
```
docker pull chernov/ubuntu-postgres:9.3
docker pull chernov/ubuntu-pgbouncer
docker-compose up -d pgbouncer
```
#### Connection string:
jdbc:postgresql://$HOST:6432/guest;user=guest;password=guest
 
#### Environment variables 

`PG_ENV_POSTGRESQL_USER` (default: guest)

`PG_ENV_POSTGRESQL_PASS` (default: guest)

`PG_ENV_POSTGRESQL_MAX_CLIENT_CONN` (default: 10000)

`PG_ENV_POSTGRESQL_DEFAULT_POOL_SIZE` (default: 400)

`PG_ENV_POSTGRESQL_SERVER_IDLE_TIMEOUT` (default: 240)
 

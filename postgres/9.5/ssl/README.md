# Docker Postgres with SSL Certificate
This repo is for running a Docker postgres image with SSL based on the library
[postgres 9.5 image](https://github.com/docker-library/postgres).

## Build
```
docker pull nimbustech/postgres-ssl:9.5 
```

## Use

 1. First get postgres up and running (replace `$PG_DATA` and '`demo'` as required):
        
        docker run --rm --name psql -e POSTGRES_DB='demo' -e POSTGRES_PASSWORD='password' nimbustech/postgres-ssl:9.5
        
 2. Then copy your `server.crt` and `server.key` files to `/my/cert/folder`. You must make sure that the ownership
  and permisions are correct, typically by running the following *in the host*:
  
        sudo chown 999.docker *
        sudo chmod 600 server.key
 
 3. You can configure postgres to use your
    certificates with:
   
        docker run --name psql -d -v /my/cert/folder:/var/ssl -e POSTGRES_PASSWORD='password' nimbustech/postgres-ssl:9.5
        
         
 3. Then connect with the proper `sslmode` parameter that your client uses to connect to postgres.
([libpq docs](http://www.postgresql.org/docs/9.4/static/libpq-connect.html#LIBPQ-CONNECT-SSLMODE))
    * disable - **will not use ssl**
    * allow - **will revert to non-ssl mode with an outdated cert**
    * prefer - **will revert to non-ssl mode with an outdated cert**
    * require - **will fail with an outdated cert**
    * verify-ca - **will fail with an outdated cert**
    * verify-full- **will fail with an outdated cert**

```
PGSSLMODE="prefer"  psql -h xxx.xxx.xxx.xxx -U postgres -d dbname
```

## Environment

The environment variables are he same as for the [official postgres](https://hub.docker.com/r/library/postgres/) image:

### POSTGRES_PASSWORD

This environment variable is recommended for you to use the PostgreSQL image. This environment variable sets the 
superuser password for PostgreSQL. The default superuser is defined by the POSTGRES_USER environment variable. 
In the above example, it is being set to "password".

### POSTGRES_USER
This optional environment variable is used in conjunction with POSTGRES_PASSWORD to set a user and its password. This 
variable will create the specified user with superuser power and a database with the same name. If it is not specified, 
then the default user of `postgres` will be used.

### PGDATA
This optional environment variable can be used to define another location - like a subdirectory - for the database 
files. The default is /var/lib/postgresql/data, but if the data volume you're using is a fs mountpoint (like with GCE 
persistent disks), Postgres initdb recommends a subdirectory (for example /var/lib/postgresql/data/pgdata ) 
be created to contain the data.

### POSTGRES_DB
This optional environment variable can be used to define a different name for the default database that is created when 
the image is first started. If it is not specified, than the value of `POSTGRES_USER` will be used.

### Volumes

The following directories are defined as volumes:

 * /var/lib/postgresql/data
 * /var/ssl - postgres looks here for your `server.crt` and `server.key` files

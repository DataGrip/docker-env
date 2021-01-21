# docker-prestodb

[![Build Status](https://travis-ci.org/IBM/docker-prestodb.svg?branch=master)](https://travis-ci.org/IBM/docker-prestodb)
[![Docker Build Statu](https://img.shields.io/docker/build/shawnzhu/prestodb.svg)](https://hub.docker.com/r/shawnzhu/prestodb/)

This is a docker image for [PrestoDB](https://prestodb.io/) with [Hive connector](https://prestodb.io/docs/current/connector/hive.html).

## Start

```SHELL
docker run -d -p 8080:8080 shawnzhu/prestodb:latest
```

## Configuration

### Hive

It requires a working Hive cluster since the default configuration files are for hive connector only. See https://prestodb.io/docs/current/installation/deployment.html Where it assumes Hive metastore listens on `thrift://hive-metastore:9083`

It's capable to change configuration like `hive.metastore.uri` by binding new directory under `/opt/presto/etc`. E.g., given configuration file `/foo/bar/hive.properties`:

```SHELL
docker run -d -p 8080:8080 -v /foo/bar/hive.properties:/home/presto/etc/catalog/hive.properties:ro shawnzhu/prestodb:0.193
``` 

### DB2

It includes a [db2 connector for presto](https://github.com/IBM/presto-db2) so you can add another configuration file for db2:

```
# cat db2.properties
connector.name=db2
connection-url=jdbc:db2://ip:port/database
connection-user=myuser
connection-password=mypassword
```

Then:

```SHELL
docker run -d -p 8080:8080 -v /foo/bar/db2.properties:/home/presto/etc/catalog/db2.properties:ro shawnzhu/prestodb:latest
```
docker image for postgres 9.3
based off of stackbrew/ubuntu:12.04

To pull this image:
`docker pull chernov/postgres9.3`

Example usage:
`docker run -i -t -d -p 5432:5432 -e POSTGRESQL_USER=docker -e POSTGRESQL_PASS=docker -e POSTGRESQL_DB=docker chernov/postgres9.3`

The following environment variables can be passed to the docker image:

`POSTGRESQL_USER` (default: docker)

`POSTGRESQL_PASS` (default: docker)

`POSTGRESQL_DB` (default: docker)

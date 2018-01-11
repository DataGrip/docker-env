FROM postgres:9.6

COPY init.sh /docker-entrypoint-initdb.d/init.sh

RUN apt-get update && \
    apt-get install -y cmake pgxnclient postgresql-plpython-9.6 postgresql-server-dev-9.6 g++ m4 && \
    apt-get install -y postgis postgresql-9.6-postgis-scripts

RUN pgxn install madlib=1.11
FROM ubuntu:14.04

COPY run.sh /

RUN (echo "deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list)
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget
RUN wget --quiet --no-check-certificate -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pgbouncer net-tools vim
ENV PG_ENV_POSTGRESQL_MAX_CLIENT_CONN 10000
ENV PG_ENV_POSTGRESQL_DEFAULT_POOL_SIZE 400
ENV PG_ENV_POSTGRESQL_SERVER_IDLE_TIMEOUT 240
COPY run.sh /usr/local/bin/run

RUN chmod +x /run.sh
EXPOSE 6432
CMD ["/run.sh"]

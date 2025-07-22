FROM influxdb:3-core

USER root

RUN apt-get update && \
        apt-get install -y \
        curl \
        iproute2 \
        gnupg2 \
        vim \
        jq &&  \
        rm -rf /var/lib/apt/lists/*

ADD ./createdb.sh /docker-entrypoint-initdb.d/createdb.sh
RUN chmod +x /docker-entrypoint-initdb.d/createdb.sh

ADD entrypoint.sh /usr/bin/entrypoint-custom.sh
RUN chmod +x /usr/bin/entrypoint-custom.sh

USER influxdb3

ENTRYPOINT ["/usr/bin/entrypoint-custom.sh"]

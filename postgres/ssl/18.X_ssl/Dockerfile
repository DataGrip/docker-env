FROM registry.jetbrains.team/p/datagrip/containers/postgresql:18-postgis

COPY ./conf/pg_hba.conf /usr/share/postgresql/18/pg_hba.conf.sample
COPY ./conf/pg_ident.conf /usr/share/postgresql/18/pg_ident.conf.sample
COPY ./conf/postgresql.conf /usr/share/postgresql/18/postgresql.conf.sample

ADD ./certs/server.key /var/ssl/
ADD ./certs/server.crt /var/ssl/
ADD ./certs/ca.pem /var/ssl/

RUN chown postgres:postgres /var/ssl/server.key && \
    chmod 600 /var/ssl/server.key

#COPY --chmod=755 ./conf/init.sh /docker-entrypoint-initdb.d/

RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/# fr_FR.UTF-8/fr_FR.UTF-8/' /etc/locale.gen && \
    sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    chown postgres:postgres \
        /usr/share/postgresql/18/pg_hba.conf.sample \
        /usr/share/postgresql/18/pg_ident.conf.sample \
        /usr/share/postgresql/18/postgresql.conf.sample

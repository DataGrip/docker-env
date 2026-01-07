FROM postgres:17

COPY ./conf/pg_hba.conf /usr/share/postgresql/17/pg_hba.conf.sample
COPY ./conf/postgresql.conf /usr/share/postgresql/17/postgresql.conf.sample
RUN chown postgres.postgres /usr/share/postgresql/17/pg_hba.conf.sample \
                            /usr/share/postgresql/17/postgresql.conf.sample && \
    apt-get update && \
    apt-get install -y postgis postgresql-17-postgis-3-scripts postgresql-17-pgrouting osm2pgrouting

COPY ./conf/init.sh /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

ENV LOCALE_CONFIG=/etc/locale.gen
RUN sed -ri 's/#\ fr_FR.UTF-8\ UTF-8/fr_FR.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN sed -ri 's/#\ en_US.UTF-8\ UTF-8/en_US.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN cd /usr/sbin/ && ./locale-gen

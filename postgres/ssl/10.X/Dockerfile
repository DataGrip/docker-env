FROM postgis/postgis:10-2.5
#FROM postgres:10

ADD ./conf/ssl.conf /etc/postgresql-common/ssl.conf

ADD ./cert/server.key /var/ssl/
ADD ./cert/server.crt /var/ssl/

# Add the ssl config setup script
COPY ./conf/pg_hba.conf /usr/share/postgresql/10/pg_hba.conf.sample
COPY ./conf/postgresql.conf /usr/share/postgresql/10/postgresql.conf.sample
COPY ./cert/server.crt ./cert/server.key /var/ssl/
RUN chown postgres.postgres /usr/share/postgresql/10/pg_hba.conf.sample \
                            /usr/share/postgresql/10/postgresql.conf.sample \
                            /var/ssl/server.key \
                            /var/ssl/server.crt && \
    chmod 600 /var/ssl/server.key &&\
    chgrp postgres /var/ssl/server.key &&\
    chown postgres /var/ssl/server.key

COPY ./conf/init.sh /docker-entrypoint-initdb.d/init.sh

ENV LOCALE_CONFIG=/etc/locale.gen
RUN sed -ri 's/#\ fr_FR.UTF-8\ UTF-8/fr_FR.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN sed -ri 's/#\ en_US.UTF-8\ UTF-8/en_US.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN cd /usr/sbin/ && ./locale-gen

FROM postgres:13

ADD ./conf/ssl.conf /etc/postgresql-common/ssl.conf

ADD ./cert/server.key /var/ssl/
ADD ./cert/server.crt /var/ssl/
ADD ./cert/root.crt /var/ssl/

# Add the ssl config setup script
COPY ./conf/pg_hba.conf /usr/share/postgresql/13/pg_hba.conf.sample
COPY ./conf/postgresql.conf /usr/share/postgresql/13/postgresql.conf.sample
COPY ./cert/server.crt ./cert/server.key /var/ssl/
RUN chown postgres.postgres /usr/share/postgresql/13/pg_hba.conf.sample \
                            /usr/share/postgresql/13/postgresql.conf.sample \
                            /var/ssl/server.key \
                            /var/ssl/root.crt \
                            /var/ssl/server.crt && \
    chmod 600 /var/ssl/server.key &&\
    chgrp postgres /var/ssl/server.key &&\
    chown postgres /var/ssl/server.key &&\
    apt-get update && \
    apt-get install -y postgis postgresql-13-postgis-3-scripts

COPY ./conf/init.sh /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

ENV LOCALE_CONFIG=/etc/locale.gen
RUN sed -ri 's/#\ fr_FR.UTF-8\ UTF-8/fr_FR.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN sed -ri 's/#\ en_US.UTF-8\ UTF-8/en_US.UTF-8\ UTF-8/' ${LOCALE_CONFIG}
RUN cd /usr/sbin/ && ./locale-gen

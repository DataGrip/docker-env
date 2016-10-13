FROM postgres:9.5

MAINTAINER Cayle Sharrock<cayle@nimbustech.biz>

# Override this in your docker run command to customize
ADD ./ssl.conf /etc/postgresql-common/ssl.conf
# Add the ssl config setup script
COPY pg_hba.conf /usr/share/postgresql/9.5/pg_hba.conf.sample
COPY postgresql.conf /usr/share/postgresql/9.5/postgresql.conf.sample
COPY server.crt server.key /var/ssl/
RUN chown postgres.postgres /usr/share/postgresql/9.5/pg_hba.conf.sample \
                            /usr/share/postgresql/9.5/postgresql.conf.sample \
                            /var/ssl/server.key \
                            /var/ssl/server.crt && \
    chmod 600 /var/ssl/server.key &&\
    chgrp postgres /var/ssl/server.key &&\
    chown postgres /var/ssl/server.key



FROM icr.io/db2_community/db2:11.5.8.0

RUN mkdir -p /var/custom
ADD start.sh /var/custom/

RUN mkdir -p /var/scripts
ADD createschema.sh /var/scripts/
ADD init.sql /var/scripts/
ADD initspatial.sql /var/scripts/

RUN chown -R 1000:1000 /var/custom
RUN chmod +x /var/custom/*.sh
RUN chown -R 1000:1000 /var/scripts

RUN sed -ri 's/^(PASS_MAX_DAYS\s+).*/\199999/' /etc/login.defs

EXPOSE 50000
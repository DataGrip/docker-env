FROM icr.io/db2_community/db2:12.1.0.0


RUN mkdir -p /var/custom
COPY createschema.sh /var/custom/createschema.sh

RUN mkdir -p /var/sql
COPY init.sql /var/sql/init.sql
COPY initspatial.sql /var/sql/initspatial.sql

RUN chmod a+x /var/custom/createschema.sh
RUN chmod a+x /var/sql/init.sql
RUN chmod a+x /var/sql/initspatial.sql

EXPOSE 50000
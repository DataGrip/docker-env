FROM icr.io/db2_community/db2


RUN mkdir /var/custom
COPY createschema.sh /var/custom/createschema.sh
COPY init.sql /var/custom/init.sql
COPY initspatial.sql /var/custom/initspatial.sql

RUN chmod a+x /var/custom/createschema.sh
RUN chmod a+x /var/custom/init.sql
RUN chmod a+x /var/custom/initspatial.sql

EXPOSE 50000
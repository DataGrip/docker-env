FROM store/ibmcorp/db2_developer_c:11.1.4.4-x86_64

RUN mkdir /var/custom
COPY createschema.sh /var/custom
COPY init.sql /var/custom/init.sql
RUN chmod a+x /var/custom/createschema.sh
RUN chmod a+x /var/custom/init.sql
EXPOSE 50000
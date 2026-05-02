FROM datagrip/db2:11.1
#FROM store/ibmcorp/db2_developer_c:11.1.4.4-x86_64

RUN mkdir -p /var/custom
ADD start.sh /var/custom/

RUN mkdir -p /var/scripts
ADD createschema.sh /var/scripts/
ADD init.sql /var/scripts/
ADD initspatial.sql /var/scripts/

RUN chown -R 1000:1000 /var/custom
RUN chmod +x /var/custom/*.sh
RUN chown -R 1000:1000 /var/scripts

EXPOSE 50000
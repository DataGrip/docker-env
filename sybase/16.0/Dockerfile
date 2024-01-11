FROM nguoianphu/docker-sybase

ADD entrypoint.sh /

RUN sed -i 's/allow sql server async i\/o = DEFAULT/allow sql server async i\/o = 0/g' /opt/sybase/ASE-16_0/MYSYBASE.cfg
RUN sed -i '$ d' /opt/sybase/ASE-16_0/install/RUN_MYSYBASE
RUN echo "-T11889" >> /opt/sybase/ASE-16_0/install/RUN_MYSYBASE
RUN sed -i 's/-T11889/-T11889 \\/g' /opt/sybase/ASE-16_0/install/RUN_MYSYBASE

RUN chmod +x /entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]

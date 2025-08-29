FROM datagrip/oracle:19.3-e

USER root

ADD https://download.oracle.com/otn_software/apex/apex_24.2_en.zip /tmp

RUN yum install -y unzip

RUN unzip /tmp/apex_24.2_en.zip
RUN chown -R oracle:dba /home/oracle

USER oracle

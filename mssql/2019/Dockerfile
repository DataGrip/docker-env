FROM mcr.microsoft.com/mssql/server:2019-CU32-GDR11-ubuntu-20.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ADD entrypoint.sh /
ADD init.sh /

USER root

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh && \
chmod +x /init.sh"]

RUN apt-get update && \
    apt-get install -y curl gnupg gnupg2 gnupg1 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list | tee /etc/apt/sources.list.d/msprod.list

RUN apt-get update && \
    apt-get install -y mssql-server-fts mssql-tools18

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

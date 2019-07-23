FROM mcr.microsoft.com/mssql/server:2019-CTP3.0-ubuntu

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD entrypoint.sh / 
ADD init.sh / 

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh && \
chmod +x /init.sh"]

RUN apt-get update && \
    apt-get install -y curl && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-preview.list | tee /etc/apt/sources.list.d/mssql-server.list

RUN apt-get update && \
    apt-get install -y mssql-server-fts

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

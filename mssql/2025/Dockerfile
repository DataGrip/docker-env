FROM mcr.microsoft.com/mssql/server:2025-RTM-ubuntu-22.04

ENV MSSQL_PID=Developer
ENV ACCEPT_EULA=Y

USER root

RUN apt-get update && \
    apt-get install -y \
    curl \
    iproute2 \
    debconf-utils \
    gnupg2 \
    vim \
    unixodbc-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2025.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && \
    apt-get install -y \
    mssql-server-fts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

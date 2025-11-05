FROM mcr.microsoft.com/mssql/server:2025-RC1-ubuntu-22.04

ENV MSSQL_PID=Developer
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=My@Super@Secret

USER root

# fts plugin 2022 need to be replaced when 2025 version is available
RUN apt-get update && \
    apt-get install -yq iproute2  \
    debconf-utils \
    gnupg2 \
    vim \
    unixodbc-dev \
    curl \
    apt-transport-https \
    ca-certificates && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list \
    -o /etc/apt/sources.list.d/mssql-server-2022.list && \
    apt-get update && \
    apt-get install -y mssql-server-fts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

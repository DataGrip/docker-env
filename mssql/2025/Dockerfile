FROM mcr.microsoft.com/mssql/server:2025-RC1-ubuntu-22.04

ENV MSSQL_PID=Developer
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=My@Super@Secret

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

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

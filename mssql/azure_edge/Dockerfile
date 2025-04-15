FROM mcr.microsoft.com/azure-sql-edge

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV GOSQLCMD_VERSION=v1.8.2
ENV PATH="${PATH}:/opt/mssql-tools/bin"

USER root

COPY entrypoint.sh /
COPY init.sh /

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh && \
chmod +x /init.sh"]

# add sqlcmd from https://github.com/microsoft/go-sqlcmd
# we add this to /opt/mssql-tools/bin which completely overrides the
# sqlcmd from the base image. Read up on why we do this here:
# https://github.com/microsoft/go-sqlcmd/discussions/501#discussion-6088877
WORKDIR /opt/mssql-tools/bin

RUN wget https://github.com/microsoft/go-sqlcmd/releases/download/${GOSQLCMD_VERSION}/sqlcmd-linux-amd64.tar.bz2 \
 && tar -xjf sqlcmd-linux-amd64.tar.bz2 \
 && chmod +x sqlcmd \
 && rm sqlcmd-linux-amd64.tar.bz2

WORKDIR /

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
	curl apt-transport-https debconf-utils gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y install locales \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]


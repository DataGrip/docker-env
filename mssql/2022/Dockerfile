FROM mcr.microsoft.com/mssql/server:2022-CU27-ubuntu-22.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ADD entrypoint.sh /
ADD init.sh /

USER root

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh && \
chmod +x /init.sh"]


# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    debconf-utils \
    gnupg2 \
    locales \
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
RUN echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" \
    > /etc/apt/sources.list.d/microsoft-prod.list

# install SQL Server drivers and tools
RUN apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8 \
        && update-locale LANG=en_US.UTF-8

ENV PATH="${PATH}:/opt/mssql-tools18/bin"

CMD /bin/bash

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

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
    && curl -fsSL -O https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list \
       -o /etc/apt/sources.list.d/mssql-server.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y \
       mssql-server-fts \
       msodbcsql18 \
       mssql-tools18 \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
        && update-locale LANG=en_US.UTF-8

ENV PATH="${PATH}:/opt/mssql-tools18/bin"

CMD /bin/bash

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

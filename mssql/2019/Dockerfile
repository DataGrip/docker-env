FROM mcr.microsoft.com/mssql/server:vNext-CTP2.0-ubuntu

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD entrypoint.sh / 
ADD init.sh / 

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh && \
chmod +x /init.sh"]

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

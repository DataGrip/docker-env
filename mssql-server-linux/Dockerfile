FROM microsoft/mssql-server-linux:rc2

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD entrypoint.sh / 

RUN ["/bin/bash", "-c", "chmod +x /entrypoint.sh"]

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

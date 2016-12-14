FROM microsoft/mssql-server-linux:latest

RUN \
apt-get update && \
apt-get install -y python sudo

ENV SA_PASSWORD=yourStrong123Password
ENV ACCEPT_EULA=Y
ENV container=docker

# sql server setup
RUN /opt/mssql/bin/sqlservr-setup --accept-eula --set-sa-password

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


ADD entrypoint.sh / 

# sql tools setup; 
# sqlcmd -S <host> -U <user> -P <password>
RUN \
locale-gen en_US.UTF-8 && \
update-locale && \
apt-get update && \
apt-get install -y curl apt-transport-https && \
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
curl https://packages.microsoft.com/config/ubuntu/15.10/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
apt-get update && \
apt-get install -y mssql-tools && \
chmod +x /entrypoint.sh

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]

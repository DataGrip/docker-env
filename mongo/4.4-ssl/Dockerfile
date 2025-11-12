FROM mongo:4-bionic

ENV MONGO_CERT=/opt/certs
ENV AUTH=yes
ENV STORAGE_ENGINE=wiredTiger
ENV JOURNALING=yes

ADD run.sh /run.sh
ADD set_mongodb_password.sh /set_mongodb_password.sh

RUN mkdir -p "$MONGO_CERT" &&\
    chmod +x /set_mongodb_password.sh && \
	chmod +x /run.sh

COPY ./cert3/ca.pem "$MONGO_CERT"
COPY ./cert3/ca.key "$MONGO_CERT"
COPY ./cert3/ca.srl "$MONGO_CERT"

COPY ./cert3/client.crt "$MONGO_CERT"
COPY ./cert3/client.csr "$MONGO_CERT"
COPY ./cert3/client.key "$MONGO_CERT"
COPY ./cert3/client.pem "$MONGO_CERT"

COPY ./cert3/server.crt "$MONGO_CERT"
COPY ./cert3/server.csr "$MONGO_CERT"
COPY ./cert3/server.key "$MONGO_CERT"
COPY ./cert3/server.pem "$MONGO_CERT"

EXPOSE 27017 28017

CMD ["/run.sh"]

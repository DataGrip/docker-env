FROM mongo:8.0

ENV MONGO_CERT=/opt/certs
ENV AUTH=yes
ENV STORAGE_ENGINE=wiredTiger
ENV JOURNALING=yes

ADD run.sh /run.sh
ADD set_password.sh /set_password.sh

RUN mkdir -p "$MONGO_CERT" &&\
    chmod +x /set_password.sh && \
	chmod +x /run.sh

COPY ./certs/* "$MONGO_CERT"

EXPOSE 27017 28017

CMD ["/run.sh"]

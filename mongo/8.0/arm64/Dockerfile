FROM arm64v8/mongo:8.0

ENV AUTH=yes
ENV STORAGE_ENGINE=wiredTiger
ENV JOURNALING=yes

COPY run.sh /run.sh
COPY set_mongodb_password.sh /set_mongodb_password.sh

RUN chmod +x /set_mongodb_password.sh && \
    chmod +x /run.sh

EXPOSE 27017 28017

CMD ["/run.sh"]

FROM mongo:5-focal

VOLUME /data/db

ENV AUTH yes
ENV STORAGE_ENGINE wiredTiger
ENV JOURNALING yes

ADD run.sh /run.sh
ADD set_mongodb_password.sh /set_mongodb_password.sh

RUN chmod +x /set_mongodb_password.sh && \
    chmod +x /run.sh

EXPOSE 27017 28017

CMD ["/run.sh"]

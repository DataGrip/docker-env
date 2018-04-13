FROM nguoianphu/docker-sybase

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]

FROM registry.jetbrains.team/p/datagrip/containers/redis:7

RUN mkdir -p /usr/local/etc/redis/tls
COPY ./certs/* /usr/local/etc/redis/tls/
RUN chown -R redis:redis /usr/local/etc/redis/tls

COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
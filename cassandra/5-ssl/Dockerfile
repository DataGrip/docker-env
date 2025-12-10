FROM registry.jetbrains.team/p/datagrip/containers/cassandra:5

RUN mkdir -p /etc/cassandra/ /etc/cassandra/certs
COPY ./certs/* /etc/cassandra/certs/

COPY ./cassandra.yaml /etc/cassandra/
RUN chown cassandra:cassandra /etc/cassandra/cassandra.yaml
RUN chown -R cassandra:cassandra /etc/cassandra/

EXPOSE 9042

ADD entrypoint.sh /
ADD init.sh /
RUN chmod +x /entrypoint.sh && \
	chmod +x /init.sh

RUN mkdir -p /root/.cassandra
ADD cqlshrc /root/.cassandra/cqlshrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["cassandra", "-f"]

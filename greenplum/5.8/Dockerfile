FROM pivotaldata/pgadmin:gpdb-5

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 5432

CMD sudo su - gp bash -c /home/gp/install_and_start_gpdb.sh && sudo su - gp bash -c /entrypoint.sh && tail -f /dev/null
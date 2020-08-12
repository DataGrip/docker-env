FROM pivotaldata/gpdb6-ubuntu18.04-test

EXPOSE 5432

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -m -r -g postgres --uid=999 postgres

# Install GreenPlum
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository ppa:greenplum/db \
  && apt-get update \
  && apt-get install -y greenplum-db

# Create GreenPlum data folders and copy/edit configuration to use a single node
RUN mkdir /data \
 && mkdir /data/data1 \
 && mkdir /data/data2 \
 && mkdir /data/master \
 && ls -al /opt/ \
 && . /opt/greenplum-db-6.8.1/greenplum_path.sh && cp $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_singlenode /data/ \
 && sed -i 's/gpdata1/data\/data1/g' /data/gpinitsystem_singlenode \
 && sed -i 's/gpdata2/data\/data2/g' /data/gpinitsystem_singlenode \
 && sed -i 's/gpmaster/data\/master/g' /data/gpinitsystem_singlenode

# Create gpadmin user and add the user to the sudoers
RUN useradd -md /home/gpadmin/ gpadmin \
 && chown gpadmin -R /data \
 && echo "source /opt/greenplum-db-6.8.1/greenplum_path.sh" > /home/gpadmin/.bash_profile && chown gpadmin:gpadmin /home/gpadmin/.bash_profile \
 && su - gpadmin bash -c 'mkdir /home/gpadmin/.ssh' \
 && echo "gpadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "root ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /run/sshd

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

## Add setup and start script to run when the container starts
ADD install_and_start_gpdb.sh /home/gpadmin/install_and_start_gpdb.sh

RUN chown gpadmin:gpadmin /home/gpadmin/install_and_start_gpdb.sh \
 && chmod a+x /home/gpadmin/install_and_start_gpdb.sh

CMD /etc/init.d/ssh start && su - gpadmin bash -c /home/gpadmin/install_and_start_gpdb.sh && su - gpadmin bash -c /entrypoint.sh && tail -f /dev/null

# currently published as pivotaldata/pgadmin:gpdb-5

FROM pivotaldata/pgadmin:base-python-selenium-chrome

EXPOSE 5432

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -m -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

RUN apt update \
 && apt install -y software-properties-common python-software-properties less \
 && add-apt-repository ppa:greenplum/db \
 && apt update \
 && apt install -y greenplum-db-oss \
 && . /opt/gpdb/greenplum_path.sh

RUN locale-gen en_US.utf8 \
 && mkdir /gpdata \
 && mkdir /gpdata/gpdata1 \
 && mkdir /gpdata/gpdata2 \
 && mkdir /gpdata/gpmaster \
 && . /opt/gpdb/greenplum_path.sh && cp $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_singlenode /gpdata/ \
 && sed -i 's/gpdata1/gpdata\/gpdata1/g' /gpdata/gpinitsystem_singlenode \
 && sed -i 's/gpdata2/gpdata\/gpdata2/g' /gpdata/gpinitsystem_singlenode \
 && sed -i 's/gpmaster/gpdata\/gpmaster/g' /gpdata/gpinitsystem_singlenode \
 && apt install -y ssh \
 && useradd -md /home/gp/ gp \
 && chown gp -R /gpdata \
 && echo "source /opt/gpdb/greenplum_path.sh" > /home/gp/.bash_profile && chown gp:gp /home/gp/.bash_profile \
 && su - gp bash -c 'mkdir /home/gp/.ssh'

ADD install_and_start_gpdb.sh /home/gp/install_and_start_gpdb.sh
RUN chown gp:gp /home/gp/install_and_start_gpdb.sh \
 && chmod a+x /home/gp/install_and_start_gpdb.sh \
 && echo "gp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "root ALL=NOPASSWD: ALL" >> /etc/sudoers

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

# CMD sudo su - gp bash -c /home/gp/install_and_start_gpdb.sh && tail -f /dev/null
CMD sudo su - gp bash -c /home/gp/install_and_start_gpdb.sh && sudo su - gp bash -c /entrypoint.sh && tail -f /dev/null
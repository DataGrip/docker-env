#!/bin/bash
sleep 5

echo "==== REMOVE OLD ID_RSA KEYS"
rm /home/gpadmin/.ssh/id_rsa
rm /home/gpadmin/.ssh/id_rsa.pub

echo "==== SSH START"
# /etc/init.d/ssh start

echo "==== SSH KEYGEN"
ssh-keygen -f /home/gpadmin/.ssh/id_rsa -t rsa -N ""

echo "==== SOURCE PROFILE"
source /home/gpadmin/.bash_profile

echo "==== HOSTNAME TO SINGLENODE"
echo `hostname` > /data/hostlist_singlenode
sed -i 's/hostname_of_machine/`hostname`/g' /data/gpinitsystem_singlenode

echo "==== VALIDATE VIA GPSSH-EXKEYS"
gpssh-exkeys -f /data/hostlist_singlenode

pushd /data
  echo "==== GPINITSYSTEM"
  gpinitsystem -ac gpinitsystem_singlenode

  echo "==== host all all 0.0.0.0/0 trust"
  echo "host all  all 0.0.0.0/0 trust" >> /data/master/gpsne-1/pg_hba.conf

  echo "==== RESTARTER"
  MASTER_DATA_DIRECTORY=/data/master/gpsne-1/ gpstop -a
  MASTER_DATA_DIRECTORY=/data/master/gpsne-1/ gpstart -a
popd

echo "==== DONE!"

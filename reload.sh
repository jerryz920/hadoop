#!/bin/bash

master=1
workers=`seq 2 4`;

#mvn package -Pdist,native -DskipTests -Dtar
#if [ $? -ne 0 ]; then
# exit 1;
#fi

for n in $master; do
docker-machine ssh hdfs-$n "source .bashrc; if test -d /opt/hadoop-2.8.0 ; then sudo /opt/hadoop-2.8.0/sbin/stop-all.sh; fi"
done

for n in $master; do
docker-machine ssh hdfs-$n "source .bashrc; /opt/hadoop-2.8.0/bin/hadoop namenode -format -force /opt/hdfs/name; rm -rf /opt/hdfs/data/*; rm -rf /opt/hdfs/tmp/*; if test -d /opt/hadoop-2.8.0 ; then  /opt/hadoop-2.8.0/sbin/start-all.sh; fi"
done

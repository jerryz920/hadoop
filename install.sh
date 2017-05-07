#!/bin/bash


mvn package -Pdist,native -DskipTests -Dtar
if [ $? -ne 0 ]; then
 exit 1;
fi
sudo /opt/hadoop-2.8.0/sbin/stop-all.sh
sudo allcp.sh hadoop-dist/target/hadoop-2.8.0.tar.gz /opt/
allrun.sh "sudo rm -rf /opt/hadoop-2.8.0/"
allrun.sh "cd /opt/; sudo tar xf hadoop-2.8.0.tar.gz"
sudo cp /opt/hadoop-unmodified/etc/hadoop/* /opt/hadoop-2.8.0/etc/hadoop/
cd /opt/hadoop-2.8.0/etc/hadoop/
sudo bash distribute.sh
cd /opt/hadoop-2.8.0/
sudo sbin/start-all.sh


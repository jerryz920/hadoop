#!/bin/bash

master=1
workers=`seq 2 4`;

#mvn package -Pdist,native -DskipTests -Dtar
#if [ $? -ne 0 ]; then
# exit 1;
#fi

for n in $master; do
docker-machine ssh hdfs-$n "if test -f /opt/hadoop-2.8.0 ; then  sudo /opt/hadoop-2.8.0/sbin/stop-all.sh; fi"
done
bash allcp.sh hadoop-dist/target/hadoop-2.8.0.tar.gz 
bash allrun.sh "
	sudo chown -R ubuntu /opt;
	sudo mv hadoop-2.8.0.tar.gz /opt/;
	if test -d /opt/hadoop-2.8.0/; then rm -rf /opt/hadoop-2.8.0/; fi
	cd /opt/;
	tar xf hadoop-2.8.0.tar.gz;
	if test -d socc-conf; then  rm -rf socc-conf; fi
"
bash allcp.sh socc-conf

DEST_CONF=/opt/hadoop-2.8.0/etc/hadoop/

for n in $master; do
docker-machine ssh hdfs-$n "
cd socc-conf/hadoop/;
sed 's/MYDOMAINNAME/hdfs-$n/' hdfs-site.xml.master > $DEST_CONF/hdfs-site.xml;
sed 's/MYDOMAINNAME/hdfs-$n/' mapred-site.xml.tapcon > $DEST_CONF/mapred-site.xml;
sed 's/MYDOMAINNAME/hdfs-$n/' yarn-site.xml.tapcon > $DEST_CONF/yarn-site.xml;
cp core-site.xml yarn-env.sh container-executor.cfg hadoop-env.sh ssl-server.xml ssl-client.xml $DEST_CONF/
";
done
for n in $workers; do
  # core-site hard coded hdfs-1 as master
docker-machine ssh hdfs-$n "
  cd socc-conf/hadoop/;
  sed 's/MYDOMAINNAME/hdfs-$n/' hdfs-site.xml.worker > $DEST_CONF/hdfs-site.xml;
  sed 's/MYDOMAINNAME/hdfs-$n/' mapred-site.xml.tapcon > $DEST_CONF/mapred-site.xml;
  sed 's/MYDOMAINNAME/hdfs-$n/' yarn-site.xml.tapcon > $DEST_CONF/yarn-site.xml;
  cp core-site.xml yarn-env.sh container-executor.cfg hadoop-env.sh ssl-server.xml ssl-client.xml $DEST_CONF/
";
done

for n in $master; do
docker-machine ssh hdfs-$n "if test -f /opt/hadoop-2.8.0 ; then  sudo /opt/hadoop-2.8.0/sbin/start-all.sh; fi"
done
bash allcp.sh bashrc
bash allrun.sh mv bashrc .bashrc



#sudo cp /opt/hadoop-unmodified/etc/hadoop/* /opt/hadoop-2.8.0/etc/hadoop/
#cd /opt/hadoop-2.8.0/etc/hadoop/
#sudo bash distribute.sh
#cd /opt/hadoop-2.8.0/
#sudo sbin/start-all.sh


#!/bin/bash

master=1
workers=`seq 2 4`;

#mvn package -Pdist,native -DskipTests -Dtar
#if [ $? -ne 0 ]; then
# exit 1;
#fi

bash allcp.sh sshconfig
bash allrun.sh "mkdir -p .ssh; mv sshconfig .ssh/config;"

for n in $master; do
docker-machine ssh hdfs-$n "if test -d /opt/hadoop-2.8.0 ; then  /opt/hadoop-2.8.0/sbin/stop-all.sh; fi"
done
bash allcp.sh hadoop-dist/target/hadoop-2.8.0.tar.gz 
bash allrun.sh "
	sudo chown -R ubuntu /opt;
	sudo mv hadoop-2.8.0.tar.gz /opt/;
	if test -d /opt/hadoop-2.8.0/; then rm -rf /opt/hadoop-2.8.0/; fi
	cd /opt/;
	tar xf hadoop-2.8.0.tar.gz;
	if test -d socc-conf; then  rm -rf socc-conf; fi
	mkdir -p /opt/hdfs/name /opt/hdfs/data /opt/hdfs/tmp;
"
bash allcp.sh socc-conf

DEST_CONF=/opt/hadoop-2.8.0/etc/hadoop/

for n in $master; do
docker-machine ssh hdfs-$n "
cd socc-conf/hadoop/;
sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' hdfs-site.xml.master > $DEST_CONF/hdfs-site.xml;
sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' mapred-site.xml.tapcon > $DEST_CONF/mapred-site.xml;
sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' yarn-site.xml.tapcon > $DEST_CONF/yarn-site.xml;
cp slaves core-site.xml yarn-env.sh container-executor.cfg hadoop-env.sh ssl-server.xml ssl-client.xml $DEST_CONF/
";
done
for n in $workers; do
  # core-site hard coded hdfs-1 as master
docker-machine ssh hdfs-$n "
  cd socc-conf/hadoop/;
  sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' hdfs-site.xml.worker > $DEST_CONF/hdfs-site.xml;
  sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' mapred-site.xml.tapcon > $DEST_CONF/mapred-site.xml;
  sed 's/MYDOMAINNAME/hdfs-$n.latte.org/' yarn-site.xml.tapcon > $DEST_CONF/yarn-site.xml;
  cp core-site.xml yarn-env.sh container-executor.cfg hadoop-env.sh ssl-server.xml ssl-client.xml $DEST_CONF/
";
done

getip()
{
  docker-machine ssh $1 ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'
}

cat > hosts <<EOF
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

for n in $master $workers; do
  echo "`getip hdfs-$n` hdfs-$n hdfs-$n.latte.org" >> hosts
done

bash allcp.sh hosts
bash allrun.sh "
sudo mv hosts /etc/hosts
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:webupd8team/java
sudo apt-add-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
"


for n in $master; do
docker-machine ssh hdfs-$n "hadoop namenode -format /opt/name -force; if test -d /opt/hadoop-2.8.0 ; then  /opt/hadoop-2.8.0/sbin/start-all.sh; fi"
done
bash allcp.sh bashrc
bash allrun.sh mv bashrc .bashrc


rm -f hdfs hdfs.pub
ssh-keygen -f hdfs -t rsa -N ''
bash allcp.sh hdfs
bash allcp.sh hdfs.pub
bash allrun.sh "
chmod 600 hdfs;
sudo mkdir -p /root/.ssh;
sudo cp hdfs /root/.ssh/id_rsa;
sudo su -c 'cat hdfs.pub >> /root/.ssh/authorized_keys'; 
sudo cp hdfs.pub /root/.ssh/id_rsa.pub;"
bash allrun.sh "
chmod 600 hdfs; 
mv hdfs .ssh/id_rsa;
cat hdfs.pub >> .ssh/authorized_keys;
mv hdfs.pub .ssh/id_rsa.pub;"


#sudo cp /opt/hadoop-unmodified/etc/hadoop/* /opt/hadoop-2.8.0/etc/hadoop/
#cd /opt/hadoop-2.8.0/etc/hadoop/
#sudo bash distribute.sh
#cd /opt/hadoop-2.8.0/
#sudo sbin/start-all.sh


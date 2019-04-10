
cp hdfs-site.xml.master hdfs-site.xml
sed -i 's/MYDOMAINNAME/hdfs-1/' hdfs-site.xml
sed 's/MYDOMAINNAME/hdfs-1/' mapred-site.xml.tapcon > mapred-site.xml
sed 's/MYDOMAINNAME/hdfs-1/' yarn-site.xml.tapcon > yarn-site.xml
for n in hdfs-2 hdfs-3 hdfs-4; do
  scp hdfs-site.xml.worker $n:/opt/hadoop-2.8.0/etc/hadoop/hdfs-site.xml
  ssh $n "sed -i 's/MYDOMAINNAME/$n/' /opt/hadoop-2.8.0/etc/hadoop/hdfs-site.xml"
  scp mapred-site.xml.tapcon $n:/opt/hadoop-2.8.0/etc/hadoop/mapred-site.xml
  ssh $n "sed -i 's/MYDOMAINNAME/$n/' /opt/hadoop-2.8.0/etc/hadoop/mapred-site.xml"
  scp core-site.xml $n:/opt/hadoop-2.8.0/etc/hadoop/
  scp yarn-site.xml.tapcon $n:/opt/hadoop-2.8.0/etc/hadoop/yarn-site.xml
  ssh $n "sed -i 's/MYDOMAINNAME/$n/' /opt/hadoop-2.8.0/etc/hadoop/yarn-site.xml"
  scp yarn-env.sh container-executor.cfg hadoop-env.sh ssl-server.xml ssl-client.xml $n:/opt/hadoop-2.8.0/etc/hadoop/
done

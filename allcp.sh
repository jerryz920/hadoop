for n in `seq 1 4`; do

docker-machine scp -r $1 hdfs-$n:

done

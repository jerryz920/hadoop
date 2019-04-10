for n in `seq 1 4`; do

docker-machine scp $1 hdfs-$n:

done

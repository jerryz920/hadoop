
for n in `seq 1 4`;
do
docker-machine ssh hdfs-$n "$@"
done

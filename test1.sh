#!/bin/bash
echo "Generating Random Data of ASCII values"
cd /exports/projects/hadoop-3.2.1
bin/hadoop fs -rm /home/input/generatedfile
bin/hadoop fs -rm -r /home/output
cd /exports/projects/hadoop-3.2.1
./gensort -a 320000000 ~/linsort/64/generatedfile
bin/hadoop fs -put ~/linsort/64/generatedfile /home/input/.
cd /exports/projects/spark-3.0.0-preview2-bin-hadoop3.2
echo "Sorting data"
javac -cp jars/spark-core_2.12-3.0.0-preview2.jar:jars/scala-library-2.12.10.jar SparkSort.java
jar cvf SparkSort.jar SparkSort*.class
bin/spark-submit --class SparkSort --master yarn --deploy-mode cluster --driver-memory 4g --executor-memory 2g --executor-cores 1 SparkSort.jar
echo "Done Sorting, Validating data"
cd /exports/projects/hadoop-3.2.1
mkdir results/
bin/hadoop fs -get /home/output/. /exports/projects/hadoop-3.2.1/results/
cd /exports/projects/hadoop-3.2.1/results/output/
cp /exports/projects/hadoop-3.2.1/valsort /exports/projects/hadoop-3.2.1/results/output/
FILES=/exports/projects/hadoop-3.2.1/results/output/data.out/part*
for f in $FILES
do
  echo "Processing $f file..."
  ./valsort $f
done
cd /exports/projects/hadoop-3.2.1
rm -rf results/

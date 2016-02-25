#!/usr/bin/env bash

echo ### [1. run zookeeper] ############################################################################################################
cd $HOME/zookeeper-3.4.8/bin
zkServer.sh start

echo ### [2. run apache-kafka] ############################################################################################################
cd $HOME/kafka
bin/kafka-server-start.sh ./config/server.properties &		# bin/zookeeper-server-stop.sh
bin/kafka-topics.sh --create --topic incoming --zookeeper 192.168.82.150:2181 --partitions 1 --replication-factor 1
#bin/kafka-topics.sh --delete --topic incoming --zookeeper 192.168.82.150:2181
#Created topic "incoming"
#bin/kafka-console-consumer.sh --topic incoming --zookeeper 192.168.82.150:2181 
#bin/kafka-console-producer.sh --topic incoming --broker 192.168.82.150:9092
#testaaa
#bin/kafka-topics.sh --zookeeper 192.168.82.150:2181 --list

echo ### [3. run apache-storm] ############################################################################################################
cd $HOME/apache-storm-0.10.0/bin
storm nimbus &
storm supervisor &
storm ui &
storm logviewer &

#http://192.168.82.150:8080/index.html
#ll /Users/dhong/apache-storm-0.10.0/logs
#http://192.168.82.150:8000/log?file=storm-kafka-topology-2-1456339787-worker-6700.log

echo ### [4. run hadoop] ############################################################################################################
cd $HOME/hadoop-2.7.2
bin/hdfs namenode -format
bin/hdfs dfs -mkdir /user
bin/hdfs dfs -mkdir /user/dhong
# sbin/start-dfs.sh  # sbin/stop-dfs.sh
#sbin/start-yarn.sh
sbin/start-all.sh # sbin/stop-all.sh

#http://192.168.82.150:8088/cluster/nodes

echo ### [5. run apache solr] ############################################################################################################
cd $HOME/solr-5.3.1
bin/solr start # bin/solr stop
bin/solr create -c collection1

#http://192.168.82.150:8983/solr/#/collection1
#http://192.168.82.150:8983/solr/#/collection1/schema-browser?field=value

echo ### [6. run mongodb] ############################################################################################################
#mongod
#bin/mongo
#> use storm
#> db.createCollection("collection1");

# https://github.com/mrvautin/adminMongo

echo ### [deploy test topology] ############################################################################################################
cd /vagrant
mvn clean package

storm jar target/stormkafka-0.0.1-SNAPSHOT.jar com.vishnu.storm.Topology
#storm deactivate storm-kafka-topology
#storm kill storm-kafka-topology
#storm list

# http://192.168.82.150:8080/index.html

echo ### [test topology] ############################################################################################################
cd $HOME/kafka
bin/kafka-console-consumer.sh --zookeeper 192.168.82.150:2181 --topic incoming --from-beginning

bin/kafka-console-producer.sh --topic incoming --broker 192.168.82.150:9092
hdfs this message goes to hdfs
mongo id:1 value:mongodb_message
solr id:1 value:solr_message
solr id:2 value:solr_message

#hdfs -> http://192.168.82.150:50070/explorer.html#/from_storm
#solr -> http://192.168.82.150:8983/solr/#/collection1/query


#!/usr/bin/env bash

# change hosts
echo '' >> /etc/hosts
echo '# for vm' >> /etc/hosts
echo '127.0.0.1	local1.test.com' >> /etc/hosts
echo '127.0.0.1	local2.test.com' >> /etc/hosts

echo "Reading config...." >&2
source /vagrant/setup.rc

HOME=/home/vagrant

apt-get -y -q update 
apt-get install software-properties-common python-software-properties -y
add-apt-repository ppa:webupd8team/java -y 
apt-get -y -q update 
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections 
apt-get -y -q install oracle-java8-installer 
apt-get purge openjdk* -y
apt-get install oracle-java8-set-default
apt-get install wget curl unzip -y
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
apt-get install maven -y
#apt-get purge maven2 -y

echo '' >> $HOME/.bashrc
echo 'export PATH=$PATH:.:$HOME/apache-storm-0.10.0/bin' >> $HOME/.bashrc
echo 'export JAVA_HOME='$JAVA_HOME >> $HOME/.bashrc
echo 'export HADOOP_PREFIX=/home/vagrant/hadoop-2.7.2' >> $HOME/.bashrc

PATH=$PATH:.:$HOME/apache-storm-0.10.0/bin

echo ### [1. install zookeeper] ############################################################################################################
cd $HOME
wget http://apache.arvixe.com/zookeeper/stable/zookeeper-3.4.8.tar.gz
tar xvzf zookeeper-3.4.8.tar.gz
cd zookeeper-3.4.8
cp conf/zoo_sample.cfg conf/zoo.cfg
echo '' >> conf/zoo.cfg
echo 'local1.test.com=zookeeper1:2888:3888' >> conf/zoo.cfg
echo 'local2.test.com=zookeeper2:2888:3888' >> conf/zoo.cfg

mkdir -p logs
chown -Rf vagrant:vagrant $HOME/zookeeper-3.4.8
chown -Rf vagrant:vagrant /tmp/zookeeper

echo ### [2. install apache-kafka] ############################################################################################################
cd $HOME
wget http://apache.tt.co.kr/kafka/0.8.2.0/kafka_2.10-0.8.2.0.tgz
tar -xzf kafka_2.10-0.8.2.0.tgz
mv kafka_2.10-0.8.2.0 kafka
cd kafka

chown -Rf vagrant:vagrant $HOME/kafka solr-5.3.1
chown -Rf vagrant:vagrant /tmp/kafka-logs

echo ### [3. install apache-storm] ############################################################################################################
cd $HOME
wget http://apache.arvixe.com/storm/apache-storm-0.10.0/apache-storm-0.10.0.zip
unzip apache-storm-0.10.0.zip
cd apache-storm-0.10.0
echo '' >> conf/storm.yaml
echo 'storm.zookeeper.servers:' >> conf/storm.yaml
echo '    - "local1.test.com"' >> conf/storm.yaml
echo '    - "local2.test.com"' >> conf/storm.yaml
echo 'nimbus.host: "127.0.0.1"' >> conf/storm.yaml

chown -Rf vagrant:vagrant $HOME/apache-storm-0.10.0

echo ### [4. install hadoop] ############################################################################################################
cd $HOME
wget wget http://apache.arvixe.com/hadoop/common/current/hadoop-2.7.2.tar.gz
tar -zxvf hadoop-2.7.2.tar.gz
cd hadoop-2.7.2

cp -rf /vagrant/etc/hadoop/core-site.xml $HOME/hadoop-2.7.2/etc/hadoop
cp -rf /vagrant/etc/hadoop/hdfs-site.xml $HOME/hadoop-2.7.2/etc/hadoop
cp -rf /vagrant/etc/hadoop/mapred-site.xml $HOME/hadoop-2.7.2/etc/hadoop
cp -rf /vagrant/etc/hadoop/yarn-site.xml $HOME/hadoop-2.7.2/etc/hadoop

cp $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh_bak
sed -i "s/export JAVA_HOME/#export JAVA_HOME/g" $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh
echo 'export JAVA_HOME='$JAVA_HOME >> $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh_work
cat $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh >> $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh_work
mv $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh_work $HOME/hadoop-2.7.2/etc/hadoop/hadoop-env.sh

ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
echo '' >> /etc/ssh/ssh_config
echo '    ForwardX11 no' >> /etc/ssh/ssh_config
echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config
# chmod +rrr ssh_config

chown -Rf vagrant:vagrant $HOME/hadoop-2.7.2

echo ### [5. install apache solr] ############################################################################################################
cd $HOME
curl -O http://apache.arvixe.com/lucene/solr/5.3.1/solr-5.3.1.zip
unzip solr-5.3.1.zip
cd solr-5.3.1
mkdir -p server/logs
mkdir -p server/solr/collection1
cp -r server/solr/configsets/basic_configs/conf/ server/solr/collection1/conf
cp -r /vagrant/etc/solr/schema.xml server/solr/collection1/conf/schema.xml

chown -Rf vagrant:vagrant $HOME/solr-5.3.1

echo ### [6. install mongodb] ############################################################################################################
apt-get install -y mongodb
mkdir -p /data/db
chown -Rf vagrant:vagrant /data/db

cd $HOME
sudo chown -Rf vagrant:vagrant apache-storm-0.10.0 kafka/ zookeeper-3.4.8 hadoop-2.7.2 solr-5.3.1 .ssh

echo #####################################################################################################################################
echo ### installation finished ###########################################################################################################
echo #### http://192.168.82.150:8080
echo #### http://192.168.82.150:8983/solr/#/collection1/query
echo #### http://192.168.82.150:8088/cluster/nodes
echo #### http://192.168.82.150:50070
echo #####################################################################################################################################
echo ### After execute 'vagrant ssh', run each of apps as follows. #######################################################################
echo #####################################################################################################################################

exit 0

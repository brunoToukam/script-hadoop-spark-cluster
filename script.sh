#!/bin/bash

echo "Installation de hadoop et spark"

sudo yum -y update
echo "*********************************************************************************"

#Configuration du /etc/hosts
echo "Entrez l'adresse du master"
read masteraddress
echo "$masteraddress" | sudo tee -a /etc/hosts
i=0
slaves=()
echo "Entrez le nombre de slaves"
read nombreslaves
while [ $i -lt $nombreslaves ]
do
        echo "entrez l'adresse du slave $((i+1))"
        read adresse
        echo "$adresse slave$((i+1))" | sudo tee -a /etc/hosts
	slaves[$i]="$adresse"
        i=$((i+1))
done

echo "*********************************************************************************"

#Création de la clé ssh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 authorized_keys
echo "partage de la clé ssh aux slaves"
p=0
while [ $p -lt $nombreslaves ]
do
	echo "Entrez le nom du slave$((p+1))"
	read username
        ssh-copy-id -i ~/.ssh/id_rsa.pub $username@${slaves[$p]}
        p=$((p+1))
done

echo "*********************************************************************************"

#Installation de java 8
sudo yum -y install java-1.8.0-openjdk-devel
echo "*********************************************************************************"

#Installation de hadoop 2.7.7
cd ~
wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
tar zxf hadoop-2.7.7.tar.gz
mv hadoop-2.7.7 hadoop
rm hadoop-2.7.7.tar.gz
echo "*********************************************************************************"

#Configuration des variables d'environnment java et hadoop
echo "#Variables env" >> ~/.bashrc 
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/.bashrc
echo "export HADOOP_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_INSTALL=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export YARN_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" >> ~/.bashrc
echo "export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin" >> ~/.bashrc
echo "*********************************************************************************"

#Création du core-site.xml
touch ~/InstallationCluster/config/core-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ~/InstallationCluster/config/core-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/InstallationCluster/config/core-site.xml
echo -e "\n" >> ~/InstallationCluster/config/core-site.xml
echo -e "\n" >> ~/InstallationCluster/config/core-site.xml

echo "<configuration>" >> ~/InstallationCluster/config/core-site.xml
echo "  <property>" >> ~/InstallationCluster/config/core-site.xml
echo "    <name>fs.default.name</name>" >> ~/InstallationCluster/config/core-site.xml
echo "    <value>hdfs://$masteraddress:8020</value>" >> ~/InstallationCluster/config/core-site.xml
echo "  </property>" >> ~/InstallationCluster/config/core-site.xml
echo "</configuration>" >> ~/InstallationCluster/config/core-site.xml
echo "*********************************************************************************"

#Création du hdfs-site.xml
mkdir -p ~/hadoop_store/hdfs/namenode
mkdir -p ~/hadoop_store/hdfs/datanode
chmod 755 ~/hadoop_store/hdfs/datanode
touch ~/InstallationCluster/config/hdfs-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ~/InstallationCluster/config/hdfs-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/InstallationCluster/config/hdfs-site.xml
echo -e "\n" >> ~/InstallationCluster/config/hdfs-site.xml
echo -e "\n" >> ~/InstallationCluster/config/hdfs-site.xml

echo "<configuration>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "  <property>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "    <name>dfs.namenode.name.dir</name>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "    <value>file://~/hadoop_store/hdfs/namenode</value>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "  </property>" >> ~/InstallationCluster/config/hdfs-site.xml

echo "  <property>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "    <name>dfs.datanode.data.dir</name>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "    <value>file://~/hadoop_store/hdfs/datanode</value>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "  </property>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "</configuration>" >> ~/InstallationCluster/config/hdfs-site.xml
echo "*********************************************************************************"

#Création du mapred-site.xml
touch ~/InstallationCluster/config/mapred-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ~/InstallationCluster/config/mapred-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/InstallationCluster/config/mapred-site.xml
echo -e "\n" >> ~/InstallationCluster/config/mapred-site.xml
echo -e "\n" >> ~/InstallationCluster/config/mapred-site.xml

echo "<configuration>" >> ~/InstallationCluster/config/mapred-site.xml
echo "  <property>" >> ~/InstallationCluster/config/mapred-site.xml
echo "    <name>mapreduce.framework.name</name>" >> ~/InstallationCluster/config/mapred-site.xml
echo "    <value>yarn</value>" >> ~/InstallationCluster/config/mapred-site.xml
echo "  </property>" >> ~/InstallationCluster/config/mapred-site.xml
echo "</configuration>" >> ~/InstallationCluster/config/mapred-site.xml
echo "*********************************************************************************"

#Création du yarn-site.xml
touch ~/InstallationCluster/config/yarn-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ~/InstallationCluster/config/yarn-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/InstallationCluster/config/yarn-site.xml
echo -e "\n" >> ~/InstallationCluster/config/yarn-site.xml
echo -e "\n" >> ~/InstallationCluster/config/yarn-site.xml

echo "<configuration>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.resourcemanager.resource-tracker.address</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>$masteraddress:8025</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml

echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.resourcemanager.scheduler.address</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>$masteraddress:8030</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml

echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.resourcemanager.address</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>$masteraddress:8050</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml

echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.nodemanager.aux-services</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>mapreduce_shuffle</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml

echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>org.apache.hadoop.mapred.ShuffleHandler</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml

echo "  <property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <name>yarn.nodemanager.disk-health-checker.min-healthy-disks</name>" >> ~/InstallationCluster/config/yarn-site.xml
echo "    <value>0</value>" >> ~/InstallationCluster/config/yarn-site.xml
echo "  </property>" >> ~/InstallationCluster/config/yarn-site.xml
echo "</configuration>" >> ~/InstallationCluster/config/yarn-site.xml



i=0
while [ $i -lt $nombreslaves ]
do
	echo ${slaves[$i]} >> ~/hadoop/etc/hadoop/slaves
        i=$((i+1))
done
echo "*********"


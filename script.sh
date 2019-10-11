#!/bin/bash

# Author BrunoToukam

echo "Installation de hadoop et spark"
cd ~
sudo yum -y update
echo "*********************************************************************************"

#Configuration du /etc/hosts
echo "Entrez l'adresse du master"
read masteraddress
echo "$masteraddress master" | sudo tee -a /etc/hosts
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
echo "make ssh-key and share into slaves"

#Création de la clé ssh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
echo "partage de la clé ssh aux slaves"
p=0
names=()
while [ $p -lt $nombreslaves ]
do
	echo "Entrez le nom du slave$((p+1))"
	read username
	names[$p]="$username"
        ssh-copy-id -i ~/.ssh/id_rsa.pub $username@${slaves[$p]}
        p=$((p+1))
done

echo "*********************************************************************************"

#Installation de java 8
sudo yum -y install java-1.8.0-openjdk-devel
echo "*********************************************************************************"

#Installation de hadoop 2.7.7
wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
tar zxf hadoop-2.7.7.tar.gz
mv hadoop-2.7.7 hadoop
rm hadoop-2.7.7.tar.gz
echo "*********************************************************************************"

#Configuration des variables d'environnment java et hadoop
echo "#Variables env" >> ~/.bashrc 
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/.bashrc
echo "export HADOOP_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_INSTALL=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export YARN_HOME=$HOME/hadoop" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HOME/hadoop/lib/native" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/hadoop/sbin:$HOME/hadoop/bin" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=$HOME/hadoop/etc/hadoop/" >> ~/.bashrc

source ~/.bashrc

echo "*********************************************************************************"

#Creation du core-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' > ~/hadoop/etc/hadoop/core-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/hadoop/etc/hadoop/core-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/core-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/core-site.xml

echo "<configuration>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "  <property>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "    <name>fs.default.name</name>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "    <value>hdfs://$masteraddress:8020</value>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "</configuration>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "*********************************************************************************"

#Creation du hdfs-site.xml
mkdir -p ~/hadoop_store/hdfs/namenode
mkdir -p ~/hadoop_store/hdfs/datanode
chmod 755 ~/hadoop_store/hdfs/datanode

echo '<?xml version="1.0" encoding="UTF-8"?>' > ~/hadoop/etc/hadoop/hdfs-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/hdfs-site.xml

echo "<configuration>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "  <property>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "    <name>dfs.namenode.name.dir</name>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "    <value>file:$HOME/hadoop_store/hdfs/namenode</value>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/hdfs-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "    <name>dfs.datanode.data.dir</name>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "    <value>file:$HOME/hadoop_store/hdfs/datanode</value>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "</configuration>" >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo "*********************************************************************************"

#Creation du mapred-site.xml
touch ~/hadoop/etc/hadoop/mapred-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' > ~/hadoop/etc/hadoop/mapred-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/hadoop/etc/hadoop/mapred-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/mapred-site.xml

echo "<configuration>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "  <property>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "    <name>mapreduce.framework.name</name>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "    <value>yarn</value>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "</configuration>" >> ~/hadoop/etc/hadoop/mapred-site.xml
echo "*********************************************************************************"

#Creation du yarn-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' > ~/hadoop/etc/hadoop/yarn-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> ~/hadoop/etc/hadoop/yarn-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo -e "\n" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "<configuration>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.resourcemanager.resource-tracker.address</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>$masteraddress:8025</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.resourcemanager.scheduler.address</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>$masteraddress:8030</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.resourcemanager.address</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>$masteraddress:8050</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.nodemanager.aux-services</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>mapreduce_shuffle</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>org.apache.hadoop.mapred.ShuffleHandler</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml

echo "  <property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <name>yarn.nodemanager.disk-health-checker.min-healthy-disks</name>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "    <value>0</value>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "  </property>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "</configuration>" >> ~/hadoop/etc/hadoop/yarn-site.xml
echo "*********************************************************************************"

#Configuration des slaves
echo > ~/hadoop/etc/hadoop/slaves
k=0
while [ $k -lt $nombreslaves ]
do
	if [ $k -eq 0 ]
	then
		echo ${slaves[$k]} > ~/hadoop/etc/hadoop/slaves
	else
		echo ${slaves[$k]} >> ~/hadoop/etc/hadoop/slaves
	fi
        k=$((k+1))
done
echo "*********************************************************************************"


#Slaves configuration
k=0
while [ $k -lt $nombreslaves ]
do
        ssh-copy-id -i ~/.ssh/id_rsa.pub ${names[$k]}@${slaves[$k]}
	ssh -t ${names[$k]}@${slaves[$k]} '
	cd ~;
	echo -e "\n"
	echo "Working on ${names[$k]}";	

	sudo yum -y update;


	#Installation de java 8;
	sudo yum -y install java-1.8.0-openjdk-devel;


	#Installation de hadoop 2.7.7;
	wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz;
	tar zxf hadoop-2.7.7.tar.gz;
	mv hadoop-2.7.7 hadoop;
	rm hadoop-2.7.7.tar.gz;


	#Configuration des variables d environnment java et hadoop;
	echo "#Variables env" >> ~/.bashrc;
	echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/.bashrc;
	echo "export HADOOP_HOME=$HOME/hadoop" >> ~/.bashrc;
	echo "export HADOOP_INSTALL=$HOME/hadoop" >> ~/.bashrc;
	echo "export HADOOP_MAPRED_HOME=$HOME/hadoop" >> ~/.bashrc;
	echo "export HADOOP_COMMON_HOME=$HOME/hadoop" >> ~/.bashrc;
	echo "export HADOOP_HDFS_HOME=$HOME/hadoop" >> ~/.bashrc;
	echo "export YARN_HOME=$HOME/hadoop" >> ~/.bashrc;
	echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HOME/hadoop/lib/native" >> ~/.bashrc;
	echo "export PATH=$PATH:$HOME/hadoop/sbin:$HOME/hadoop/bin" >> ~/.bashrc;


	source ~/.bashrc;


	mkdir -p ~/hadoop_store/hdfs/namenode;
	mkdir -p ~/hadoop_store/hdfs/datanode;
	chmod 755 ~/hadoop_store/hdfs/datanode;

	echo "exit ${names[$k]}";
	exit;

	bash -l'	
		
        k=$((k+1))
done
echo "*********************************************************************************"


echo "Retour au master"
echo "les adresses ${slaves[@]}"
echo "les hostnames ${names[@]}"
echo "*********************************************************************************"

#Copie des config hadoop dans les slaves
p=0
while [ $p -lt $nombreslaves ]
do
	scp ~/hadoop/etc/hadoop/core-site.xml \
	~/hadoop/etc/hadoop/hdfs-site.xml \
	~/hadoop/etc/hadoop/mapred-site.xml \
	~/hadoop/etc/hadoop/yarn-site.xml \
	${names[$p]}@${slaves[$p]}:~/hadoop/etc/hadoop/.
        p=$((p+1))
done
echo "*********************************************************************************"


#Formater le namenode
echo "Formating namenode"
hdfs namenode -format

source ~/.bashrc

echo "Starting dfs"
start-dfs.sh

echo "starting yarn"
start-yarn.sh

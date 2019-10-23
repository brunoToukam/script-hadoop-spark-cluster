#!/bin/bash

# Author BrunoToukam


cd ~
sudo yum -y update
echo "*********************************************************************************"

# Config for barner
sudo yum -y install epel-release
sudo yum -y install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo yum -y update
sudo snap install figlet --edge
sudo yum -y install figlet



figlet Installation de hadoop-2.7.7


#Configuration du /etc/hosts
echo "Entrez l'adresse du master"
read masteraddress
#echo "Entrez le nom du master"
#read mastername
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
echo "    <name>fs.defaultFS</name>" >> ~/hadoop/etc/hadoop/core-site.xml
echo "    <value>hdfs://$masteraddress:9000</value>" >> ~/hadoop/etc/hadoop/core-site.xml
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

# Configuration des masters
touch ~/hadoop/etc/hadoop/masters
echo $masteraddress > ~/hadoop/etc/hadoop/masters
echo "*********************************************************************************"

#Configuration des slaves
touch ~/hadoop/etc/hadoop/slaves
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

# archiver hadoop pour l'envoyer aux slaves
cd ~
tar czf hadoop.tar.gz hadoop

#Copie des config hadoop dans les slaves
p=0
while [ $p -lt $nombreslaves ]
do
	scp hadoop.tar.gz ${names[$p]}@${slaves[$p]}:~/.
        p=$((p+1))
done
rm hadoop.tar.gz
echo "*********************************************************************************"



#Slaves configuration
k=0
while [ $k -lt $nombreslaves ]
do
	ssh -t ${names[$k]}@${slaves[$k]} '
	cd ~;
	sudo yum -y update;


	#Installation de java 8;
	sudo yum -y install java-1.8.0-openjdk-devel;


	#Configuration des variables d environnment java et hadoop;
	echo "#Variables env" >> ~/.bashrc;
	echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/.bashrc;
	

	source ~/.bashrc;

	mkdir -p ~/hadoop_store/hdfs/namenode;
	mkdir -p ~/hadoop_store/hdfs/datanode;
	chmod 755 ~/hadoop_store/hdfs/datanode;

	tar zxf hadoop.tar.gz;
	rm hadoop.tar.gz;

	exit

	bash -l'	
		
        k=$((k+1))
done
echo "*********************************************************************************"


echo "Retour au master"

#Formater le namenode
echo "Formating namenode"
hdfs namenode -format

source ~/.bashrc

echo "Starting dfs"
start-dfs.sh

echo "starting yarn"
start-yarn.sh



echo "*********************************************************************************"
figlet Installation de Spark-2.4.4
echo "*********************************************************************************"

cd ~
sudo yum -y update
echo "*********************************************************************************"


# Installer scala
cd ~
wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm
sudo yum -y install scala-2.11.8.rpm

echo "*********************************************************************************"

#Installation de spark-2.4.4
wget https://www-eu.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
tar zxf spark-2.4.4-bin-hadoop2.7.tgz
mv spark-2.4.4-bin-hadoop2.7 spark
rm spark-2.4.4-bin-hadoop2.7.tgz


echo "*********************************************************************************"

#Configuration des variables d'environnment spark
echo "export SPARK_HOME=$HOME/spark" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/spark/sbin:$HOME/spark/bin" >> ~/.bashrc
echo "export export SPARK_HOME=$HOME/spark" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> ~/.bashrc
echo "export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> ~/.bashrc
echo "export SPARK_WORKER_DIR=$HOME/spark/work" >> ~/.bashrc
echo "export SPARK_LOG_DIR=$HOME/spark/log" >> ~/.bashrc
echo "export SPARK_MASTER_IP=$masteraddress" >> ~/.bashrc


source ~/.bashrc

echo "*********************************************************************************"
#Configuration de spark-env.sh
cp ~/spark/conf/spark-env.sh.template ~/spark/conf/spark-env.sh

#echo "SCALA_HOME=" >> ~/spark/conf/spark-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/spark/conf/spark-env.sh

echo "*********************************************************************************"

#Configuration des slaves
touch ~/spark/conf/slaves
k=0
while [ $k -lt $nombreslaves ]
do
	if [ $k -eq 0 ]
	then
		echo ${slaves[$k]} > ~/spark/conf/slaves
	else
		echo ${slaves[$k]} >> ~/spark/conf/slaves
	fi
        k=$((k+1))
done

echo "*********************************************************************************"

# archiver hadoop pour l'envoyer aux slaves
cd ~
tar czf spark.tar.gz spark

#Copie des config hadoop dans les slaves
p=0
while [ $p -lt $nombreslaves ]
do
	scp spark.tar.gz ${names[$p]}@${slaves[$p]}:~/.
        p=$((p+1))
done

rm spark.tar.gz
echo "*********************************************************************************"


#Slaves configuration
k=0
while [ $k -lt $nombreslaves ]
do
	ssh -t ${names[$k]}@${slaves[$k]} '
	cd ~;
	sudo yum -y update;
	
	tar zxf spark.tar.gz;
	rm spark.tar.gz;
	exit
	bash -l'	
		
        k=$((k+1))
done
echo "*********************************************************************************"


echo "Retour au master"
cd ~
# Lancer spark
start-all.sh


#!/bin/bash

# Author BrunoToukam


cd ~
sudo yum -y update
echo "*********************************************************************************"

echo "Installation de hadoop"


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
ssh-keygen -t rsa -P ""
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

# Installer scala
cd ~
wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm
sudo yum -y install scala-2.11.8.rpm

echo "*********************************************************************************"

#Installation de hadoop 2.7.7
wget https://www-eu.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
tar zxf spark-2.4.4-bin-hadoop2.7.tgz
mv spark-2.4.4-bin-hadoop2.7 spark
rm spark-2.4.4-bin-hadoop2.7.tgz


echo "*********************************************************************************"

#Configuration des variables d'environnment java et hadoop
echo "#Variables env" >> ~/.bashrc 
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/.bashrc
echo "export SPARK_HOME=$HOME/spark" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/spark/bin:$HOME/spark/sbin" >> ~/.bashrc

#echo "export HADOOP_CONF_DIR=$HOME/hadoop/etc/hadoop/" >> ~/.bashrc

source ~/.bashrc

echo "*********************************************************************************"


cp ~/spark/conf/spark-env.sh.template ~/spark/conf/spark-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~/spark/conf/spark-env.sh
echo "export SPARK_WORKER_CORES=8" >> ~/spark/conf/spark-env.sh

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

	tar zxf spark.tar.gz;
	rm spark.tar.gz;

	exit

	bash -l'	
		
        k=$((k+1))
done
echo "*********************************************************************************"


echo "Retour au master"

# Lancer spark
start-all.sh




install java

sudo apt install openjdk-8-jre-headless

nano /etc/environment

write:
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

save

Download spark and filezilla into home di of server
ssh and go to home, then (replacing with righ file names / version of spark):

mkdir spark
mv spark-2.4.2-bin-hadoop2.7.tgz spark

tar -zxvf spark-2.4.2-bin-hadoop2.7.tgz

Add the following entries to ~/.bashrc or ~/.bash_profile (make sure you run a source ~/.bashrc or logout and re-login to the remote machine.)

export SPARK_HOME=/home/ubuntu/spark/spark-2.4.2-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH

Generate a new key pair

ssh-keygen

filename: bigdata in 1 machine and bigdata2 on other machin
pw same: kolomino19


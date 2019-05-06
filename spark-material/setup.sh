#!/usr/bin/env bash

cp -r /home/tools/spark-2.4.0-bin-hadoop2.7 ~/
mv ~/spark-2.4.0-bin-hadoop2.7 ~/spark
echo "export SPARK_HOME=~/spark" >> ~/.bashrc
cd ~/spark/conf
echo "F4Linux1" >> slaves
echo "F4Linux2" >> slaves
cp spark-env.sh.template spark-env.sh
echo "export SPARK_LOCAL_IP=12.42.205.8" >> spark-env.sh
echo "export SPARK_MASTER_HOST=12.42.205.8" >> spark-env.sh
cd ~/


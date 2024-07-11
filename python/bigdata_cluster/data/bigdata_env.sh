#!/bin/bash
export BIGDATA_HOME=/opt/bigdata/installed
export JAVA_HOME=${BIGDATA_HOME}/jdk
export PATH=${JAVA_HOME}/bin:${PATH}

export DORIS_HOME=${BIGDATA_HOME}/doris
export PATH=${DORIS_HOME}/bin:${PATH}

export FLINK_HOME=${BIGDATA_HOME}/flink
export PATH=${FLINK_HOME}/bin:${PATH}

export HADOOP_HOME=${BIGDATA_HOME}/hadoop
export PATH=${HADOOP_HOME}/bin:${PATH}

export HBASE_HOME=${BIGDATA_HOME}/hbase
export PATH=${HBASE_HOME}/bin:${PATH}

export HIVE_HOME=${BIGDATA_HOME}/hive
export PATH=${HIVE_HOME}/bin:${PATH}

export KAFKA_HOME=${BIGDATA_HOME}/kafka
export PATH=${KAFKA_HOME}/bin:${PATH}

export SPARK_HOME=${BIGDATA_HOME}/spark
export PATH=${SPARK_HOME}/bin:${PATH}

export ZOOKEEPER_HOME=${BIGDATA_HOME}/zookeeper
export PATH=${ZOOKEEPER_HOME}/bin:${PATH}

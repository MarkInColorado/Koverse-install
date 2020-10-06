#!/bin/bash

KOVERSE_VERSION=2.3.27-af
STORAGE_DIR=/data/tmp
PACKAGES_DIR=/data/tmp/yum

main(){
  getRepos
  getSoftware
  getFiles
  getPythonEnvSoftware
}


# adding the repos we need to get software from
getRepos(){
  sudo yum -y install epel-release
  sudo curl -s http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari.repo -o /etc/yum.repos.d/ambari.repo
  sudo curl -s http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/hdp.repo -o /etc/yum.repos.d/hdp.repo
}

#downloading all of the RPMs with their dependancies to the attached disk to be approved
getSoftware(){
  mkdir -p ${PACKAGES_DIR}
  sudo yum -y install yum-utils
  yumdownloader --destdir=${PACKAGES_DIR} --resolve nginx
  yumdownloader --destdir=${PACKAGES_DIR} --resolve createrepo
  yumdownloader --destdir=${PACKAGES_DIR} --resolve wget
  yumdownloader --destdir=${PACKAGES_DIR} --resolve unzip
  yumdownloader --destdir=${PACKAGES_DIR} --resolve bzip2
  yumdownloader --destdir=${PACKAGES_DIR} --resolve cloud-init
  yumdownloader --destdir=${PACKAGES_DIR} --resolve java-1.8.0-openjdk-devel
  yumdownloader --destdir=${PACKAGES_DIR} --resolve screen
  yumdownloader --destdir=${PACKAGES_DIR} --resolve vim-enhanced
  yumdownloader --destdir=${PACKAGES_DIR} --resolve strace
  yumdownloader --destdir=${PACKAGES_DIR} --resolve lsof
  yumdownloader --destdir=${PACKAGES_DIR} --resolve yum-cron
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ssm-agent
  yumdownloader --destdir=${PACKAGES_DIR} --resolve tesseract
  yumdownloader --destdir=${PACKAGES_DIR} --resolve rpcbind
  yumdownloader --destdir=${PACKAGES_DIR} --resolve openssl-devel
  yumdownloader --destdir=${PACKAGES_DIR} --resolve redhat-rpm-config
  yumdownloader --destdir=${PACKAGES_DIR} --resolve augeas-libs
  yumdownloader --destdir=${PACKAGES_DIR} --resolve dialog
  yumdownloader --destdir=${PACKAGES_DIR} --resolve libffi-devel
  yumdownloader --destdir=${PACKAGES_DIR} --resolve gcc-c++
  yumdownloader --destdir=${PACKAGES_DIR} --resolve bind-utils
  yumdownloader --destdir=${PACKAGES_DIR} --resolve git
  yumdownloader --destdir=${PACKAGES_DIR} --resolve chrony
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-server
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-agent
  yumdownloader --destdir=${PACKAGES_DIR} --resolve zookeeper
  yumdownloader --destdir=${PACKAGES_DIR} --resolve zookeeper-server
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop-hdfs
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop-libhdfs
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop-yarn
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop-mapreduce
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hadoop-client
  yumdownloader --destdir=${PACKAGES_DIR} --resolve openssl
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive hive-jdbc
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-hcatalog
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-webhcat
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-webhcat-server
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-hcatalog-server
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-server2
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive-metastore
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hive_warehouse_connector
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark2
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark2-master
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark2-python
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark2-worker
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark2-yarn-shuffle
  yumdownloader --destdir=${PACKAGES_DIR} --resolve accumulo
  yumdownloader --destdir=${PACKAGES_DIR} --resolve hbase
  yumdownloader --destdir=${PACKAGES_DIR} --resolve livy2
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark_schema_registry
  yumdownloader --destdir=${PACKAGES_DIR} --resolve libtirpc
  yumdownloader --destdir=${PACKAGES_DIR} --resolve snappy-devel
  yumdownloader --destdir=${PACKAGES_DIR} --resolve python34-tkinter
  yumdownloader --destdir=${PACKAGES_DIR} --resolve python-virtualenv
  yumdownloader --destdir=${PACKAGES_DIR} --resolve python-tools
  yumdownloader --destdir=${PACKAGES_DIR} --resolve python34-pip
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark_schema_registry
  yumdownloader --destdir=${PACKAGES_DIR} --resolve mysql-connector-java
  yumdownloader --destdir=${PACKAGES_DIR} --resolve unzip hdp-select
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-metrics-collector
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-metrics-monitor
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-metrics-hadoop-sink
  yumdownloader --destdir=${PACKAGES_DIR} --resolve python-kerberos
  yumdownloader --destdir=${PACKAGES_DIR} --resolve ambari-metrics-grafana
  yumdownloader --destdir=${PACKAGES_DIR} --resolve mariadb-server
  yumdownloader --destdir=${PACKAGES_DIR} --resolve pig
  yumdownloader --destdir=${PACKAGES_DIR} --resolve datafu
  yumdownloader --destdir=${PACKAGES_DIR} --resolve tez
  yumdownloader --destdir=${PACKAGES_DIR} --resolve spark-atlas-connector
}

getFiles(){
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/hdp3-ami/topology_script_python3.py -o ${STORAGE_DIR}/topology_script_python3.py
  sudo curl -s http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/HDP-3.1.4.0-315.xml -o ${STORAGE_DIR}/HDP-3.1.4.0-315.xml

  #comment out the three lines below if you are doing a multi-node layout
  # sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-blueprint.json -o ${STORAGE_DIR}/blueprint.json
  # sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-single-node-bootstrap.py -o ${STORAGE_DIR}/bootstrap.py
  # sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-cluster.json -o ${STORAGE_DIR}/cluster.json

  # comment out the three lines below if we arer doing a single node install
  # uncomment if we are doing a multinode layout
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-multi-node-blueprint.json -o ${STORAGE_DIR}/blueprint.json
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-multi-node-bootstrap.py -o ${STORAGE_DIR}/bootstrap.py
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-multi-node-cluster.json -o ${STORAGE_DIR}/cluster.json

  sudo curl https://nexus.koverse.com/nexus/content/repositories/releases/com/koverse/koverse-server/${KOVERSE_VERSION}/koverse-server-${KOVERSE_VERSION}.rpm -o ${STORAGE_DIR}/koverse-server-${KOVERSE_VERSION}.rpm
  sudo curl https://nexus.koverse.com/nexus/content/repositories/releases/com/koverse/koverse-webapp/${KOVERSE_VERSION}/koverse-webapp-${KOVERSE_VERSION}.rpm -o ${STORAGE_DIR}/koverse-webapp-${KOVERSE_VERSION}.rpm

  sudo curl -s https://s3.amazonaws.com/koverse-bdaas/koverse.conf -o ${STORAGE_DIR}/koverse.conf
  sudo curl -s https://s3.amazonaws.com/koverse-bdaas/accumulo.conf -o ${STORAGE_DIR}/accumulo.conf

  sudo curl https://koverse-cloudera.s3-us-west-2.amazonaws.com/ambari/koverse-ambari-stack-3.0.tar.gz -o ${STORAGE_DIR}/KOVERSE.tar.gz
}

getPythonEnvSoftware(){
  sudo curl -s https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ${STORAGE_DIR}/miniconda3-latest-Linux-x86_64.sh
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/koverse-3.2.8.1-py2.py3-none-any.whl -o ${STORAGE_DIR}/koverse-3.2.8.1-py2.py3-none-any.whl
}
# silly comment to create a delta
main

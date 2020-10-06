#!/bin/bash

KOVERSE_VERSION=3.2.7
AMBARI_STACK_DIR=/var/lib/ambari-server/resources/stacks/HDP/3.1/services
STAGING_DIR=/var/local/staging
KOVERSE_HOME=/home/koverse
MINICONDA_DIR=${KOVERSE_HOME}/miniconda3

# The sleep 30 is important.  Packer is able to detect and SSH into the instance
# as soon as SSH is available, CENTOS doesn't get proper amounts of time to initialize.
# The sleep makes sure that the OS properly initializes.
sleep 30

main(){
  createLocalRepos
  stagingDir
  userKoverse
  enhanceHistory
  swapDisable
  systemUpdate
  javaHome
  ambariRepos
  dataStackInstall
  mysqlConnectorHive
  sparkShuffle
  topologyScript
  utilitiesKoverse
  installMiniconda
  condaPython
  getKoverse
  koverseInstall
  uLimitConfigs
  ambariForceTLS
  installKoverseStack
}

createLocalRepos(){
  sudo yum -y install epel-release
  sudo yum -y install nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo systemctl status nginx
  sudo firewall-cmd --zone=public --permanent --add-service=http
  sudo firewall-cmd --zone=public --permanent --add-service=https
  sudo firewall-cmd --reload
  sudo yum -y install createrepo  yum-utils
  sudo mkdir -p  /usr/share/nginx/html/Ambari-2.7.4.0/centos7/
  sudo mkdir -p   /usr/share/nginx/html/hdp/HDP/centos7/3.x/updates/3.1.4.0-315/
  sudo mkdir -p   /usr/share/nginx/html/hdp/HDP-UTILS-1.1.0.22/repos/centos7/

  sudo curl http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari-2.7.4.0-centos7.tar.gz -o /usr/share/nginx/html/Ambari-2.7.4.0/centos7/ambari-2.7.4.0-centos7.tar.gz
  sudo tar zxvf /usr/share/nginx/html/Ambari-2.7.4.0/centos7/ambari-2.7.4.0-centos7.tar.gz -C /usr/share/nginx/html/Ambari-2.7.4.0/centos7/

  sudo curl http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/HDP-3.1.4.0-centos7-rpm.tar.gz -o /usr/share/nginx/html/hdp/HDP/centos7/3.x/updates/3.1.4.0-315/HDP-3.1.4.0-centos7-rpm.tar.gz
  sudo tar zxvf /usr/share/nginx/html/hdp/HDP/centos7/3.x/updates/3.1.4.0-315/HDP-3.1.4.0-centos7-rpm.tar.gz -C /usr/share/nginx/html/hdp/HDP/centos7/3.x/updates/3.1.4.0-315/

  sudo curl http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz -o /usr/share/nginx/html/hdp/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz
  sudo tar zxvf /usr/share/nginx/html/hdp/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz -C /usr/share/nginx/html/hdp/HDP-UTILS-1.1.0.22/repos/centos7/

  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/local-repos.repo -o /etc/yum.repos.d/local-repos.repo
}

# create staging directory
stagingDir(){
  sudo mkdir -p -m777 ${STAGING_DIR}
}
#Koverse User
userKoverse(){
  sudo useradd koverse -c "koverse" -m -d ${KOVERSE_HOME}
}
# history enhancement
enhanceHistory(){
  echo -e "export HISTTIMEFORMAT='%F %T ' \nexport PROMPT_COMMAND='history -a' \nexport HISTCONTROL=ignoredups \nexport HISTIGNORE='ls:ps:history' \nexport HISTSIZE=10000 \nexport HISTFILESIZE=10000" | sudo tee -a /etc/profile.d/history.sh
}
# disable swap
swapDisable(){
if [[ ! `free -h | grep -q -i swap` ]]; then
  sudo swapoff -a
  echo "vm.swappiness=1" | sudo tee -i /etc/sysctl.conf
fi
}

# Install dependncies and updates
systemUpdate(){
  sudo yum -y install epel-release.noarch
  sudo yum -y install wget unzip bzip2 cloud-init java-1.8.0-openjdk-devel screen vim-enhanced strace lsof yum-cron ssm-agent tesseract rpcbind openssl-devel redhat-rpm-config augeas-libs dialog libffi-devel gcc-c++ bind-utils git chrony
}

javaHome(){
  echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre" | sudo tee -i /etc/profile.d/java.sh
}

ambariRepos(){
  if [[ -d "/etc/yum.repos.d" ]]; then
    sudo curl -s http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/HDP-3.1.4.0-315.xml -o ${STAGING_DIR}/HDP-3.1.4.0-315.xml
  fi
}

# Install ambari and all components found installing during blueprint load "yum history list; yum history info {number from list} | grep command"
dataStackInstall(){
  sudo yum -y install ambari-server ambari-agent zookeeper zookeeper-server hadoop hadoop-hdfs hadoop-libhdfs hadoop-yarn hadoop-mapreduce hadoop-client openssl hive hive-jdbc hive-hcatalog hive-webhcat hive-webhcat-server hive-hcatalog-server hive-server2 hive-metastore hive_warehouse_connector spark2 spark2-master spark2-python spark2-worker spark2-yarn-shuffle accumulo zeppelin hbase livy2 spark_schema_registry libtirpc snappy-devel python34-tkinter python-virtualenv python-tools python34-pip spark_schema_registry mysql-connector-java unzip hdp-select ambari-metrics-collector ambari-metrics-monitor ambari-metrics-hadoop-sink python-kerberos ambari-metrics-grafana mariadb-server pig datafu tez spark-atlas-connector
}

#Link mysql connector for Hive
mysqlConnectorHive(){
  sudo ln -s /usr/share/java/mysql-connector-java.jar /var/lib/ambari-server/resources/
}

sparkShuffle() {
  sudo cp /usr/hdp/3.1.4.0-315/spark2/aux/spark-2.3.2.3.1.4.0-315-yarn-shuffle.jar /usr/hdp/current/hadoop-yarn-nodemanager/lib/.
}

topologyScript() {
  sudo curl -s https://koverse-bdaas.s3.amazonaws.com/hdp3-ami/topology_script_python3.py -o /etc/hadoop/conf/topology_script_python3.py
  sudo chmod +x /etc/hadoop/conf/topology_script_python3.py
}

utilitiesKoverse(){
  if [[ -d "${STAGING_DIR}" ]]; then

    sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-blueprint.json -o $STAGING_DIR/blueprint.json
    sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-single-node-bootstrap.py -o $STAGING_DIR/bootstrap.py
    sudo curl -s https://koverse-bdaas.s3.amazonaws.com/ssdp-cluster.json -o $STAGING_DIR/cluster.json

    sudo curl -s https://koverse-bdaas.s3.amazonaws.com/hdp3-aws/password-reset.sh -o ${STAGING_DIR}/password-reset.sh
    sudo curl -s https://koverse-bdaas.s3.amazonaws.com/hdp3-aws/password-reset.sql -o ${STAGING_DIR}/password-reset.sql
    sudo curl -s https://nexus.koverse.com/nexus/content/groups/public/com/koverse/koverse-squirrel/${KOVERSE_VERSION}/koverse-squirrel-${KOVERSE_VERSION}.jar -o ${STAGING_DIR}/koverse-squirrel.jar
    sudo chmod +x ${STAGING_DIR}/*.json ${STAGING_DIR}/*.sh ${STAGING_DIR}/*.jar
  fi
}

installMiniconda(){
  sudo mkdir -p ${MINICONDA_DIR}
  sudo -u koverse bash -c "curl -s https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ${STAGING_DIR}/miniconda3-latest-Linux-x86_64.sh"
  sudo chmod +x ${STAGING_DIR}/miniconda3-latest-Linux-x86_64.sh
  sudo bash ${STAGING_DIR}/miniconda3-latest-Linux-x86_64.sh -bu -p ${MINICONDA_DIR}
  sudo chown -R koverse:koverse ${MINICONDA_DIR}
  sudo echo -e "export PATH=\$PATH:${MINICONDA_DIR}/bin" | sudo tee -i /etc/profile.d/miniconda3.sh
}

condaPython(){
  sudo mkdir -p /opt/koverse-pyspark-env
  sudo chown -R koverse:koverse /opt/koverse-pyspark-env
  #yaml file to update environment with all python libraries used
  sudo -u koverse bash -c "unset SUDO_GID  SUDO_USER SUDO_UID; ${MINICONDA_DIR}/bin/conda create -y --prefix /opt/koverse-pyspark-env python=3.7"
  sudo -u koverse bash -c "unset SUDO_GID  SUDO_USER SUDO_UID; ${MINICONDA_DIR}/bin/conda install -y --prefix /opt/koverse-pyspark-env numpy pandas scikit-learn matplotlib"
  sudo -u koverse bash -c "unset SUDO_GID  SUDO_USER SUDO_UID; /opt/koverse-pyspark-env/bin/pip install koverse"
}

getKoverse(){
  sudo curl https://nexus.koverse.com/nexus/content/repositories/releases/com/koverse/koverse-server/${KOVERSE_VERSION}/koverse-server-${KOVERSE_VERSION}.rpm -o ${STAGING_DIR}/koverse-server-${KOVERSE_VERSION}.rpm
  sudo curl https://nexus.koverse.com/nexus/content/repositories/releases/com/koverse/koverse-webapp/${KOVERSE_VERSION}/koverse-webapp-${KOVERSE_VERSION}.rpm -o ${STAGING_DIR}/koverse-webapp-${KOVERSE_VERSION}.rpm
}

koverseInstall(){
  sudo yum install -y ${STAGING_DIR}/koverse-server-$KOVERSE_VERSION.rpm
  sudo yum install -y ${STAGING_DIR}/koverse-webapp-$KOVERSE_VERSION.rpm
  sudo rm -f ${STAGING_DIR}/*.rpm
}

uLimitConfigs(){
  sudo curl -s https://s3.amazonaws.com/koverse-bdaas/koverse.conf -o /etc/security/limits.d/koverse.conf
  sudo curl -s https://s3.amazonaws.com/koverse-bdaas/accumulo.conf -o /etc/security/limits.d/accumulo.conf
}

ambariForceTLS(){
  sudo perl -pi -e "s/\[security\]/\[security\]\nforce_https_protocol=PROTOCOL_TLSv1_2/g" /etc/ambari-agent/conf/ambari-agent.ini
  sudo perl -pi -e "s/platform_default/disable/g" /etc/python/cert-verification.cfg
}

installKoverseStack() {
  sudo mkdir $AMBARI_STACK_DIR/KOVERSE
  sudo curl https://koverse-cloudera.s3-us-west-2.amazonaws.com/ambari/koverse-ambari-stack-3.0.tar.gz -o $AMBARI_STACK_DIR/KOVERSE/KOVERSE.tar.gz
  sudo tar zxvf $AMBARI_STACK_DIR/KOVERSE/KOVERSE.tar.gz -C $AMBARI_STACK_DIR/KOVERSE
  sudo rm -f $AMBARI_STACK_DIR/KOVERSE/KOVERSE.tar.gz
}

main

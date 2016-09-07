#!/bin/bash
#
# 
# Shell  : aaSetup.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.2 for CentOS 7.2
#
#
# Please run this sript as superuser or its permission as sudo bash asSetup.bash
#


# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"




# Somehow, hostname is conflicted between what I set, and what IT assigned.
declare -r  hostname_cmd="$(hostname --all-fqdn)"
declare -gr AA_HOSTNAME="$(tr -d ' ' <<< $hostname_cmd )"
declare -gr AA_USERNAME="$(whoami)"

declare -gr TARGET_TOP=/opt
declare -gr ARCHAPPL_TOP=${TARGET_TOP}/archappl
declare -gr TEMPLATE_DIR=${SC_TOP}/template
declare -gr DEPLOY_DIR=${ARCHAPPL_TOP}-${SC_LOGDATE}
declare -gr TARGET_DIR=${ARCHAPPL_TOP}


#
# This approach is only valid for the single appliance installation.
# If one wants to install multiple appliances, appliances.xml should
# has the different structures. 
#
declare -gr AA_MYIDENTITY="appliance0"

export ARCHAPPL_APPLIANCES=${DEPLOY_DIR}/appliances.xml
export ARCHAPPL_MYIDENTITY=${AA_MYIDENTITY}

# JAVA Environment is defined by the System.
# If not, please set them properly.

# export JAVA_HOME=/usr/java/latest
# export PATH=${JAVA_HOME}/bin:${PATH}

# Set Tomcat home
export TOMCAT_HOME=/usr/share/tomcat



# 0) It is safe to create archappl directory according to date, time, 
#    then, create symlink to point to the real directory
#    So, TARGET_DIR is the symlink.


printf "\n%s\n" "->"

pushd ${TARGET_TOP}

if [[ -L ${TARGET_DIR} && -d ${TARGET_DIR} ]]
then
    echo "${TARGET_DIR} is a symlink to a directory, so removing it."
    rm ${TARGET_DIR}
fi

if [[ -d ${TARGET_DIR} ]]
then
    echo "${TARGET_DIR} is the physical directory, it should NOT be."
    echo "Please check it, the old ${TARGET_DIR} is renamed to ${TARGET_DIR}-PLEASECHECK-${SC_LOGDATE}"
    mv ${TARGET_DIR} ${TARGET_DIR}-PLEASECHECK-${SC_LOGDATE}
fi

mkdir -p ${DEPLOY_DIR}
ln -s ${DEPLOY_DIR} ${TARGET_DIR}

popd


printf "\n%s\n" "-->"
pushd ${SC_TOP}

printf "Put log4j.properties in ${TOMCAT_HOME}/lib\n"
# 1) Put log4j.properties in ${TOMCAT_HOME}/lib

cat > ${TOMCAT_HOME}/lib/log4j.properties <<EOF
# 
#  Generated at  ${SC_LOGDATE}     
#            on  ${AA_HOSTNAME}  
#            by  ${AA_USERNAME}
#                ${SC_TOP}/${SC_SCRIPTNAME}
#  Jeong Han Lee, han.lee@esss.se
# 
#  This file should be in ${TOMCAT_HOME}/lib/ 
#

# Set root logger level and its only appender to A1.
log4j.rootLogger=ERROR, A1
log4j.logger.config.org.epics.archiverappliance=INFO
log4j.logger.org.apache.http=ERROR


# A1 is set to be a DailyRollingFileAppender
log4j.appender.A1=org.apache.log4j.DailyRollingFileAppender
log4j.appender.A1.File=arch.log
log4j.appender.A1.DatePattern='.'yyyy-MM-dd


# A1 uses PatternLayout.
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n
EOF

popd

printf "\n%s\n" "--->"

pushd ${SC_TOP}
printf  "Put appliances.xml in ${DEPLOY_DIR}\n"
# 2) Put appliances.xml in ${DEPLOY_DIR}


cat > ${ARCHAPPL_APPLIANCES} <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!--
  Took the contents from single\_machine\_install.sh, and modified 
  them according to our configuration. 
 
  Generated at  ${SC_LOGDATE}     
            on  ${AA_HOSTNAME}  
            by  ${AA_USERNAME}
                ${SC_TOP}/${SC_SCRIPTNAME}

  Jeong Han Lee, han.lee@esss.se
-->
<appliances>
   <appliance>
     <identity>${AA_MYIDENTITY}</identity>
     <cluster_inetport>${AA_HOSTNAME}:16670</cluster_inetport>
     <mgmt_url>http://${AA_HOSTNAME}:17665/mgmt/bpl</mgmt_url>
     <engine_url>http://${AA_HOSTNAME}:17666/engine/bpl</engine_url>
     <etl_url>http://${AA_HOSTNAME}:17667/etl/bpl</etl_url>
     <retrieval_url>http://${AA_HOSTNAME}:17668/retrieval/bpl</retrieval_url>
     <data_retrieval_url>http://${AA_HOSTNAME}:17668/retrieval</data_retrieval_url>
   </appliance>
</appliances>
EOF

popd


printf "\n%s\n" "---->"

## TODO
#  Think how we use the archappl generic scripts and its MySQL db file
#  , which I put them in aa_scripts/ directory 
#  The following approach is only vaild for "git"
#  I should develop a way if one wants to use "the binary file from the site"
#  Wednesday, September  7 13:28:03 CEST 2016, jhlee


declare -gr SC_GIT_SRC_NAME="epicsarchiverap"
declare -gr SC_GIT_SRC_DIR=${SC_TOP}/${SC_GIT_SRC_NAME}
declare -gr AA_DEPLOY_PYTHON=${SC_GIT_SRC_DIR}/docs/samples/deployMultipleTomcats.py

printf " Deploy multiple tomcats into ${DEPLOY_DIR}\n"
# 3) Deploy multiple tomcats into ${DEPLOY_DIR} via the original source
#
echo "Calling ${AA_DEPLOY_PYTHON} ${DEPLOY_DIR}"
python ${AA_DEPLOY_PYTHON} ${DEPLOY_DIR}


printf "\n%s\n" "----->"
printf  "Put context.xml in to ${DEPLOY_DIR}/mgmt/conf/\n"

# 4) Put context.xml in to ${DEPLOY_DIR}/mgmt/conf/
#    in order that mgmt tomcat service can connect to
#    mariadb (CentOS) or mysql (others). 
#    Only the mgmt web app needs to talk to the MySQL database. 
#    It is an error/bug if the other components need to talk to MySQL;

TOMCAT_CONTEXTCONTAINER=${DEPLOY_DIR}/mgmt/conf/context.xml

declare -gr AA_MYSQL_DB="archappl"
declare -gr AA_MYSQL_USERNAME="archappl"
declare -gr AA_MYSQL_PASSWORD="archappl"

# with MySQL, use mysql-connector/j
#
#AA_DRIVER_CLASSNAME="com.mysql.jdbc.Driver"
#AA_URL="mysql"

# with MariaDB, use mariadb-connector/j
# mariadb-java-client-1.4.6.jar
# This file should be in ${TOMCAT_HOME}/lib
#
declare -gr AA_DRIVER_CLASSNAME="org.mariadb.jdbc.Driver"
declare -gr AA_URL="mariadb"


cat > ${TOMCAT_CONTEXTCONTAINER} <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<!-- The contents of this file will be loaded for each web application -->
<!--
  Took the default contex.xml from /usr/share/tomcat/conf (CentOS 7.2), 
  and add Resource according to addMysqlConnPool.py
 
 
  Generated at  ${SC_LOGDATE}     
            on  ${AA_HOSTNAME}  
            by  ${AA_USERNAME}
                ${SC_TOP}/${SC_SCRIPTNAME}

  Jeong Han Lee, han.lee@esss.se
-->
<Context>

    <!-- Default set of monitored resources -->
    <WatchedResource>WEB-INF/web.xml</WatchedResource>

    <!-- Uncomment this to disable session persistence across Tomcat restarts -->
    <!--
    <Manager pathname="" />
    -->

    <!-- Uncomment this to enable Comet connection tacking (provides events
         on session expiration as well as webapp lifecycle) -->
    <!--
    <Valve className="org.apache.catalina.valves.CometConnectionManagerValve" />
    -->
    <Resource name="jdbc/archappl"
         auth="Container"
         type="javax.sql.DataSource"
         factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
         testWhileIdle="true"
         testOnBorrow="true"
         testOnReturn="false"
         validationQuery="SELECT 1"
         validationInterval="30000"
         timeBetweenEvictionRunsMillis="30000"
         maxActive="10"
         minIdle="2"
         maxWait="10000"
         initialSize="2"
         removeAbandonedTimeout="60"
         removeAbandoned="true"
         logAbandoned="true"
         minEvictableIdleTimeMillis="30000"
         jmxEnabled="true"
         driverClassName="${AA_DRIVER_CLASSNAME}"
         url="jdbc:${AA_URL}://localhost:3306/${AA_MYSQL_DB}"
         username="${AA_MYSQL_USERNAME}"
         password="${AA_MYSQL_PASSWORD}"
     />
</Context>
EOF

printf "%s\n" "------|"

#!/bin/bash

# # The function is defined in the following article
# # http://pempek.net/articles/2013/07/08/bash-sh-as-template-engine/

# render_template() 
# {
#     eval "echo \"$(cat $1)\""
# }


# if [[ -z ${JAVA_HOME} ]]
# then
#     echo "Please set JAVA_HOME to point to a 1.8 JDK"
#     exit 1
# fi

# export PATH=${JAVA_HOME}/bin:${PATH}

# if [[ -z ${TOMCAT_HOME} ]]
# then
#     echo "Please set TOMCAT_HOME to point to a proper PATH"
#     exit 1
# fi
# #
# CENTOS, TOMCAT_HOME is /usr/share/tomcat
export TOMCAT_HOME=/usr/share/tomcat
# TOMCAT_HOME=/usr/share/tomcat
# export TOMCAT_HOME
#
# Variable with Prefix AA_ are used in heredoc cat >...
# and were used in appliances.template and context.template
#
AA_SCRIPTNAME=`basename $0`
AA_LOGDATE=`date +%Y.%m.%d.%H:%M`

SCRIPTS_DIR=`dirname $0`
AA_SCRIPTS_PATH=`cd ${SCRIPTS_DIR} && pwd`
AA_HOSTNAME=`hostname -f`
AA_USERNAME=`whoami`

 
TEMPLATE_DIR=${AA_SCRIPTS_PATH}/template
DEPLOY_DIR=/opt/archappl

mkdir -p ${DEPLOY_DIR}

##
# The following two PATHs for only testing purpose, 
# they override PATHS in order to create appliances.xml and context.xml
# in the SCRIPTS_DIR. So they should comment out after testing.  
# 
# DEPLOY_DIR=${SCRIPTS_DIR}
# TOMCAT_HOME=${SCRIPTS_DIR}
# mkdir -p ${TOMCAT_HOME}/lib/
# mkdir -p ${DEPLOY_DIR}/mgmt/conf/
# one should remove them later.
#

#cp ${TEMPLATE_DIR}/log4j.properties ${TOMCAT_HOME}/lib/

cat > ${TOMCAT_HOME}/lib/log4j.properties <<EOF
# 
#  Generated at  ${AA_LOGDATE}     
#            on  ${AA_HOSTNAME}  
#            by  ${AA_USERNAME}
#                ${AA_SCRIPTS_PATH}/${AA_SCRIPTNAME}
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


#
# This approach is only valid for the single appliance installation.
# If one wants to install multiple appliances, appliances.xml should
# has the different structures. 
#
AA_MYIDENTITY="appliance0"

export ARCHAPPL_APPLIANCES=${DEPLOY_DIR}/appliances.xml
export ARCHAPPL_MYIDENTITY=${AA_MYIDENTITY}

#render_template ${TEMPLATE_DIR}/appliances.template > ${ARCHAPPL_APPLIANCES}

cat > ${ARCHAPPL_APPLIANCES} <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!--
  Took the contents from single\_machine\_install.sh, and modified 
  them according to our configuration. 
 
  Generated at  ${AA_LOGDATE}     
            on  ${AA_HOSTNAME}  
            by  ${AA_USERNAME}
                ${AA_SCRIPTS_PATH}/${AA_SCRIPTNAME}

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

echo "Calling ${SCRIPTS_DIR}/aa_scripts/deployMultipleTomcats.py ${DEPLOY_DIR}"
${SCRIPTS_DIR}/aa_scripts/deployMultipleTomcats.py ${DEPLOY_DIR}

TOMCAT_CONTEXTCONTAINER=${DEPLOY_DIR}/mgmt/conf/context.xml

# Do we need to deploy the same context.xml file into
# {mgmt,etl,retrieval,engine}/conf/?
# In single_machine_install.sh, this was done only in {mgmt} directory with  addMysqlConnPool.py,
# But in FRIB puppet/minifest/init.pp, four directories should have the same one. 
# need to contact ...
# 2016-08-30, Jeong Han Lee
# 
# Only the mgmt web app needs to talk to the MySQL database. 
# It is an error/bug if the other components need to talk to MySQL;
# 2016-08-31, Jeong Han Lee

AA_MYSQL_DB="archappl"
AA_MYSQL_USERNAME="archappl"
AA_MYSQL_PASSWORD="archappl"


#render_template ${TEMPLATE_DIR}/contex.template > ${TOMCAT_CONTEXTCONTAINER}

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
 
 
  Generated at  ${AA_LOGDATE}     
            on  ${AA_HOSTNAME}  
            by  ${AA_USERNAME}
                ${AA_SCRIPTS_PATH}/${AA_SCRIPTNAME}

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
         driverClassName="com.mysql.jdbc.Driver"
         url="jdbc:mysql://localhost:3306/${AA_MYSQL_DB}"
         username="${AA_MYSQL_USERNAME}"
         password="${AA_MYSQL_PASSWORD}"
     />
</Context>
EOF

#!/bin/bash
#
#  Copyright (c) 2016 Jeong Han Lee
#  Copyright (c) 2016 European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
# 
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.5
#
#
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }





declare -gr SUDO_CMD="sudo";
declare -g SUDO_PID="";

${SUDO_CMD} -v

. ${SC_TOP}/setEnvAA.bash

printf "\n%s\n" "->"

pushd ${AA_TARGET_TOP}

if [[ -L ${ARCHAPPL_TOP} && -d ${ARCHAPPL_TOP} ]]
then
    printf "%s is a symlink to a directory, so removing it.\n" "${ARCHAPPL_TOP}";
    ${SUDO_CMD} rm ${ARCHAPPL_TOP}
fi

if [[ -d ${ARCHAPPL_TOP} ]]
then
    printf "$s is the physical directory, it should NOT be." "${ARCHAPPL_TOP}";
    printf "Please check it, and the old %s is renamed to %s\n" "${ARCHAPPL_TOP}" "${ARCHAPPL_TOP}-PLEASECHECK-${SC_LOGDATE}"
    ${SUDO_CMD} mv ${ARCHAPPL_TOP} ${ARCHAPPL_TOP}-PLEASECHECK-${SC_LOGDATE}
fi


declare -r SC_DEPLOY_DIR=${ARCHAPPL_TOP}-${SC_LOGDATE};

${SUDO_CMD} mkdir -p ${SC_DEPLOY_DIR}
${SUDO_CMD} ln -s ${SC_DEPLOY_DIR} ${ARCHAPPL_TOP}

popd


printf "\n%s\n" "--->"
pushd ${SC_TOP}

printf "Put log4j.properties in ${TOMCAT_LIB}\n"
# 1) Put log4j.properties in ${TOMCAT_LIB}
declare LOG4J="log4j.properties";

cat > ${LOG4J} <<EOF
# 
#  Generated at  ${SC_LOGDATE}     
#            on  ${_HOST_NAME}  
#                ${_HOST_IP}
#            by  ${_USER_NAME}
#                ${SC_TOP}/${SC_SCRIPTNAME}
#
#  Jeong Han Lee, han.lee@esss.se
# 
#  This file should be in ${TOMCAT_LIB}/ 
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

# Permission and ownership should be considered later
${SUDO_CMD} mv ${LOG4J} ${TOMCAT_LIB}/ ;
popd



# 2) Put appliances.xml in  "${ARCHAPPL_TOP}"
printf "\n%s\n" "----->"
pushd ${SC_TOP}
printf  "Put %s in %s\n" "${APPLIANCES_XML}" "${ARCHAPPL_TOP}";

cat > ${APPLIANCES_XML} <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!--
  Took the contents from single\_machine\_install.sh, and modified 
  them according to our configuration. 
 
  Generated at  ${SC_LOGDATE}     
            on  ${_HOST_NAME}  
                ${_HOST_IP}
            by  ${_USER_NAME}
                ${SC_TOP}/${SC_SCRIPTNAME}

  Jeong Han Lee, han.lee@esss.se

-->
<appliances>
   <appliance>
     <identity>${AACHAPPL_SINGLE_IDENTITY}</identity>
     <cluster_inetport>${_HOST_IP}:16670</cluster_inetport>
     <mgmt_url>http://${_HOST_IP}:17665/mgmt/bpl</mgmt_url>
     <engine_url>http://${_HOST_IP}:17666/engine/bpl</engine_url>
     <etl_url>http://${_HOST_IP}:17667/etl/bpl</etl_url>
     <retrieval_url>http://${_HOST_IP}:17668/retrieval/bpl</retrieval_url>
     <data_retrieval_url>http://${_HOST_IP}:17668/retrieval</data_retrieval_url>
   </appliance>
</appliances>
EOF

# Permission and ownership should be considered later
${SUDO_CMD} mv ${APPLIANCES_XML} ${ARCHAPPL_TOP}/ ;

popd


# 3) Deploy multiple tomcats into ${DEPLOY_DIR} via the original source
#
printf "\n%s\n" "------->"

if [[ ! -d ${AA_GIT_DIR} ]]; then
    printf "No git source repository in the expected location %s\n" "${AA_GIT_DIR}";
    exit;
fi

declare -r aa_deployMultipleTomcats_py=${AA_GIT_DIR}/docs/samples/deployMultipleTomcats.py
printf " Deploy multiple tomcats into %s\n" "${ARCHAPPL_TOP}";
printf "Calling %s %s\n" "${aa_deployMultipleTomcats_py}" "${ARCHAPPL_TOP}";
${SUDO_CMD} -E python  "${aa_deployMultipleTomcats_py}" "${ARCHAPPL_TOP}"



# 4) Put context.xml in to ${ARCHAPPL_TOP}/mgmt/conf/
#    in order that mgmt tomcat service can connect to
#    mariadb (CentOS) or mysql (others). 
#    Only the mgmt web app needs to talk to the MySQL database. 
#    It is an error/bug if the other components need to talk to MySQL;

printf "\n%s\n" "--------->"
printf  "Put context.xml in to %s/mgmt/conf/\n" "${ARCHAPPL_TOP}";

pushd ${SC_TOP};

tomcat_context_container=context.xml

cat > ${tomcat_context_container} <<EOF
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
            on  ${_HOST_NAME}
                ${_HOST_IP}  
            by  ${_USER_NAME}
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
         driverClassName="${DB_CLASSNAME}"
         url="jdbc:${DB_AA_URL}://localhost:3306/${DB_NAME}"
         username="${DB_USER_NAME}"
         password="${DB_USER_PWD}"
     />
</Context>
EOF

# Permission and ownership should be considered later
${SUDO_CMD} mv ${tomcat_context_container} ${ARCHAPPL_TOP}/mgmt/conf/ ; 
popd



printf "%s\n" "------|"


# 5) Set the DB tables into DB ${DB_NAME}
#+---------------------+
#| Tables_in_archappl  |
#+---------------------+
#| ArchivePVRequests   |
#| ExternalDataServers |
#| PVAliases           |
#| PVTypeInfo          |
#+---------------------+

declare -r aa_deploy_db_tables=${AA_GIT_DIR}/src/main/org/epics/archiverappliance/config/persistence/archappl_mysql.sql
declare -r aa_deploy_db_tables_new=${aa_deploy_db_tables}_new.sql

# In the case, to run this script again, keep the original file, and create new file with "IF NOT EXITS", 
# and use the new file to query to DB.
# Thus, if the tables exist in DB, it will skip to create these tables
#
sed "s/CREATE TABLE /CREATE TABLE IF NOT EXISTS /g" ${aa_deploy_db_tables} > ${aa_deploy_db_tables_new};
mysql --user=${DB_USER_NAME} --password=${DB_USER_PWD} --database=${DB_NAME} < ${aa_deploy_db_tables_new};



exit
